//
//  S5SpO2RecordModel.swift
//  1SKConnect
//
//  Created by admin on 22/12/2021.
//

import RealmSwift
import TrusangBluetooth

class S5SpO2RecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    @objc dynamic var spO2Max: Int = 0
    @objc dynamic var spO2Min: Int = 0
    @objc dynamic var spO2AVG: Int = 0
    @objc dynamic var dateTime: String = ""
    let spO2Detail = List<S5SpO2DetailModel>()

    var timestamp: Double {
        return self.dateTime.toDate(.ymd)?.timeIntervalSince1970 ?? 0
    }
    
    var vitalSigns: [VitalSign] {
        return self.spO2Detail.map { return VitalSign(value: Double($0.bO), timestamp: $0.timestamp) }
    }
    
    override init() {
        super.init()
    }

    init(with data: ZHJBloodOxygen, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.dateTime = data.dateTime
        self.device = device
        self.spO2Max = data.max
        self.spO2Min = data.min
        self.spO2AVG = data.avg
        for detail in data.details where detail.BO != 0 {
            let spDetail = S5SpO2DetailModel(bo: detail, of: device)
            self.spO2Detail.append(spDetail)
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
