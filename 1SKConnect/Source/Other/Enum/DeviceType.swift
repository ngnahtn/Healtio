//
//  DeviceType.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//

import Foundation
import RealmSwift

@objc enum DeviceType: Int, RealmEnum, Codable, CaseIterable {
    case scale
    case spO2
    case biolightBloodPressure
    case smartWatchS5
}
