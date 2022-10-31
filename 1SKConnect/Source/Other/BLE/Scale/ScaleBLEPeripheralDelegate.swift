//
//  SacleBLEPeripheralDelegate.swift
//  1SKConnect
//
//  Created by tuyenvx on 16/04/2021.
//

import CoreBluetooth

protocol BLEPeripheralDelegate: CBPeripheralDelegate {
    var services: [CBService] { get set }
    var notifyUUIDs: [CBUUID] { get set }
    var writeUUIDs: [CBUUID] { get set }
    var writeWithoutResponseCharacteristic: [CBCharacteristic] { get set }
    var workingServiceUUID: [CBUUID] { get set }
    var readCharacteristicUUID: [CBUUID] { get set }
    var writeWithoutResponseCharacteristicUUID: [CBUUID] { get set }
    var notifyCharacteristics: [CBCharacteristic] { get set }
    var writeCharacteristics: [CBCharacteristic] { get set }
    var dataHandler: (([UInt8], CBCharacteristic, Error?) -> Void)? { get }
}

class ScaleBLEPeripheralDelegate: NSObject, BLEPeripheralDelegate {
    var writeWithoutResponseCharacteristic: [CBCharacteristic] = []
    var workingServiceUUID: [CBUUID] = []
    var readCharacteristicUUID: [CBUUID] = []
    var writeWithoutResponseCharacteristicUUID: [CBUUID] = []
    var services: [CBService] = []
    var notifyUUIDs: [CBUUID] = []
    var writeUUIDs: [CBUUID] = []
    var notifyCharacteristics: [CBCharacteristic] = []
    var writeCharacteristics: [CBCharacteristic] = []
    var dataHandler: (([UInt8], CBCharacteristic, Error?) -> Void)?

    override init() {
        super.init()
        self.notifyUUIDs = ["FFF4"].map({ CBUUID(string: $0) })
        self.writeUUIDs = ["FFF1"].map({ CBUUID(string: $0) })
    }

    convenience init(notifyUUIDs: [String], writeUUIDs: [String]) {
        self.init()
        self.notifyUUIDs = notifyUUIDs.map({ CBUUID(string: $0) })
        self.writeUUIDs = writeUUIDs.map({ CBUUID(string: $0) })
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        services = peripheral.services ?? []
        peripheral.services?.forEach({ (service) in
            peripheral.discoverCharacteristics(nil, for: service)
        })
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        characteristics.forEach { characteristic in
            if notifyUUIDs.contains(characteristic.uuid) && characteristic.properties.contains(.notify) {
                notifyCharacteristics.append(characteristic)
                peripheral.setNotifyValue(true, for: characteristic)

            }
            if writeUUIDs.contains(characteristic.uuid) && characteristic.properties.contains(.write) {
                writeCharacteristics.append(characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let characteristicData = characteristic.value else {
            dataHandler?([], characteristic, error)
            return
        }
        let data = [UInt8](characteristicData)
        dataHandler?(data, characteristic, error)
    }
}
