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
    
    var state: HeartRateState {
        let porfileListDAO = GenericDAO<ProfileListModel>()
        guard let currentProfile = porfileListDAO.getFirstObject()?.currentProfile,
              let birthday = currentProfile.birthday?.toDate(.ymd) else {
            return HeartRateState(heartRate, and: 18)
        }
        let age = Date().year - birthday.year
        return HeartRateState(heartRate, and: age)
    }
    
    var hrExerciseModel: HeartRateExerciseModel {
        let porfileListDAO = GenericDAO<ProfileListModel>()
        guard let currentProfile = porfileListDAO.getFirstObject()?.currentProfile,
              let birthday = currentProfile.birthday?.toDate(.ymd) else {
            return HeartRateExerciseModel(age: 18)
        }
        let age = Date().year - birthday.year
        return HeartRateExerciseModel(age: age)
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}

class HeartRateExerciseModel {
    var maxHr: Int
    var minHrRateZone: Int
    var maxHrRateZone: Int
    
    init(age: Int) {
        self.maxHr = 220 - age
        self.minHrRateZone = maxHr / 2
        self.maxHrRateZone = Int(Double(maxHr) * 0.85)
    }
}
