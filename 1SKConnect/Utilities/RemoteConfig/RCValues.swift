//
//  RCValues.swift
//  1SKConnect
//
//  Created by TrungDN on 14/02/2022.
//

import Foundation
import FirebaseRemoteConfig

enum RCValueKey: String {
    case baseUrlDev = "base_url_dev"
    case baseUrl = "base_url"
}

class RCValues {
    static let sharedInstance = RCValues()
    
    private init() {
        self.loadDefaultValues()
        self.fetchCloudValues()
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            RCValueKey.baseUrlDev.rawValue: "",
            RCValueKey.baseUrl.rawValue: ""
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
    func activateDebugMode() {
        let settings = RemoteConfigSettings()
        // WARNING: Don't actually do this in production!
        
        // set minimumFetchInterval = 43200 mean it will change within a day.
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
    }
    
    func fetchCloudValues() {
        // only use this for debugging
        activateDebugMode()
        
        // fetch data
        RemoteConfig.remoteConfig().fetch { [weak self] _, error in
            if let error = error {
                print("Uh-oh. Got an error fetching remote values \(error)")
                // In a real app, you would probably want to call the loading
                // done callback anyway, and just proceed with the default values.
                // I won't do that here, so we can call attention
                // to the fact that Remote Config isn't loading.
                return
            }
            
            // 3
            RemoteConfig.remoteConfig().activate { _, _ in
                print("Retrieved values from the cloud!")
            }
        }
    }
    
    func baseUrl(forKey key: RCValueKey) -> String {
        if let value = RemoteConfig.remoteConfig()[key.rawValue].jsonValue as? [String: Any] {
            dLogDebug(value[RCValueKey.baseUrl.rawValue] as? String ?? "")
            return value[RCValueKey.baseUrl.rawValue] as? String ?? ""
        }
        return ""
    }
}
