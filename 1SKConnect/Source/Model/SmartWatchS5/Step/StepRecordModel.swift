//
//  StepRecordModel.swift
//  1SKConnect
//
//  Created by TrungDN on 15/12/2021.
//

import RealmSwift
import TrusangBluetooth

class StepRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    @objc dynamic var totalCalories: Double = 0
    @objc dynamic var totalDistance: Double = 0
    @objc dynamic var totalStep: Int = 0
    @objc dynamic var goal: Int = 0
    @objc dynamic var duration: Int = 0
    @objc dynamic var dateTime: String = ""
    let stepDetail = List<StepDetailModel>()
    
    var timestamp: Double {
        return self.dateTime.toDate(.ymd)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    }
    
    var stepSigns: [VitalSign] {
        return self.stepDetail.map { return VitalSign(value: Double($0.step), timestamp: $0.timestamp) }
    }

    override init() {
        super.init()
    }

    init(with data: ZHJStep, and goal: Int, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.dateTime = data.dateTime
        self.device = device
        self.totalStep = data.step
        self.totalCalories = Double(data.calories)
        self.totalDistance = Double(data.distance)
        for detail in data.details where detail.step != 0 {
            let stepDetail = StepDetailModel(step: detail, of: device)
            self.stepDetail.append(stepDetail)
        }
        self.goal = goal
        self.duration = data.duration
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
