//
//  StepDetailModel.swift
//  1SKConnect
//
//  Created by TrungDN on 15/12/2021.
//

import RealmSwift
import TrusangBluetooth

class StepDetailModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var s5SmartWatch: DeviceModel?
    
    var timestamp: Double {
        return self.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
    }
    
    @objc dynamic var dateTime: String = ""
    @objc dynamic var type: Int = 0
    @objc dynamic var calories: Double = 0
    @objc dynamic var distance: Double = 0
    @objc dynamic var step: Int = 0
    
    init(step data: ZHJStepDetail, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.s5SmartWatch = device
        self.dateTime = data.dateTime
        self.type = data.type
        self.step = data.step
        self.distance = data.distance
        self.calories = data.calories
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    func toDictionary() -> [String: Any] {
        var json = [String: Any]()
        
        return json
    }
}
