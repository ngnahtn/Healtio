//
//  BluetoothManager.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//

import Foundation
import CoreBluetooth
import RealmSwift
import TrusangBluetooth

final class BluetoothManager: NSObject {
    static let shared = BluetoothManager()
    var centralManager: CBCentralManager!
    private let deviceModelTypes: [Device.Type] = [ScaleDevice.self, SpO2Device.self, BODevice.self, SmartWatchS5Device.self]
    private var connectedDevice: [DeviceModel] = []
    private var deviceWaitingForConnect: DeviceModel?
    private let deviceListDAO = GenericDAO<DeviceList>()
    private var peripherals: [CBPeripheral] = []
    private weak var scalePeripheralDelegate: CBPeripheralDelegate?
    weak var spO2PeripheralDelegate: CBPeripheralDelegate?
    private weak var bpPeripheraDelegate: CBPeripheralDelegate?
    private let timeout = TimeInterval(10) // seconds
    private var stopScanTimer: Timer?

    var spO2Timmer: Timer?
    var isScanning: Bool = false

    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true]) // [CBCentralManagerOptionShowPowerAlertKey: true])
    }

    // MARK: - Action
    func scanForDevice(turnOffTimeout: Bool = false) {
        removeAllOthersDevice()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        isScanning = true
        if !turnOffTimeout {
            self.startTimer()
        } else {
            self.stopTimer()
        }
        if ZHJBLEManagerProvider.shared.btManager?.state == .poweredOn {
            self.scanSmartWatch(seconds: Double.greatestFiniteMagnitude)
        }
        self.bluetoothPrepare()
    }
    
    func scanSmartWatch(seconds: Double) {
        if ZHJBLEManagerProvider.shared.deviceState == .connected || ZHJBLEManagerProvider.shared.deviceState == .connecting {
            return
        }
        ZHJBLEManagerProvider.shared.scan(seconds: seconds) {[weak self] (devices) in
            guard let `self` = self else { return }
            for device in devices {
                guard let peripheral = device.peripheral else { return }
                if let smartWatch = SmartWatchS5Device.init(peripheral: peripheral, advertisementData: [:], rssi: device.rssi) {
                    let isUserDevice = self.deviceListDAO.getObject(with: SKKey.connectedDevice)?.devices.contains(where: {$0.mac == peripheral.mac}) ?? false
                    let isDeviceConnect = self.peripherals.contains(where: { peripheral.mac == $0.mac })
                    switch (isUserDevice, isDeviceConnect) {
                    case (true, false):
                        self.peripherals.append(peripheral)
                        ZHJBLEManagerProvider.shared.connectDevice(device: device) { [weak self] peripheral in
                            guard let `self` = self else { return }
                            self.sendDeviceConnectionChangeNotification(peripheral)
                        } fail: { [weak self] (peripheral, err) in
                            guard let `self` = self else { return }
                            self.sendDeviceConnectionChangeNotification(peripheral)
                        } timeout: {
                            
                        }
                        break
                    case (false, _):
                        self.addOtherDevice(smartWatch)
                    default:
                        break
                    }
                }
            }
        }
    }

    func bluetoothPrepare() {
        ZHJBLEManagerProvider.shared.bluetoothProviderManagerStateDidUpdate {[weak self] (state) in
            guard let `self` = self else { return }
            if state == .poweredOn {
                delay(by: 1.0) {
                    self.scanSmartWatch(seconds: 5.0)
                }
            }
        }
    }

    func stopScan() {
        if deviceWaitingForConnect != nil {
            self.deviceWaitingForConnect = nil
        }
        centralManager.stopScan()
        isScanning = false
        removeAllOthersDevice()
        stopTimer()
        ZHJBLEManagerProvider.shared.stopScan()
    }

    @discardableResult
    func checkBluetoothStatusAvailble() -> Bool {
        switch centralManager.state {
        case .poweredOn:
            return true
        case .poweredOff:
            return false
        case .unauthorized:
            return false
        case .unsupported:
            return false
        default:
            return false
        }
    }

    func sendCommand(_ peripheral: CBPeripheral, _ command: BLECommand, to writeCharateristic: CBCharacteristic?, type: CBCharacteristicWriteType = .withResponse) {
        guard let writeCharateristic = writeCharateristic else {
            return
        }
        peripheral.writeValue(command.getData(), for: writeCharateristic, type: type)
    }

    func starSpO2Measuring(_ peripheral: CBPeripheral, _ command: BLECommand) {
        SpO2DataHandler.shared.startMeasuring(peripheral)
        self.writeSpO2Value(peripheral, command)
        spO2Timmer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1), repeats: true, block: { _ in
            self.writeSpO2Value(peripheral, command)
        })
    }

    /// Write value down to spO2 device
    /// - Parameters:
    ///   - peripheral: peripheral
    ///   - command: write without response command
    private func writeSpO2Value(_ peripheral: CBPeripheral, _ command: BLECommand) {
        guard let writeCharateristic = SpO2DataHandler.shared.spO2PeripheralGlobalDelegate.writeWithoutResponseCharacteristic.first else {
            return
        }
        peripheral.writeValue(command.getData(), for: writeCharateristic, type: .withoutResponse)
    }

    func isConnect(with device: DeviceModel) -> Bool {
        guard let  peripheral = peripherals.first(where: { $0.mac == device.mac }) else {
            return false
        }
        return peripheral.state == .connected
    }

    func peripheral(for device: DeviceModel) -> CBPeripheral? {
        guard let  peripheral = peripherals.first(where: { $0.mac == device.mac }) else {
            return nil
        }
        return peripheral
    }

    func connectToDevice(_ device: DeviceModel, turnOffTimeout: Bool = false) {
        if !isConnect(with: device) {
            deviceWaitingForConnect = device
            scanForDevice(turnOffTimeout: turnOffTimeout)
        }
    }

    func disConnectDevice(_ device: DeviceModel) {
        if deviceWaitingForConnect?.mac == device.mac {
            deviceWaitingForConnect = nil
        }
        if let peripheral = peripherals.first(where: { $0.mac == device.mac}) {
            centralManager.cancelPeripheralConnection(peripheral)
            peripherals.removeAll(where: { $0.mac == peripheral.mac })
            sendDeviceConnectionChangeNotification(peripheral)
        }
    }

    func setScalePeripheralDelegate(_ delegate: CBPeripheralDelegate) {
        self.scalePeripheralDelegate = delegate
    }

    func setBiolightPeripheralDelegate( _ delegate: CBPeripheralDelegate) {
        self.bpPeripheraDelegate = delegate
    }

    func setSpO2PeripheralDelegate(_ delegate: CBPeripheralDelegate) {
        self.spO2PeripheralDelegate = delegate
    }

    func discoverServices(serviceUUIDs: [CBUUID]?, of device: DeviceModel) {
        guard let peripheral = peripherals.first(where: { $0.mac == device.mac }) else {
            return
        }
        switch device.type {
        case .scale:
            peripheral.delegate = scalePeripheralDelegate
            peripheral.discoverServices(serviceUUIDs)
        case .spO2:
            peripheral.delegate = spO2PeripheralDelegate
            peripheral.discoverServices(serviceUUIDs)
        case .biolightBloodPressure:
            peripheral.delegate = bpPeripheraDelegate
            peripheral.discoverServices(serviceUUIDs)
        case .smartWatchS5:
            return
        }
    }

    // MARK: - Helper
    private func addOtherDevice(_ device: Device) {
        if let deviceList = deviceListDAO.getObject(with: SKKey.otherDevice) {
            guard !deviceList.devices.contains(where: { $0.mac == device.mac }) else {
                return
            }
            deviceListDAO.update {
                deviceList.devices.append(device.toDeviceModel())
            }
        } else {
            let deviceList = DeviceList(id: SKKey.otherDevice, devices: [device.toDeviceModel()])
            deviceListDAO.add(deviceList)
        }
    }

    private func removeAllOthersDevice() {
        deviceListDAO.update { [weak self] in
            self?.deviceListDAO.getObject(with: SKKey.otherDevice)?.devices.removeAll()
        }
    }

    // MARK: - Send Notification
    private func sendDeviceConnectionChangeNotification(_ peripheral: CBPeripheral) {
        let userInfo: [String: Any] = [
            SKKey.mac: peripheral.mac
        ]
        kNotificationCenter.post(name: .deviceConnectionChanged, object: nil, userInfo: userInfo)
    }

    private func sendCanNotConnectToDeviceNotification(device: DeviceModel) {
        let userInfo: [String: Any] = [
            SKKey.mac: device.mac
        ]
        kNotificationCenter.post(name: .canNotConnectToDevice, object: nil, userInfo: userInfo)
    }

    private func sendScanDeviceReachTimeout() {
        kNotificationCenter.post(name: .scanDeviceReachTimeout, object: nil, userInfo: nil)
    }

    // MARK: - Time out timer
    private func startTimer() {
        stopTimer()
        stopScanTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false, block: { [weak self] (_) in
            // Can't connect for special device
            if let `deviceWaitingForConnect` = self?.deviceWaitingForConnect {
                self?.sendCanNotConnectToDeviceNotification(device: deviceWaitingForConnect)
                self?.deviceWaitingForConnect = nil
            }
            self?.isScanning = false
            self?.sendScanDeviceReachTimeout()
            self?.centralManager.stopScan()
            self?.stopTimer()
        })
    }

    private func stopTimer() {
        stopScanTimer?.invalidate()
        stopScanTimer = nil
    }

    func stopSpo2Timer(_ device: DeviceModel) {
        SpO2DataHandler.shared.stopMeasuring(device)
        spO2Timmer?.invalidate()
        spO2Timmer = nil
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.scanForDevice(turnOffTimeout: true)
        case .poweredOff:
            self.peripherals.removeAll()
            self.stopScan()
            self.bluetoothPrepare()
        default:
            self.stopScan()
        }
        kNotificationCenter.post(name: .bleStateChanged, object: nil, userInfo: nil)
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        // - Connect to special device
        if let `deviceWaitingForConnect` = deviceWaitingForConnect {
            guard deviceWaitingForConnect.mac == peripheral.mac,
                  !peripherals.contains(where: { $0.mac == peripheral.mac}) else {
                return
            }
            peripherals.append(peripheral)
            centralManager.connect(peripheral, options: nil)
            stopScan()
            return
        }

        // Searching device and auto connect
        for deviceModelType in deviceModelTypes {
            if let device = deviceModelType.init(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI) {
                let isUserDevice = deviceListDAO.getObject(with: SKKey.connectedDevice)?.devices.contains(where: {$0.mac == device.mac}) ?? false
                let isDeviceConnect = peripherals.contains(where: { peripheral.mac == $0.mac })
                switch (isUserDevice, isDeviceConnect) {
                case (true, false):
                    peripherals.append(peripheral)
                    centralManager.connect(peripheral, options: nil)
                case (false, _):
                    addOtherDevice(device)
                default:
                    break
                }
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard (deviceListDAO.getObject(with: SKKey.connectedDevice)?.devices
                .first(where: { $0.mac == peripheral.mac})) != nil else {
            return
        }
        // Connect special device
        if deviceWaitingForConnect?.mac == peripheral.mac {
            deviceWaitingForConnect = nil
        }
        sendDeviceConnectionChangeNotification(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripherals.removeAll(where: { $0.mac == peripheral.mac })
        sendDeviceConnectionChangeNotification(peripheral)
    }
}
