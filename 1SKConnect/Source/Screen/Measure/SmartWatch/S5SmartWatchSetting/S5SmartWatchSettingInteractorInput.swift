//
//  
//  S5SmartWatchSettingInteractorInput.swift
//  1SKConnect
//
//  Created by Be More on 24/01/2022.
//
//

import UIKit
import TrusangBluetooth

class S5SmartWatchSettingInteractorInput {

    // processor properties
    let deviceConfigProcessor = ZHJDeviceConfigProcessor()
    let temperatureProcessor = ZHJTemperatureProcessor()
    let HR_BP_BOProcessor = ZHJHR_BP_BOProcessor()
    let deviceInfoProcessor = ZHJDeviceInfoProcessor()
    let goalTargetProcessor = ZHJSportTargetProcessor()

    weak var output: S5SmartWatchSettingInteractorOutputProtocol?
}

// MARK: - S5SmartWatchSettingInteractorInputProtocol
extension S5SmartWatchSettingInteractorInput: S5SmartWatchSettingInteractorInputProtocol {

    func stopScan() {
        ZHJBLEManagerProvider.shared.stopScan()
    }

    /// find charactoristic
    func foundServerCharacteristics() {
        ZHJBLEManagerProvider.shared.discoverReadCharacteristic { _ in }
        ZHJBLEManagerProvider.shared.discoverWriteCharacteristic { [weak self] characteristic in
            guard let `self` = self else { return }
            self.output?.foundServerCharacteristics(characteristic)
        }
    }
    
    /// Connect to device
    /// - Parameter device: `ZHJBTDevice`
    func connect(to device: ZHJBTDevice) {
        ZHJBLEManagerProvider.shared.connectDevice(device: device) { [weak self] peripheral in
            guard let `self` = self else { return }
            self.output?.connect(to: peripheral, error: nil)
        } fail: { [weak self] peripheral, error in
            guard let `self` = self else { return }
            self.output?.connect(to: peripheral, error: error)
        } timeout: { [weak self] in
            guard let `self` = self else { return }
            self.output?.connect(to: nil, error: nil)
        }
    }

    /// Scan for ble devices
    /// - Parameters:
    ///   - seconds: scan for seconds
    func scanDevice(seconds: Double) {
        ZHJBLEManagerProvider.shared.scan(seconds: seconds) { [weak self] bleDevices in
            guard let `self` = self else { return }
            self.output?.scanDevice(devices: bleDevices)
        }
    }
    
    /// Prepare BLE
    func bluetoothPrepare() {
        ZHJBLEManagerProvider.shared.bluetoothProviderManagerStateDidUpdate { [weak self] bleState in
            guard let `self` = self else { return }
            self.output?.bluetoothPrepare(state: bleState)
        }
    }

    // handle read goalState
    func readGoalState() {
        self.goalTargetProcessor.readSportTarget { [weak self] goalTarget in
            guard let `self` = self else { return }
            print("get ok")
            self.output?.onGoalStateFinished(isOn: goalTarget.stepTarget.enable)
        }
    }
    
    // handle read deviceInfo
    func readDeviceInfo() {
        deviceInfoProcessor.readDeviceInfo(deviceInfoHandle: {[weak self](device) in
            guard let `self` = self else { return }
            self.output?.onDeviceInfoFinished(info: device)
        })
    }

    // handle read s5AutoDetectTemp
    func readAutoDetectTemp() {
        self.temperatureProcessor.readTemperatureTimingDetectSetting { [weak self] tempDetectResult in
            guard let `self` = self else { return }
            self.output?.onAutoDetectTempFinished(isOn: tempDetectResult.detectEnable)
        }
    }

    // handle read s5AutoDetectHR
    func readAutoDetectHR() {
        HR_BP_BOProcessor.readHeartTimingDetectSetting { [weak self] heartDetectResult in
            guard let `self` = self else { return }
            self.output?.onAutoDetectHRFinished(isOn: heartDetectResult.detectEnable)
        }
    }

    // handle read s5DeviceConfig
    func readDeviceConfig() {
        self.deviceConfigProcessor.readDeviceConfig {[weak self] (config) in
            guard let self = self else { return }
            self.output?.onDeviceConfigFinished(config: config)
        }
    }
}
