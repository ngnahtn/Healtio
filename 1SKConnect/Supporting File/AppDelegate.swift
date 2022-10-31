//
//  AppDelegate.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//

import UIKit
import IQKeyboardManagerSwift
import RealmSwift
import Firebase
import FirebaseMessaging
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
          
        FirebaseApp.configure()
        
        // Remote config
        _ = RCValues.sharedInstance
        
        // Config Realm
        configRealm()
        
        // IQKeyboard manager
        IQKeyboardManager.shared.enable = true
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        print(Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? "")
        
        let iOSVersion = ProcessInfo().operatingSystemVersion.majorVersion
        if iOSVersion < 13 { // iOS version < 13.0.0
            let frame = UIScreen.main.bounds
            let windowSize = CGSize(width: min(frame.width, frame.height), height: max(frame.width, frame.height))
            window = UIWindow(frame: CGRect(origin: .zero, size: windowSize))
            let startViewController = StartRouter.setupModule()
            window?.rootViewController = startViewController
            window?.makeKeyAndVisible()
        }
        return true
    }
    
    func application(
           _ app: UIApplication,
           open url: URL,
           options: [UIApplication.OpenURLOptionsKey : Any] = [:]
       ) -> Bool {

           ApplicationDelegate.shared.application(
               app,
               open: url,
               sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
               annotation: options[UIApplication.OpenURLOptionsKey.annotation]
           )

       }  

    func applicationWillEnterForeground(_ application: UIApplication) {
        kNotificationCenter.post(name: .willEnterForeground, object: nil)
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func configRealm() {
        let encryptionKeyData = KeyChainManager.shared.encryptionKey
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            encryptionKey: encryptionKeyData,
            schemaVersion: 4,
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: ProfileModel.className()) { (oldObject, newObject) in
                        newObject!["linkAccount"] = nil
                        newObject!["enableAutomaticSync"] = false
                        newObject!["lastSyncDate"] = ""
                        newObject!["linkAccountId"] = ""
                        newObject!["deleteSyncId"] = List<String>()
                        newObject!["needDowloadData"] = false
                        newObject!["scaleDowloadMonths"] = RealmOptional<Int>()
                        newObject!["spO2DowloadMonths"] = RealmOptional<Int>()
                    }

                    migration.enumerateObjects(ofType: BodyFat.className()) { oldObject, newObject in
                        newObject!["bmrStatus"] = ""
                        newObject!["weightOfMuscleStatus"] = ""
                        newObject!["weightOfBoneStatus"] = ""
                        newObject!["ratioOfFatStatus"] = ""
                        newObject!["syncId"] = ""
                        newObject!["isSync"] = false
                        newObject!["subcutaneousFatStatus"] = ""
                    }
                }

                if oldSchemaVersion < 3 {
                    migration.enumerateObjects(ofType: BodyFat.className()) { oldObject, newObject in
                        newObject!["impedance"] = 0
                    }
                    migration.enumerateObjects(ofType: ProfileModel.className()) { (oldObject, newObject) in
                        newObject!["bpDeleteSyncId"] = List<String>()
                    }
                    migration.enumerateObjects(ofType: DeviceModel.className()) { (oldObject, newObject) in
                        newObject!["fileList"] = List<String>()
                    }
                }
                
                if oldSchemaVersion < 4 { }
            })
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
}