//
//  BluetoothManager.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//

import Foundation
import CoreBluetooth

protocol BluetoothConnectionDelegate: AnyObject {
    func showTurnOnBluetoothAlert()
    func isSearchingPeripheral(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) -> Bool
    func didConnect(to peripheral: CBPeripheral)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    func handleUpdateData(bytes: [UInt8], of characteristic: CBCharacteristic)
    func centralManagerDidUpdateState(_ centraManager: CBCentralManager)
}

class BluetoothConnection: NSObject {
    var peripheral: CBPeripheral!
    var servicesUUID: [CBUUID] = []
    private var centralManager: CBCentralManager!
    private var charaters: CBCharacteristic?
    private var scanDeviceTimer: Timer?
    var isConnect = false

    weak var delegate: BluetoothConnectionDelegate?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func scanForDevice() {
        centralManager.scanForPeripherals(withServices: servicesUUID, options: nil)
    }

    func checkBluetoothStatusAvailble() -> Bool {
        switch centralManager.state {
        case .poweredOn:
            return true
        case .poweredOff:
            delegate?.showTurnOnBluetoothAlert()
            return false
        case .unsupported:
            return false
        default:
            return false
        }
    }

    func disconnectDevice() {
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

    func stopScan() {
        centralManager.stopScan()
        self.isConnect = false
        print(peripheral.state)
    }

    func sendCommand(_ command: BLECommand, to writeCharateristic: CBCharacteristic, type: CBCharacteristicWriteType = .withResponse) {
        peripheral.writeValue(command.getData(), for: writeCharateristic, type: type)
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothConnection: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        delegate?.centralManagerDidUpdateState(central)
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        if delegate?.isSearchingPeripheral(peripheral, advertisementData: advertisementData, rssi: RSSI) ?? false {
            self.peripheral = peripheral
            central.connect(peripheral, options: nil)
            self.isConnect = true
            central.stopScan()
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        centralManager.connect(peripheral, options: nil)
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothConnection: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        delegate?.peripheral(peripheral, didDiscoverServices: error)
        peripheral.services?.forEach({ (service) in
            peripheral.discoverCharacteristics(nil, for: service)
        })
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        delegate?.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: error)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        delegate?.handleUpdateData(bytes: byteArray, of: characteristic)
    }
}
