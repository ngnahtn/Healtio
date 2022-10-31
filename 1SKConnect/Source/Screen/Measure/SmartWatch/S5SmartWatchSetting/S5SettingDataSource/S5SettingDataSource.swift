//
//  S5SettingDataSource.swift
//  1SKConnect
//
//  Created by Be More on 24/01/2022.
//

import Foundation

enum S5SettingType: Int, CaseIterable {
    case alert
    case alarm
    case remindActivity
    case remindWater
    case goal
    case heartRate
    case temperature
    case turnWrist
    case findWatch
    case watchFace
    case version
    case reset
}

struct S5SettingDataSource {
    var title: String
    var type: S5SettingType
    var status: Bool?
    var description: String
}

var s5Setting1stSectionDataSource = [
    S5SettingDataSource(title: R.string.localizable.s5_setting_type_notice(), type: .alert, status: nil, description: ""),
//    S5SettingDataSource(title: R.string.localizable.s5_setting_type_alarm(), type: .alarm, status: nil, description: ""),
//    S5SettingDataSource(title: R.string.localizable.s5_setting_type_sedentary_reminder(), type: .remindActivity, status: nil, description: ""),
//    S5SettingDataSource(title: R.string.localizable.s5_setting_type_water_reminder(), type: .remindWater, status: nil, description: ""),
//    S5SettingDataSource(title: R.string.localizable.s5_setting_type_watch_face(), type: .wat`chFace, status: nil, description: ""),
    S5SettingDataSource(title: R.string.localizable.s5_setting_type_movement_goal(), type: .goal, status: nil, description: "")
]

var s5Setting2ndSectionDataSource = [
    S5SettingDataSource(title: R.string.localizable.s5_setting_type_auto_heart_rate(), type: .heartRate, status: nil, description: ""),
    S5SettingDataSource(title: R.string.localizable.s5_setting_type_auto_temp(), type: .temperature, status: nil, description: ""),
    S5SettingDataSource(title: R.string.localizable.s5_setting_type_turn_wrist(), type: .turnWrist, status: nil, description: ""),
    S5SettingDataSource(title: R.string.localizable.s5_setting_type_searching_s5(), type: .findWatch, status: nil, description: "")]

var s5Setting3thSectionDataSource = [
    S5SettingDataSource(title: R.string.localizable.s5_setting_type_s5_version(), type: .version, status: nil, description: ""),
    S5SettingDataSource(title: R.string.localizable.s5_setting_type_s5_reset(), type: .reset, status: nil, description: "")]
