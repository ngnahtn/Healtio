//
//  SleepType.swift
//  1SKConnect
//
//  Created by TrungDN on 17/12/2021.
//

import RealmSwift

enum SleepType: Int, RealmEnum, Codable {
    case non
    case awake
    case light
    case deep
    case rem
    case begin
    
    init(value: Int) {
        switch value {
        case 0:
            self = .non
        case 1:
            self = .awake
        case 2:
            self = .light
        case 3:
            self = .deep
        case 4:
            self = .rem
        case 5:
            self = .begin
        default:
            self = .non
        }
    }
}
