//
//  SpO2Device.swift
//  1SKConnect
//
//  Created by Be More on 21/11/2021.
//

import Foundation
import CoreBluetooth

class SpO2Device: BaseDevice, Device {
    required init?(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        guard let deviceName = peripheral.name, deviceName.hasPrefix("O2") else {
            return nil
        }
        super.init()
        self.name = deviceName
        self.mac = peripheral.identifier.uuidString
        self.type = .spO2
        self.imageData = UIImage(named: "O2 2291")?.jpegData(compressionQuality: 1)
    }

    override init() {
        super.init()
    }
}
