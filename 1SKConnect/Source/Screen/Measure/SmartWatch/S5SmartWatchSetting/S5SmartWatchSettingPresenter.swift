//
//  
//  S5SmartWatchSettingPresenter.swift
//  1SKConnect
//
//  Created by Be More on 24/01/2022.
//
//

import UIKit
import TrusangBluetooth

class S5SmartWatchSettingPresenter {

    weak var view: S5SmartWatchSettingViewProtocol?
    private var interactor: S5SmartWatchSettingInteractorInputProtocol
    private var router: S5SmartWatchSettingRouterProtocol
    private var deviceConfig = ZHJDeviceConfig()
    private let btProvider = ZHJBLEManagerProvider.shared
    
    var smartWatch: DeviceModel!

    // s5Processor properties
    let deviceClearProcessor = ZHJClearDeviceProcessor()
    let deviceConfigProcessor = ZHJDeviceConfigProcessor()
    let temperatureProcessor = ZHJTemperatureProcessor()
    let HR_BP_BOProcessor = ZHJHR_BP_BOProcessor()
    let deviceControlProcessor = ZHJDeviceControlProcessor()

    // s5State properties
    private var isTempAuto: Bool = false {
        didSet {
            self.view?.reloadData(at: IndexPath(row: 1, section: 1))
        }
    }
    
    private var isHRAuto: Bool = false {
        didSet {
            self.view?.reloadData(at: IndexPath(row: 0, section: 1))
        }
    }
    
    private var notice: Bool! {
        didSet {
            self.view?.reloadData(at: IndexPath(row: 0, section: 0))
        }
    }
    
    private var goalNotice: Bool! {
        didSet {
            self.view?.reloadData(at: IndexPath(row: 1, section: 0))
        }
    }
    
    private var trunWrist: Bool! {
        didSet {
            self.view?.reloadData(at: IndexPath(row: 2, section: 1))
        }
    }

    init(interactor: S5SmartWatchSettingInteractorInputProtocol,
         router: S5SmartWatchSettingRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    @objc private func onNotiChange(_ sender: NSNotification) {
        if let isOn = sender.userInfo?["isOn"] as? Bool {
            self.deviceConfig.notice = isOn
            s5Setting1stSectionDataSource[0].status = isOn
            self.notice = isOn
        }
    }
    
    @objc private func onGoalNotiChange(_ sender: NSNotification) {
        if let isOn = sender.userInfo?["isOn"] as? Bool {
            s5Setting1stSectionDataSource[1].status = isOn
            self.goalNotice = isOn
        }
    }
}

// MARK: - S5SmartWatchSettingPresenterProtocol
extension S5SmartWatchSettingPresenter: S5SmartWatchSettingPresenterProtocol {

    // handle Reset S5Device
    func resetS5Device() {
        deviceClearProcessor.resetDevice {[weak self] (result) in
            guard let `self` = self else { return }
            self.view?.hideReset()
            guard result == .correct else {
                return
            }
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

    func setOn(on: Bool, atType: S5SettingType) {
        switch atType {
        case .heartRate:
            self.writeAutoDetectHR(isOn: on)
        case .temperature:
            self.writeAutoDetectTemp(isOn: on)
        case .turnWrist:
            self.writeTrunWrist(isOn: on)
        default:
            return
        }
    }

    // handle find s5Watch
    func findS5Watch() {
        self.deviceControlProcessor.findDevice { [weak self] (result) in
            guard result == .correct else {
                return
            }
        }
    }

    func goToNotificationSetting() {
        self.router.goToNotificationSetting(noticeStatus: self.deviceConfig)
    }

    func goToGoalView() {
        self.router.goToGoalView()
    }
    
    func goToWaterView() {
        self.router.goToWaterView()
    }

    func goToWatchFace() {
        self.router.goToWatchFace()
    }

    func onViewDidLoad() {
        if btProvider.deviceState == .connected {
            self.interactor.readDeviceInfo()
        } else {
            self.scanForDevice()
        }
        kNotificationCenter.addObserver(self, selector: #selector(self.onNotiChange(_:)), name: .s5NotiSettingChange, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(self.onGoalNotiChange(_:)), name: .s5GoalSettingChange, object: nil)
    }

    func onViewWiilApear() {
    }
    
    /// Scan device
    private func scanForDevice() {
        BluetoothManager.shared.stopScan()
        if ZHJBLEManagerProvider.shared.btManager?.state == .poweredOn {
            self.interactor.scanDevice(seconds: Double.greatestFiniteMagnitude)
        }
        self.interactor.bluetoothPrepare()
    }
}

// MARK: - S5SmartWatchSettingInteractorOutput 
extension S5SmartWatchSettingPresenter: S5SmartWatchSettingInteractorOutputProtocol {
    func foundServerCharacteristics(_ characteristic: CBCharacteristic) {
        self.interactor.readDeviceConfig()
    }
    
    func scanDevice(devices: [ZHJBTDevice]) {
        DispatchQueue.main.async {
            for device in devices where device.name == self.smartWatch.name {
                // connect to device
                self.interactor.connect(to: device)
            }
        }
    }
    
    func bluetoothPrepare(state: ZHJBTManagerState) {
        if state == .poweredOn {
            delay(by: 1.0) {
                self.interactor.scanDevice(seconds: Double.greatestFiniteMagnitude)
            }
        }
    }
    
    func connect(to peripheral: CBPeripheral?, error: Error?) {
        DispatchQueue.main.async {
            if error != nil {
                // error
                dLogDebug("Smart watch Failed")
            } else {
                if peripheral != nil {
                    // success
                    dLogDebug("Smart watch connected")
                    self.interactor.foundServerCharacteristics()
                    self.interactor.stopScan()
                } else {
                    // timeout
                    dLogDebug("Smart watch timeout")
                }
            }
        }
    }
    
    // get deviceInfo
    func onDeviceInfoFinished(info: ZHJBTDevice) {
        s5Setting3thSectionDataSource[0].description = info.version
        self.view?.reloadData(at: IndexPath(row: 0, section: 2))
        self.interactor.readDeviceConfig()
    }

    // get goalState
    func onGoalStateFinished(isOn: Bool) {
        s5Setting1stSectionDataSource[1].status = isOn
        self.goalNotice = isOn
        self.interactor.readAutoDetectTemp()
    }
    
    // get state of autoDetectTemp
    func onAutoDetectTempFinished(isOn: Bool) {
        s5Setting2ndSectionDataSource[1].status = isOn
        self.isTempAuto = isOn
        self.interactor.readAutoDetectHR()
    }

    // get state of autoDetectHR
    func onAutoDetectHRFinished(isOn: Bool) {
        s5Setting2ndSectionDataSource[0].status = isOn
        self.isHRAuto = isOn
    }

    // get deviceConfig
    func onDeviceConfigFinished(config: ZHJDeviceConfig) {
        self.deviceConfig = config
        s5Setting1stSectionDataSource[0].status = config.notice
        self.notice = config.notice
        s5Setting2ndSectionDataSource[2].status = config.trunWrist
        self.trunWrist = config.trunWrist
        self.interactor.readGoalState()
    }
}

// MARK: Helpers
extension S5SmartWatchSettingPresenter {
    
    /// Handle set state of s5AutoDetectTemp
    /// - Parameter isOn: Bool
    private func writeAutoDetectTemp(isOn: Bool) {
        temperatureProcessor.setAutoDetectTemperature(interval: 15, isOn: isOn) {[weak self] (errors) in
            guard let `self` = self else { return }
            guard errors == .correct else {
                return
            }
            s5Setting2ndSectionDataSource[1].status = isOn
            self.isTempAuto = isOn
        }
    }
    
    /// Handle set state of s5AutoDetectHR
    /// - Parameter isOn: Bool
    private func writeAutoDetectHR(isOn: Bool) {
        HR_BP_BOProcessor.setAutoDetectHeartRate(interval: 15, isOn: isOn) {[weak self] (errors) in
            guard let `self` = self else { return }
            guard errors == .correct else {
                return
            }
            s5Setting2ndSectionDataSource[0].status = isOn
            self.isHRAuto = isOn
        }
    }
    
    /// Handle state of turnWrist
    /// - Parameter isOn: Bool
    private func writeTrunWrist(isOn: Bool) {
        self.deviceConfig.trunWrist = isOn
        self.deviceConfigProcessor.writeDeviceConfig(self.deviceConfig) { [weak self] (errors) in
            guard let `self` = self else { return }
            guard errors == .correct else {
                return
            }
            s5Setting2ndSectionDataSource[2].status = isOn
            self.trunWrist = isOn
        }
    }
}
