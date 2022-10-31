//
//  BaseRouterProtocol.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import Foundation

protocol BaseRouterProtocol {
    func showHud()
    func showHud(offsetTop: CGFloat, offsetBottom: CGFloat, position: SKLoadingViewPosition, backgroundColor: UIColor)
    func hideHud()
    func showToast(content: String?)
    func showErrorView(with content: String?, delegate: ErrorViewDelegate)
    func showErrorView(with content: String?,
                       delegate: ErrorViewDelegate,
                       offsetTop: CGFloat,
                       offsetBottom: CGFloat,
                       position: SKLoadingViewPosition)
    func hideErrorView()
}

class BaseRouter: BaseRouterProtocol {
    weak var viewController: UIViewController?

    func showHud() {
        guard let `viewController` = viewController as? BaseViewController else {
            return
        }
        viewController.showHud()
    }

    func showHud(offsetTop: CGFloat = 0,
                 offsetBottom: CGFloat = 0,
                 position: SKLoadingViewPosition = .full,
                 backgroundColor: UIColor = .clear) {
        guard let `viewController` = viewController as? BaseViewController else {
            return
        }
        viewController.showHud(offsetTop: offsetTop,
                               offsetBottom: offsetBottom,
                               position: position,
                               backgroundColor: backgroundColor)
    }

    func hideHud() {
        guard let `viewController` = viewController as? BaseViewController else {
            return
        }
        viewController.hideHud()
    }

    func showToast(content: String?) {
        guard let `viewController` = viewController,
              let `content` = content,
              !content.isEmpty else {
            return
        }
        SKToast.shared.showToast(content: content, on: viewController)
    }

    func showErrorView(with content: String?,
                       delegate: ErrorViewDelegate,
                       offsetTop: CGFloat = 0,
                       offsetBottom: CGFloat = 0,
                       position: SKLoadingViewPosition = .full) {
        if let `viewController` = viewController as? BaseViewController {
            viewController.showErrorView(with: content,
                                         delegate: delegate,
                                         position: position,
                                         offsetTop: offsetTop,
                                         offsetBottom: offsetBottom)
        }
    }

    func showErrorView(with content: String?, delegate: ErrorViewDelegate) {
        if let `viewController` = viewController as? BaseViewController {
            viewController.showErrorView(with: content, delegate: delegate)
        }
    }
//
    func hideErrorView() {
        if let baseViewController = viewController as? BaseViewController,
           let errorView = baseViewController.errorView {
            errorView.removeFromSuperview()
            baseViewController.errorView = nil
        }
    }
}
