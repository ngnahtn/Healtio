//
//  S5TemperatureRecordModel.swift
//  1SKConnect
//
//  Created by admin on 22/12/2021.
//

import RealmSwift
import TrusangBluetooth

class S5TemperatureRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    @objc dynamic var max: Int = 0
    @objc dynamic var min: Int = 0
    @objc dynamic var avg: Int = 0
    @objc dynamic var dateTime: String = ""
    let tempDetail = List<S5TemperatureDetailModel>()

    var timestamp: Double {
        return self.dateTime.toDate(.ymd)?.timeIntervalSince1970 ?? 0
    }
    
    var vitalSigns: [VitalSign] {
        return self.tempDetail.map { return VitalSign(value: $0.wristTemp, timestamp: $0.timestamp) }
    }
    
    override init() {
        super.init()
    }

    init(with data: ZHJTemperature, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.dateTime = data.dateTime
        self.device = device
        self.max = data.max
        self.min = data.min
        self.avg = data.avg
        for detail in data.details where detail.wristTemperature != 0 {
            let tempDetail = S5TemperatureDetailModel(temp: detail, of: device)
            self.tempDetail.append(tempDetail)
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
