//
//  MainTabbarViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//

import UIKit
import RealmSwift

class MainTabbarViewController: UITabBarController {
    
    var token: NotificationToken?
    var countNotificationDao = GenericDAO<CountedNotification>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        setViewController()
        kNotificationCenter.addObserver(self, selector: #selector(onUncountNotificationCountChanged), name: .uncountNotificationCountChanged, object: nil)
        countNotificationDao.registerToken(token: &token) { [weak self] in
            self?.onUncountNotificationCountChanged()
        }
    }

    deinit {
        token?.invalidate()
    }
    
    private func setupDefaults() {
        //        if #available(iOS 13.0, *) {
        //            let tabbarAppearance = tabBar.standardAppearance
        //            tabbarAppearance.shadowImage = image(from: UIColor(hex: "D4D4D4"))
        //            tabbarAppearance.shadowColor = nil
        //            tabBar.standardAppearance = tabbarAppearance
        //        } else {
        //            tabBar.shadowImage = image(from: UIColor(hex: "D4D4D4"))
        //            tabBar.backgroundImage = UIImage()
        //        }
        tabBar.shadowImage = image(from: UIColor(hex: "D4D4D4"))
        tabBar.backgroundImage = UIImage()
        tabBar.tintColor = R.color.mainColor()
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white
        tabBar.unselectedItemTintColor = R.color.title()
        self.view.backgroundColor = .white
    }

    private func image(from color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(color.cgColor)
        context!.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    private func setViewController() {
        let mainHomeVC = MainHomeRouter.setupModule(type: .home)
        let homeNavigationController = BaseNavigationController(rootViewController: mainHomeVC)
        homeNavigationController.setHiddenNavigationBarViewControllers([MainHomeViewController.self, HomeViewController.self])
        mainHomeVC.tabBarItem = TabbarItem.home.item

        let trackingVC = MainHomeRouter.setupModule(type: .tracking)
        let trackingNavigationController = BaseNavigationController(rootViewController: trackingVC)
        trackingNavigationController.setHiddenNavigationBarViewControllers([MainHomeViewController.self])
        trackingVC.tabBarItem = TabbarItem.tracking.item

        let notificationVC = NotificationRouter.setupModule()
        let notificationNavigationController = BaseNavigationController(rootViewController: notificationVC)
        //        notificationNavigationController.setHiddenNavigationBarViewControllers([NotificationViewController.self])
        notificationVC.tabBarItem = TabbarItem.notification.item

        notificationVC.tabBarItem.badgeColor = UIColor(hex: "FF4D4D")

        let settingVC = SettingRouter.setupModule()
        let settingNavigationController = BaseNavigationController(rootViewController: settingVC)
        settingNavigationController.setHiddenNavigationBarViewControllers([SettingViewController.self])
        settingVC.tabBarItem = TabbarItem.setting.item
        viewControllers = [
            homeNavigationController,
            trackingNavigationController,
            notificationNavigationController,
            settingNavigationController
        ]
    }

    @objc func onUncountNotificationCountChanged() {
        let totalNotification = SKUserDefaults.shared.totalNotification ?? 0
        let readNotificationCount = countNotificationDao.getAllObject().count
        if totalNotification >= readNotificationCount {
            let unreadCount = totalNotification - readNotificationCount
            updateUnreadNotificationNumber(unreadCount)
        }
    }

    func showHomeViewController() {
        selectedIndex = 0
        guard let baseNavigation = viewControllers?.first as? BaseNavigationController else {
            return
        }
        if presentedViewController != nil {
            dismiss(animated: true, completion: nil)
        }
        baseNavigation.popToRootViewController(animated: true)
    }

    func updateUnreadNotificationNumber(_ unreadCount: Int?) {
        viewControllers?[2].tabBarItem.badgeValue = unreadCount != 0 ? unreadCount?.stringValue : nil
    }
}
