//
//  S5SportListRecordModel.swift
//  1SKConnect
//
//  Created by Be More on 25/12/2021.
//

import RealmSwift

class S5SportListRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    let sportList = List<S5SportRecordModel>()
    
    init(profile: ProfileModel, device: DeviceModel, sportList: [S5SportRecordModel]) {
        super.init()
        self.id = profile.id
        self.device = device
        self.sportList.append(objectsIn: sportList)
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
