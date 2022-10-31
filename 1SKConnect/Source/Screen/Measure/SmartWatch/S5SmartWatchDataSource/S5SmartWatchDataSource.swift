//
//  S5SmartWatchDataSource.swift
//  1SKConnect
//
//  Created by TrungDN on 07/12/2021.
//

import Foundation
import UIKit

enum CellType: CaseIterable {
    case exercise
    case heartRate
    case spO2
    case bloodPressure
    case temperature
    case sleep
    case synthetic
}

enum UnitType {
    case kcal
    case km
    case bpm
    case percentage
    case bloodPresssure
    case celcius
    case non
    
    var description: String {
        switch self {
        case .kcal:
            return "kcal"
        case .km:
            return "km"
        case .bpm:
            return "bpm"
        case .percentage:
            return "%"
        case .bloodPresssure:
            return "mmHg"
        case .celcius:
            return "°C"
        case .non:
            return ""
        }
    }
}

struct ExerciseDetail {
    var stepValue: Int
    var timestamp: Double
}

struct S5Exercise {
    var step: Int
    var stepGoal: Int
    var kcal: Double
    var distance: Double
    var duration: Int
    var sportDuration: Int
    var heartRate: Int
    var detail: [ExerciseDetail]
}

struct VitalSign {
    var value: Double
    var timestamp: Double
}

enum SyntheticCategoriesType {
    case run
    case step
    case calo
    case hr
    case spO2
    case bp
    case temp
    case sleep
}

struct SyntheticCategories {
    var image: UIImage
    var title: String
    var type: SyntheticCategoriesType
    var value: String
}

var syntheticFullCategoriesDataSource = [SyntheticCategories(image: R.image.ic_s5_run()!, title: "-", type: .run, value: "-"),
                                         SyntheticCategories(image: R.image.ic_step_count()!, title: R.string.localizable.smart_watch_s5_step_count(), type: .step, value: "-"),
                                         SyntheticCategories(image: R.image.ic_calo()!, title: R.string.localizable.smart_watch_s5_calo(), type: .calo, value: "---"),
                                         SyntheticCategories(image: R.image.ic_average_hr()!, title: R.string.localizable.spO2_detail_value_average_pr(), type: .hr, value: "---"),
                                         SyntheticCategories(image: R.image.ic_average_spO2()!, title: R.string.localizable.smart_watch_s5_average_spO2(), type: .spO2, value: "--"),
                                         SyntheticCategories(image: R.image.ic_bp()!, title: R.string.localizable.bloodpressure(), type: .bp, value: "---"),
                                         SyntheticCategories(image: R.image.ic_temperature()!, title: R.string.localizable.temperature(), type: .temp, value: "--"),
                                         SyntheticCategories(image: R.image.ic_sleep()!, title: R.string.localizable.smart_watch_s5_sleep(), type: .sleep, value: "--  -- ")]

var syntheticCategoriesDataSource = [SyntheticCategories(image: R.image.ic_step_count()!, title: R.string.localizable.smart_watch_s5_step_count(), type: .step, value: "-"),
                                     SyntheticCategories(image: R.image.ic_calo()!, title: R.string.localizable.smart_watch_s5_calo(), type: .calo, value: "---"),
                                     SyntheticCategories(image: R.image.ic_average_hr()!, title: R.string.localizable.spO2_detail_value_average_pr(), type: .hr, value: "---"),
                                     SyntheticCategories(image: R.image.ic_average_spO2()!, title: R.string.localizable.smart_watch_s5_average_spO2(), type: .spO2, value: "--"),
                                     SyntheticCategories(image: R.image.ic_bp()!, title: R.string.localizable.bloodpressure(), type: .bp, value: "---"),
                                     SyntheticCategories(image: R.image.ic_temperature()!, title: R.string.localizable.temperature(), type: .temp, value: "--"),
                                     SyntheticCategories(image: R.image.ic_sleep()!, title: R.string.localizable.smart_watch_s5_sleep(), type: .sleep, value: "--  -- ")]

struct SyntheticData {
    var run: String
    var step: String
    var calo: String
    var hr: String
    var spO2: String
    var bp: String
    var temp: String
    var sleep: String
}
