//
//  SleepRecordModel.swift
//  1SKConnect
//
//  Created by TrungDN on 17/12/2021.
//

import RealmSwift
import TrusangBluetooth

class SleepRecordModel: Object {
    @objc dynamic var id: String = ""
    let sleeppDetail = List<SleepDetailModel>()
    @objc dynamic var beginDuration: Int = 0
    @objc dynamic var awakeDuration: Int = 0
    @objc dynamic var lightDuration: Int = 0
    @objc dynamic var deepDuration: Int = 0
    @objc dynamic var remDuration: Int = 0
    @objc dynamic var dateTime: String = ""
    
    var timestamp: Double {
        return self.dateTime.toDate(.ymd)!.timeIntervalSince1970
    }
    
    init(with data: ZHJSleep, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.beginDuration = data.beginDuration
        self.dateTime = data.dateTime
        self.awakeDuration = data.awakeDuration
        self.lightDuration = data.lightDuration
        self.deepDuration = data.deepDuration
        self.remDuration = data.REMDuration
        for detail in data.details where detail.duration != 0 {
            let sleepDetail = SleepDetailModel(sleep: detail, of: device)
            self.sleeppDetail.append(sleepDetail)
        }
    }

    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
