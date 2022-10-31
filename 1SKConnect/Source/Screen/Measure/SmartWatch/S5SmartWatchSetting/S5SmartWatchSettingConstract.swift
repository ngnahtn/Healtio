//
//  
//  S5SmartWatchSettingConstract.swift
//  1SKConnect
//
//  Created by Be More on 24/01/2022.
//
//

import UIKit
import TrusangBluetooth

// MARK: - View
protocol S5SmartWatchSettingViewProtocol: AnyObject {
    func reloadData(at index: IndexPath)
    func hideReset()
}

// MARK: - Presenter
protocol S5SmartWatchSettingPresenterProtocol {

    var safeAreaBottom: CGFloat { get }
    func onViewDidLoad()
    func onViewWiilApear()
    
    // setOn
    func setOn(on: Bool, atType: S5SettingType)

    // handle s5 function
    func resetS5Device()
    func findS5Watch()

    // navigation functions
    func goToNotificationSetting()
    func goToGoalView()
    func goToWaterView()
    func goToWatchFace()
}

// MARK: - Interactor Input
protocol S5SmartWatchSettingInteractorInputProtocol {
    
    // Bluetooth connection
    func bluetoothPrepare()
    func scanDevice(seconds: Double)
    func stopScan()
    func connect(to device: ZHJBTDevice)
    
    // Bluetooth find chracteristics
    func foundServerCharacteristics()

    // get goalS5GoalState
    func readGoalState()

    // get s5DeviceInfoAndConfig
    func readDeviceConfig()
    func readDeviceInfo()

    // get s5AutoDectectState
    func readAutoDetectTemp()
    func readAutoDetectHR()
}

// MARK: - Interactor Output
protocol S5SmartWatchSettingInteractorOutputProtocol: AnyObject {
    
    // Bluetooth connection
    func bluetoothPrepare(state: ZHJBTManagerState)
    func scanDevice(devices: [ZHJBTDevice])
    func connect(to peripheral: CBPeripheral?, error: Error?)
    
    // Bluetooth found chracteristics
    func foundServerCharacteristics(_ characteristic: CBCharacteristic)
    
    // read s5GoalState
    func onGoalStateFinished(isOn: Bool)

    // read s5DeviceInfoAndConfig
    func onDeviceConfigFinished(config: ZHJDeviceConfig)
    func onDeviceInfoFinished(info:  ZHJBTDevice)

    // read s5AutoDectectState
    func onAutoDetectTempFinished(isOn: Bool)
    func onAutoDetectHRFinished(isOn: Bool)
}

// MARK: - Router
protocol S5SmartWatchSettingRouterProtocol {

    // navigation functions
    func goToNotificationSetting(noticeStatus: ZHJDeviceConfig)
    func goToGoalView()
    func goToWaterView()
    func goToWatchFace()
}
