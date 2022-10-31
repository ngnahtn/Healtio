//
//  
//  StartPresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//
//

import UIKit
import SkeletonView
import FirebaseMessaging
import CoreText

class StartPresenter: NSObject {

    weak var view: StartViewProtocol?
    private var interactor: StartInteractorInputProtocol
    private var router: StartRouterProtocol

    init(interactor: StartInteractorInputProtocol,
         router: StartRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    // MARK: - Action

}

// MARK: - extending StartPresenter: StartPresenterProtocol -
extension StartPresenter: StartPresenterProtocol {
    func onViewDidLoad() {
        Messaging.messaging().delegate = self
        Messaging.messaging().subscribe(toTopic: "All")
        SKUserDefaults.shared.numberOfUncountNotification = nil
        interactor.getNumberNotification("")
    }

    func onViewDidAppear() {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self

        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let profile = profileListDAO.getFirstObject()?.profiles, !profile.isEmpty else {
            router.showCreateProfileViewController(delegate: self)
            return
        }
        router.showMainTabbarController()
    }
}

// MARK: - StartPresenter: StartInteractorOutput -
extension StartPresenter: StartInteractorOutputProtocol {
    func onGetNumberNotificationFinished(with totalNotificationNumber: Int) {
        SKUserDefaults.shared.totalNotification = totalNotificationNumber
    }
}
// MARK: - CreateDefautlsProfilePresenterDelegate
extension StartPresenter: CreateDefautlsProfilePresenterDelegate {
    func didCreateDefaultProfile() {
        router.showMainTabbarController()
    }
}
// MARK: - MessagingDelegate
extension StartPresenter: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let `fcmToken` = fcmToken else {
            return
        }
//        self.fcmToken = fcmToken
//        interactor.saveDeviceToken(fcmToken)
//        let dataDict: [String: String] = ["token": fcmToken]
//          kNotificationCenter.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
// MARK: - UNUserNotificationCenterDelegate
extension StartPresenter: UNUserNotificationCenterDelegate {
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print message ID.
    if let messageID = userInfo["gcmMessageIDKey"] {
      print("Message ID: \(messageID)")
    }

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.alert, .sound]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageID = userInfo["gcmMessageIDKey"] {
      print("Message ID: \(messageID)")
    }

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)

    completionHandler()
  }
}
