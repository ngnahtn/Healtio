//
//  SpO2DetailsItem.swift
//  1SKConnect
//
//  Created by Elcom Corp on 15/11/2021.
//

import UIKit

enum SpO2Status: DetailsItemProtocol {
    var navigationTitle: String {
        return ""
    }

    var description: String {
        return ""
    }

    var unit: String {
        return ""
    }

    var maxValue: Double {
        return 0
    }

    var minValue: Double {
        return 0
    }

    var valueScale: [Double] {
        return []
    }

    var descriptionSacle: [String] {
        return []
    }

    case good
    case medium
    case low

    var title: String? {
        switch self {
        case .good:
            return R.string.localizable.scale_result_find_description()
        case .medium:
            return R.string.localizable.average()
        case .low:
            return R.string.localizable.low()
        }
    }

    var status: String? {
        return ""
    }

    var statusCode: String? {
        return ""
    }

    var color: UIColor? {
        switch self {
        case .good:
            return R.color.spO2Good()
        case .medium:
            return R.color.spO2Average()
        case .low:
            return R.color.spO2Low()
        }
    }

    init(value: Int) {
        if value <= 90 {
            self = .low
        } else if value <= 95 {
            self = .medium
        } else {
            self = .good
        }
    }
}
