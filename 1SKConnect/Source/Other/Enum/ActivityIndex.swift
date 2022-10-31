//
//  ActivityIndex.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//

import Foundation
import RealmSwift

enum ActivityIndex: Double, RealmEnum, CaseIterable, Codable {
    case lessActive = 1.2
    case normalWorkOrEasyTraining = 1.375
    case usualyDoExcesicer = 1.55
    case positive = 1.725
    case passion = 1.9

    var name: String {
        switch self {
        case .lessActive:
            return "Người ít hoạt động hoặc không hoặt động"
        case .normalWorkOrEasyTraining:
            return "Người lao động hoặc tập nhẹ nhàng"
        case .usualyDoExcesicer:
            return "Thường xuyện tập thể dục (3-5 ngày 1 tuần)"
        case .positive:
            return "Tích cực (6-7 ngày 1 tuần)"
        case .passion:
            return "Đam mê"
        }
    }
}
