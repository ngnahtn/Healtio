//
//  UIViewController+Extension.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//

import UIKit
extension UIViewController {
    static func loadFromNib() -> Self {
        return self.init(nibName: String(describing: self), bundle: nil)
    }

    func setLeftBarButton(style: SKBarButtonItem.BarButtonStyle, handler: ((SKBarButtonItem) -> Void)?) {
        let barButton = SKBarButtonItem(style: style, actionHandler: handler)
        navigationItem.setLeftBarButton(barButton, animated: true)
    }

    func setRightBarButton(style: SKBarButtonItem.BarButtonStyle, handler: ((SKBarButtonItem) -> Void)?) {
        let barButton = SKBarButtonItem(style: style, actionHandler: handler)
        navigationItem.setRightBarButton(barButton, animated: true)
    }
}

extension UIViewController {
    /// present alert with one button
    /// - Parameters:
    ///   - error: errort to present
    /// - Returns: Voic
    func presentError(_ error: Error) {
        let alertController = UIAlertController(title: R.string.localizable.alert_error(),
                                                message: error.localizedDescription,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: R.string.localizable.agree(), style: .default))
        self.present(alertController, animated: true)
    }

    /// present message with one button
    /// - Parameters:
    ///   - message: message to present
    /// - Returns: Void
    func presentMessage(_ message: String) {
        let alertController = UIAlertController(title: R.string.localizable.notification(),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: R.string.localizable.agree(), style: .default))
        self.present(alertController, animated: true)
    }

    /// present message with one button
    /// - Parameters:
    ///   - message: message to present
    /// - Returns: Void
    func presentMessage(_ message: String, cancelHandler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: R.string.localizable.notification(),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: R.string.localizable.agree(), style: .default, handler: cancelHandler))
        self.present(alertController, animated: true)
    }

    /// present message with two buttons
    /// - Parameters:
    ///   - message: message to present
    /// - Returns: Void
    func presentMessage(_ message: String, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: R.string.localizable.notification(),
                                                message: message,
                                                preferredStyle: .alert)

        let ok = UIAlertAction(title: R.string.localizable.agree(), style: .default, handler: handler)

        let cancel = UIAlertAction(title: R.string.localizable.alert_cancel(), style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(ok)
        alertController.addAction(cancel)

        self.present(alertController, animated: true, completion: nil)
    }

    /// Change root view controller
    /// - Parameters:
    ///   - rootViewController: change to view controller
    ///   - options: animation option, default is curveLinear
    ///   - duration: animation duration, default is 0
    /// - Returns: Void
    func changeRootViewControllerTo(rootViewController: UIViewController, withOption options: UIView.AnimationOptions = .curveLinear, duration: TimeInterval = 2) {
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let sceneDelegate = windowScene.delegate as? SceneDelegate
            else {
                return
            }

            sceneDelegate.window?.rootViewController = rootViewController

            UIView.transition(with: sceneDelegate.window!,
                              duration: duration,
                              options: options,
                              animations: {},
                              completion: { completed in })
        } else {
            UIApplication.shared.windows.first?.rootViewController = rootViewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }

}
