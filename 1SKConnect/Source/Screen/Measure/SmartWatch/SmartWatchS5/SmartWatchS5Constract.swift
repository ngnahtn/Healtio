//
//  
//  SmartWatchS5Constract.swift
//  1SKConnect
//
//  Created by TrungDN on 07/12/2021.
//
//

import UIKit
import TrusangBluetooth
import CoreBluetooth

// MARK: - View
protocol SmartWatchS5ViewProtocol: AnyObject {
    func updateView(with state: Bool)
    func updateBattery(at level: Int)
    
    func reloadData(at cellType: CellType)
}

// MARK: - Presenter
protocol SmartWatchS5PresenterProtocol {
    var exerciseData: S5Exercise? { get }

    var hrListData: S5HeartRateRecordModel? { get }

    var spO2ListData: S5SpO2RecordModel? { get }

    var temperatureListData: S5TemperatureRecordModel? { get }
    
    var bloodPressureListData: BloodPressureRecordModel? { get }
    
    var syntheticData: SyntheticData? { get }
    
    var sleepModelData: SleepRecordModel? { get }

    func onViewDidLoad()
    
    func prepareToPushToExcerciseView(with timeDefault: TimeFilterType)

    func refeshData()
    
    // handle navigation
    func goToBloodPressureDetail(with timeDefault: TimeFilterType)
    func goToHeartRateDetail(with timeDefault: TimeFilterType)
    func goToSpO2Detail(with timeDefault: TimeFilterType)
    func goToSleepDetail(with timeDefault: TimeFilterType)
    func goToTemperatureDetail(with timeDefault: TimeFilterType)
    func goToSetting()
    
    // func handle sync
    func uploadData()
}

// MARK: - Interactor Input
protocol SmartWatchS5InteractorInputProtocol {
    // observe change state
    func startObserver()
    
    // Bluetooth connection
    func bluetoothPrepare()
    func scanDevice(seconds: Double)
    func stopScan()
    func connect(to device: ZHJBTDevice)
    
    // Bluetooth find chracteristics
    func foundServerCharacteristics()
    
    // device services
    func readBatteryPower()
    func readHistoryStepAndSleep(with value: Int)
    func readCurrentHeartrate()
    func readHistoryHeartrate()
    func readHistoryTemperature()
    func syncTimeAndLanguage()
    func turnOnSaveData(with profileModel: ProfileModel)
    
    // save data
    func saveStep(_ step: StepRecordModel, smartWatch: DeviceModel)
    func saveSteps(_ steps: [StepRecordModel], smartWatch: DeviceModel)

    func saveSleep(_ sleep: SleepRecordModel, smartWatch: DeviceModel)
    func saveSleeps(_ sleeps: [SleepRecordModel], smartWatch: DeviceModel)

    func saveHR(_ hr: S5HeartRateRecordModel, smartWatch: DeviceModel)
    func saveHRList(_ hrs: [S5HeartRateRecordModel], smartWatch: DeviceModel)

    func saveSpO2(_ spo2: S5SpO2RecordModel, smartWatch: DeviceModel)
    func saveSpO2List(_ spo2s: [S5SpO2RecordModel], smartWatch: DeviceModel)

    func saveTemp(_ temp: S5TemperatureRecordModel, smartWatch: DeviceModel)
    func saveTempList(_ temps: [S5TemperatureRecordModel], smartWatch: DeviceModel)

    func saveBloodPressure(_ bp: BloodPressureRecordModel, smartWatch: DeviceModel)
    func saveBloodPressureList(_ bps: [BloodPressureRecordModel], smartWatch: DeviceModel)

    func saveSports(_ sports: [S5SportRecordModel], smartWatch: DeviceModel)
}

// MARK: - Interactor Output
protocol SmartWatchS5InteractorOutputProtocol: AnyObject {
    // Bluetooth connection
    func bluetoothPrepare(state: ZHJBTManagerState)
    func scanDevice(devices: [ZHJBTDevice])
    func connect(to peripheral: CBPeripheral?, error: Error?)
    
    // Bluetooth found chracteristics
    func foundServerCharacteristics(_ characteristic: CBCharacteristic)
    
    // device services
    func readBatteryPower(_ power: Int)
    func readHistoryStepAndSleep(with value: Int)
    func readCurrentHeartrate()
    func readHistoryHeartrate()
    func readHistoryTemperature()
    func readHistorySport()
    
    // data change
    func onStepListChage(with data: [StepRecordModel])
    func onSleepListChage(with data: [SleepRecordModel])
    func onHeartRateListChange(with data: [S5HeartRateRecordModel])
    func onSpo2ListChange(with data: [S5SpO2RecordModel])
    func onTempListChange(with data: [S5TemperatureRecordModel])
    func onBloodPressureListChange(with data: [BloodPressureRecordModel])
    func onSportListChange(with data: [S5SportRecordModel])
}

// MARK: - Router
protocol SmartWatchS5RouterProtocol {
    func goToExerciseView(with timeDefault: TimeFilterType, device: DeviceModel)

    // handle navigation
    func goToBloodPressureDetail(with timeType: TimeFilterType)
    func goToHeartRateDetail(with timeType: TimeFilterType)
    func goToSpO2Detail(with timeType: TimeFilterType)
    func goToSleepDetail(with timeType: TimeFilterType)
    func goToTemperatureDetail(with timeType: TimeFilterType)
    func goToSetting()
}
