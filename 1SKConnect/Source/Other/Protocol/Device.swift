//
//  Device.swift
//  1SKConnect
//
//  Created by tuyenvx on 02/04/2021.
//

import Foundation
import CoreBluetooth

protocol Device {
    var name: String { get set }
    var mac: String { get set }
    var type: DeviceType { get set }
    var imageData: Data? { get set }
    var image: UIImage? { get }

    init?(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber)

    func toDeviceModel() -> DeviceModel
}

extension Device {
    func toDeviceModel() -> DeviceModel {
        let deviceModel = DeviceModel(name: name, mac: mac, deviceType: type, image: image)
        return deviceModel
    }
}
