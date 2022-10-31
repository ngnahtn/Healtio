//
//  NotificationName+Extension.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import Foundation

extension Notification.Name {
    static let willEnterForeground = Notification.Name("WillEnterForeground")
    static let connectionAvailable = Notification.Name("ConnectionAvailable")
    static let connectionUnavailable = Notification.Name("ConnectionNotAvailable")
    static let tokenExpire = Notification.Name("TokenExpire")
    static let bleStateChanged = Notification.Name("BLEStateChanged")
    static let updateSpO2Data = Notification.Name("UpdateSpO2Data")
    static let deviceConnectionChanged = Notification.Name("DeviceConnectionChanged")
    static let activitiesDataChanged = Notification.Name("ActivitiesDataChanged")
    static let canNotConnectToDevice = Notification.Name("CanNotConnectToDevice")
    static let scanDeviceReachTimeout = Notification.Name("ScanDeviceReachTimeout")
    static let uncountNotificationCountChanged = Notification.Name("UncountNotificationCountChanged")
    static let changeProfile = Notification.Name("ChangeProfile")
    static let asignedWriteWithoutResponse = Notification.Name("AsignedWriteWithoutResponse")
    static let finishSaveData = Notification.Name("FinishSaveData")
    static let reloadData = Notification.Name("ReloadData")
    static let s5NotiSettingChange = Notification.Name("S5NotiSettingChange")
    static let s5GoalSettingChange = Notification.Name("s5GoalSettingChange")
}
