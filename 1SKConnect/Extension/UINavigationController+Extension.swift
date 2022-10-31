//
//  UINavigationController+Extension.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//

import UIKit

extension UINavigationController {
    func changeBackgroundColor(to color: UIColor?) {
        navigationBar.barTintColor = color
    }

    func changeTintColor(to color: UIColor?) {
        navigationBar.tintColor = color
    }

    func changeBarTintColor(to color: UIColor?) {
        navigationBar.barTintColor = color
    }

    func changeTitleColor(to color: UIColor) {
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
    }

    func setSeperatorLineHidden(_ isHidden: Bool) {
        navigationBar.setValue(isHidden, forKey: "hidesShadow")
    }
}
