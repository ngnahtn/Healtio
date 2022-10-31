//
//  BloodGroup.swift
//  1SKConnect
//
//  Created by tuyenvx on 30/03/2021.
//

import Foundation
import RealmSwift

enum BloodGroup: String, RealmEnum, Codable, CaseIterable {
    case APositive = "A+"
    case ANegative = "A-"
    case BPositive = "B+"
    case BNegative = "B-"
    case ABPositive = "AB+"
    case ABNegative = "AB-"
    case OPositive = "O+"
    case ONegative = "O-"

    var name: String {
        switch self {
        case .APositive:
            return "A+"
        case .ANegative:
            return "A-"
        case .BPositive:
            return "B+"
        case .BNegative:
            return "B-"
        case .ABPositive:
            return "AB+"
        case .ABNegative:
            return "AB-"
        case .OPositive:
            return "O+"
        case .ONegative:
            return "O-"
        }
    }
}
