//
//  ZHJSportMode+Extension.swift
//  1SKConnect
//
//  Created by Be More on 25/12/2021.
//

import Foundation
import TrusangBluetooth

extension ZHJSportMode {
    func getSportName() -> String {
        switch ZHJSportModeType(rawValue: sportType) {
        case .some(.walk):
            return "walk"
        case .some(.run):
            return "running"
        case .some(.ride):
            return "Cycling"
        case .some(.indoorRun):
            return "Indoor running"
        case .some(.freeTrain):
            return "Free training"
        case .some(.football):
            return "football"
        case .some(.basketball):
            return "basketball"
        case .some(.badminton):
            return "badminton"
        case .some(.ropeSkip):
            return "jump rope"
        case .some(.pushUps):
            return "push ups"
        case .some(.sitUps):
            return "Sit-ups"
        case .some(.climb):
            return "Climbing"
        case .some(.tennis):
            return "tennis"
        default:
            return "unknown"
        }
    }
}
