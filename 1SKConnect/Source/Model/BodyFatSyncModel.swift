//
//  BodyFatSyncModel.swift
//  1SKConnect
//
//  Created by Be More on 26/07/2021.
//

import Foundation
import SwiftyJSON

class SyncBaseModel: BaseResponseModel {
    var data: BodyFatSyncModel?

    override init(_ json: JSON) {
        super.init(json)
        data = BodyFatSyncModel(json["data"])
    }
}

class BodyFatSyncModel {
    var smartScale: [SmartScale]?

    init(_ json: JSON) {
        smartScale = json["smart_scale"].arrayValue.map { SmartScale($0) }
    }

    init(_ profile: ProfileModel, bodyFat: [BodyFat]) {
        self.smartScale = bodyFat.map { SmartScale(userId: profile.linkAccount?.uuid ?? "", $0) }
    }

    func toDictionary() -> [String: Any] {
        var json = [String: Any]()
        json["smart_scale"] = smartScale?.map { $0.toDictionary() }
        return json
    }
}

class UserInfo {
    var userId: String?
    var name: String?
    var gender: Int?
    var birthday: String?
    var relation: Int?
    var height: Double?
    var weight: Double?
    var blood: String?
    var id: String?

    init(_ profile: ProfileModel) {
        self.userId = profile.linkAccount?.uuid ?? ""
        self.name = profile.name ?? ""
        self.gender = profile.gender.value?.rawValue ?? 0
        self.birthday = profile.birthday ?? ""
        self.relation = profile.relation.value?.rawValue ?? 0
        self.height = profile.height.value ?? 0.0
        self.weight = profile.weight.value ?? 0
        self.blood = profile.blood.value?.name ?? ""
        self.id = ""
    }

    init(_ json: JSON) {
        userId = json["user_id"].stringValue
        name = json["name"].stringValue
        gender = json["gender"].intValue
        birthday = json["birthday"].stringValue
        relation = json["relation"].intValue
        height = json["height"].doubleValue
        weight = json["weight"].doubleValue
        blood = json["blood"].stringValue
        id = json["id"].stringValue
    }

    func toDictionary() -> [String: Any] {
        var json = [String: Any]()
        json["user_id"] = userId
        json["name"] = name
        json["gender"] = gender
        json["birthday"] = birthday
        json["relation"] = relation
        json["height"] = height
        json["weight"] = weight
//        json["blood"] = blood
        return json
    }
}

class SmartScale {
    var id: String?
    var device: String?
    var userId: String?
    var weight: Double?
    var statusWeight: String?
    var bmi: Double?
    var statusBmi: String?
    var bmr: Double?
    var statusBmr: String?
    var muscleMass: Double?
    var statusMuscle: String?
    var boneMass: Double?
    var statusBoneMass: String?
    var bodyWater: Double?
    var statusBodyWater: String?
    var protein: Double?
    var statusProtein: String?
    var fatLevel: Double?
    var statusFatLevel: String?
    var fat: Double?
    var statusFat: String?
    var visceralFat: Double?
    var statusVisceralFat: String?
    var subcutaneousFat: Double?
    var statusSubcutaneousFat: String?
    var leanBodyMass: Double?
    var statusLeanBodyMass: String?
    var standartWeight: Double?
    var statusStandartWeight: String?
    var bodyType: String?
    var metaData: String?
    var createdAt: String?
    var mac: String?
    var scaleType: String?
    var impedance: Int?

    init(userId: String, _ bodyFat: BodyFat) {
        self.device = bodyFat.deviceName ?? ""
        self.userId = userId
        self.impedance = bodyFat.impedance.value

        self.weight = roundValue(value: bodyFat.weight.value ?? 0.0)

        if let bmi = bodyFat.bmiEnum {
            self.statusWeight = bmi.statusCode ?? ""
        } else {
            self.statusWeight = ""
        }

        self.bmi = roundValue(value: bodyFat.bmi.value ?? 0.0)
        self.statusBmi = bodyFat.items[0].statusCode ?? ""
        self.bmr = roundValue(value: bodyFat.items[1].value)
        self.statusBmr = bodyFat.items[1].statusCode ?? ""

        if bodyFat.items.count > 3 {
            self.muscleMass = roundValue(value: bodyFat.items[2].value)
            self.statusMuscle = bodyFat.items[2].statusCode ?? ""
        } else {
            self.standartWeight = roundValue(value: bodyFat.items[1].value)
            self.muscleMass = 0
            self.statusMuscle = ""
        }

        if bodyFat.items.count > 4 {
            self.boneMass = roundValue(value: bodyFat.items[3].value)
            self.statusBoneMass = bodyFat.items[3].statusCode ?? ""
        } else {
            self.boneMass = 0
            self.statusBoneMass = ""
        }

        if bodyFat.items.count > 5 {
            self.bodyWater = roundValue(value: bodyFat.items[4].value)
            self.statusBodyWater = bodyFat.items[4].statusCode ?? ""
        } else {
            self.bodyWater = 0
            self.statusBodyWater = ""
        }

        if bodyFat.items.count > 6 {
            self.protein = roundValue(value: bodyFat.items[5].value)
            self.statusProtein = bodyFat.items[5].statusCode ?? ""
        } else {
            self.protein = 0
            self.statusProtein = ""
        }

        if bodyFat.items.count > 7 {
            self.fat = roundValue(value: bodyFat.items[6].value)
            self.statusFat = bodyFat.items[6].statusCode ?? ""
        } else {
            self.fat = 0
            self.statusFat = ""
        }

        if bodyFat.items.count > 8 {
            self.fatLevel = roundValue(value: bodyFat.items[7].value)
            self.statusFatLevel = bodyFat.items[7].statusCode ?? ""
        } else {
            self.fatLevel = 0
            self.statusFatLevel = ""
        }

        if bodyFat.items.count > 9 {
            self.visceralFat = roundValue(value: bodyFat.items[8].value)
            self.statusVisceralFat = bodyFat.items[8].statusCode ?? ""
        } else {
            self.visceralFat = 0
            self.statusVisceralFat = ""
        }

        if bodyFat.items.count > 10 {
            self.subcutaneousFat = roundValue(value: bodyFat.items[9].value)
            self.statusSubcutaneousFat = bodyFat.items[9].statusCode ?? ""
        } else {
            self.subcutaneousFat = 0
            self.statusSubcutaneousFat = ""
        }

        if bodyFat.items.count > 11 {
            self.leanBodyMass = roundValue(value: bodyFat.items[10].value)
        } else {
            self.leanBodyMass = 0
        }

        if bodyFat.items.count > 12 {
            self.standartWeight = roundValue(value: bodyFat.items[11].value)
        } else {
            self.standartWeight = 0
        }

        self.statusLeanBodyMass = ""
        self.statusStandartWeight = ""
        self.bodyType = bodyFat.bodyType.value?.statusCode ?? ""
        self.metaData = ""
        self.createdAt = bodyFat.createAt.toDate(.hmsdMy)?.toString(.ymdhms) ?? ""
        self.id = ""
        self.scaleType = "CF"
        self.mac = bodyFat.deviceMac
    }

    init(_ json: JSON) {
        createdAt = json["created_at"].stringValue
        device = json["device"].stringValue
        userId = json["user_id"].stringValue
        weight = json["weight"].doubleValue
        statusWeight = json["status_weight"].stringValue
        bmi = json["bmi"].doubleValue
        statusBmi = json["status_bmi"].stringValue
        bmr = json["bmr"].doubleValue
        statusBmr = json["status_bmr"].stringValue
        muscleMass = json["muscle_mass"].doubleValue
        statusMuscle = json["status_muscle"].stringValue
        boneMass = json["bone_mass"].doubleValue
        statusBoneMass = json["status_bone_mass"].stringValue
        bodyWater = json["body_water"].doubleValue
        statusBodyWater = json["status_body_water"].stringValue
        protein = json["protein"].doubleValue
        statusProtein = json["status_protein"].stringValue
        fatLevel = json["fat_level"].doubleValue
        statusFatLevel = json["status_fat_level"].stringValue
        fat = json["fat"].doubleValue
        statusFat = json["status_fat"].stringValue
        visceralFat = json["visceral_fat"].doubleValue
        statusVisceralFat = json["status_visceral_fat"].stringValue
        subcutaneousFat = json["subcutaneous_fat"].doubleValue
        statusSubcutaneousFat = json["status_subcutaneous_fat"].stringValue
        leanBodyMass = json["lean_body_mass"].doubleValue
        statusLeanBodyMass = json["status_lean_body_mass"].stringValue
        standartWeight = json["standart_weight"].doubleValue
        statusStandartWeight = json["status_standart_weight"].stringValue
        bodyType = json["body_type"].stringValue
        metaData = json["meta_data"].stringValue
        id = json["id"].stringValue
        mac = json["mac"].stringValue
        scaleType = json["scale_type"].stringValue
        impedance = json["impedance"].intValue
    }

    func toDictionary() -> [String: Any] {
        var json = [String: Any]()
        json["device"] = device
        json["user_id"] = userId
        json["weight"] = weight
        json["status_weight"] = statusWeight
        json["bmi"] = bmi
        json["status_bmi"] = statusBmi
        json["bmr"] = bmr
        json["status_bmr"] = statusBmr
        json["muscle_mass"] = muscleMass
        json["status_muscle"] = statusMuscle
        json["bone_mass"] = boneMass
        json["status_bone_mass"] = statusBoneMass
        json["body_water"] = bodyWater
        json["status_body_water"] = statusBodyWater
        json["protein"] = protein
        json["status_protein"] = statusProtein
        json["fat_level"] = fatLevel
        json["status_fat_level"] = statusFatLevel
        json["fat"] = fat
        json["status_fat"] = statusFat
        json["visceral_fat"] = visceralFat
        json["status_visceral_fat"] = statusVisceralFat
        json["subcutaneous_fat"] = subcutaneousFat
        json["status_subcutaneous_fat"] = statusSubcutaneousFat
        json["lean_body_mass"] = leanBodyMass
        json["status_lean_body_mass"] = statusLeanBodyMass
        json["standart_weight"] = standartWeight
        json["status_standart_weight"] = statusStandartWeight
        json["body_type"] = bodyType
        json["meta_data"] = []
        json["created_at"] = createdAt
        json["mac"] = mac
        json["scale_type"] = scaleType
        json["impedance"] = impedance
        return json
    }

    func roundValue(value: Double) -> Double {
        return round(value * 100000) / 100000.0
    }
}
