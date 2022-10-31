//
//  
//  NotificationConstract.swift
//  1SK
//
//  Created by tuyenvx on 25/02/2021.
//
//

import UIKit

// MARK: View -
protocol NotificationViewProtocol: AnyObject {
    func reloadData()
    func getVisibleIndexPath() -> [IndexPath]?
    func updateView(with canReceiveNotification: Bool)
    func updateNotificationStatus(at index: Int, status: Int)
    func updateUnreadCount(_ unreadCount: Int)
}

// MARK: Interactor -
protocol NotificationInteractorInputProtocol {
    func getListNotifications(with userID: String, page: Int, limit: Int)
    func updateNotificationStatus(with notificationID: String)
    func isNotificationHasRead(id: String) -> Bool
    func addReadNotification(_ readNotification: ReadNotification)
    func addCountedNotifications(_ notifications: [NotificationModel])
}

protocol NotificationInteractorOutputProtocol: AnyObject {
    func onGetListNotificationsFinished(with result: Result<[NotificationModel], APIError>, page: Int, total: Int)
    func onUpdateNotificationStatusFinished(with result: Result<NotificationModel, APIError>)
}
// MARK: Presenter -
protocol NotificationPresenterProtocol {
    func onViewDidLoad()
    func onViewWillAppear()
    func numberOfRow(in section: Int) -> Int
    func itemForRow(at index: IndexPath) -> NotificationModel?
    func onItemDidSelected(at index: IndexPath)
    func onButtonTurnOnNotificationDidTapped()
    func onPrefetchItem(at indexPaths: [IndexPath])
    func isNotificationHasRead(at index: IndexPath) -> Bool
}

// MARK: Router -
protocol NotificationRouterProtocol: BaseRouterProtocol {

}
