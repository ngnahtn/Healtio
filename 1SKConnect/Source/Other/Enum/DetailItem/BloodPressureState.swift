//
//  BloodPressureState.swift
//  1SKConnect
//
//  Created by admin on 22/11/2021.
//

import Foundation

enum BloodPressureState: DetailsItemProtocol {
    case low
    case normal
    case pre_hypertension
    case high_1
    case high_2

    var title: String? {
        switch self {
        case .low:
            return R.string.localizable.biolight_detail_blood_pressure_low()
        case .normal:
            return R.string.localizable.biolight_detail_blood_pressure_normal()
        case .pre_hypertension:
            return R.string.localizable.biolight_detail_blood_pressure_pre_hypertension()
        case .high_1:
            return R.string.localizable.biolight_detail_blood_pressure_high_1()
        case .high_2:
            return R.string.localizable.biolight_detail_blood_pressure_high_2()
        }
    }

    init(sys: Int, dia: Int) {
        if dia == 0 {
            self = .normal
        }
        switch dia {
        case 0...60:
            switch sys {
            case 0...90:
                self = .low
            case 91...120:
                self = .normal
            case 121...140:
                self = .pre_hypertension
            case 141...160:
                self = .high_1
            default:
                self = .high_2
            }
        case 61...80:
            switch sys {
            case 40...120:
                self = .normal
            case 121...140:
                self = .pre_hypertension
            case 141...160:
                self = .high_1
            default:
                self = .high_2
            }
        case 81...90:
            switch sys {
            case 40...140:
                self = .pre_hypertension
            case 141...160:
                self = .high_1
            default:
                self = .high_2
            }
        case 91...100:
            switch sys {
            case 40...160:
                self = .high_1
            default:
                self = .high_2
            }
        default:
            self = .high_2
        }
    }

    var navigationTitle: String { return "" }
    var description: String {
        switch self {
        case .low:
            return R.string.localizable.biolight_description_blood_pressure_low()
        case .normal:
            return R.string.localizable.biolight_description_blood_pressure_normal()
        case .pre_hypertension:
            return R.string.localizable.biolight_description_blood_pressure_pre_hypertension()
        case .high_1:
            return R.string.localizable.biolight_description_blood_pressure_high_1()
        case .high_2:
            return R.string.localizable.biolight_description_blood_pressure_high_2()
        }
    }

    var unit: String { return "" }
    var status: String? { return "" }
    var statusCode: String? { return "" }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.biolightLow()
        case .normal:
            return R.color.biolightNormal()
        case .pre_hypertension:
            return R.color.biolightPre()
        case .high_1:
            return R.color.biolightHigh1()
        case .high_2:
            return R.color.biolightHigh2()
        }
    }

    var value: Double { return 0 }
    var maxValue: Double { return 0 }
    var minValue: Double { return 0 }
    var valueScale: [Double] { return [] }
    var descriptionSacle: [String] { return [] }
}
