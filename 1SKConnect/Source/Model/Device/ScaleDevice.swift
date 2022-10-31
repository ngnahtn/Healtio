//
//  ScaleDevice.swift
//  1SKConnect
//
//  Created by Be More on 21/11/2021.
//

import Foundation
import CoreBluetooth

class ScaleDevice: BaseDevice, Device {
    required init?(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        guard let deviceName = peripheral.name, deviceName.contains("1SK-SmartScale") else {
            return nil
        }
        super.init()
        self.name = deviceName
        self.mac = peripheral.identifier.uuidString
        self.type = .scale
        self.imageData = UIImage(named: deviceName)?.jpegData(compressionQuality: 1)
    }

    override init() {
        super.init()
    }
}
