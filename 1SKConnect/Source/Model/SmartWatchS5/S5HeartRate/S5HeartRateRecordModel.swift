//
//  S5HeartRateRecordModel.swift
//  1SKConnect
//
//  Created by admin on 22/12/2021.
//
import RealmSwift
import TrusangBluetooth

class S5HeartRateRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    @objc dynamic var heartRateMax: Int = 0
    @objc dynamic var heartRateMin: Int = 0
    @objc dynamic var heartRateAVG: Int = 0
    @objc dynamic var dateTime: String = ""
    let hrDetail = List<S5HeartRateDetailModel>()
    
    var timestamp: Double {
        return self.dateTime.toDate(.ymd)?.timeIntervalSince1970 ?? 0
    }

    var vitalSigns: [VitalSign] {
        return self.hrDetail.map { return VitalSign(value: Double($0.heartRate), timestamp: $0.timestamp) }
    }

    override init() {
        super.init()
    }

    init(with data: ZHJHeartRate, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.dateTime = data.dateTime
        self.device = device
        self.heartRateMax = data.max
        self.heartRateMin = data.min
        self.heartRateAVG = data.avg
        for detail in data.details where detail.HR != 0 {
            let heartRateDetail = S5HeartRateDetailModel(hr: detail, of: device)
            self.hrDetail.append(heartRateDetail)
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
