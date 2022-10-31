//
//  MonthGroup.swift
//  1SKConnect
//
//  Created by Be More on 24/08/2021.
//

import Foundation
import RealmSwift

enum MonthGroup: String, RealmEnum, Codable, CaseIterable {
    case one = "1 Tháng"
    case two = "2 Tháng"
    case three = "3 Tháng"
    case four = "4 Tháng"
    case five = "5 Tháng"
    case six = "6 Tháng"
    case seven = "7 Tháng"
    case eight = "8 Tháng"
    case nine = "9 Tháng"
    case ten = "10 Tháng"
    case eleven = "11 Tháng"
    case twelve = "12 Tháng"

    var value: String {
        switch self {
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .ten:
            return "10"
        case .eleven:
            return "11"
        case .twelve:
            return "12"
        }
    }
}
