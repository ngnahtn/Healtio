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
    var time: DateComponents
    var isOn: Bool = false
    
    mutating func changeTime(with time: DateComponents) {
        self.time = time
    }
}
