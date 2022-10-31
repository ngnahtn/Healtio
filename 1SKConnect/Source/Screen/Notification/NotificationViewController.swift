//
//  
//  NotificationViewController.swift
//  1SK
//
//  Created by tuyenvx on 25/02/2021.
//
//

import UIKit
import Photos
import PhotosUI

class NotificationViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var turnOnNotificationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noNotificationView: UIView!

    var presenter: NotificationPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.onViewWillAppear()
    }

    private func setupDefaults() {
        setupTableView()
        navigationItem.title = L.notification.localized
    }

    private func setupTableView() {
        tableView.registerNib(ofType: NotificationTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.estimatedRowHeight = 91
        tableView.contentInset.top = 0
    }

    @IBAction func turnOnNotificationButtonDidTapped(_ sender: Any) {
        presenter.onButtonTurnOnNotificationDidTapped()
    }
}

// MARK: NotificationViewController - NotificationViewProtocol -
extension NotificationViewController: NotificationViewProtocol {

    func reloadData() {
        tableView.reloadData()
        noNotificationView.isHidden = presenter.numberOfRow(in: 0) > 0
    }

    func getVisibleIndexPath() -> [IndexPath]? {
        return tableView.indexPathsForVisibleRows
    }

    func updateNotificationStatus(at index: Int, status: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? NotificationTableViewCell {
            cell.updateStatus(with: status)
        }
    }

    func updateView(with canReceiveNotification: Bool) {
//        turnOnNotificationViewHeightConstraint.constant = canReceiveNotification ? 0 : 80
        tableView.contentInset.top = canReceiveNotification ? 0 : 0
    }

    func updateUnreadCount(_ unreadCount: Int) {
        tabBarItem.badgeValue = unreadCount > 0 ? unreadCount.stringValue : nil
    }

}

// MARK: - UITableView DataSource
extension NotificationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRow(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: NotificationTableViewCell.self, for: indexPath)
        let item = presenter.itemForRow(at: indexPath)
        cell.config(with: item, hasRead: presenter.isNotificationHasRead(at: indexPath))
        return cell
    }

}

// MARK: - UITableView Delegate
extension NotificationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.onItemDidSelected(at: indexPath)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

// MARK: - UITableViewDataSourcePrefetching
extension NotificationViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        presenter.onPrefetchItem(at: indexPaths)
    }

}
