//
//  SmartWatchS5Device.swift
//  1SKConnect
//
//  Created by TrungDN on 07/12/2021.
//

import Foundation
import CoreBluetooth

class SmartWatchS5Device: BaseDevice, Device {
    required init?(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        guard let deviceName = peripheral.name, deviceName.hasPrefix("S5") else {
            return nil
        }
        super.init()
        self.name = deviceName
        self.mac = peripheral.identifier.uuidString
        self.type = .smartWatchS5
        self.imageData = R.image.ic_smart_watch()?.jpegData(compressionQuality: 1)
    }

    override init() {
        super.init()
    }
}
