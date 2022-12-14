//
//  LocalNotificationManager.swift
//  1SKConnect
//
//  Created by Nguyễn Anh Tuấn on 14/12/2022.
//

import Foundation
import UserNotifications

class LocalNotificationManager {
    var notifications = [LocalNotificationModel]() {
        didSet {
            self.schedule()
        }
    }

    func listScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            notifications.forEach( { print($0) })
        }
    }
    
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break // Do nothing
            }
        }
    }
    
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (granted, error) in
            guard let `self` = self else { return }
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    private func scheduleNotifications() {
        notifications.forEach { notification in
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.dateTime, repeats: true)
            
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                
                print("Notification scheduled! --- title = \(notification.title)")
            }
        }
    }
}
