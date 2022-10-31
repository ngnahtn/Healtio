//
//  SKUserDefaults.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import UIKit

class SKUserDefaults {

    static let shared = SKUserDefaults()
    private let skUserDefaults = UserDefaults(suiteName: "1SKConnect")

    private init() {

    }

    var currentStepGoal: Int {
        get {
            return skUserDefaults?.integer(forKey: SKKey.currentStepGoal) ?? 10000
        }
        set {
            skUserDefaults?.set(newValue, forKey: SKKey.currentStepGoal)
        }
    }
    
    var hasLogin: Bool {
        get {
            return skUserDefaults?.bool(forKey: SKKey.firstLoad) ?? false
        }
        set {
            skUserDefaults?.set(newValue, forKey: SKKey.firstLoad)
        }
    }

    var isSearchOtherDevice: Bool {
        get {
            if skUserDefaults?.value(forKey: SKKey.isSearchForOtherDevice) == nil {
                return true
            }
            return skUserDefaults?.bool(forKey: SKKey.isSearchForOtherDevice) ?? false
        }
        set {
            skUserDefaults?.set(newValue, forKey: SKKey.isSearchForOtherDevice)
        }
    }
        
    dynamic var numberOfUncountNotification: Int? {
        get {
            return skUserDefaults?.integer(forKey: SKKey.numberOfUncountNotification)
        }

        set {
            skUserDefaults?.set(newValue, forKey: SKKey.numberOfUncountNotification)
            kNotificationCenter.post(name: .uncountNotificationCountChanged, object: nil)
        }
    }

    dynamic var totalNotification: Int? {
        get {
            return skUserDefaults?.integer(forKey: SKKey.totalNotification)
        }

        set {
            skUserDefaults?.set(newValue, forKey: SKKey.totalNotification)
            kNotificationCenter.post(name: .uncountNotificationCountChanged, object: nil)
        }
    }
    
    dynamic var token: String {
        get {
            return skUserDefaults?.string(forKey: SKKey.token) ?? ""
        }

        set {
            skUserDefaults?.set(newValue, forKey: SKKey.token)
        }
    }

}
