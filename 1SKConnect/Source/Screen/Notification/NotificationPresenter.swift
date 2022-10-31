//
//  
//  NotificationPresenter.swift
//  1SK
//
//  Created by tuyenvx on 25/02/2021.
//
//

import UIKit

class NotificationPresenter {

    weak var view: NotificationViewProtocol?
    private var interactor: NotificationInteractorInputProtocol
    private var router: NotificationRouterProtocol

    // Loadmore
    var notifications: [NotificationModel] = []
    private var totalItem = 0
    private var currentPage = 1
    private var isFetchingItems = false
    private let limit = 10

    init(interactor: NotificationInteractorInputProtocol,
         router: NotificationRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    private func loadItem(in page: Int) {
        if page == 1 {
            router.showHud()
        }
        isFetchingItems = true
        let userID = ""//GenericDAO<UserModel>().getFirstObject()?.uuid ?? ""
        interactor.getListNotifications(with: userID, page: page, limit: limit)
    }

    private func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            DispatchQueue.main.async {
                switch setting.authorizationStatus {
                case .notDetermined:
                    self.view?.updateView(with: false)
                case .denied:
                    self.view?.updateView(with: false)
                case .authorized:
                    self.view?.updateView(with: true)
                case .provisional:
                    self.view?.updateView(with: true)
                case .ephemeral:
                    self.view?.updateView(with: false)
                @unknown default:
                    self.view?.updateView(with: false)
                }
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    private func requestNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isSuccess, _) in
            DispatchQueue.main.async {
                self.view?.updateView(with: isSuccess)
            }
        }
    }

    @objc func onApplicationWillEnterForeground() {
        checkNotificationAuthorization()
    }

}

// MARK: - extending NotificationPresenter: NotificationPresenterProtocol -
extension NotificationPresenter: NotificationPresenterProtocol {
    func onViewDidLoad() {
        loadItem(in: currentPage)
        kNotificationCenter.addObserver(self, selector: #selector(onApplicationWillEnterForeground), name: .willEnterForeground, object: nil)
        interactor.addCountedNotifications(notifications)
    }

    func onViewWillAppear() {
        checkNotificationAuthorization()
    }

    func numberOfRow(in section: Int) -> Int {
        return totalItem
    }

    func itemForRow(at index: IndexPath) -> NotificationModel? {
        return  index.row < notifications.count ? notifications[index.row] : nil
    }

    func onItemDidSelected(at index: IndexPath) {
        let notification = notifications[index.row]
        if let url = URL(string: notification.url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        if !interactor.isNotificationHasRead(id: notification.id) {
            let readNotification = ReadNotification(id: notification.id)
            interactor.addReadNotification(readNotification)
        }
    }

    func onPrefetchItem(at indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            if needFetchData(indexPath: indexPath) && !isFetchingItems {
                // Fetch more data
                loadItem(in: currentPage + 1)
            }
        }
    }

    func onButtonTurnOnNotificationDidTapped() {
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            DispatchQueue.main.async {
                switch setting.authorizationStatus {
                case .notDetermined:
                    self.requestNotificationAuthorization()
                case .authorized, .ephemeral:
                    break
                default:
                    self.openAppSetting()
                }
            }
        }
    }

    func isNotificationHasRead(at index: IndexPath) -> Bool {
        return interactor.isNotificationHasRead(id: notifications[index.row].id)
    }

    private func openAppSetting() {
        guard let settingURL = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingURL) else {
            return
        }
        UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
    }

}

// MARK: - NotificationPresenter: NotificationInteractorOutput -
extension NotificationPresenter: NotificationInteractorOutputProtocol {
    func onGetListNotificationsFinished(with result: Result<[NotificationModel], APIError>, page: Int, total: Int) {
        SKUserDefaults.shared.totalNotification = total
        isFetchingItems = false
        switch result {
        case .success(let notifications):
            let isLoadmore = page != 1
            if isLoadmore {
                self.handleLoadmoreItems(notifications)
            } else {
                self.notifications = notifications
                totalItem = total
                view?.reloadData()
                router.hideHud()
                router.hideErrorView()
            }
            interactor.addCountedNotifications(notifications)
            currentPage = page
        case .failure:
            router.hideHud()
            dLogDebug("Noti error")
//            router.showErrorView(with: nil, delegate: self, offsetTop: 0, offsetBottom: 0, position: .aboveTabbar)
        }
    }

    func onUpdateNotificationStatusFinished(with result: Result<NotificationModel, APIError>) {
        switch result {
        case .success(let notification):
            if notifications.firstIndex(where: { $0.id == notification.id }) != nil {
                // update cell
            }
        case .failure(let error):
            print(error)
        }
    }
}
// MARK: - Load more
extension NotificationPresenter {
    private func handleLoadmoreItems(_ items: [NotificationModel]) {
        self.notifications.append(contentsOf: items)
        let visibleIndexPaths = view?.getVisibleIndexPath()
        let startIndex = (currentPage - 1) * limit
        let endIndex = min(startIndex + limit, totalItem)
        view?.reloadData()
        // Continue fetch if needed
        if visibleIndexPaths?.contains(where: { $0.row >= endIndex }) ?? false && !isFetchingItems {
            loadItem(in: currentPage + 1)
        }
    }

    private func needFetchData(indexPath: IndexPath) -> Bool {
        let numberOfItem = notifications.count
        return indexPath.row >= numberOfItem && indexPath.row < totalItem
    }
}
// MARK: - ErrorView Delegate
extension NotificationPresenter: ErrorViewDelegate {
    func onRetryButtonDidTapped(_ errorView: UIView) {
        loadItem(in: 1)
    }
}
