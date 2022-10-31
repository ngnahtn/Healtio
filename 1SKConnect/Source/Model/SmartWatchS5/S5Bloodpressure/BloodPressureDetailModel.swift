//
//  BloodPressureDetailModel.swift
//  1SKConnect
//
//  Created by TrungDN on 15/12/2021.
//

import RealmSwift
import TrusangBluetooth

class BloodPressureDetailModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var s5SmartWatch: DeviceModel?
    
    var timestamp: Double {
        return self.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    }
    
    @objc dynamic var dateTime: String = ""
    @objc dynamic var dbp: Int = 0
    @objc dynamic var sbp: Int = 0
    
    init(bloodPressure data: ZHJBloodPressureDetail, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.s5SmartWatch = device
        self.dateTime = data.dateTime
        self.dbp = data.DBP
        self.sbp = data.SBP
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
