//
//  ActivityData.swift
//  1SKConnect
//
//  Created by tuyenvx on 16/04/2021.
//

import Foundation

enum ActivityData {
    case scale(BodyFat?)
    case bp(BloodPressureModel?)
    case spO2(WaveformListModel?)
    case sport(S5SportRecordModel?)
    case step(StepRecordModel?)
    case s5Bp(BloodPressureRecordModel?)
    case s5SpO2(S5SpO2RecordModel?)
    case s5HR(S5HeartRateRecordModel?)

    var device: DeviceModel? {
        switch self {
        case .scale(let bodyfat):
            return bodyfat?.scale
        case .bp(let bloodpressure):
            return bloodpressure?.biolight
        case .spO2(let spO2):
            return spO2?.device
        case .sport(let excercise):
            return excercise?.s5SmartWatch
        case .step(let stepRecord):
            return stepRecord?.device
        case .s5Bp(let record):
            return record?.device
        case .s5SpO2(let record):
            return record?.device
        case .s5HR(let record):
            return record?.device
        }
    }
}
