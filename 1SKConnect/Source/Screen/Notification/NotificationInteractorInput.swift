//
//  
//  NotificationInteractorInput.swift
//  1SK
//
//  Created by tuyenvx on 25/02/2021.
//
//

import UIKit
import RealmSwift

class NotificationInteractorInput {
    private var readNotificationDAO = GenericDAO<ReadNotification>()
    private var countNotificationDAO = GenericDAO<CountedNotification>()

    weak var output: NotificationInteractorOutputProtocol?
    var configService: ConfigServiceProtocol?
}

// MARK: - NotificationInteractorInput - NotificationInteractorInputProtocol -
extension NotificationInteractorInput: NotificationInteractorInputProtocol {
    func getListNotifications(with userID: String, page: Int, limit: Int) {
        configService?.getListNotification(of: userID, page: page, limit: limit, completion: { [weak self] result in
            let total = result.getTotal() ?? 0
            self?.output?.onGetListNotificationsFinished(with: result.unwrapSuccessModel(), page: page, total: total)
        })
    }

    func updateNotificationStatus(with notificationID: String) {
        configService?.updateNotificationStatus(of: notificationID, completion: { [weak self] result in
            self?.output?.onUpdateNotificationStatusFinished(with: result.unwrapSuccessModel())
        })
    }

    func isNotificationHasRead(id: String) -> Bool {
        return readNotificationDAO.getObject(with: id) != nil 
    }

    func addReadNotification(_ readNotification: ReadNotification) {
        readNotificationDAO.add(readNotification)
    }

    func addCountedNotifications(_ notifications: [NotificationModel]) {
        countNotificationDAO.addList(notifications.map({ CountedNotification(id: $0.id) }))
    }
}
