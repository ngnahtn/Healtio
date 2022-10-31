//
//  SpO2DataListModel.swift
//  1SKConnect
//
//  Created by TrungDN on 22/11/2021.
//

import RealmSwift

class SpO2DataListModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    let waveformList = List<WaveformListModel>()

    init(profile: ProfileModel, device: DeviceModel, waveformList: [WaveformListModel]) {
        super.init()
        self.id = profile.id
        self.device = device
        self.waveformList.append(objectsIn: waveformList)
    }

    init(profile: ProfileModel, waveformList: WaveformListModel) {
        super.init()
        self.id = profile.id
        self.device = waveformList.device
        self.waveformList.append(waveformList)
    }

    init(profile: ProfileModel) {
        self.id = profile.id
        self.device = nil
        self.waveformList.append(objectsIn: [])
    }

    init(profileID: String, device: DeviceModel, waveformList: [WaveformListModel]) {
        super.init()
        self.id = profileID
        self.device = device
        self.waveformList.append(objectsIn: waveformList)
    }

    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
