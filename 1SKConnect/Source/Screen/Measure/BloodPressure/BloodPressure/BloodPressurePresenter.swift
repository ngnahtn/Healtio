//
//  
//  BloodPressurePresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/02/2021.
//
//

import UIKit
import CoreBluetooth
import SwiftUI

class BloodPressurePresenter {
    // bluetooth properties
    var biolight: DeviceModel!
    private let biolightBLEPeripheral = BioLightBLEPeripheralDelegate()
    private lazy var peripheral = BluetoothManager.shared.peripheral(for: self.biolight)
    private var writeCharacteristic: CBCharacteristic!
    var isShowBLEConnection: Bool = true
    private var connectDevices: [DeviceModel] = []

    weak var view: BloodPressureViewProtocol?
    private var interactor: BloodPressureInteractorInputProtocol
    private var router: BloodPressureRouterProtocol

    // data handler properties
    private var currentPage = 1
    private let limit = 100000
    private var measurementState: BloodPressureMeasurementState = .none
    private var currentType: TimeFilterType = .day
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let bloodPressureListDAO = GenericDAO<BloodPressureListModel>()
    private var bloodPressureModels: [BloodPressureModel] = [] {
        didSet {
            view?.tableViewReloadData()
        }
    }
    var sysValue = 0 {
        didSet {
            view?.getValueWhenMeasuring(with: sysValue)
        }
    }

    init(interactor: BloodPressureInteractorInputProtocol,
         router: BloodPressureRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    deinit {
        BluetoothManager.shared.stopScan()
        kNotificationCenter.removeObserver(self, name: .deviceConnectionChanged, object: nil)
        kNotificationCenter.removeObserver(self, name: .canNotConnectToDevice, object: nil)
        kNotificationCenter.removeObserver(self, name: .bleStateChanged, object: nil)
    }

    // MARK: - Action
    private func observerBLEState() {
        kNotificationCenter.addObserver(self, selector: #selector(onDeviceConnectionChanged(_:)), name: .deviceConnectionChanged, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(onCanNotConnectToDevice(_:)), name: .canNotConnectToDevice, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(onBleStateChanged(_:)), name: .bleStateChanged, object: nil)
    }

    private func checkBLEAvailble() -> Bool {
        let isBLEAvailable = BluetoothManager.shared.checkBluetoothStatusAvailble()
        if !isBLEAvailable {
            switch BluetoothManager.shared.centralManager.state {
            case .poweredOff:
                self.isShowBLEConnection = true
            case .unauthorized:
                self.isShowBLEConnection = true
            default:
                break
            }
        }
        return isBLEAvailable
    }

    private func handleLoadmoreItems(_ items: [BloodPressure]?) {
        guard let bpData = items else { return }
        var bloodPressure = [BloodPressureModel]()
        for data in bpData {
            var bp: BloodPressureModel?
            bp = BloodPressureModel(data)
            if let `bp` = bp {
                if bp.biolight?.mac == self.biolight.mac {
                    bloodPressure.append(bp)
                }
            }
        }

        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }

        if let bloodPressureList = bloodPressureListDAO.getObject(with: currentProfile.id) {
            bloodPressureListDAO.update {
                for data1 in bloodPressure {
                    var exist = false
                    for data2 in bloodPressureList.bloodPressureList.array where data1.syncId == data2.syncId {
                        exist = true
                        break
                    }
                    if !exist {
                        var isDeleted = false
                        for data in currentProfile.bpDeleteSyncId.array  where data == data1.syncId {
                            isDeleted = true
                            break
                        }
                        if !isDeleted {
                            bloodPressureList.bloodPressureList.append(data1)
                        }
                    }
                }
            }
        } else {
            for (i, data) in bloodPressure.enumerated() where self.biolight.mac != data.biolight?.mac {
                bloodPressure.remove(at: i)
            }
            let bpList = BloodPressureListModel(profile: currentProfile, device: self.biolight, bloodPressureList: bloodPressure)
            bloodPressureListDAO.add(bpList)
        }
    }

    private func loadItem(in page: Int) {
//        isFetchingItems = true
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let linkAccount = profile.linkAccount {
            if profile.needDowloadData {
                self.interactor.syncListData(with: linkAccount.uuid, accessToken: linkAccount.accessToken ?? "", page: page, limit: self.limit)
            }
        }
    }

    private func handleSaveDate(_ dateString: String) {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        profileListDAO.update {
            currentProfile.lastSyncDate = dateString
        }
    }

    private func handleUpdateBloodPressure(with models: BloodPressureSyncModel) {
        guard let bloodPressure = models.bloodPressure else { return }
        var bloodPressureModels = [BloodPressureModel]()
        for data in bloodPressure {
            let bloodpressure = BloodPressureModel(data)
            bloodPressureModels.append(bloodpressure)
        }

        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile, let bloodPressureList = bloodPressureListDAO.getObject(with: currentProfile.id) else {
            return
        }

        bloodPressureListDAO.update {
            for data1 in bloodPressureList.bloodPressureList.array {
                for data2 in bloodPressureModels where data1.createAt  == data2.createAt {
                    if String.isNilOrEmpty(data1.syncId) {
                        data1.syncId = data2.syncId
                    }
                }
            }
        }
    }
}

// MARK: - Selectors
extension BloodPressurePresenter {

    @objc func onDeviceConnectionChanged(_ sender: Notification) {
        guard let mac = sender.userInfo?[SKKey.mac] as? String,
              biolight?.mac == mac else {
            return
        }
        let isConnect = BluetoothManager.shared.isConnect(with: biolight)
        if isConnect {
            view?.setIndicatorHidden(true)
            BluetoothManager.shared.discoverServices(serviceUUIDs: nil, of: biolight)
        } else {
            view?.setIndicatorHidden(false)
            BluetoothManager.shared.connectToDevice(self.biolight, turnOffTimeout: true)
        }
        view?.updateConnectState(isConnect)
    }

    @objc func onBleStateChanged(_ sender: Notification) {
        if BluetoothManager.shared.checkBluetoothStatusAvailble() {
            let isConnect = BluetoothManager.shared.isConnect(with: biolight)
            if isConnect {
                view?.setIndicatorHidden(true)
                BluetoothManager.shared.discoverServices(serviceUUIDs: nil, of: biolight)
            } else {
                view?.setIndicatorHidden(false)
                BluetoothManager.shared.connectToDevice(self.biolight, turnOffTimeout: true)
            }
            view?.updateConnectState(isConnect)
        } else {
            view?.updateConnectState(false)
        }
    }

    @objc func onCanNotConnectToDevice(_ sender: Notification) {
        guard let mac = sender.userInfo?[SKKey.mac] as? String, biolight?.mac == mac else {
            return
        }
        BluetoothManager.shared.connectToDevice(self.biolight, turnOffTimeout: true)
        let isConnect = BluetoothManager.shared.isConnect(with: biolight)
        view?.updateConnectState(isConnect)
        view?.setIndicatorHidden(false)
    }
}

// MARK: - Data Handler
extension BloodPressurePresenter {

    private func automaticSync(bloodpressure: BloodPressureModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if profile.linkAccount != nil {
            let syncModel = BloodPressureSyncModel(profile, bp: [bloodpressure])
            ConfigService.share.createBpSync(with: syncModel, accessToken: profile.linkAccount?.accessToken ?? "") { data, status, _ in
                if status {
                    dLogDebug("[Sync successed]: \(String(describing: data))")
                    guard let syncModel = data?.data else {
                        return
                    }
                    let dateUpdated = R.string.localizable.sync_last_date(Date().hourString, Date().minuteString, Date().dayString, Date().monthString, Date().yearString)
                    self.handleSaveDate(dateUpdated)
                    self.handleUpdateBloodPressure(with: syncModel)
                } else {
                    dLogError("[Sync error]")
                }
            }
        }
    }
    private func sendCommand(_ command: BioCommand.Command) {
        let bioCommand = BioCommand(command: command)
        guard let peripheral = self.peripheral else {
            return
        }
        BluetoothManager.shared.sendCommand(peripheral, bioCommand, to: self.biolightBLEPeripheral.writeCharacteristics.first)
    }

    func handleUpdateData(bytes: [UInt8], of characteristic: CBCharacteristic) {
        guard let bioData = BiolightData(data: bytes), let dataBlock = bioData.dataBlock else {
            return
        }
        switch dataBlock.id {
        case 40:
            // case: send sysData when measuring
            measurementState = .measuring
            guard dataBlock.dataSegment.count > 0 else {
                return
            }
            let sys = dataBlock.dataSegment[0]
            self.sysValue = Int(sys)
        case 41:
            // case: send result when lock data
            measurementState = .none
            guard dataBlock.dataSegment.count > 0 else {
                return
            }
            // errorByte show error code
            let errorByte = dataBlock.dataSegment[1]
            if errorByte == 0 {
                // no error
                let firstByte = dataBlock.dataSegment[0]
                let sys = firstByte.uInt8Bits()[0].intValue() * 256 + dataBlock.dataSegment[2].intValue()
                let dia = firstByte.uInt8Bits()[1].intValue() * 256 + dataBlock.dataSegment[3].intValue()
                let map = firstByte.uInt8Bits()[2].intValue() * 256 + dataBlock.dataSegment[4].intValue()
                let pr = firstByte.uInt8Bits()[3].intValue() * 256 + dataBlock.dataSegment[5].intValue()
                let biolightMeasurementModel = BiolightMeasurementModel(sys: sys, dia: dia, map: map, pr: pr)
                let bloodPressureModel = BloodPressureModel(with: biolightMeasurementModel, of: self.biolight)
                self.interactor.saveBloodPressure(bloodPressureModel, biolight: self.biolight)
                self.automaticSync(bloodpressure: bloodPressureModel)
                router.gotoBloodPressureResultViewController(with: bloodPressureModel, and: "", and: self)
            } else {
                if errorByte == 6 || errorByte == 20 {
                    router.gotoBloodPressureResultViewController(with: nil, and: R.string.localizable.biolight_error_device(), and: self)
                } else if errorByte == 11 || errorByte == 13 {
                    router.gotoBloodPressureResultViewController(with: nil, and: R.string.localizable.biolight_error_movement(), and: self)
                } else if errorByte == 19 {
                    router.gotoBloodPressureResultViewController(with: nil, and: R.string.localizable.biolight_error_timeout(), and: self)
                }
            }
            view?.getMeasurementState(.none)
            guard dataBlock.dataSegment.count > 0 else {
                return
            }
//            let status = dataBlock.dataSegment[0].bits()[4]  error status = 0 : 1
        case 42:
            guard dataBlock.dataSegment.count > 0 else {
                return
            }
            // show device status 0 : 1
            let status = dataBlock.dataSegment[0].uInt8Bits()[4]
            if status == 0 {
                measurementState = .none
                view?.getMeasurementState(.none)
            } else {
                view?.getMeasurementState(.measuring)
            }
            print(status)
        default:
            break
        }
    }
}
// MARK: - BloodPressurePresenterProtocol -
extension BloodPressurePresenter: BloodPressurePresenterProtocol {
    func onViewDidAppear() {
        self.loadItem(in: 1)
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

    func onButtonSettingLinkTapped() {
        router.openLinkSetting()
    }

    func onButtonSettingBLEDidTapped() {
        router.openAppSetting()
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
        guard let view = self.view as? BloodPressureViewController else {
            return
        }
        view.showHud()
        self.interactor.handleSync()
    }

    func onDeleteItem(at index: IndexPath) {
        let bloodPressure = bloodPressureModels[index.row]
        interactor.deleteBloodPressureModel(bloodPressure)
    }

    func showBioLightDataSelected(with data: BloodPressureModel?, and errorText: String) {
        router.gotoBloodPressureResultViewController(with: data, and: errorText, and: self)
    }

    func tableViewNumberOfRow(in section: Int) -> Int {
        return self.bloodPressureModels.count
    }

    func tableViewCellForRow(at index: IndexPath) -> BloodPressureModel? {
        if index.row > self.bloodPressureModels.count {
            return nil
        }
        return self.bloodPressureModels[index.row]
    }

    func onViewDidLoad() {
        observerBLEState()
//        self.loadItem(in: 1)
        BluetoothManager.shared.setBiolightPeripheralDelegate(biolightBLEPeripheral)
        self.biolightBLEPeripheral.continuousDataHandler = { [weak self] (data, characteristic, _) in
            guard let `self` = self else { return }
            self.handleUpdateData(bytes: data, of: characteristic)
        }
        let isConnect = BluetoothManager.shared.isConnect(with: biolight)
        view?.updateConnectState(isConnect)
        interactor.startObserver()
        if isConnect {
            BluetoothManager.shared.discoverServices(serviceUUIDs: nil, of: biolight)
        } else {
            BluetoothManager.shared.connectToDevice(biolight)
        }
    }

    func onFilterViewDidSelected(_ filterViewType: TimeFilterType) {
        self.currentType = filterViewType
        self.view?.updateGraphView(times: [], type: self.currentType)
        self.view?.updateGraphView(with: self.getGraphData(of: self.currentType),
                                   timeType: self.currentType,
                                   deviceType: self.biolight.type)
    }

    func onButtonStartDidTapped() {
        if !checkBLEAvailble() {
            return
        }
        let isConnectedDevice = connectDevices.contains(where: { $0.mac == biolight.mac})
        if isConnectedDevice {
            switch measurementState {
            case .measuring:
                sendCommand(.abandon)
            case .none:
                sendCommand(.start)
            case .pause:
                sendCommand(.continueMeasurement)
            }
        }
    }
}

// MARK: - BloodPressurePresenter: BloodPressureInteractorOutput -
extension BloodPressurePresenter: BloodPressureInteractorOutputProtocol {
    func onSyncFinished(with message: String) {
        guard let view = self.view as? BloodPressureViewController else {
            return
        }
        view.hideHud()
    }

    func onSyncFinished(with data: BloodPressureSyncBaseModel?, status: Bool, message: String, page: Int) {
        if status {
            if data?.meta?.code == 200 {
                guard let data = data else { return }
                self.handleLoadmoreItems(data.data?.bloodPressure)
                currentPage = page
            } else {
                dLogError("[Error code]: \(data?.meta?.code ?? 0), [Error message]: \(data?.meta?.message ?? "")")
            }
        } else {
            dLogError("[Error code]: \(data?.meta?.code ?? 0), [Error message]: \(data?.meta?.message ?? "")")
        }
    }

    func onBloodPressureListChange(with bloodPressureList: [BloodPressureModel]) {
        if !self.bloodPressureModels.isEmpty {
            self.bloodPressureModels.removeAll()
        }

        self.bloodPressureModels = bloodPressureList.filter({ $0.deviceMac == self.biolight.mac })
        self.view?.updateGraphView(times: [], type: self.currentType)

        self.view?.updateGraphView(with: self.getGraphData(of: self.currentType),
                                   timeType: self.currentType,
                                   deviceType: self.biolight.type)
        kNotificationCenter.post(name: .changeProfile, object: nil)
    }

    func onConnectDeviceListChanged(with devices: [DeviceModel]) {
        self.connectDevices = devices
        let isConnectedDevice = devices.contains(where: { $0.mac == biolight.mac })
        if isConnectedDevice {
            let isConnect = BluetoothManager.shared.isConnect(with: biolight)
            view?.updateConnectState(isConnect)
            view?.setIndicatorHidden(isConnect)
        }
    }
}
// MARK: - Get garph data
extension BloodPressurePresenter {
    private func getGraphData(of type: TimeFilterType) -> [[[BloodPressureModel]]] {
        var joinedArray: [[[BloodPressureModel]]] = []
        switch type {
        case .day:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { bloodPressure, bloodPressures in
                return bloodPressure.date.toDate().isSameHour(with: bloodPressures.last!.date.toDate())
            }, isSameLargeGroup: { bloodPressures, listBloodPressures in
                return bloodPressures.last!.date.toDate().isSameDay(with: listBloodPressures.last!.last!.date.toDate())
            })
        case .week:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { bloodPressure, bloodPressures in
                return bloodPressure.date.toDate().isSameDay(with: bloodPressures.last!.date.toDate())
            }, isSameLargeGroup: { bloodPressures, listBloodPressures in
                return bloodPressures.last!.date.toDate().isInSameWeek(as: listBloodPressures.last!.last!.date.toDate())
            })
        case .month:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { bloodPressure, bloodPressures in
                return bloodPressure.date.toDate().isSameDay(with: bloodPressures.last!.date.toDate())
            }, isSameLargeGroup: { bloodPressures, listBloodPressures in
                return bloodPressures.last!.date.toDate().isSameMonth(with: listBloodPressures.last!.last!.date.toDate())
            })
        case .year:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { bloodPressure, bloodPressures in
                return bloodPressure.date.toDate().isSameMonth(with: bloodPressures.last!.date.toDate())
            }, isSameLargeGroup: { bloodPressures, listBloodPressures in
                return bloodPressures.last!.date.toDate().isInSameYear(as: listBloodPressures.last!.last!.date.toDate())
            })
        }
        return joinedArray
    }

    private func processDataForGraphView(isSameSmallGroup: (BloodPressureModel, [BloodPressureModel]) -> Bool, isSameLargeGroup: ([BloodPressureModel], [[BloodPressureModel]]) -> Bool) -> [[[BloodPressureModel]]] {
        var joinedArray: [[[BloodPressureModel]]] = []
        var largeTemp: [[BloodPressureModel]] = []
        var smallTemp: [BloodPressureModel] = []
        for data in bloodPressureModels.reversed() {
            if !smallTemp.isEmpty {
                if isSameSmallGroup(data, smallTemp) {
                    smallTemp.append(data)
                } else {
                    largeTemp.append(smallTemp)
                    smallTemp = [data]
                }
            } else { // temp empty
                smallTemp.append(data)
            }
        }
        if !smallTemp.isEmpty {
            largeTemp.append(smallTemp)
        }

        var temp: [[BloodPressureModel]] = []
        for data in largeTemp {
            if !temp.isEmpty {
                if isSameLargeGroup(data, temp) {
                    temp.append(data)
                } else {
                    joinedArray.append(temp)
                    temp = [data]
                }
            } else { // temp empty
                temp.append(data)
            }
        }

        if !temp.isEmpty {
            joinedArray.append(temp)
        }

        return joinedArray
    }
}
