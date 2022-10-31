//
//  BaseNavigationController.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//

import UIKit

class BaseNavigationController: UINavigationController {
    var hiddenNavigationBarViewController: [UIViewController.Type] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        navigationBar.isTranslucent = false
        navigationBar.layer.masksToBounds = false
        navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationBar.layer.shadowOpacity = 0.1
        navigationBar.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        navigationBar.layer.shadowRadius = 4
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()

        self.navigationBar.update(backroundColor: .white, titleColor: R.color.title()!)
        changeTintColor(to: R.color.title()!)
        navigationBar.titleTextAttributes = [
            .foregroundColor: R.color.title()!,
            .font: R.font.robotoRegular(size: 16)!
        ]
        changeBarTintColor(to: .white)
        changeBackgroundColor(to: .white)
        delegate = self
    }

    func setHiddenNavigationBarViewControllers(_ viewControllers: [UIViewController.Type]) {
        hiddenNavigationBarViewController = viewControllers
    }

    func addHiddenNavigationBarViewController(_ viewController: UIViewController.Type) {
        hiddenNavigationBarViewController.append(viewController)
    }
}
extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isHidden = hiddenNavigationBarViewController.first(where: { viewController.isKind(of: $0.self) }) != nil
        navigationController.setNavigationBarHidden(isHidden, animated: true)
    }
}

extension UINavigationBar {
    func update(backroundColor: UIColor? = nil, titleColor: UIColor? = nil) {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()

            if let backroundColor = backroundColor {
              appearance.backgroundColor = backroundColor
            }

            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage()
            if let titleColor = titleColor {
              appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
            }

            self.standardAppearance = appearance
            self.scrollEdgeAppearance = appearance
        } else {
        }
    }
}
