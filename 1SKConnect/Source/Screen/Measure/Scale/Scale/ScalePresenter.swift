//
//  
//  ScalePresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit
import CoreBluetooth

class ScalePresenter: NSObject {

    private var numberOfItem = 0
    private var currentPage = 1
    private let limit = 100000
    private var isFetchingItems = false
    private var totalItem = 0
    var isShowBLEConnection: Bool = true
    var scale: DeviceModel!
    private var bodyFats: [BodyFat] = []
    private var filteredBodyFats: [BodyFat] = []
    private var currentType: TimeFilterType = .day
    private var connectDevices: [DeviceModel] = []
    weak var view: ScaleViewProtocol?
    private var interactor: ScaleInteractorInputProtocol
    private var router: ScaleRouterProtocol
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let bodyFatListDAO = GenericDAO<BodyFatList>()
    var filterTimesScaleValue = TimeScaleModel(fromeDate: nil, toDate: Date())

    init(interactor: ScaleInteractorInputProtocol,
         router: ScaleRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    deinit {
        BluetoothManager.shared.stopScan()
    }

    // MARK: - Action
    private func observerBLEState() {
        kNotificationCenter.addObserver(self, selector: #selector(onDeviceConnectionChanged(_:)), name: .deviceConnectionChanged, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(onCanNotConnectToDevice(_:)), name: .canNotConnectToDevice, object: nil)
    }

    @objc func onDeviceConnectionChanged(_ sender: Notification) {
        guard let mac = sender.userInfo?[SKKey.mac] as? String,
              scale?.mac == mac else {
            return
        }
        let isConnect = BluetoothManager.shared.isConnect(with: scale)
        if isConnect {
            view?.setIndicatorHidden(true)
        }
        view?.updateConnectState(isConnect)
    }

    @objc func onCanNotConnectToDevice(_ sender: Notification) {
        guard let mac = sender.userInfo?[SKKey.mac] as? String, scale?.mac == mac else {
            return
        }
        router.showToast(content: L.canNotConnectToDevice.localized)
        view?.setIndicatorHidden(true)
    }

    private func getGraphData(of type: TimeFilterType) -> [[[BodyFat]]] {
        var joinedArray: [[[BodyFat]]] = []
        switch type {
        case .day:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { bodyFat, bodyFats in
                return bodyFat.timestamp.toDate().isSameHour(with: bodyFats.last!.timestamp.toDate())
            }, isSameLargeGroup: { bodyFats, listBodyFats in
                return bodyFats.last!.timestamp.toDate().isSameDay(with: listBodyFats.last!.last!.timestamp.toDate())
            })
        case .week:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { bodyFat, bodyFats in
                return bodyFat.timestamp.toDate().isSameDay(with: bodyFats.last!.timestamp.toDate())
            }, isSameLargeGroup: { bodyFats, listBodyFats in
                return bodyFats.last!.timestamp.toDate().isInSameWeek(as: listBodyFats.last!.last!.timestamp.toDate())
            })
        case .month:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { bodyFat, bodyFats in
                return bodyFat.timestamp.toDate().isSameDay(with: bodyFats.last!.timestamp.toDate())
            }, isSameLargeGroup: { bodyFats, listBodyFats in
                return bodyFats.last!.timestamp.toDate().isSameMonth(with: listBodyFats.last!.last!.timestamp.toDate())
            })
        case .year:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { bodyFat, bodyFats in
                return bodyFat.timestamp.toDate().isSameMonth(with: bodyFats.last!.timestamp.toDate())
            }, isSameLargeGroup: { bodyFats, listBodyFats in
                return bodyFats.last!.timestamp.toDate().isInSameYear(as: listBodyFats.last!.last!.timestamp.toDate())
            })
        }
        return joinedArray
    }

    private func processDataForGraphView(isSameSmallGroup: (BodyFat, [BodyFat]) -> Bool, isSameLargeGroup: ([BodyFat], [[BodyFat]]) -> Bool) -> [[[BodyFat]]] {
        var joinedArray: [[[BodyFat]]] = []
        var largeTemp: [[BodyFat]] = []
        var smallTemp: [BodyFat] = []
        for bodyFat in bodyFats.reversed() {
            if !smallTemp.isEmpty {
                if isSameSmallGroup(bodyFat, smallTemp) {
                    smallTemp.append(bodyFat)
                } else {
                    largeTemp.append(smallTemp)
                    smallTemp = [bodyFat]
                }
            } else { // temp empty
                smallTemp.append(bodyFat)
            }
        }
        if !smallTemp.isEmpty {
            largeTemp.append(smallTemp)
        }

        var temp: [[BodyFat]] = []
        for listBodyFat in largeTemp {
            if !temp.isEmpty {
                if isSameLargeGroup(listBodyFat, temp) {
                    temp.append(listBodyFat)
                } else {
                    joinedArray.append(temp)
                    temp = [listBodyFat]
                }
            } else { // temp empty
                temp.append(listBodyFat)
            }
        }

        if !temp.isEmpty {
            joinedArray.append(temp)
        }

        return joinedArray
    }

    private func checkBLEAvailble() -> Bool {
        let isBLEAvailable = BluetoothManager.shared.checkBluetoothStatusAvailble()
        if !isBLEAvailable {
            switch BluetoothManager.shared.centralManager.state {
            case .poweredOff:
                self.isShowBLEConnection = true
                router.showTurnOnBleAlert()
            case .unauthorized:
                self.isShowBLEConnection = true
                router.showTurnOnBleAlert()
            default:
                break
            }
        }
        return isBLEAvailable
    }

    private func loadItem(in page: Int) {
        isFetchingItems = true
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let linkAccount = profile.linkAccount {
            if profile.needDowloadData {
                self.interactor.syncListData(with: linkAccount.uuid, accessToken: linkAccount.accessToken ?? "", page: page, limit: self.limit)
            }
        }
    }

    private func needFetchData(indexPath: IndexPath) -> Bool {
        return indexPath.row < totalItem
    }
}

// MARK: - ScalePresenterProtocol
extension ScalePresenter: ScalePresenterProtocol {
    var filterTimesScale: TimeScaleModel {
        get {
            return self.filterTimesScaleValue
        }
        set {
            if !self.filteredBodyFats.isEmpty {
                self.filteredBodyFats.removeAll()
            }
            self.filterTimesScaleValue = newValue
            if let fromeDate = self.filterTimesScaleValue.fromeDate {
                self.filteredBodyFats = self.bodyFats.filter { return $0.timestamp <= self.filterTimesScaleValue.toDate.endOfDay.timeIntervalSince1970 && $0.timestamp >= fromeDate.startOfDay.timeIntervalSince1970 }
            } else {
                self.filteredBodyFats = self.bodyFats.filter { return $0.timestamp <= self.filterTimesScaleValue.toDate.endOfDay.timeIntervalSince1970 && $0.timestamp >= self.filterTimesScaleValue.toDate.startOfDay.timeIntervalSince1970 }
            }
            view?.reloadData()
        }
    }

    var safeAreaBottom: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            return window.safeAreaInsets.bottom
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.bottom ?? 0
        }
    }

    func onButtonSyncDidTapped() {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if currentProfile.linkAccount == nil {
            self.isShowBLEConnection = false
            self.router.showLinkAccountAlert()
            return
        }
        guard let view = self.view as? ScaleViewController else {
            return
        }
        view.showHud()
        self.interactor.handleSync()
    }

    func onButtonSettingLinkTapped() {
        router.openLinkSetting()
    }

    func onPrefetchItem(at indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            if needFetchData(indexPath: indexPath) && !isFetchingItems {
                // Fetch more data
//                loadItem(in: currentPage + 1)
            }
        }
    }

    func onViewDidLoad() {
        observerBLEState()
//        self.loadItem(in: 1)
        let isConnect = BluetoothManager.shared.isConnect(with: scale)
        view?.updateConnectState(isConnect)
        view?.setScaleImage(image: scale.image)
        interactor.startObserver()
    }

    func onViewDidDisappear() {
    }

    func numberOfRow(in section: Int) -> Int {
        return filteredBodyFats.count
    }

    func itemForRow(at index: IndexPath) -> BodyFat? {
        return filteredBodyFats[index.row]
    }

    func onItemDidSelected(at index: IndexPath) {
        let bodyFat = filteredBodyFats[index.row]
        router.showResultViewController(bodyFat: bodyFat)
    }

    func onDeleteItem(at index: IndexPath) {
        let bodyfat = bodyFats[index.row]
        interactor.deleteBodyFat(bodyfat)
    }

    func onButtonConnectDidTapped() {
        let isConnect = BluetoothManager.shared.isConnect(with: scale)
        if isConnect {
            BluetoothManager.shared.disConnectDevice(scale)
        } else {
            if !checkBLEAvailble() {
                return
            }
            BluetoothManager.shared.connectToDevice(scale)
            view?.setIndicatorHidden(false)
        }
    }

    func onButtonMeasureDidTapped() {
        if !checkBLEAvailble() {
            return
        }
        let isConnectedDevice = connectDevices.contains(where: { $0.mac == scale.mac })
        if isConnectedDevice {
            router.gotoWeightMeasuringViewController(scale)
        } else {
            router.gotoDeviceViewController()
        }
    }

    func onButtonSettingBLEDidTapped() {
        router.openAppSetting()
    }

    func onButtonCloseDidTapped() {
        router.dismiss()
    }

    func onFilterViewDidSelected(_ filterViewType: TimeFilterType) {
        currentType = filterViewType
        self.view?.updateGraphView(times: [], type: filterViewType)
        self.view?.updateGraphView(with: self.getGraphData(of: self.currentType), timeType: self.currentType, deviceType: self.scale.type)
    }

    private func handleLoadmoreItems(_ items: [SmartScale]?) {
        guard let smartScale = items else { return }
        var bodyFats = [BodyFat]()
        for data in smartScale {
            var bodyFat: BodyFat?
            if data.impedance == 0 {
                bodyFat = BodyFat(data)
            } else {
                bodyFat = self.caculateBodyFatData(from: CGFloat(data.weight ?? 0), impedance: data.impedance!, syncId: data.id ?? "", createdAt: data.createdAt ?? "")
            }
            if let bodyFat = bodyFat {
                if bodyFat.scale?.mac == self.scale.mac {
                    bodyFats.append(bodyFat)
                }
            }
        }

        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }

        if let bodyFatList = bodyFatListDAO.getObject(with: currentProfile.id) {
            bodyFatListDAO.update {
                for data1 in bodyFats {
                    var exist = false
                    for data2 in bodyFatList.bodyfats.array where data1.syncId == data2.syncId {
                        exist = true
                        break
                    }
                    if !exist {
                        var isDeleted = false
                        for data in currentProfile.deleteSyncId.array  where data == data1.syncId {
                            isDeleted = true
                            break
                        }
                        if !isDeleted {
                            bodyFatList.bodyfats.append(data1)
                        }
                    }
                }
            }
        } else {
            for (i, data) in bodyFats.enumerated() where self.scale.mac != data.scale?.mac {
                bodyFats.remove(at: i)
            }
            let bodyFatList = BodyFatList(profile: currentProfile, device: self.scale, bodyFats: bodyFats)
            bodyFatListDAO.add(bodyFatList)
        }

        let visibleIndexPaths = view?.getVisibleIndexPath()
        let startIndex = (currentPage - 1) * limit
        let endIndex = min(startIndex + limit, totalItem)

        // Continue fetch if needed
        if visibleIndexPaths?.contains(where: { $0.row >= endIndex }) ?? false && !isFetchingItems {
//            loadItem(in: currentPage + 1)
        }
    }
}

// MARK: - ScalePresenter: ScaleInteractorOutput
extension ScalePresenter: ScaleInteractorOutputProtocol {
    func onSyncFinished(with message: String) {
        guard let view = self.view as? ScaleViewController else {
            return
        }
        view.hideHud()
    }

    func onSyncFinished(with data: SyncBaseModel?, status: Bool, message: String, page: Int) {
        isFetchingItems = false
        if status {
            if data?.meta?.code == 200 {
                guard let data = data else { return }
                self.handleLoadmoreItems(data.data?.smartScale)
                currentPage = page
                self.totalItem = data.meta?.total ?? 0
            } else {
                dLogError("[Error code]: \(data?.meta?.code ?? 0), [Error message]: \(data?.meta?.message ?? "")")
            }
        } else {
            dLogError("[Error code]: \(data?.meta?.code ?? 0), [Error message]: \(data?.meta?.message ?? "")")
        }
    }

    func onBodyFatListDidChanged(with bodyfatList: BodyFatList?) {
        self.bodyFats = bodyfatList?.bodyfats.array
            .filter({ $0.deviceMac == scale.mac })
            .sorted(by: { $0.timestamp > $1.timestamp }) ?? []
        self.numberOfItem = self.bodyFats.count
        self.filteredBodyFats = self.bodyFats
        view?.reloadData()
        self.view?.updateGraphView(times: [], type: self.currentType)
        self.view?.updateGraphView(with: self.getGraphData(of: self.currentType), timeType: self.currentType, deviceType: self.scale.type)
        kNotificationCenter.post(name: .changeProfile, object: nil)
    }

    func onConnectDeviceListChanged(with devices: [DeviceModel]) {
        self.connectDevices = devices
        let isConnectedDevice = devices.contains(where: { $0.mac == scale.mac })
        view?.updateHeader(with: !isConnectedDevice)
        if isConnectedDevice {
            let isConnect = BluetoothManager.shared.isConnect(with: scale)
            view?.updateConnectState(isConnect)
        }
    }
}

// MARK: - ScalePresenter: ScaleInteractorOutput
extension ScalePresenter {
    /// Calculate body fat data
    /// - Parameters:
    ///   - weight: body weight
    ///   - impedance: impedance
    ///   - syncId: synnc id
    ///   - createdAt: time created
    /// - Returns: synchronized body fat data from server
    private func caculateBodyFatData(from weight: CGFloat, impedance: Int, syncId: String, createdAt: String) -> BodyFat? {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile,
              let height = currentProfile.height.value,
              let birthday = currentProfile.birthday?.toDate(.ymd),
              let gender = currentProfile.gender.value else {
            return nil
        }

        let hTBodyfat = HTBodyfat_NewSDK()
        let sex = gender == .male ? THTSexType.male : .female
        let timeCreated = createdAt.toDate(.ymdhms) ?? Date()
        let age = timeCreated.year - birthday.year
        let errorType = hTBodyfat.getBodyfatWithweightKg(weight, heightCm: CGFloat(height), sex: sex, age: age, impedance: impedance)
        let bodyfat = BodyFat(bodyFat: hTBodyfat, hasError: errorType != .none, impedance: impedance)
        bodyfat.profileID = currentProfile.id
        bodyfat.scale = scale
        bodyfat.isSync = true
        bodyfat.syncId = syncId
        bodyfat.createAt = timeCreated.toString(.hmsdMy)
        bodyfat.timestamp = timeCreated.timeIntervalSince1970
        return bodyfat
    }
}
