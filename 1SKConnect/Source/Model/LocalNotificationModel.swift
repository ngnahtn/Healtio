//
//  LocalNotificationModel.swift
//  1SKConnect
//
//  Created by Nguyễn Anh Tuấn on 14/12/2022.
//

import Foundation

struct LocalNotificationModel {
    var id: String
    var title: String
    var body: String
    var dateTime: DateComponents
}

struct ReminderModel {
    var title: String
    var time = Date()
    var isOn: Bool = false
}
