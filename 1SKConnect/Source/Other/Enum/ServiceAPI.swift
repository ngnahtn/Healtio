//
//  ServiceAPI.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//

import Foundation

/// Api for config services
enum ConfigServiceAPI: ApiUrlProtocol {
    case updateNotifyStatus
    case notify
    case notifyNumber
    case saveDeviceToken
    case facebookLogin
    case googleLogin
    case syncData
    case syncDelete
    case bloodPressureSyncData

    var path: String {
        switch self {
        case .updateNotifyStatus:
            return "config/updateStatusNotifyUser"
        case .notify:
            return "notify"
        case . notifyNumber:
            return "config/getNumberNotify"
        case .saveDeviceToken:
            return "config/saveDeviceToken"
        case .facebookLogin:
            return "user/social-login/facebook"
        case .googleLogin:
            return "user/social-login/google"
        case .syncData:
            return "connect/sync-data"
        case .syncDelete:
            return "connect/sync-data/delete"
        case .bloodPressureSyncData:
            return "connect/blood-pressure"
        }
    }
}

/// Api for synchronize s5 data
enum SyncS5ServiceAPI: ApiUrlProtocol {
    case step
    case sleep
    case heartRate
    case bloodPressure
    case bloodOxigen
    case temperature
    case sport
    
    var path: String {
        switch self {
        case .step:
            return "connect/s5/steps"
        case .sleep:
            return "connect/s5/sleeps"
        case .heartRate:
            return "connect/s5/heart-rates"
        case .bloodPressure:
            return "connect/s5/blood-pressures"
        case .bloodOxigen:
            return "connect/s5/blood-oxigens"
        case .temperature:
            return "connect/s5/temperatures"
        case .sport:
            return "connect/s5/sports"
        }
    }
}
