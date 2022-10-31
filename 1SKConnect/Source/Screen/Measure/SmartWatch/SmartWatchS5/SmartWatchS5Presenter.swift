//
//  
//  SmartWatchS5Presenter.swift
//  1SKConnect
//
//  Created by TrungDN on 07/12/2021.
//
//

import UIKit
import TrusangBluetooth

class SmartWatchS5Presenter {
    
    // MARK: - Properties
    weak var view: SmartWatchS5ViewProtocol?
    var intTimer = 0
    
    var smartWatch: DeviceModel!
    
    // MARK: - Private Properties
    private var interactor: SmartWatchS5InteractorInputProtocol
    private var router: SmartWatchS5RouterProtocol
    
    // user info
    private let userInfoProcessor = ZHJUserInfoProcessor()
    
    // step and sleep functions
    let stepAndSleepProcessor = ZHJStepAndSleepProcessor()
    private var sleepRecordModels: [ZHJSleep] = [ZHJSleep]()
    private var stepRecordModels: [ZHJStep] = [ZHJStep]()
    
    /// goalTarget
    private let goalTargetProcessor = ZHJSportTargetProcessor()
    
    /// temperature
    private let temperatureProcessor = ZHJTemperatureProcessor()
    
    /// sport
    private let sportModeProcessor = ZHJSportModeProcessor()
    
    /// read current vital sign
    private let HR_BP_BOProcessor = ZHJHR_BP_BOProcessor()
    
    /// Paỉr processor.
    private let pairProcesor: ZHJEnablePairProcessor = ZHJEnablePairProcessor()
    
    // DAO
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let stepListModelDAO = GenericDAO<StepListRecordModel>()
    private let sleepListModelDAO = GenericDAO<SleepListRecordModel>()
    private let heartRateListModelDAO = GenericDAO<S5HeartRateListRecordModel>()
    private let spO2ListModelDAO = GenericDAO<S5SpO2ListRecordModel>()
    private let bloodPressureListModelDAO = GenericDAO<BloodPressureListRecordModel>()
    private let temperatureListModelDAO = GenericDAO<S5TemperatureListRecordModel>()
    private var currentDistance: Double?
    private var currentKcal: Double?
    
    /// Delay time call S5 functions
    private var callDelayTime: Double = 0
    
    private var exercise: S5Exercise? {
        didSet {
            self.view?.reloadData(at: .exercise)
        }
    }
    
    private var hrList: S5HeartRateRecordModel? {
        didSet {
            self.view?.reloadData(at: .heartRate)
        }
    }
    
    private var spO2List: S5SpO2RecordModel? {
        didSet {
            self.view?.reloadData(at: .spO2)
        }
    }
    
    private var bloodPressureList: BloodPressureRecordModel? {
        didSet {
            self.view?.reloadData(at: .bloodPressure)
        }
    }
    
    private var temperatureList: S5TemperatureRecordModel? {
        didSet {
            kNotificationCenter.post(name: .finishSaveData, object: nil, userInfo: nil)
            self.view?.reloadData(at: .temperature)
        }
    }
    
    private var syntheticList: SyntheticData? {
        didSet {
            self.view?.reloadData(at: .synthetic)
        }
    }
    
    private var todySleepModel: SleepRecordModel? {
        didSet {
            self.view?.reloadData(at: .sleep)
        }
    }
    
    // MARK: - Initializer
    init(interactor: SmartWatchS5InteractorInputProtocol,
         router: SmartWatchS5RouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Deinitializer
    deinit {
        self.smartWatch = nil
        self.removeObserverBLEState()
    }
}

// MARK: - BLE Connection
extension SmartWatchS5Presenter {
    /// observer BLE state
    private func observerBLEState() {
        kNotificationCenter.addObserver(self, selector: #selector(deviceConnected(_:)), name: .NOTIFY_DEVICE_DID_CONNECT, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(deviceDisconnected(_:)), name: .NOTIFY_DEVICE_DID_DISCONNECT, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(timeout(_:)), name: .NOTIFY_BLE_DATA_TIMEOUT, object: nil)
    }
    
    /// remove observer BLE state
    private func removeObserverBLEState() {
        kNotificationCenter.removeObserver(self, name: .NOTIFY_DEVICE_DID_CONNECT, object: nil)
        kNotificationCenter.removeObserver(self, name: .NOTIFY_DEVICE_DID_DISCONNECT, object: nil)
        kNotificationCenter.removeObserver(self, name: .NOTIFY_BLE_DATA_TIMEOUT, object: nil)
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

// MARK: - Selectors
extension SmartWatchS5Presenter {
    @objc func deviceConnected(_ sender: Notification) {
        self.view?.updateView(with: true)
    }
    
    @objc func deviceDisconnected(_ sender: Notification) {
        dLogDebug("\(self.smartWatch.name) dissconnected")
        self.view?.updateView(with: false)
    }
    
    @objc func timeout(_ sender: Notification) {
        let obj = sender.userInfo
        if let dict = obj as? [String: Any], let api = dict["api"] as? ZHJBleApiCMD {
            switch api {
            case .readBatteryPower:
                dLogDebug("Read battery power timeout")
                self.interactor.readBatteryPower()
            case .readSportTarget:
                dLogDebug("Read target timeout")
                self.readGoalTarget()
            case .readCurrentStep:
                dLogDebug("Read current step power timeout")
                self.readCurrentStep()
            case .readStepAndSleepHistoryRecord:
                dLogDebug("Read current step power timeout")
                if let exercise = self.exercise {
                    self.interactor.readHistoryStepAndSleep(with: exercise.stepGoal)
                }
            case .enablePair:
                self.enablePair { [weak self] in
                    guard let `self` = self else { return }
                    self.interactor.readBatteryPower()
                }
            case .readCurrentHR_BP_BO:
                dLogDebug("Read current vital sign power timeout")
                self.interactor.readCurrentHeartrate()
            case .readHR_BP_BOHistoryRecord:
                dLogDebug("Read history vital sign power timeout")
                self.interactor.readHistoryHeartrate()
            case .readTemperatureHistoryRecord:
                dLogDebug("Read history temperature power timeout")
                self.interactor.readHistoryTemperature()
            default:
                break
            }
        }
    }
}

// MARK: - SmartWatchS5PresenterProtocol
extension SmartWatchS5Presenter: SmartWatchS5PresenterProtocol {
    func uploadData() {
    
    }
    
    func goToSleepDetail(with timeDefault: TimeFilterType) {
        self.router.goToSleepDetail(with: timeDefault)
    }
    
    func goToTemperatureDetail(with timeDefault: TimeFilterType) {
        self.router.goToTemperatureDetail(with: timeDefault)
    }
    
    func goToSpO2Detail(with timeDefault: TimeFilterType) {
        self.router.goToSpO2Detail(with: timeDefault)
    }
    
    func goToSetting() {
        self.router.goToSetting()
    }
    
    func refeshData() {
        kNotificationCenter.post(name: .reloadData, object: nil, userInfo: nil)
        if ZHJBLEManagerProvider.shared.btManager?.state == .poweredOn {
            self.interactor.readBatteryPower()
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.intTimer += 1
                if self.intTimer == 4 {
                    self.intTimer = 0
                    kNotificationCenter.post(name: .finishSaveData, object: nil, userInfo: nil)
                }
            }
        } else {
            kNotificationCenter.post(name: .finishSaveData, object: nil, userInfo: nil)
        }
    }
    
    func prepareToPushToExcerciseView(with timeDefault: TimeFilterType) {
        router.goToExerciseView(with: timeDefault, device: self.smartWatch)
        
    }
    
    var syntheticData: SyntheticData? {
        return self.syntheticList
    }
    
    var sleepModelData: SleepRecordModel? {
        return self.todySleepModel
    }
    
    var bloodPressureListData: BloodPressureRecordModel? {
        return self.bloodPressureList
    }
    
    var temperatureListData: S5TemperatureRecordModel? {
        return self.temperatureList
    }
    
    var hrListData: S5HeartRateRecordModel? {
        return self.hrList
    }
    
    var spO2ListData: S5SpO2RecordModel? {
        return self.spO2List
    }
    
    var exerciseData: S5Exercise? {
        return self.exercise
    }
    
    func onViewDidLoad() {
        self.interactor.startObserver()
        self.observerBLEState()
        self.scanForDevice()
    }
    
    /// handle navigation
    func goToBloodPressureDetail(with timeDefault: TimeFilterType) {
        self.router.goToBloodPressureDetail(with: timeDefault)
    }
    
    func goToHeartRateDetail(with timeDefault: TimeFilterType) {
        self.router.goToHeartRateDetail(with: timeDefault)
    }
}

// MARK: - Realm Data Change
extension SmartWatchS5Presenter {
    /// Sprot list change
    /// - Parameter data: `[S5SportRecordModel]`
    func onSportListChange(with data: [S5SportRecordModel]) {
        let filterList = data.filter({ $0.deviceMac == smartWatch.mac })
        var uniqueRecord = [S5SportRecordModel]()
        for post in filterList {
            if !uniqueRecord.contains(where: {$0.dateTime == post.dateTime }) {
                uniqueRecord.append(post)
            }
        }
        
        var sportDuration = 0
        var totalRun = 0
        var totalDistance = 0
        for sportData in uniqueRecord {
            if sportData.dateTime.toDate(.ymdhm)?.isInToday == true {
                sportDuration += sportData.duration
            }
            if sportData.dateTime.toDate(.ymdhm)!.timeIntervalSince1970 <= Date().timeIntervalSince1970 && sportData.dateTime.toDate(.ymdhm)!.timeIntervalSince1970 >= Date().timeIntervalSince1970 - 7 * 24 * 3600 {
                if sportData.type == .some(.run) {
                    totalRun += 1
                    totalDistance += sportData.distance
                }
            }
        }
        self.exercise?.sportDuration = sportDuration
        
        let totalRunString = totalRun == 0 ? "" : "\(totalRun)"
        let totalDistanceString = totalDistance == 0 ? "" : (Double(totalDistance) / 1000).toString()
        
        self.syntheticList?.run = "\(totalRunString)-\(totalDistanceString)"
    }
    
    /// Blood Pressure List Change
    /// - Parameter data: `[BloodPressureRecordModel]`
    func onBloodPressureListChange(with data: [BloodPressureRecordModel]) {
        if !data.isEmpty {
            let sevenDaysData = data.prefix(7)
            let todayData = sevenDaysData[0]
            var sysSigns: [VitalSign] = []
            var diaSigns: [VitalSign] = []
            for item in todayData.bloodPressureDetail {
                let sysSign = VitalSign(value: Double(item.sbp), timestamp: item.timestamp)
                let diaSign = VitalSign(value: Double(item.dbp), timestamp: item.timestamp)
                sysSigns.append(sysSign)
                diaSigns.append(diaSign)
            }
            if todayData.dateTime.toDate(.ymd)?.isInToday == true {
                let checkData = sevenDaysData.filter { $0.min.dbp != 0}
                let maxSys = (checkData.map { $0.max.sbp }.max() ?? 0).stringValue
                let minSys = (checkData.map { $0.min.sbp }.min() ?? 0).stringValue
                let maxDia = (checkData.map { $0.max.dbp }.max() ?? 0).stringValue
                let minDia = (checkData.map { $0.min.dbp }.min() ?? 0).stringValue
                if self.syntheticList == nil {
                    self.syntheticList = SyntheticData(run: "", step: "", calo: "", hr: "", spO2: "", bp: "\(minSys) - \(maxSys)/\(minDia) - \(maxDia)", temp: "", sleep: "")
                } else {
                    self.syntheticList?.bp = "\(minSys) - \(maxSys)/\(minDia) - \(maxDia)"
                }
                self.bloodPressureList = todayData
            } else {
                self.bloodPressureList = nil
            }
        }
    }
    
    func onTempListChange(with data: [S5TemperatureRecordModel]) {
        if !data.isEmpty {
            let sevenDaysData = data.prefix(7)
            let todayData = sevenDaysData[0]
            if todayData.dateTime.toDate(.ymd)?.isInToday == true {
                let checkData = sevenDaysData.filter { $0.min != 0 && $0.max != 0}
                let minAVGTemp = ((checkData.map { $0.min }.min() ?? 0) / 100).stringValue
                let maxAVGTemp = ((checkData.map { $0.max }.max() ?? 0) / 100).stringValue
                self.syntheticList?.temp = "\(minAVGTemp) - \(maxAVGTemp)"
                self.temperatureList = todayData
            }
        } else {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.intTimer += 1
                if self.intTimer == 4 {
                    self.intTimer = 0
                    kNotificationCenter.post(name: .finishSaveData, object: nil, userInfo: nil)
                }
            }
        }
    }
    
    func onSpo2ListChange(with data: [S5SpO2RecordModel]) {
        if !data.isEmpty {
            let sevenDaysData = data.prefix(7)
            let todayData = sevenDaysData[0]
            if todayData.dateTime.toDate(.ymd)?.isInToday == true {
                let averageBO = (sevenDaysData.map { $0.spO2AVG }.reduce(0, +) / sevenDaysData.count).stringValue
                if self.syntheticList == nil {
                    self.syntheticList = SyntheticData(run: "", step: "", calo: "", hr: "", spO2: averageBO, bp: "", temp: "", sleep: "")
                } else {
                    self.syntheticList?.spO2 = averageBO
                }
                self.spO2List = todayData
            } else {
                self.spO2List = nil
            }
        }
    }
    
    func onHeartRateListChange(with data: [S5HeartRateRecordModel]) {
        if !data.isEmpty {
            let sevenDaysHRData = data.prefix(7)
            let todayHRData = sevenDaysHRData[0]
            
            if todayHRData.dateTime.toDate(.ymd)?.isInToday == true {
                let averageHR = (sevenDaysHRData.map { $0.heartRateAVG }.reduce(0, +) / sevenDaysHRData.count).stringValue
                if self.syntheticList == nil {
                    self.syntheticList = SyntheticData(run: "", step: "", calo: "", hr: averageHR, spO2: "", bp: "", temp: "", sleep: "")
                } else {
                    self.syntheticList?.hr = averageHR
                }
                self.hrList = todayHRData
            } else {
                self.hrList = nil
            }
        }
    }
}

// MARK: - SmartWatchS5InteractorOutput
extension SmartWatchS5Presenter: SmartWatchS5InteractorOutputProtocol {
}

// MARK: - Scan and connect device
extension SmartWatchS5Presenter {
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
                dLogDebug("Smart watch connection failed")
                self.view?.updateView(with: false)
            } else {
                if peripheral != nil {
                    // success
                    dLogDebug("Smart watch connected")
                    self.view?.updateView(with: true)
                    self.interactor.foundServerCharacteristics()
                    self.interactor.stopScan()
                } else {
                    // timeout
                    self.view?.updateView(with: false)
                    dLogDebug("Smart watch timeout")
                }
            }
        }
    }
    
    func foundServerCharacteristics(_ characteristic: CBCharacteristic) {
        delay(by: self.callDelayTime) {
            guard let currentProfile = self.profileListDAO.getFirstObject()?.currentProfile else {
                return
            }
            delay(by: self.callDelayTime) {
                self.enablePair { [weak self] in
                    guard let `self` = self else { return }
                    self.interactor.turnOnSaveData(with: currentProfile)
                }
            }
        }
    }
}

// MARK: - Enable pair
extension SmartWatchS5Presenter {
    private func enablePair(completion: @escaping () -> Void) {
        self.pairProcesor.enablePair { errors in
            guard errors == .correct else {
                return
            }
            completion()
        }
    }
}

// MARK: - Read Battery Power
extension SmartWatchS5Presenter {
    func readBatteryPower(_ power: Int) {
        self.view?.updateBattery(at: power)
        delay(by: self.callDelayTime) {
            self.readGoalTarget()
        }
    }
}

// MARK: - Read Sport Target
extension SmartWatchS5Presenter {
    func readGoalTarget() {
        self.readTargetData()
    }
    
    private func readTargetData() {
        self.goalTargetProcessor.readSportTarget { [weak self] (goal) in
            guard let `self` = self else { return }
            SKUserDefaults.shared.currentStepGoal = goal.stepTarget.value
            self.exercise?.stepGoal = goal.stepTarget.value
            delay(by: self.callDelayTime) {
                self.readCurrentStep()
            }
        }
    }
    
    private func readCurrentStep() {
        self.stepAndSleepProcessor.readCurrentStep { [weak self] step in
            guard let `self` = self else { return }
            self.currentKcal = step.calories
            self.currentDistance = step.distance / 1000
            self.exercise?.kcal = step.calories
            self.exercise?.distance = step.distance / 1000
            if let exercise = self.exercise {
                delay(by: self.callDelayTime) {
                    self.interactor.readHistoryStepAndSleep(with: exercise.stepGoal)
                }
            }
        }
    }
}

// MARK: - Handle Sleep and step data
extension SmartWatchS5Presenter {
    /// Step sleep list change
    /// - Parameter data: `[SleepRecordModel]`
    func onSleepListChage(with data: [SleepRecordModel]) {
        if !data.isEmpty {
            let svenDaysSleepData = data.prefix(7)
            let todaySleepData = svenDaysSleepData[0]
            if todaySleepData.dateTime.toDate(.ymd)?.isInToday == true {
                self.todySleepModel = todaySleepData
            } else {
                self.todySleepModel = nil
            }
            
            let averageSleep = (svenDaysSleepData.map { $0.awakeDuration + $0.beginDuration + $0.lightDuration + $0.deepDuration + $0.remDuration }.reduce(0, +) / svenDaysSleepData.count).stringValue
            self.syntheticList?.sleep = averageSleep
        }
    }
    
    /// Step list change on database
    /// - Parameter data: `[StepRecordModel]`
    func onStepListChage(with data: [StepRecordModel]) {
        if !data.isEmpty {
            let svenDaysStepData = data.prefix(7)
            let todayStepData = svenDaysStepData[0]
            if todayStepData.dateTime.toDate(.ymd)?.isInToday == true {
                let averageStep = (svenDaysStepData.map { $0.totalStep }.reduce(0, +) / svenDaysStepData.count).stringValue
                let averageCalo = (svenDaysStepData.map { Int($0.totalCalories) }.reduce(0, +) / svenDaysStepData.count).stringValue
                if self.syntheticList == nil {
                    self.syntheticList = SyntheticData(run: "", step: averageStep, calo: averageCalo, hr: "", spO2: "", bp: "", temp: "", sleep: "")
                } else {
                    self.syntheticList?.step = averageStep
                    self.syntheticList?.calo = averageCalo
                }
                self.exercise = S5Exercise(step: todayStepData.totalStep,
                                           stepGoal: SKUserDefaults.shared.currentStepGoal,
                                           kcal: self.currentKcal ?? 0,
                                           distance: currentDistance ?? 0,
                                           duration: todayStepData.duration,
                                           sportDuration: 0,
                                           heartRate: 0,
                                           detail: self.handleExerciseDetailData(stepRecordModelDetail: todayStepData.stepDetail.array))
            } else {
                self.exercise = S5Exercise(step: 0,
                                           stepGoal: SKUserDefaults.shared.currentStepGoal,
                                           kcal: 0,
                                           distance: 0,
                                           duration: 0,
                                           sportDuration: 0,
                                           heartRate: 0,
                                           detail: [])
            }
        } else {
            self.exercise = S5Exercise(step: 0,
                                       stepGoal: SKUserDefaults.shared.currentStepGoal,
                                       kcal: 0,
                                       distance: 0,
                                       duration: 0,
                                       sportDuration: 0,
                                       heartRate: 0,
                                       detail: [])
        }
    }
    
    /// Read step and sleep
    /// - Parameter value: number of days
    func readHistoryStepAndSleep(with value: Int) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if stepListModelDAO.getObject(with: profile.id) != nil {
            self.readStepAndSleepData(for: 1, and: value)
        } else {
            if sleepListModelDAO.getObject(with: profile.id) != nil {
                self.readStepAndSleepData(for: 1, and: value)
            } else {
                self.readStepAndSleepData(for: 7, and: value)
            }
        }
    }
    
    /// Read step and sleep data
    /// - Parameter days: for days
    private func readStepAndSleepData(for days: Int, and goal: Int) {
        sleepRecordModels.removeAll()
        stepRecordModels.removeAll()
        let stepAndSleepSemaphore = DispatchSemaphore(value: 0)
        var dataSyncDone = 0
        let stepAndSleepQueue = DispatchQueue.init(label: "BRANCH_STEP_SLEEP")
        
        for i in 0 ..< days {
            let date = DateClass.dateStringOffset(from: today, offset: -i)
            stepAndSleepQueue.async {
                if dataSyncDone == 1 {
                    return
                }
                self.stepAndSleepProcessor.readStepAndSleepHistoryRecord(date: date, historyDataHandle: {[weak self] (stepModel, sleepModel) in
                    guard let `self` = self else { return }
                    if stepModel.step != 0 {
                        self.stepRecordModels.append(stepModel)
                    }
                    self.sleepRecordModels.append(sleepModel)
                    if sleepModel.details.count > 0 {
                        self.mergeSleepWithDB(sleeps: sleepModel.splitSleep())
                    }
                    stepAndSleepSemaphore.signal()
                    if i == days - 1 {
                        dataSyncDone = 1
                        self.handleStepAndSleepData(with: goal)
                        delay(by: self.callDelayTime) {
                            self.interactor.readCurrentHeartrate()
                        }
                    }
                }, historyDoneHandle: { [weak self] _ in
                    guard let `self` = self else { return }
                    stepAndSleepSemaphore.signal()
                    dataSyncDone = 1
                    self.handleStepAndSleepData(with: goal)
                    delay(by: self.callDelayTime) {
                        self.interactor.readCurrentHeartrate()
                    }
                })
                stepAndSleepSemaphore.wait()
            }
        }
    }
    
    /// Handle step and sleep data
    /// - Parameter goal: save data with goal
    private func handleStepAndSleepData(with goal: Int) {
        if !self.stepRecordModels.isEmpty {
            if self.stepRecordModels.count > 1 {
                var stepRecordModels: [StepRecordModel] = []
                for data in self.stepRecordModels {
                    let stepRecordModel = StepRecordModel(with: data, and: goal, of: self.smartWatch)
                    stepRecordModels.append(stepRecordModel)
                }
                self.interactor.saveSteps(stepRecordModels, smartWatch: self.smartWatch)
            } else {
                let todayData = self.stepRecordModels[0]
                let stepRecordModel = StepRecordModel(with: todayData, and: goal, of: self.smartWatch)
                self.interactor.saveStep(stepRecordModel, smartWatch: self.smartWatch)
            }
        }
        
        // remove record where duration = 0
        let checkedRecord = self.sleepRecordModels.filter({ ($0.awakeDuration + $0.beginDuration + $0.lightDuration + $0.deepDuration + $0.REMDuration) != 0 })
        
        // sort day data.
        let sortedRecord = checkedRecord.sorted { $0.dateTime.toDate(.ymd)! > $1.dateTime.toDate(.ymd)! }
        
        if !sortedRecord.isEmpty {
            if sortedRecord.count > 1 {
                var sleepRecordModels: [SleepRecordModel] = []
                for data in sortedRecord where !data.dateTime.toDate(.ymd)!.isInTomorrow {
                    let sleepRecordModel = SleepRecordModel(with: data, of: self.smartWatch)
                    sleepRecordModels.append(sleepRecordModel)
                }
                self.interactor.saveSleeps(sleepRecordModels, smartWatch: self.smartWatch)
            } else {
                let todayData = sortedRecord[0]
                let sleepRecordModel = SleepRecordModel(with: todayData, of: self.smartWatch)
                self.interactor.saveSleep(sleepRecordModel, smartWatch: self.smartWatch)
            }
        }
    }
}

// MARK: - Handle Vital Sign Data
extension SmartWatchS5Presenter {
    func readCurrentHeartrate() {
        HR_BP_BOProcessor.readCurrentHR_BP_BO { [weak self] (heartrateModel, _, _) in
            guard let `self` = self else {return}
            self.exercise?.heartRate = heartrateModel.HR
            delay(by: self.callDelayTime) {
                self.interactor.readHistoryHeartrate()
            }
        }
    }
    
    func readHistoryHeartrate() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if self.heartRateListModelDAO.getObject(with: profile.id) != nil &&
            self.bloodPressureListModelDAO.getObject(with: profile.id) != nil &&
            self.spO2ListModelDAO.getObject(with: profile.id) != nil {
            self.readVitalSign(for: 1)
        } else {
            self.readVitalSign(for: 7)
        }
    }
    
    private func readVitalSign(for days: Int) {
        var hrRecordModels: [ZHJHeartRate] = [ZHJHeartRate]()
        var bpRecordModels: [ZHJBloodPressure] = [ZHJBloodPressure]()
        var boRecordModels: [ZHJBloodOxygen] = [ZHJBloodOxygen]()
        
        var dataSyncDone = 0
        let HR_BP_BOSemaphore = DispatchSemaphore(value: 0)
        let HR_BP_BOQueue = DispatchQueue.init(label: "BRANCH_HR_BP_BO")
        
        // get 7 days latest
        for i in 0 ..< days {
            let date = DateClass.dateStringOffset(from: today, offset: -i)
            HR_BP_BOQueue.async {
                if dataSyncDone == 1 {
                    return
                }
                self.HR_BP_BOProcessor.readHR_BP_BOHistoryRecord(date, historyDataHandle: { [weak self] (HRModel, BPModel, BOModel) in
                    guard let `self` = self else { return }
                    
                    if HRModel.avg != 0 {
                        hrRecordModels.append(HRModel)
                    }
                    
                    if BPModel.avg.SBP != 0 && BPModel.avg.DBP != 0 {
                        bpRecordModels.append(BPModel)
                    }
                    
                    if BOModel.avg != 0 {
                        boRecordModels.append(BOModel)
                    }
                    
                    HR_BP_BOSemaphore.signal()
                    if i == days - 1 {
                        dataSyncDone = 1
                        self.handleVitalSignData(hrRecordModels: hrRecordModels, bpRecordModels: bpRecordModels, boRecordModels: boRecordModels)
                        delay(by: self.callDelayTime) {
                            self.interactor.readHistoryTemperature()
                        }
                    }
                }, historyDoneHandle: { [weak self] _ in
                    guard let `self` = self else { return }
                    HR_BP_BOSemaphore.signal()
                    dataSyncDone = 1
                    
                    self.handleVitalSignData(hrRecordModels: hrRecordModels, bpRecordModels: bpRecordModels, boRecordModels: boRecordModels)
                    delay(by: self.callDelayTime) {
                        self.interactor.readHistoryTemperature()
                    }
                })
                HR_BP_BOSemaphore.wait()
            }
        }
    }
    
    /// handle vital sign data
    /// - Parameters:
    ///   - hrRecordModels: `[ZHJHeartRate]`
    ///   - bpRecordModels: `[ZHJBloodPressure]`
    ///   - boRecordModels: `[ZHJBloodOxygen]`
    private func handleVitalSignData(hrRecordModels: [ZHJHeartRate], bpRecordModels: [ZHJBloodPressure], boRecordModels: [ZHJBloodOxygen]) {
        
        if !bpRecordModels.isEmpty {
            if bpRecordModels.count > 1 {
                var bloodPressureRecordModels: [BloodPressureRecordModel] = []
                for data in bpRecordModels {
                    let bloodPressureRecordModel = BloodPressureRecordModel(with: data, of: self.smartWatch)
                    bloodPressureRecordModels.append(bloodPressureRecordModel)
                }
                self.interactor.saveBloodPressureList(bloodPressureRecordModels, smartWatch: self.smartWatch)
            } else {
                let todayData = bpRecordModels[0]
                let bloodPressureRecordModel = BloodPressureRecordModel(with: todayData, of: self.smartWatch)
                self.interactor.saveBloodPressure(bloodPressureRecordModel, smartWatch: self.smartWatch)
            }
        }
        if !boRecordModels.isEmpty {
            if boRecordModels.count > 1 {
                var spO2RecordModels: [S5SpO2RecordModel] = []
                for data in boRecordModels {
                    let spO2RecordModel = S5SpO2RecordModel(with: data, of: self.smartWatch)
                    spO2RecordModels.append(spO2RecordModel)
                }
                self.interactor.saveSpO2List(spO2RecordModels, smartWatch: self.smartWatch)
            } else {
                let todayData = boRecordModels[0]
                let spO2RecordModel = S5SpO2RecordModel(with: todayData, of: self.smartWatch)
                self.interactor.saveSpO2(spO2RecordModel, smartWatch: self.smartWatch)
            }
        }
        
        if !hrRecordModels.isEmpty {
            if hrRecordModels.count > 1 {
                var hearRateRecordModels: [S5HeartRateRecordModel] = []
                for data in hrRecordModels {
                    let heartRecordModel = S5HeartRateRecordModel(with: data, of: self.smartWatch)
                    hearRateRecordModels.append(heartRecordModel)
                }
                self.interactor.saveHRList(hearRateRecordModels, smartWatch: self.smartWatch)
            } else {
                let todayData = hrRecordModels[0]
                let heartRecordModel = S5HeartRateRecordModel(with: todayData, of: self.smartWatch)
                self.interactor.saveHR(heartRecordModel, smartWatch: self.smartWatch)
            }
        }
    }
}

// MARK: - Handle Temperature Data
extension SmartWatchS5Presenter {
    func readHistoryTemperature() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if temperatureListModelDAO.getObject(with: profile.id) != nil {
            // get 1 day
            self.readTemperaturepData(for: 1)
        } else {
            // get seven days
            self.readTemperaturepData(for: 7)
        }
    }
    
    func readTemperaturepData(for days: Int) {
        var temperatureModels: [ZHJTemperature] = [ZHJTemperature]()
        var dataSyncDone = 0
        let temperatureSemaphore = DispatchSemaphore(value: 0)
        let temperatureQueue = DispatchQueue.init(label: "BRANCH_TEMPERATURE")
        for i in 0 ..< days {
            let date = DateClass.dateStringOffset(from: today, offset: -i)
            temperatureQueue.async {
                if dataSyncDone == 1 {
                    return
                }
                self.temperatureProcessor.readTemperatureHistoryRecord(date, historyDataHandle: {[weak self] (temperatureModel) in
                    guard let `self` = self else { return }
                    
                    if temperatureModel.avg != 0 {
                        temperatureModels.append(temperatureModel)
                    }
                    
                    temperatureSemaphore.signal()
                    if i == days - 1 {
                        dataSyncDone = 1
                        self.handleTemperatureData(with: temperatureModels)
                        delay(by: self.callDelayTime) {
                            self.interactor.syncTimeAndLanguage()
                        }
                    }
                }, historyDoneHandle: { [weak self] _ in
                    guard let `self` = self else { return }
                    temperatureSemaphore.signal()
                    dataSyncDone = 1
                    self.handleTemperatureData(with: temperatureModels)
                    delay(by: self.callDelayTime) {
                        self.interactor.syncTimeAndLanguage()
                    }
                })
                temperatureSemaphore.wait()
            }
        }
    }
    
    /// handle temperature data
    /// - Parameter temperatureModels: `[ZHJTemperature]`
    private func handleTemperatureData(with temperatureModels: [ZHJTemperature]) {
        if !temperatureModels.isEmpty {
            if temperatureModels.count > 1 {
                var tempRecordModels: [S5TemperatureRecordModel] = []
                for data in temperatureModels {
                    let tempRecordModel = S5TemperatureRecordModel(with: data, of: self.smartWatch)
                    tempRecordModels.append(tempRecordModel)
                }
                self.interactor.saveTempList(tempRecordModels, smartWatch: self.smartWatch)
            } else {
                let todayData = temperatureModels[0]
                let tempRecordModel = S5TemperatureRecordModel(with: todayData, of: self.smartWatch)
                self.interactor.saveTemp(tempRecordModel, smartWatch: self.smartWatch)
            }
        }
    }
}

// MARK: - Handle sport data
extension SmartWatchS5Presenter {
    func readHistorySport() {
        var sportRecordModels: [ZHJSportMode] = [ZHJSportMode]()
        var sportDataSyncDone = 0
        let sportSemaphore = DispatchSemaphore(value: 0)
        let sportQueue = DispatchQueue.init(label: "BRANCH_SPORT")
        for _ in 0 ..< 5 {
            sportQueue.async {
                if sportDataSyncDone == 1 {
                    return
                }
                self.sportModeProcessor.readSportModeHistoryRecord(sportModeHandle: { (sportModel) in
                    if let model = sportModel {
                        sportRecordModels.append(model)
                    }
                    sportSemaphore.signal()
                }, historyDoneHandle: { [weak self] _ in
                    guard let `self` = self else { return }
                    sportDataSyncDone = 1
                    sportSemaphore.signal()
                    self.handleSprotData(sports: sportRecordModels)
                })
                sportSemaphore.wait()
            }
        }
    }
    
    /// Handle sport data
    /// - Parameter sports: `[ZHJSportMode]`
    private func handleSprotData(sports: [ZHJSportMode]) {
        var uniqueRecord = [ZHJSportMode]()
        for post in sports {
            if !uniqueRecord.contains(where: { $0.dateTime == post.dateTime }) {
                uniqueRecord.append(post)
            }
        }
        
        if !uniqueRecord.isEmpty {
            var sportRecords: [S5SportRecordModel] = []
            for model in sports {
                let sportRecord = S5SportRecordModel(sport: model, of: self.smartWatch)
                sportRecords.append(sportRecord)
            }
            self.interactor.saveSports(sportRecords, smartWatch: self.smartWatch)
        }
        
        self.uploadData()
    }
}

// MARK: - Helpers
extension SmartWatchS5Presenter {
    private func syncUserInfo() {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile, let birthday = currentProfile.birthday?.toDate(.ymd) else {
            return
        }
        let user = ZHJUserInfo()
        let age = Date().year - birthday.year
        user.sex = currentProfile.gender.value?.rawValue ?? 0
        user.height = Int(currentProfile.height.value ?? 0)
        user.weight = Int(currentProfile.weight.value ?? 0)
        user.age = age
        self.userInfoProcessor.writeUserInfo(user) { result in
            guard result == .correct else {
                return
            }
        }
    }
    
    /// merge sleep data
    /// - Parameter sleeps: `[ZHJSleep]`
    private func mergeSleepWithDB(sleeps: [ZHJSleep]) {
        var yesterdayModel = sleeps.first!
        var todayModel = sleeps.last!
        let modelsA = sleepRecordModels.filter { $0.dateTime == yesterdayModel.dateTime }
        sleepRecordModels.removeAll { $0.dateTime == yesterdayModel.dateTime }
        let replaceDateA = DateClass.getTimeStrToDate(.ymdhm, timeStr: yesterdayModel.dateTime + " 00:00")
        if let model = modelsA.first {
            var details = model.details
            details = details.filter { DateClass.getTimeStrToDate(.ymdhm, timeStr: $0.dateTime) < replaceDateA }
            details.append(contentsOf: yesterdayModel.details)
            model.details = details
            model.countingSleepTypeDuration()
            yesterdayModel = model
        }
        
        sleepRecordModels.append(yesterdayModel)
        
        let modelsB = sleepRecordModels.filter { $0.dateTime == todayModel.dateTime }
        sleepRecordModels.removeAll { $0.dateTime == todayModel.dateTime }
        // Replacement time
        let replaceDateB = DateClass.getTimeStrToDate(.ymdhm, timeStr: yesterdayModel.dateTime + " 23:59")
        if let model = modelsB.first {
            var details = model.details
            model.details.removeAll()
            // Filter out data before 23:59 of the day
            details = details.filter { DateClass.getTimeStrToDate(.ymdhm, timeStr: $0.dateTime) > replaceDateB }
            // Replacement
            model.details.append(contentsOf: todayModel.details)
            model.details.append(contentsOf: details)
            model.countingSleepTypeDuration()
            todayModel = model
        }
        sleepRecordModels.append(todayModel)
    }
    
    /// Handle show step data
    /// - Parameter stepRecordModelDetail: `[StepDetailModel]`
    /// - Returns: `[ExerciseDetail]`
    private func handleExerciseDetailData(stepRecordModelDetail: [StepDetailModel]) -> [ExerciseDetail] {
        var exerciseDetail: [ExerciseDetail] = []
        if !stepRecordModelDetail.isEmpty {
            for detail in stepRecordModelDetail where detail.step != 0 {
                let time = detail.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
                let stepDetail = ExerciseDetail(stepValue: detail.step, timestamp: time)
                exerciseDetail.append(stepDetail)
            }
        }
        return exerciseDetail
    }
}
