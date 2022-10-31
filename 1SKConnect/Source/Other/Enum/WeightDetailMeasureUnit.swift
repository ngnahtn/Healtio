//
//  WeightDetailMeasureUnit.swift
//  1SKConnect
//
//  Created by Elcom Corp on 02/11/2021.
//

import Foundation

enum WeightDetailMeasureUnit {
    case weight
    case percentage
    case kcal
    case none

    var desciption: String {
        switch self {
        case .weight:
            return "Kg"
        case .kcal:
            return "Kcal"
        case .percentage:
            return "%"
        case .none:
            return ""
        }
    }
}
