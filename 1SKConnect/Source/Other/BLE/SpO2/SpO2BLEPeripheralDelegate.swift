//
//  SpO2BLEPeripheralDelegate.swift
//  1SKConnect
//
//  Created by Be More on 16/09/2021.
//

import CoreBluetooth

class SpO2BLEPeripheralDelegate: NSObject, BLEPeripheralDelegate {
    var services: [CBService] = []
    var notifyUUIDs: [CBUUID] = []
    var writeUUIDs: [CBUUID] = []
    var writeWithoutResponseCharacteristic: [CBCharacteristic] = []
    var workingServiceUUID: [CBUUID] = []
    var readCharacteristicUUID: [CBUUID] = []
    var writeWithoutResponseCharacteristicUUID: [CBUUID] = []
    var notifyCharacteristics: [CBCharacteristic] = []
    var writeCharacteristics: [CBCharacteristic] = []
    var dataHandler: (([UInt8], CBCharacteristic, Error?) -> Void)?

    override init() {
        super.init()
        self.workingServiceUUID = ["14839AC4-7D7E-415C-9A42-167340CF2339"].map({ CBUUID(string: $0) })
        self.writeWithoutResponseCharacteristicUUID = ["8B00ACE7-EB0B-49B0-BBE9-9AEE0A26E1A3"].map({ CBUUID(string: $0) })
        self.readCharacteristicUUID = ["0734594A-A8E7-4B1A-A6B1-CD5243059A57"].map({ CBUUID(string: $0) })
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        services = peripheral.services ?? []
        peripheral.services?.forEach({ (service) in
            peripheral.discoverCharacteristics(nil, for: service)
        })
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if workingServiceUUID.contains(service.uuid) {
            guard let characteristics = service.characteristics else {
                return
            }
            characteristics.forEach { characteristic in
                if writeWithoutResponseCharacteristicUUID.contains(characteristic.uuid) && characteristic.properties.contains(.writeWithoutResponse) {
                    self.writeWithoutResponseCharacteristic.append(characteristic)
                }
                if readCharacteristicUUID.contains(characteristic.uuid) {
                    notifyCharacteristics.append(characteristic)
                    peripheral.setNotifyValue(true, for: characteristic)
                }
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
