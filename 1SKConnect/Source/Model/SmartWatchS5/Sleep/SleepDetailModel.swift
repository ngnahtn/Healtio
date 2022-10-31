//
//  SleepDetailModel.swift
//  1SKConnect
//
//  Created by TrungDN on 17/12/2021.
//

import RealmSwift
import TrusangBluetooth

class SleepDetailModel: Object {
    @objc dynamic private var id: String = ""
    @objc dynamic var dateTime: String = ""
    @objc dynamic var s5SmartWatch: DeviceModel?
    @objc dynamic var duration: Int = 0
    
    var timestamp: Double {
        return self.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    }
    let type = RealmOptional<SleepType>()

    init(sleep data: ZHJSleepDetail, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.s5SmartWatch = device
        self.type.value = SleepType(value: data.type)
        self.dateTime = data.dateTime
        self.duration = data.duration
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
