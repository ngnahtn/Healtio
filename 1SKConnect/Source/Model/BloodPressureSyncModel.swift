//
//  BloodPressureSyncModel.swift
//  1SKConnect
//
//  Created by admin on 30/11/2021.
//

import Foundation
import SwiftyJSON

class BloodPressureSyncBaseModel: BaseResponseModel {

    var data: BloodPressureSyncModel?

    override init(_ json: JSON) {
        super.init(json)
        data = BloodPressureSyncModel(json["data"])
    }
}

class BloodPressureSyncModel {

    let bloodPressure: [BloodPressure]?

    init(_ json: JSON) {
        bloodPressure = json["blood_pressure"].arrayValue.map { BloodPressure($0) }
    }

    init(_ profile: ProfileModel, bp: [BloodPressureModel]) {
        self.bloodPressure = bp.map {BloodPressure(userId: profile.linkAccount?.uuid ?? "", $0) }
    }

    func toDictionary() -> [String: Any] {
        var json = [String: Any]()
        json["blood_pressure"] = bloodPressure?.map { $0.toDictionary() }
        return json
    }
}

class BloodPressure {

    let sys: Int?
    let dia: Int?
    let pr: Int?
    let map: Int?
    let mac: String?
    let deviceName: String?
    let id: String?
    let userId: String?
    let createdAt: String?
    let ts: Double?

    init(_ json: JSON) {
        sys = json["sys"].intValue
        dia = json["dia"].intValue
        pr = json["pr"].intValue
        map = json["map"].intValue
        mac = json["mac"].stringValue
        deviceName = json["deviceName"].stringValue
        id = json["id"].stringValue
        userId = json["user_id"].stringValue
        createdAt = json["created_at"].stringValue
        ts = json["ts"].doubleValue
    }
    init(userId: String, _ bp: BloodPressureModel) {
        self.deviceName = bp.deviceName ?? ""
        self.mac = bp.deviceMac ?? ""
        self.map = bp.map.value ?? 0
        self.pr = bp.pr.value ?? 0
        self.dia = bp.dia.value ?? 0
        self.sys = bp.sys.value ?? 0
        self.createdAt = bp.createAt
        self.id = bp.id
        self.ts = bp.date
        self.userId = userId
    }

    func toDictionary() -> [String: Any] {
        var json = [String: Any]()
        json["sys"] = self.sys
        json["dia"] = self.dia
        json["pr"] = self.pr
        json["map"] = self.map
        json["mac"] = self.mac
        json["ts"] = self.createdAt?.toDate(.ymdhms)?.timeIntervalSince1970
        json["deviceName"] = self.deviceName
        json["user_id"] = self.userId
        json["created_at"] = self.createdAt
        return json
    }
}
