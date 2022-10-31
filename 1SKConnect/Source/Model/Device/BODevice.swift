//
//  BODevice.swift
//  1SKConnect
//
//  Created by Be More on 21/11/2021.
//

import Foundation
import CoreBluetooth

class BODevice: BaseDevice, Device {
    required init?(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        guard let deviceName = peripheral.name, deviceName.contains("AL_") else {
            return nil
        }
        super.init()
        self.name = deviceName
        self.mac = peripheral.identifier.uuidString
        self.type = .biolightBloodPressure
        self.imageData = UIImage(named: "AL_WBP")?.jpegData(compressionQuality: 1)
    }

    override init() {
        super.init()
    }
}
