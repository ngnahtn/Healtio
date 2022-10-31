//
//  
//  SpO2Presenter.swift
//  1SKConnect
//
//  Created by Be More on 1/10/2021.
//
//

import UIKit
import CoreBluetooth
import SwiftyJSON
import VTO2Lib

class SpO2Presenter: NSObject {
    var spO2: DeviceModel!
    private var writeCharacteristic: CBCharacteristic!
    private var currentResponse: ViatomResponse?
    private lazy var peripheral = BluetoothManager.shared.peripheral(for: self.spO2)
    var fileToLoad: [String] = []

    /// file count from 0 max is 4
    var fileCount = 0

    private var currentType: TimeFilterType = .day

    /// save the spO2 waveform data in realm data base.
    private var waveformModel = [WaveformModel]()
    private var waveformListModel = [WaveformListModel]()

    weak var view: SpO2ViewProtocol?
    private var interactor: SpO2InteractorInputProtocol
    private var router: SpO2RouterProtocol

    init(interactor: SpO2InteractorInputProtocol,
         router: SpO2RouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    deinit {
        kNotificationCenter.removeObserver(self, name: .deviceConnectionChanged, object: nil)
        kNotificationCenter.removeObserver(self, name: .bleStateChanged, object: nil)
        kNotificationCenter.removeObserver(self, name: .updateSpO2Data, object: nil)
    }
}

// MARK: - SpO2PresenterProtocol
extension SpO2Presenter: SpO2PresenterProtocol {
    func onDeleteItem(at index: IndexPath) {
        let waveform = self.waveformListModel[index.row]
        self.interactor.onDeleteWaveformListModel(waveform)
    }

    var device: DeviceModel {
        return self.spO2
    }

    func tableViewDidSelect(rowAt indexPath: IndexPath) {
        if indexPath.row > self.waveformListModel.count {
            return
        }
        guard !self.waveformListModel[indexPath.row].waveforms.array.isEmpty else { return }
        self.router.goToSpO2DetailValue(with: self.waveformListModel[indexPath.row])
    }

    func tableViewNumberOfRows() -> Int {
        self.waveformListModel.count
    }

    func tableWaveformFor(rowAt indexPath: IndexPath) -> WaveformListModel? {
        if indexPath.row > self.waveformListModel.count {
            return nil
        }
        return self.waveformListModel[indexPath.row]
    }

    var isConnected: Bool {
        return BluetoothManager.shared.isConnect(with: self.spO2)
    }

    func onFilterViewDidSelected(_ filterViewType: TimeFilterType) {
        self.currentType = filterViewType
        let graphData = getGraphData(of: filterViewType)
        self.view?.updateGraphView(times: [], type: self.currentType)
        self.view?.updateGraphView(with: graphData, timeType: self.currentType, deviceType: self.spO2.type)
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

    func onViewDidLoad() {
        self.observerBLEState()
        self.interactor.registerToken()
        self.getFileData()
    }

    func onButtonMeasurementDidTapped(stop: Bool) {
        if stop {
            BluetoothManager.shared.stopSpo2Timer(self.spO2)
            self.view?.setStopMeasuring()
        } else {
            if SpO2DataHandler.shared.measuringProfile != nil {
                BluetoothManager.shared.stopSpo2Timer(self.spO2)
            }
            self.sendWaveformCommand(.waveformData, packetNumber: 1, data: [0, 0])
        }
    }
}

// MARK: - SpO2InteractorOutputProtocol
extension SpO2Presenter: SpO2InteractorOutputProtocol {
    func onSpo2DataListChange(waveforms: [WaveformListModel]) {
        if !self.waveformModel.isEmpty {
            self.waveformModel.removeAll()
        }
        self.waveformListModel = waveforms
        for waveform in waveformListModel where !waveform.waveforms.array.isEmpty {
            self.waveformModel.append(contentsOf: waveform.waveforms.array)
        }
        let graphData = getGraphData(of: self.currentType)
        self.view?.updateGraphView(times: [], type: self.currentType)
        self.view?.updateGraphView(with: graphData, timeType: self.currentType, deviceType: self.spO2.type)
        self.view?.reloadTableViewData()
    }
}

// MARK: - Helpers
extension SpO2Presenter {
    private func checkBLEAvailble() -> Bool {
        let isBLEAvailable = BluetoothManager.shared.checkBluetoothStatusAvailble()
        if !isBLEAvailable {
            switch BluetoothManager.shared.centralManager.state {
            case .poweredOff:
                router.showTurnOnBleAlert()
            case .unauthorized:
                router.showTurnOnBleAlert()
            default:
                break
            }
        }
        return isBLEAvailable
    }

    private func observerBLEState() {
        kNotificationCenter.addObserver(self, selector: #selector(onDeviceConnectionChanged(_:)), name: .deviceConnectionChanged, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(onBleStateChanged(_:)), name: .bleStateChanged, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(onUpdateSpO2Data(_:)), name: .updateSpO2Data, object: nil)
    }
}

// MARK: - Selectors
extension SpO2Presenter {
    @objc func onDeviceConnectionChanged(_ sender: Notification) {
        guard let mac = sender.userInfo?[SKKey.mac] as? String,
              self.spO2?.mac == mac else {
            return
        }
        if self.isConnected {
            view?.setIndicatorHidden(true)
            BluetoothManager.shared.discoverServices(serviceUUIDs: nil, of: self.spO2)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                VTBLEUtils.sharedInstance().startScan()
            }
        }
        view?.updateConnectState(self.isConnected)
    }

    @objc func onBleStateChanged(_ sender: Notification) {
        if !BluetoothManager.shared.checkBluetoothStatusAvailble() {
            if SpO2DataHandler.shared.spO2Status == .measuring {
                BluetoothManager.shared.stopSpo2Timer(self.spO2)
            }
        } else {
            VTBLEUtils.sharedInstance().startScan()
        }
    }

    @objc func onUpdateSpO2Data(_ sender: Notification) {
        guard let dictionary = sender.userInfo else {
            return
        }
        let viatomRealTimeWaveform = ViatomRealTimeWaveform(JSON(dictionary))
        self.view?.updateData(with: viatomRealTimeWaveform)
    }
}

// MARK: - Helpers
extension SpO2Presenter {
    /// Get spO2 device infor
    private func getFileData() {
        VTBLEUtils.sharedInstance().delegate = self
        if SpO2DataHandler.shared.spO2Status == .stop {
            if isConnected {
                BluetoothManager.shared.disConnectDevice(self.spO2)
            } else {
                BluetoothManager.shared.stopScan()
                VTBLEUtils.sharedInstance().startScan()
            }
        }
    }

    /// Send write command to peripheral
    /// - Parameters:
    ///   - command: `ViatomCommand`
    ///   - packetNumber: packet number
    ///   - data: data
    ///   - type: write type
    private func sendCommand(_ command: ViatomCommand.Command, packetNumber: Int, data: [UInt8], type: CBCharacteristicWriteType = .withoutResponse) {
        let request = ViatomCommand(command: command, packetNumber: packetNumber, data: data)
        guard let peripheral = self.peripheral, let writeCharacteristic = SpO2DataHandler.shared.spO2PeripheralGlobalDelegate.writeWithoutResponseCharacteristic.first else {
            return
        }
        BluetoothManager.shared.sendCommand(peripheral, request, to: writeCharacteristic, type: type)
    }

    /// Send command start measuring spO2 wavefom
    /// - Parameters:
    ///   - command: `ViatomCommand`
    ///   - packetNumber: packet number
    ///   - data: data
    private func sendWaveformCommand(_ command: ViatomCommand.Command, packetNumber: Int, data: [UInt8]) {
        let request = ViatomCommand(command: command, packetNumber: packetNumber, data: data)
        guard let peripheral = self.peripheral else {
            return
        }
        BluetoothManager.shared.starSpO2Measuring(peripheral, request)
    }

    private func getGraphData(of type: TimeFilterType) -> [[[WaveformModel]]] {
        var joinedArray: [[[WaveformModel]]] = []
        switch type {
        case .day:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { waveform, waveforms in
                return waveform.timeCreated.toDate().isSameHour(with: waveforms.last!.timeCreated.toDate())
            }, isSameLargeGroup: { waveforms, listWaveforms in
                return waveforms.last!.timeCreated.toDate().isSameDay(with: listWaveforms.last!.last!.timeCreated.toDate())
            })
        case .week:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { waveform, waveforms in
                return waveform.timeCreated.toDate().isSameDay(with: waveforms.last!.timeCreated.toDate())
            }, isSameLargeGroup: { waveforms, listWaveforms in
                return waveforms.last!.timeCreated.toDate().isInSameWeek(as: listWaveforms.last!.last!.timeCreated.toDate())
            })
        case .month:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { waveform, waveforms in
                return waveform.timeCreated.toDate().isSameDay(with: waveforms.last!.timeCreated.toDate())
            }, isSameLargeGroup: { waveforms, listWaveforms in
                return waveforms.last!.timeCreated.toDate().isSameMonth(with: listWaveforms.last!.last!.timeCreated.toDate())
            })
        case .year:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { waveform, waveforms in
                return waveform.timeCreated.toDate().isSameMonth(with: waveforms.last!.timeCreated.toDate())
            }, isSameLargeGroup: { waveforms, listWaveforms in
                return waveforms.last!.timeCreated.toDate().isInSameYear(as: listWaveforms.last!.last!.timeCreated.toDate())
            })
        }
        return joinedArray
    }

    /// Sort WaveformModel
    /// - Parameters:
    ///   - isSameSmallGroup: is in same small date group
    ///   - isSameLargeGroup: is in same large date group
    /// - Returns: sorted array
    private func processDataForGraphView(isSameSmallGroup: (WaveformModel, [WaveformModel]) -> Bool, isSameLargeGroup: ([WaveformModel], [[WaveformModel]]) -> Bool) -> [[[WaveformModel]]] {
        var joinedArray: [[[WaveformModel]]] = []
        var largeTemp: [[WaveformModel]] = []
        var smallTemp: [WaveformModel] = []
        for waveform in waveformModel.reversed() {
            if !smallTemp.isEmpty {
                if isSameSmallGroup(waveform, smallTemp) {
                    smallTemp.append(waveform)
                } else {
                    largeTemp.append(smallTemp)
                    smallTemp = [waveform]
                }
            } else { // temp empty
                smallTemp.append(waveform)
            }
        }
        if !smallTemp.isEmpty {
            largeTemp.append(smallTemp)
        }

        var temp: [[WaveformModel]] = []
        for listWaveform in largeTemp {
            if !temp.isEmpty {
                if isSameLargeGroup(listWaveform, temp) {
                    temp.append(listWaveform)
                } else {
                    joinedArray.append(temp)
                    temp = [listWaveform]
                }
            } else { // temp empty
                temp.append(listWaveform)
            }
        }

        if !temp.isEmpty {
            joinedArray.append(temp)
        }

        return joinedArray
    }
}

// MARK: - VTBLEUtilsDelegate
extension SpO2Presenter: VTBLEUtilsDelegate {
    func update(_ state: VTBLEState) {
        if state == .poweredOn {
            BluetoothManager.shared.stopScan()
            VTBLEUtils.sharedInstance().startScan()
        }
    }

    func didDiscover(_ device: VTDevice) {
        self.view?.loadFileView(hide: false, of: self.device)
        if self.spO2.mac == device.rawPeripheral.mac {
            VTBLEUtils.sharedInstance().stopScan()
            VTBLEUtils.sharedInstance().connect(to: device)
        } else {
            self.view?.loadFileView(hide: true, of: self.device)
        }
    }

    func didConnectedDevice(_ device: VTDevice) {
        VTO2Communicate.sharedInstance().peripheral = device.rawPeripheral
        VTO2Communicate.sharedInstance().delegate = self
    }

    func didDisconnectedDevice(_ device: VTDevice, andError error: Error) {
        BluetoothManager.shared.setSpO2PeripheralDelegate(SpO2DataHandler.shared.spO2PeripheralGlobalDelegate)
        BluetoothManager.shared.scanForDevice()
        if self.isConnected {
            BluetoothManager.shared.discoverServices(serviceUUIDs: nil, of: self.spO2)
        } else {
            BluetoothManager.shared.connectToDevice(self.spO2)
        }
    }
}

// MARK: - VTO2CommunicateDelegate
extension SpO2Presenter: VTO2CommunicateDelegate {
    func serviceDeployed(_ completed: Bool) {
        if completed {
            VTO2Communicate.sharedInstance().beginGetInfo()
        }
    }

    func getInfoWithResultData(_ infoData: Data?) {
        if let data = infoData {
            let info = VTO2Parser.parseO2Info(with: data)
            info.curBattery.removeLast()
            self.view?.updateBatteryView(with: Int(info.curBattery) ?? 0)
            var fileList = info.fileList.components(separatedBy: ",")
            fileList.removeLast()

            if !fileList.isEmpty {
                // remove loaded files
                for file in fileList where !self.device.fileList.array.contains(file) {
                    self.fileToLoad.append(file)
                }

                // if exist file to load, start load file, else cancel connect
                if !self.fileToLoad.isEmpty {
                    VTO2Communicate.sharedInstance().beginReadFile(withFileName: self.fileToLoad[self.fileCount])
                } else {
                    self.view?.updateDowloadProgress(progess: 1)
                    self.view?.loadFileView(hide: true, of: self.device)
                    VTBLEUtils.sharedInstance().cancelConnect()
                }
            }
        }
    }

    func readComplete(withData fileData: VTFileToRead) {
        if fileData.enLoadResult == VTFileLoadResultSuccess {
            let dataFile = VTO2Parser.parseO2WaveObjectArray(withWave: fileData.fileData as Data)

            let fileName = String(fileData.fileName)
            let startDateString = fileName.filenameToDateString()
            let startTime = startDateString.toDate(.ymdhms)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
            var endTime: Double = 0
            self.view?.updateDowloadProgress(progess: Float(self.fileCount) / Float(self.fileToLoad.count))
            self.fileCount += 1

            var waveFormModels: [WaveformModel] = []
            for i in 0 ..< dataFile.count {
                let waveFormModel = WaveformModel(waveforms: dataFile[i], of: self.device, timeCreated: startTime + Double(i) * 4)
                if (waveFormModel.spO2Value.value ?? 0 >= 70 && waveFormModel.spO2Value.value ?? 0 <= 100) &&
                    (waveFormModel.prValue.value ?? 0 >= 30 && waveFormModel.spO2Value.value ?? 0 <= 250) {
                    waveFormModels.append(waveFormModel)
                }
            }

            endTime = startTime + Double(dataFile.count - 1) * 4
            if !waveFormModels.isEmpty {
                let waveFormListModel = WaveformListModel(device: self.device, waveforms: waveFormModels, startTime: startTime, endTime: endTime)
                self.interactor.saveWaveformList(waveFormListModel, spO2: self.device)
                self.interactor.saveLoadedFileName(fileName: fileName, of: self.device)
            }
            if self.fileToLoad.count > self.fileCount {
                if !String.isNilOrEmpty(fileToLoad[self.fileCount]) {
                    VTO2Communicate.sharedInstance().beginReadFile(withFileName: fileToLoad[self.fileCount])
                }
            } else {
                self.view?.loadFileView(hide: true, of: self.device)
                VTBLEUtils.sharedInstance().cancelConnect()
            }
        }
    }
}
