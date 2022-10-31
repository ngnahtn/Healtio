//
//  UserLoginModel.swift
//  1SKConnect
//
//  Created by Be More on 14/07/2021.
//

import Foundation
import SwiftyJSON

//class UserLoginModel: Codable {
//    var accessToken: String?
//    var refreshToken: String?
//    var uuid: String?
//    var userName: String?
//    var email: String?
//    var mobile: String?
//    var fullName: String?
//    var avatar: String?
//    var status: Int?
//    var address: String?
//    var skype: String?
//    var facebook: String?
//    var signupType: Int?
//    var createdAt: Int?
//    var lastLogin: Int?
//    var emailVerify: Int?
//    var mobileVerify: Int?
//    var lastUpdate: Int?
//    var loginIp: String?
//    var isDelete: Int?
//    var birthDay: String?
//    var gender: Int?
//    var fbId: String?
//    var ggId: String?
//    var setPassword: Int?
//    var profileUpdate: String?
//    var avatarUpdate: Int?
//}

class TokenModel: Codable {
    
    enum CodingKeys: String, CodingKey {
        case tokenType
        case accessToken
    }
    
    var tokenType: String?
    var accessToken: String?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tokenType = try container.decodeIfPresent(String.self, forKey: .tokenType)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
    }
    
}

class UserLoginBaseModel: BaseResponseModel {
    var data: UserLoginModel?

    override init(_ json: JSON) {
        super.init(json)
        data = UserLoginModel(json["data"])
    }
}

class UserLoginModel {
    var id: Int?
    var uuid: String?
    var username: String?
    var email: String?
    var mobile: String?
    var fullName: String?
    var skype: String?
    var facebook: String?
    var avatar: String?
    var address: String?
    var birthday: String?
    var gender: Int?
    var fbId: String?
    var ggId: String?
    var phoneNumber: String?
    var createdAt: String?
    var updatedAt: String?
    var canAccess: [CanAccess]?
    var lastDeviceRequest: LastDeviceRequest?
    var statusId: Int?

    init(_ json: JSON) {
        id = json["id"].intValue
        uuid = json["uuid"].stringValue
        username = json["username"].stringValue
        email = json["email"].stringValue
        mobile = json["mobile"].stringValue
        fullName = json["full_name"].stringValue
        skype = json["skype"].stringValue
        facebook = json["facebook"].stringValue
        avatar = json["avatar"].stringValue
        address = json["address"].stringValue
        birthday = json["birthday"].stringValue
        gender = json["gender"].intValue
        fbId = json["fb_id"].stringValue
        ggId = json["gg_id"].stringValue
        phoneNumber = json["phone_number"].stringValue
        createdAt = json["created_at"].stringValue
        updatedAt = json["updated_at"].stringValue
        canAccess = json["can_access"].arrayValue.map { CanAccess($0) }
        lastDeviceRequest = LastDeviceRequest(json["last_device_request"])
        statusId = json["status_id"].intValue
    }
}

class CanAccess {
    var name: String?
    var code: String

    init(_ json: JSON) {
        name = json["name"].stringValue
        code = json["code"].stringValue
    }
}

class LastDeviceRequest {

    var id: Int
    var createdAt: String
    var updatedAt: String
    var modelableType: String
    var modelableId: Int
    var ip: String
    var userAgent: String

    init(_ json: JSON) {
        id = json["id"].intValue
        createdAt = json["created_at"].stringValue
        updatedAt = json["updated_at"].stringValue
        modelableType = json["modelable_type"].stringValue
        modelableId = json["modelable_id"].intValue
        ip = json["ip"].stringValue
        userAgent = json["user_agent"].stringValue
    }

}
