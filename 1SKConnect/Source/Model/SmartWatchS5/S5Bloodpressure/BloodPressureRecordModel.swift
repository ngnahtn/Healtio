//
//  BloodPressureRecordModel.swift
//  1SKConnect
//
//  Created by TrungDN on 15/12/2021.
//

import RealmSwift
import TrusangBluetooth

class BloodPressureRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    @objc dynamic var dateTime: String = ""
    @objc dynamic var min: BloodPressureDetailModel!
    @objc dynamic var max: BloodPressureDetailModel!
    @objc dynamic var avg: BloodPressureDetailModel!
    let bloodPressureDetail = List<BloodPressureDetailModel>()

    var timestamp: Double {
        return self.dateTime.toDate(.ymd)?.timeIntervalSince1970 ?? 0
    }
    
    var diaSigns: [VitalSign] {
        return self.bloodPressureDetail.map { return VitalSign(value: Double($0.dbp), timestamp: $0.timestamp) }
    }

    var sysSigns: [VitalSign] {
        return self.bloodPressureDetail.map { return VitalSign(value: Double($0.sbp), timestamp: $0.timestamp) }
    }
    
    override init() {
        super.init()
    }

    init(with data: ZHJBloodPressure, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.device = device
        self.dateTime = data.dateTime
        self.min = BloodPressureDetailModel(bloodPressure: data.min, of: device)
        self.max = BloodPressureDetailModel(bloodPressure: data.max, of: device)
        self.avg = BloodPressureDetailModel(bloodPressure: data.avg, of: device)
        for detail in data.details where detail.SBP != 0 {
            let bloodPressureDetail = BloodPressureDetailModel(bloodPressure: detail, of: device)
            self.bloodPressureDetail.append(bloodPressureDetail)
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
