//
//  ActivityType.swift
//  1SKConnect
//
//  Created by tuyenvx on 07/04/2021.
//

import Foundation

enum ActivityGroup: Int, CaseIterable {
    case move
    case other
    case significance

    var name: String {
        switch self {
        case .move:
            return L.move.localized
        case .other:
            return L.other.localized
        case .significance:
            return L.significance.localized
        }
    }

    var types: [ActivityType] {
        switch self {
        case .move:
            return []
        case .other:
            return [.scale]
        case .significance:
            return []
        }
    }
}

enum ActivityType: Int, CaseIterable {
    case scale
}

enum ActivityFilterType: CaseIterable {
    case activity
    case deviceActivity

    var name: String {
        switch self {
        case .activity:
            return L.measurementIndex.localized
        case .deviceActivity:
            return L.deviceMeasurementIndex.localized
        }
    }
}
