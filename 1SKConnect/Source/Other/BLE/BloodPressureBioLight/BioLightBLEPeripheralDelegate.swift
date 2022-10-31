//
//  BioLightBLEPeripheralDelegate.swift
//  1SKConnect
//
//  Created by admin on 21/11/2021.
//

import CoreBluetooth

class BioLightBLEPeripheralDelegate: NSObject, BLEPeripheralDelegate {
    var services: [CBService] = []
    var notifyUUIDs: [CBUUID] = []
    var writeUUIDs: [CBUUID] = []
    var writeWithoutResponseCharacteristic: [CBCharacteristic] = []
    var workingServiceUUID: [CBUUID] = []
    var readCharacteristicUUID: [CBUUID] = []
    var writeWithoutResponseCharacteristicUUID: [CBUUID] = []
    var notifyCharacteristics: [CBCharacteristic] = []
    var writeCharacteristics: [CBCharacteristic] = []
    var continuousDataHandler: (([UInt8], CBCharacteristic, Error?) -> Void)?
    var dataHandler: (([UInt8], CBCharacteristic, Error?) -> Void)?

    override init() {
        super.init()
        self.writeUUIDs = ["0xFFF4"].map({ CBUUID(string: $0) })
        self.readCharacteristicUUID = ["0xFFF4"].map({ CBUUID(string: $0) })
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        services = peripheral.services ?? []
        peripheral.services?.forEach({ (service) in
            peripheral.discoverCharacteristics(nil, for: service)
        })
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for charateristic in service.characteristics ?? [] {
            if writeUUIDs.contains(charateristic.uuid) {
                writeCharacteristics.append(charateristic)
            }
            peripheral.setNotifyValue(true, for: charateristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let characteristicData = characteristic.value else {
            continuousDataHandler?([], characteristic, error)
            return
        }
        let data = [UInt8](characteristicData)
        continuousDataHandler?(data, characteristic, error)
    }
}
