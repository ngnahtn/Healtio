//
//  BloodPressureListModel.swift
//  1SKConnect
//
//  Created by TrungDN on 22/11/2021.
//

import RealmSwift

class BloodPressureListModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    let bloodPressureList = List<BloodPressureModel>()

    init(profile: ProfileModel, device: DeviceModel, bloodPressureList: [BloodPressureModel]) {
        super.init()
        self.id = profile.id
        self.device = device
        self.bloodPressureList.append(objectsIn: bloodPressureList)
    }

    init(profile: ProfileModel) {
        self.id = profile.id
        self.device = nil
        self.bloodPressureList.append(objectsIn: [])
    }

    init(profileID: String, device: DeviceModel, bloodPressureList: [BloodPressureModel]) {
        super.init()
        self.id = profileID
        self.device = device
        self.bloodPressureList.append(objectsIn: bloodPressureList)
    }

    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
