//
//  
//  WeightMeasuringPresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit
import CoreBluetooth

// MARK: - State
extension WeightMeasuringPresenter {
    enum State {
        case waiting
        case measuring
        case finish
    }
}

class WeightMeasuringPresenter: NSObject {
    var scale: DeviceModel!
    var state: State = .waiting
    private let scalePeripheralDelegate = ScaleBLEPeripheralDelegate()
    private var scaleDataHandler: ScaleBLEDataHandler?
    private var timeoutTimer: Timer?
    private let timeout = TimeInterval(30) // seconds

    weak var view: WeightMeasuringViewProtocol?
    private var interactor: WeightMeasuringInteractorInputProtocol
    private var router: WeightMeasuringRouterProtocol

    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let bodyFatListDAO = GenericDAO<BodyFatList>()
    private var bodyFat: BodyFat!

    init(interactor: WeightMeasuringInteractorInputProtocol,
         router: WeightMeasuringRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    private func observerBLEState() {
        kNotificationCenter.addObserver(self, selector: #selector(onDeviceConnectionChanged(_:)), name: .deviceConnectionChanged, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(onCanNotConnectToDevice(_:)), name: .canNotConnectToDevice, object: nil)
    }

    @objc func onDeviceConnectionChanged(_ sender: Notification) {
        guard let mac = sender.userInfo?[SKKey.mac] as? String, scale?.mac == mac else {
            return
        }
        let isConnect = BluetoothManager.shared.isConnect(with: scale)
        if isConnect, state == .waiting {
            BluetoothManager.shared.discoverServices(serviceUUIDs: nil, of: scale)
        }
    }

    @objc func onCanNotConnectToDevice(_ sender: Notification) {
        guard let mac = sender.userInfo?[SKKey.mac] as? String, scale?.mac == mac else {
            return
        }
        if state == .waiting {
            SKToast.shared.showToast(content: L.canNotConnectToDevice.localized)
            router.dismiss()
        }
    }

    // MARK: - Time out timer
    private func startTimer() {
        stopTimer()
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false, block: { [weak self] (_) in
            // Can't connect for special device
            if self?.state == .measuring {
                SKToast.shared.showToast(content: L.weightMeasuringFalseMessage.localized)
                self?.router.dismiss()
            }
            self?.stopTimer()
        })
    }

    private func stopTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
}

// MARK: - WeightMeasuringPresenterProtocol
extension WeightMeasuringPresenter: WeightMeasuringPresenterProtocol {
    func onGoToScaleResultDetail(with weightDetail: DetailsItemProtocol) {
        guard let `bodyFat` = bodyFat else {
            return
        }
        self.router.onGoToScaleResultDetail(with: weightDetail, bodyFat: bodyFat)
    }

    func onViewDidLoad() {
        interactor.startObserver()
        observerBLEState()
        view?.setScaleImage(scale.image)
        BluetoothManager.shared.setScalePeripheralDelegate(scalePeripheralDelegate)
        scalePeripheralDelegate.dataHandler = { [weak self] (data, characteristic, error) in
            self?.scaleDataHandler?.handlerData(data, of: characteristic, error: error)
        }
        let isConnect = BluetoothManager.shared.isConnect(with: scale)
        if isConnect {
            BluetoothManager.shared.discoverServices(serviceUUIDs: nil, of: scale)
        } else {
            BluetoothManager.shared.connectToDevice(scale)
        }
    }

    func onViewDidDisappear() {
//        BluetoothManager.shared.disConnectDevice(scale)
    }

    func onButtonCloseDidTapped() {
        router.dismiss()
    }
}

// MARK: - WeightMeasuringPresenter: WeightMeasuringInteractorOutput -
extension WeightMeasuringPresenter: WeightMeasuringInteractorOutputProtocol {
    func onProfileListChange(with profileList: ProfileListModel?) {
        if scale.name.contains("1SK-SmartScale") {
            scaleDataHandler = SKScaleBLEDataHandler(profile: profileList?.currentProfile, scale: scale)
            scaleDataHandler?.delegate = self
        }
    }
}

// MARK: -
extension WeightMeasuringPresenter: ScaleBLEDataHandlerDelegate {
    func updateWeight(_ weight: Double) {
        if state == .measuring {
            view?.update(with: weight)
        } else if state == .waiting {
            state = .measuring
            startTimer()
            view?.update(with: state)
        }
    }

    func finishData(_ bodyFat: BodyFat) {
        if state == .measuring {
            state = .finish
            interactor.addBodyFat(bodyFat, scale: scale)
            view?.update(with: state)
            view?.update(with: bodyFat)

            self.bodyFat = bodyFat
            // handle sync data when user turn on.
            guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
                return
            }
            if let linkAccount = profile.linkAccount {
                let syncModel = BodyFatSyncModel(profile, bodyFat: [bodyFat])
                ConfigService.share.sync(with: syncModel, accessToken: linkAccount.accessToken ?? "") { data, status, _ in
                    if status {
                        dLogDebug("[Sync successed]: \(String(describing: data))")
                        guard let syncModel = data?.data else {
                            return
                        }
                        let dateUpdated = R.string.localizable.sync_last_date(Date().hourString, Date().minuteString, Date().dayString, Date().monthString, Date().yearString)
                        self.handleSaveDate(dateUpdated)
                        self.handleUpdateBodyFat(with: syncModel)
                    } else {
                        dLogError("[Sync error]")
                    }
                }
            }
        }
    }

    func scaleDidOverload() {
        router.showToast(content: L.overWeightMessage.localized)
    }
}

// MARK: - Helpers
extension WeightMeasuringPresenter {
    private func handleSaveDate(_ dateString: String) {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        profileListDAO.update {
            currentProfile.lastSyncDate = dateString
        }
    }

    private func handleUpdateBodyFat(with models: BodyFatSyncModel) {
        guard let smartScale = models.smartScale else { return }
        var bodyFats = [BodyFat]()
        for data in smartScale {
            let bodyFat = BodyFat(data)
            bodyFats.append(bodyFat)
        }

        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile, let bodyFatList = bodyFatListDAO.getObject(with: currentProfile.id) else {
            return
        }

        bodyFatListDAO.update {
            for data1 in bodyFatList.bodyfats.array {
                for data2 in bodyFats where data1.createAt == data2.createAt {
                    if String.isNilOrEmpty(data1.syncId) {
                        data1.syncId = data2.syncId
                        data1.isSync = true
                    }
                }
            }
        }
    }
}
