//
//  MeasurementType.swift
//  1SKConnect
//
//  Created by Be More on 03/08/2021.
//

import Foundation

/// Scale measurement Type
enum MeasurementType {
    case mass
    case percentage
    case none

    var description: String {
        switch self {
        case .mass:
            return "Kg"
        case .percentage:
            return "%"
        default:
            return ""
        }
    }
}

/// Scale measurement Data
enum MeasurementData {
    case weightPoints
    case musclePoints
    case bonePoints
    case idealWeightPoint
    case waterPoints
    case proteinPoints
    case fatPoints
    case subcutaneousFatPoints
}
