//
//  S5SpO2DetailModel.swift
//  1SKConnect
//
//  Created by admin on 22/12/2021.
//

import RealmSwift
import TrusangBluetooth

class S5SpO2DetailModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var s5SmartWatch: DeviceModel?
    
    var timestamp: Double {
        return self.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    }
    
    @objc dynamic var dateTime: String = ""
    @objc dynamic var bO: Int = 0
    
    init(bo data: ZHJBloodOxygenDetail, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.s5SmartWatch = device
        self.dateTime = data.dateTime
        self.bO = data.BO
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
