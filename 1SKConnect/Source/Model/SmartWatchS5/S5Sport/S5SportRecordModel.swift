//
//  S5SportRecordModel.swift
//  1SKConnect
//
//  Created by Be More on 25/12/2021.
//

import RealmSwift
import TrusangBluetooth

class S5SportRecordModel: Object {
    @objc dynamic var id: String = ""
    
    static func == (left: S5SportRecordModel, right: S5SportRecordModel) -> Bool {
        return left.dateTime == right.dateTime
    }
    
    var deviceMac: String {
        return self.s5SmartWatch?.mac ?? ""
    }
    
    @objc dynamic var sportType: Int = 0

    @objc dynamic var dateTime = ""
    
    var timestamp: Double {
        return dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? 0
    }

    @objc dynamic var duration: Int = 0

    @objc dynamic var step: Int = 0

    @objc dynamic var heartRate: Int = 0

    @objc dynamic var pace: Int = 0

    @objc dynamic var speed: Int = 0

    @objc dynamic var calories: Int = 0

    @objc dynamic var distance: Int = 0

    @objc dynamic var interval: Int = 0

    let heartRateArr = List<Int>()

    let stepArr = List<Int>()

    let paceArr = List<Int>()

    let coordinateArr = List<String>()

    @objc dynamic var s5SmartWatch: DeviceModel?

    var type: ZHJSportModeType {
        return ZHJSportModeType(rawValue: self.sportType)!
    }

    init(sport data: ZHJSportMode, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.s5SmartWatch = device
        self.dateTime = data.dateTime
        self.sportType = data.sportType
        self.duration = data.duration
        self.step = data.step
        self.heartRate = data.heartRate
        self.pace = data.pace
        self.speed = data.speed
        self.calories = data.calories
        self.distance = data.distance
        self.interval = data.interval
        self.heartRateArr.append(objectsIn: data.heartRateArr)
        self.stepArr.append(objectsIn: data.stepArr)
        self.paceArr.append(objectsIn: data.paceArr)
        self.coordinateArr.append(objectsIn: data.coordinateArr)
    }
    
    init(s5SM: DeviceModel) {
        super.init()
        self.s5SmartWatch = s5SM
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
