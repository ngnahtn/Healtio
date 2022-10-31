//
//  DeviceModel.swift
//  1SKConnect
//
//  Created by tuyenvx on 30/03/2021.
//

import Foundation
import RealmSwift
import CoreBluetooth

class DeviceModel: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var mac: String = ""
    @objc dynamic var type: DeviceType = .scale
    @objc dynamic var imageData: NSData?
    let fileList = List<String>()

    var image: UIImage? {
        guard let `imageData` = imageData else {
            return nil
        }
        return UIImage(data: Data(referencing: imageData))
    }

    override init() {
        super.init()
    }

    init(name: String, mac: String, deviceType: DeviceType, image: UIImage?) {
        super.init()
        self.name = name
        self.mac = mac
        self.type = deviceType
        if let `image` = image, let data = image.pngData() {
            self.imageData = NSData(data: data)
        }
    }

    init(name: String, mac: String, deviceType: DeviceType) {
        super.init()
        self.name = name
        self.mac = mac
        self.type = deviceType
    }

    required init?(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        return nil
    }
}

class DeviceList: Object {
    @objc dynamic var id: String = ""
    let devices = List<DeviceModel>()

    convenience init(id: String, devices: [DeviceModel]) {
        self.init()
        self.id = id
        self.devices.append(objectsIn: devices)
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
