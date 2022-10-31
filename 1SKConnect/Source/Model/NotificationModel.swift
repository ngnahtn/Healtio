//
//  NotificationModel.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//

import RealmSwift

class NotificationModel: Codable {
    var id: String = ""
    var title: String = ""
    var content: String = ""
    var detail: String = ""
    var image: String = ""
    var objectId: String = ""
    var url: String = ""
    var pageAction: String = ""
    var deviceType: String = ""
    var sendType: String = ""
    var timeSendNotify: Int = 0
    var property: String = ""
    var status: String = ""
    var notifyUserStatus: Int? = 0
}

class ReadNotification: Object {
    @objc dynamic var id: String = ""

    override class func primaryKey() -> String? {
        return "id"
    }

    override init() {
        super.init()
    }

    init(id: String) {
        super.init()
        self.id = id
    }
}

class CountedNotification: Object {
    @objc dynamic var id: String = ""

    override class func primaryKey() -> String? {
        return "id"
    }

    override init() {
        super.init()
    }

    init(id: String) {
        super.init()
        self.id = id
    }
}

struct NotificationNumberModel: Codable {
    var numberNotify: Int = 0
}
