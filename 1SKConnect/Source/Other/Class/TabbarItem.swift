//
//  TabbarItem.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//

import UIKit

enum TabbarItem {
    case home
    case tracking
    case notification
    case setting

    var item: UITabBarItem {
        switch self {
        case .home:
            return UITabBarItem(title: L.home.localized,
                                image: tabbarImage(with: R.image.ic_home()),
                                selectedImage: tabbarImage(with: R.image.ic_home_selected()))
        case .tracking:
            return UITabBarItem(title: L.tracking.localized,
                                image: tabbarImage(with: R.image.ic_tracking()),
                                selectedImage: tabbarImage(with: R.image.ic_tracking_selected()))
        case .notification:
            return UITabBarItem(title: L.notification.localized,
                                image: tabbarImage(with: R.image.ic_notification()),
                                selectedImage: tabbarImage(with: R.image.ic_notification_selected()))
        case .setting:
            return UITabBarItem(title: L.setting.localized,
                                image: tabbarImage(with: R.image.ic_setting()),
                                selectedImage: tabbarImage(with: R.image.ic_setting_selected()))
        }
    }

    private func tabbarImage(with image: UIImage?) -> UIImage? {
        return image?.withRenderingMode(.alwaysOriginal)
    }
}
