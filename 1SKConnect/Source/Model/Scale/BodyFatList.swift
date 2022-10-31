//
//  BodyFatList.swift
//  1SKConnect
//
//  Created by TrungDN on 22/11/2021.
//

import RealmSwift

class BodyFatList: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    let bodyfats = List<BodyFat>()

    init(profile: ProfileModel, device: DeviceModel, bodyFats: [BodyFat]) {
        super.init()
        self.id = profile.id
        self.device = device
        self.bodyfats.append(objectsIn: bodyFats)
    }

    init(profile: ProfileModel, bodyFat: BodyFat) {
        super.init()
        self.id = profile.id
        self.device = bodyFat.scale
        self.bodyfats.append(bodyFat)
    }

    init(profile: ProfileModel) {
        self.id = profile.id
        self.device = nil
        self.bodyfats.append(objectsIn: [])
    }

    init(profileID: String, device: DeviceModel, bodyFats: [BodyFat]) {
        super.init()
        self.id = profileID
        self.device = device
        self.bodyfats.append(objectsIn: bodyFats)
    }

    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
