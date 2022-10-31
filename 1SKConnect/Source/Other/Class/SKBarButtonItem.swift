//
//  SKBarButtonItem.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import UIKit

class SKBarButtonItem: UIBarButtonItem {
    private var actionHandler: ((SKBarButtonItem) -> Void)?

    convenience init(style: BarButtonStyle, actionHandler: ((SKBarButtonItem) -> Void)?) {
        self.init(image: style.image, style: .plain, target: nil, action: #selector(didTapped))
        self.target = self
        self.actionHandler = actionHandler
    }

    @objc func didTapped(sender: SKBarButtonItem) {
        actionHandler?(sender)
    }
}
// MARK: - SKBarButton Style
extension SKBarButtonItem {
    enum BarButtonStyle {
        case back
        case close
        case addProfile
        case delete
        case option
        case sync

        var image: UIImage? {
            switch self {
            case .back:
                return R.image.ic_back()
            case .close:
                return R.image.ic_close()
            case .addProfile:
                return R.image.ic_add_profile()
            case .delete:
                return R.image.ic_delete()
            case .option:
                return R.image.ic_option()
            case .sync:
                return R.image.ic_sync()
            }
        }
    }
}
