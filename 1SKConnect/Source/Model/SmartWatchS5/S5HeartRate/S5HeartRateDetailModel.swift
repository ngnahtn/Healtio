//
//  HeartDetailModel.swift
//  1SKConnect
//
//  Created by admin on 22/12/2021.
//

import RealmSwift
import TrusangBluetooth

class S5HeartRateDetailModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var s5SmartWatch: DeviceModel?
    
    var timestamp: Double {
        return self.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    }
    
    @objc dynamic var dateTime: String = ""
    @objc dynamic var heartRate: Int = 0
    
    init(hr data: ZHJHeartRateDetail, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.s5SmartWatch = device
        self.dateTime = data.dateTime
        self.heartRate = data.HR
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
