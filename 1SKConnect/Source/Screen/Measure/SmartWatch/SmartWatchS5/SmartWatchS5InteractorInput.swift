//
//  
//  SmartWatchS5InteractorInput.swift
//  1SKConnect
//
//  Created by TrungDN on 07/12/2021.
//
//

import UIKit
import TrusangBluetooth
import RealmSwift

class SmartWatchS5InteractorInput {
    weak var output: SmartWatchS5InteractorOutputProtocol?
    
    var syncS5Service: SyncS5ServiceProtocol?

    // connect
    let btProvider = ZHJBLEManagerProvider.shared
    
    // get battery
    let batteryProcessor = ZHJBatteryProcessor()
    let userInfoProcessor = ZHJUserInfoProcessor()
    
    // step and sleep functions
    let stepAndSleepProcessor = ZHJStepAndSleepProcessor()
    
    // time sync
    let syncTimeProcessor = ZHJSyncTimeProcessor()
    
    // sync language
    var deviceConfig = ZHJDeviceConfig()
    let deviceConfigProcessor = ZHJDeviceConfigProcessor()
    
    // auto save temperature
    let temperatureProcessor = ZHJTemperatureProcessor()
    private var callDelayTime: Double = 0
    
    var profileNotificationToken: NotificationToken?
    var stepNotificationToken: NotificationToken?
    var deviceNotificationToken: NotificationToken?
    var sleepNotificationToken: NotificationToken?
    var heartRateNotificationToken: NotificationToken?
    var spO2NotifacationToken: NotificationToken?
    var temperatureNotificationToken: NotificationToken?
    var bloodPressureNotificationToken: NotificationToken?
    var sportMotificationToken: NotificationToken?
    
    private let sleepListModelDAO = GenericDAO<SleepListRecordModel>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let deviceListDAO = GenericDAO<DeviceList>()
    private let stepListModelDAO = GenericDAO<StepListRecordModel>()
    private let heartRateListModelDAO = GenericDAO<S5HeartRateListRecordModel>()
    private let spO2ListModelDAO = GenericDAO<S5SpO2ListRecordModel>()
    private let tempListModelDAO = GenericDAO<S5TemperatureListRecordModel>()
    private let bloodPressureListModelDAO = GenericDAO<BloodPressureListRecordModel>()
    private let sportListModelDAO = GenericDAO<S5SportListRecordModel>()

    private func registerToken() {
        self.deviceListDAO.registerToken(token: &self.deviceNotificationToken) { [weak self] in
            guard let `self` = self else { return }
        }

        self.profileListDAO.registerToken(token: &self.profileNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onStepListChange()
            self.onSleepListChange()
            self.onHeartRateListChange()
            self.onSpO2ListChange()
            self.onTempListChange()
            self.onBpListChange()
            self.onSportListChange()
        }

        self.stepListModelDAO.registerToken(token: &self.stepNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onStepListChange()
        }

        self.sleepListModelDAO.registerToken(token: &self.sleepNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onSleepListChange()
        }

        self.heartRateListModelDAO.registerToken(token: &self.heartRateNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onHeartRateListChange()
        }

        self.spO2ListModelDAO.registerToken(token: &self.spO2NotifacationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onSpO2ListChange()
        }

        self.tempListModelDAO.registerToken(token: &self.temperatureNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onTempListChange()
        }

        self.bloodPressureListModelDAO.registerToken(token: &self.bloodPressureNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onBpListChange()
        }
        
        self.sportListModelDAO.registerToken(token: &self.sportMotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onSportListChange()
        }
    }

    private func onBpListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let bpList = self.bloodPressureListModelDAO.getObject(with: profile.id) {
            self.output?.onBloodPressureListChange(with: bpList.bloodPressureList.array)
        } else {
            self.output?.onBloodPressureListChange(with: [])
        }
    }
    
    private func onTempListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let tempList = self.tempListModelDAO.getObject(with: profile.id) {
            self.output?.onTempListChange(with: tempList.tempList.array)
        } else {
            self.output?.onTempListChange(with: [])
        }
    }

    private func onHeartRateListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let hrList = self.heartRateListModelDAO.getObject(with: profile.id) {
            self.output?.onHeartRateListChange(with: hrList.hrList.array)
        } else {
            self.output?.onHeartRateListChange(with: [])
        }
    }

    private func onSpO2ListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let spO2List = spO2ListModelDAO.getObject(with: profile.id) {
            self.output?.onSpo2ListChange(with: spO2List.spO2List.array)
        } else {
            self.output?.onSpo2ListChange(with: [])
        }
    }
    
    private func onStepListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let stepList = stepListModelDAO.getObject(with: profile.id) {
            self.output?.onStepListChage(with: stepList.stepList.array)
        } else {
            self.output?.onStepListChage(with: [])
        }
    }

    private func onSleepListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let sleepList = sleepListModelDAO.getObject(with: profile.id) {
            self.output?.onSleepListChage(with: sleepList.sleepList.array)
        } else {
            self.output?.onSleepListChage(with: [])
        }
    }

    private func onSportListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let sportList = self.sportListModelDAO.getObject(with: profile.id) {
            self.output?.onSportListChange(with: sportList.sportList.array)
        } else {
            self.output?.onSportListChange(with: [])
        }
    }

    /// Sync language
    private func syncLanguage() {
        deviceConfig.timeMode = Tools.is12HourFormat() ? .hour12 : .hour24
        deviceConfig.language = self.getLanguage()
        deviceConfig.temperatureUnit = .celsius
        deviceConfigProcessor.writeDeviceConfig(deviceConfig, setHandle: { [weak self] _ in
            guard let `self` = self else { return }
            delay(by: self.callDelayTime) {
                self.readHistorySport()
            }
        })
    }
    
    private func readHistorySport() {
        self.output?.readHistorySport()
    }

    /// Get current language
    /// - Returns: `ZHJlLanguage`
    private func getLanguage() -> ZHJlLanguage {
        var configLanguage: ZHJlLanguage = .english
        let language = Locale.preferredLanguages.first!

        switch language.prefix(language.count - 3) {
        case "en":
            configLanguage = .english
        case "zh-Hans":
            configLanguage = .chinese
        case "ru":
            configLanguage = .russian
        case "uk":
            configLanguage = .ukrainian
        case "fr":
            configLanguage = .french
        case "es":
            configLanguage = .spanish
        case "pt":
            configLanguage = .portuguese
        case "de":
            configLanguage = .german
        case "ja":
            configLanguage = .japan
        case "pl":
            configLanguage = .poland
        case "it":
            configLanguage = .italy
        case "ro":
            configLanguage = .romania
        default:
            configLanguage = .english
        }
        return configLanguage
    }
    
    deinit {
        self.profileNotificationToken?.invalidate()
        self.deviceNotificationToken?.invalidate()
        self.stepNotificationToken?.invalidate()
        self.sleepNotificationToken?.invalidate()
        self.heartRateNotificationToken?.invalidate()
        self.spO2NotifacationToken?.invalidate()
        self.temperatureNotificationToken?.invalidate()
        self.bloodPressureNotificationToken?.invalidate()
        self.sportMotificationToken?.invalidate()
    }
}

// MARK: - SmartWatchS5InteractorInputProtocol
extension SmartWatchS5InteractorInput: SmartWatchS5InteractorInputProtocol {
    func startObserver() {
        self.registerToken()
    }

    /// Save step data
    /// - Parameters:
    ///   - step: `StepRecordModel`
    ///   - smartWatch: `DeviceModel`
    func saveStep(_ step: StepRecordModel, smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let stepList = stepListModelDAO.getObject(with: profile.id) {
            stepListModelDAO.update {
                // if time in today.
                if stepList.stepList[0].timestamp.toDate().isInToday {
                    
                        stepList.stepList[0] = step
                    
                    if step.goal != stepList.stepList[0].goal {
                        stepList.stepList[0].goal = step.goal
                    }
                } else {
                    // if not add a new day.
                    var exist = false
                    for data in stepList.stepList where data.dateTime == step.dateTime {
                        exist = true
                        break
                    }
                    if !exist {
                        stepList.stepList.insert(step, at: 0)
                    }
                }
            }
        } else {
            let stepList = StepListRecordModel(profile: profile, device: smartWatch, stepList: [step])
            self.stepListModelDAO.add(stepList)
        }
    }

    /// Save steps data
    /// - Parameters:
    ///   - steps: save list of `StepRecordModel`
    ///   - smartWatch: `DeviceModel`
    func saveSteps(_ steps: [StepRecordModel], smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        let stepList = StepListRecordModel(profile: profile, device: smartWatch, stepList: steps)
        self.stepListModelDAO.add(stepList)
    }

    /// Save hr data
    /// - Parameters:
    ///   - hr: S5HeartRateRecordModel
    ///   - smartWatch: DeviceModel
    func saveHR(_ hr: S5HeartRateRecordModel, smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else { return }
        
        if let hrList = heartRateListModelDAO.getObject(with: profile.id) {
            heartRateListModelDAO.update {
                if hrList.hrList[0].timestamp.toDate().isInToday {
                        hrList.hrList[0] = hr
                } else {
                    // check object existence
                    var exist = false
                    for data in hrList.hrList where data.dateTime == hr.dateTime {
                        exist = true
                        break
                    }
                    if !exist {
                        hrList.hrList.insert(hr, at: 0)
                    }
                }
            }
        } else {
            let hrList = S5HeartRateListRecordModel(profile: profile, device: smartWatch, hrList: [hr])
            self.heartRateListModelDAO.add(hrList)
        }
    }

    /// Save hr data
    /// - Parameters:
    ///   - hrs: save list of S5HeartRateRecordModel
    ///   - smartWatch: DeviceModel
    func saveHRList(_ hrs: [S5HeartRateRecordModel], smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        let hrList = S5HeartRateListRecordModel(profile: profile, device: smartWatch, hrList: hrs)
        self.heartRateListModelDAO.add(hrList)
    }

    /// save bp data
    /// - Parameters:
    ///   - bp: BloodPressureRecordModel
    ///   - smartWatch: DeviceModel
    func saveBloodPressure(_ bp: BloodPressureRecordModel, smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let bpList = self.bloodPressureListModelDAO.getObject(with: profile.id) {
            self.bloodPressureListModelDAO.update {
                if bpList.bloodPressureList[0].timestamp.toDate().isInToday {
                    
                        bpList.bloodPressureList[0] = bp
                    
                } else {
                    // check object existence
                    var exist = false
                    for tempData in bpList.bloodPressureList where tempData.dateTime == bp.dateTime {
                        exist = true
                        break
                    }
                    if !exist {
                        bpList.bloodPressureList.insert(bp, at: 0)
                    }
                }
            }
        } else {
            let bpList = BloodPressureListRecordModel(profile: profile, device: smartWatch, bloodPressureList: [bp])
            self.bloodPressureListModelDAO.add(bpList)
        }
    }

    /// save bp list data
    /// - Parameters:
    ///   - bps: list of BloodPressureRecordModel
    ///   - smartWatch: DeviceModel
    func saveBloodPressureList(_ bps: [BloodPressureRecordModel], smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        let bpList = BloodPressureListRecordModel(profile: profile, device: smartWatch, bloodPressureList: bps)
        self.bloodPressureListModelDAO.add(bpList)
    }
    
    /// save spO2 data
    /// - Parameters:
    ///   - spo2: S5SpO2RecordModel
    ///   - smartWatch: DeviceModel
    func saveSpO2(_ spo2: S5SpO2RecordModel, smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let spO2List = spO2ListModelDAO.getObject(with: profile.id) {
            spO2ListModelDAO.update {
                if spO2List.spO2List[0].timestamp.toDate().isInToday {
                
                        spO2List.spO2List[0] = spo2
                    
                } else {
                    // check object existence
                    var exist = false
                    for data in spO2List.spO2List where data.dateTime == spo2.dateTime {
                        exist = true
                        break
                    }
                    if !exist {
                        spO2List.spO2List.insert(spo2, at: 0)
                    }
                }
            }
        } else {
            let spO2 = S5SpO2ListRecordModel(profile: profile, device: smartWatch, spO2List: [spo2])
            self.spO2ListModelDAO.add(spO2)
        }
    }

    /// save spO2 List data
    /// - Parameters:
    ///   - spo2s: list of S5SpO2RecordModel
    ///   - smartWatch: Device
    func saveSpO2List(_ spo2s: [S5SpO2RecordModel], smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        let spO2 = S5SpO2ListRecordModel(profile: profile, device: smartWatch, spO2List: spo2s)
        self.spO2ListModelDAO.add(spO2)
    }

    /// save temp data
    /// - Parameters:
    ///   - temp: S5TemperatureRecordModel
    ///   - smartWatch: DeviceModel
    func saveTemp(_ temp: S5TemperatureRecordModel, smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let tempList = self.tempListModelDAO.getObject(with: profile.id) {
            tempListModelDAO.update {
                if tempList.tempList[0].timestamp.toDate().isInToday {
                    
                        tempList.tempList[0] = temp
                    
                        kNotificationCenter.post(name: .finishSaveData, object: nil, userInfo: nil)
                    
                } else {
                    // check object existence
                    var exist = false
                    for tempData in tempList.tempList where tempData.dateTime == temp.dateTime {
                        exist = true
                        break
                    }
                    if !exist {
                        tempList.tempList.insert(temp, at: 0)
                    }
                }
            }
        } else {
            let tempList = S5TemperatureListRecordModel(profile: profile, device: smartWatch, tempList: [temp])
            self.tempListModelDAO.add(tempList)
        }
    }
    
    /// save list temp data
    /// - Parameters:
    ///   - temps: list of S5TemperatureRecordModel
    ///   - smartWatch: DeviceModel
    func saveTempList(_ temps: [S5TemperatureRecordModel], smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        let tempList = S5TemperatureListRecordModel(profile: profile, device: smartWatch, tempList: temps)
        self.tempListModelDAO.add(tempList)
    }
    
    /// Save sleep data
    /// - Parameters:
    ///   - sleep: `SleepRecordModel`
    ///   - smartWatch: `DeviceModel`
    func saveSleep(_ sleep: SleepRecordModel, smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let sleepList = sleepListModelDAO.getObject(with: profile.id) {
            sleepListModelDAO.update {
                if sleepList.sleepList[0].timestamp.toDate().isInToday {
                    
                        sleepList.sleepList[0] = sleep
                    
                } else {
                    // check object existence
                    var exist = false
                    for data in sleepList.sleepList where data.dateTime == sleep.dateTime {
                        exist = true
                        break
                    }
                    if !exist && sleep.dateTime.toDate(.ymd)?.isInToday == true {
                        sleepList.sleepList.insert(sleep, at: 0)
                    }
                }
            }
        } else {
            let sleepList = SleepListRecordModel(profile: profile, device: smartWatch, sleepList: [sleep])
            self.sleepListModelDAO.add(sleepList)
        }
    }
 
    /// Save sleeps data
    /// - Parameters:
    ///   - sleeps: `[SleepRecordModel`]
    ///   - smartWatch: `DeviceModel`
    func saveSleeps(_ sleeps: [SleepRecordModel], smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        let sleepList = SleepListRecordModel(profile: profile, device: smartWatch, sleepList: sleeps)
        self.sleepListModelDAO.add(sleepList)
    }

    /// Save list sport
    /// - Parameters:
    ///   - sports: `[S5SportRecordModel]`
    ///   - smartWatch: `DeviceModel`
    func saveSports(_ sports: [S5SportRecordModel], smartWatch: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let sportList = self.sportListModelDAO.getObject(with: profile.id) {
            self.sportListModelDAO.update {
                sportList.sportList.insert(contentsOf: sports, at: 0)
            }
        } else {
            let sportList = S5SportListRecordModel(profile: profile, device: smartWatch, sportList: sports)
            self.sportListModelDAO.add(sportList)
        }
    }

    /// Stop scan devices
    func stopScan() {
        ZHJBLEManagerProvider.shared.stopScan()
    }

    /// Prepare BLE
    func bluetoothPrepare() {
        ZHJBLEManagerProvider.shared.bluetoothProviderManagerStateDidUpdate { [weak self] bleState in
            guard let `self` = self else { return }
            self.output?.bluetoothPrepare(state: bleState)
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
    
    /// find charactoristic
    func foundServerCharacteristics() {
        ZHJBLEManagerProvider.shared.discoverReadCharacteristic { _ in }
        ZHJBLEManagerProvider.shared.discoverWriteCharacteristic { [weak self] characteristic in
            guard let `self` = self else { return }
            self.output?.foundServerCharacteristics(characteristic)
        }
    }
    
    /// Read battery power
    func readBatteryPower() {
        batteryProcessor.readBatteryPower { [weak self] power in
            guard let `self` = self else { return }
            ZHJBLEManagerProvider.shared.currentDevice?.power = power
            self.output?.readBatteryPower(power)
        }
    }
    
    /// Read history step and sleep
    func readHistoryStepAndSleep(with value: Int) {
        self.output?.readHistoryStepAndSleep(with: value)
    }
    
    /// Read current heart rate
    func readCurrentHeartrate() {
        self.output?.readCurrentHeartrate()
    }
    
    /// Read history heart rate
    func readHistoryHeartrate() {
        self.output?.readHistoryHeartrate()
    }
    
    /// Read history temperature
    func readHistoryTemperature() {
        self.output?.readHistoryTemperature()
    }
    
    func syncTimeAndLanguage() {
        syncTimeProcessor.writeTime(ZHJSyncTime.init(Date())) {[weak self] (result) in
            guard let `self` = self else { return }
            guard result == .correct else {
                return
            }
            self.syncLanguage()
        }
    }
    
    /// Turn on save data
    func turnOnSaveData(with profileModel: ProfileModel) {
        let user = ZHJUserInfo()
        let birthday = profileModel.birthday!.toDate(.ymd)!
        let age = Date().year - birthday.year
        user.sex = profileModel.gender.value?.rawValue ?? 0
        user.height = Int(profileModel.height.value ?? 0)
        user.weight = Int(profileModel.weight.value ?? 0)
        user.age = age
        ZHJBLEManagerProvider.shared.setBodyInfo(gender: user.sex, age: user.age, height: CGFloat(user.height), weight: CGFloat(user.weight), calculateRMR: true)
        
        temperatureProcessor.setAutoDetectTemperature(interval: 10, isOn: true) {[weak self] (result) in
            guard let `self` = self else { return }
            guard result == .correct else {
                return
            }
            self.readBatteryPower()
        }
    }
}
