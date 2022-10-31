//
//  S5TemperatureDetailModel.swift
//  1SKConnect
//
//  Created by admin on 22/12/2021.
//

import RealmSwift
import TrusangBluetooth

class S5TemperatureDetailModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var s5SmartWatch: DeviceModel?
    
    var timestamp: Double {
        return self.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    }
    
    @objc dynamic var dateTime: String = ""
    @objc dynamic var wristTemp: Double = 0
    @objc dynamic var headTemp: Double = 0
    
    init(temp data: ZHJTemperatureDetail, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.s5SmartWatch = device
        self.wristTemp = Double(data.wristTemperature / 100)
        self.headTemp = Double(data.headTemperature / 100)
        self.dateTime = data.dateTime
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
