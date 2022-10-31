//
//  LinkModel.swift
//  1SKConnect
//
//  Created by Be More on 15/11/2021.
//

import Foundation
import RealmSwift

class LinkModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var accessToken: String?
    @objc dynamic var refreshToken: String?
    @objc dynamic var uuid: String = ""
    @objc dynamic var userName: String?
    @objc dynamic var email: String?
    @objc dynamic var mobile: String?
    @objc dynamic var fullName: String?
    @objc dynamic var avatar: String?
    var status = RealmOptional<Int>()
    @objc dynamic var address: String?
    @objc dynamic var skype: String?
    @objc dynamic var facebook: String?
    @objc dynamic var birthDay: String?
    var gender = RealmOptional<Int>()
    @objc dynamic var fbId: String?
    @objc dynamic var ggId: String?
    @objc dynamic var isGoogleAccount: Bool = false

    override class func primaryKey() -> String? {
        return "id"
    }

    override init() {
        super.init()
    }

    init(loginModel: UserLoginModel) {
        super.init()
        self.id = NSUUID().uuidString
        self.uuid = String(loginModel.id!)
        self.userName = loginModel.username
        self.email = loginModel.email
        self.mobile = loginModel.mobile
        self.fullName = loginModel.fullName
        self.avatar = loginModel.avatar
        self.address = loginModel.address
        self.skype = loginModel.skype
        self.facebook = loginModel.facebook
        self.gender.value = loginModel.gender
        self.fbId = loginModel.fbId
        self.ggId = loginModel.ggId
    }
}
