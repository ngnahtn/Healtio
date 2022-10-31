//
//  BaseViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//

import UIKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    private var hud: UIActivityIndicatorView?
    private var loadingView: UIView?
    var errorView: ErrorView?

    var isInteractivePopGestureEnable = false {
        didSet {
            updateInteractivePopGesture()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let `navigationController` = navigationController, self != navigationController.viewControllers.first {
            setLeftBackButton()
        }
        addIndicator()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateInteractivePopGesture()

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return .darkContent
        }
        return .default
    }

    func setLeftBackButton(_ isInteractivePopGestureEnable: Bool = true) {
        setLeftBarButton(style: .back) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        self.isInteractivePopGestureEnable = isInteractivePopGestureEnable
    }

    func setNavagationBarHidden(_ viewControllers: UIViewController.Type...) {
        guard let baseNavigationController = navigationController as? BaseNavigationController else {
            return
        }
        baseNavigationController.setHiddenNavigationBarViewControllers(viewControllers)
    }

    private func updateInteractivePopGesture() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isInteractivePopGestureEnable
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
}
// MARK: - Loading
extension BaseViewController {
    private func addIndicator() {
        loadingView = UIView()
        loadingView!.backgroundColor = .clear
        loadingView?.alpha = 0
        loadingView?.isHidden = true
        view.addSubview(loadingView!)
        view.bringSubviewToFront(loadingView!)
        loadingView?.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        hud = UIActivityIndicatorView(style: .whiteLarge)
//        hud?.color = R.color.mainColor()
        let hudBGView = UIView()
        hudBGView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.53)
        loadingView?.addSubview(hudBGView)
        hudBGView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
        hudBGView.cornerRadius = 8
        hudBGView.addSubview(hud!)
        hud?.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }

    func showHud(offsetTop: CGFloat = 0,
                 offsetBottom: CGFloat = 0,
                 position: SKLoadingViewPosition = .full,
                 backgroundColor: UIColor = .clear) {
        loadingView!.backgroundColor = backgroundColor
        view.bringSubviewToFront(loadingView!)
        let navigationBarHeight = navigationController?.navigationBar.height ?? 0
        let tabbarHeight = tabBarController?.tabBar.height ?? 0
        var statusBarHeight = UIApplication.shared.statusBarFrame.height
        if #available(iOS 13, *) {
            statusBarHeight = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
        var topMargin: CGFloat = 0
        var bottomMargin: CGFloat = 0
        switch position {
        case .full:
            topMargin = offsetTop
            bottomMargin = offsetBottom
        case .underStatusBar:
            topMargin = statusBarHeight + offsetTop
            bottomMargin = offsetBottom
        case .aboveTabbar:
            topMargin = offsetTop
            bottomMargin = tabbarHeight + offsetBottom
        case .underNavigationBar:
            topMargin = statusBarHeight + navigationBarHeight + offsetTop
            bottomMargin = offsetBottom
        case .aboveTabbarAndUnderNavigationBar:
            topMargin = statusBarHeight + navigationBarHeight + offsetTop
            bottomMargin = offsetBottom + tabbarHeight
        case .aboveTabbarAndUnderStatusBar:
            topMargin = statusBarHeight + offsetTop
            bottomMargin = offsetBottom + tabbarHeight
        }

        loadingView?.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(topMargin)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-bottomMargin)
        }
        hud?.startAnimating()
        loadingView?.isHidden = false
//        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.loadingView?.alpha = 1
            self.view.layoutIfNeeded()
//        })

    }

    func hideHud() {
        hud?.stopAnimating()
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.loadingView?.alpha = 0
        }, completion: { _ in
            self.loadingView?.isHidden = true
        })
    }
}
// MARK: - Error View
extension BaseViewController {
    func showErrorView(with content: String?,
                       delegate: ErrorViewDelegate,
                       position: SKLoadingViewPosition = .full,
                       offsetTop: CGFloat = 0,
                       offsetBottom: CGFloat = 0) {
        if let `errorView` = errorView {
            errorView.removeFromSuperview()
            self.errorView = nil
        }
        let navigationBarHeight = navigationController?.navigationBar.height ?? 0
        let tabbarHeight = tabBarController?.tabBar.height ?? 0
        var statusBarHeight = UIApplication.shared.statusBarFrame.height
        if #available(iOS 13, *) {
            statusBarHeight = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
        var topMargin: CGFloat = 0
        var bottomMargin: CGFloat = 0
        switch position {
        case .full:
            topMargin = offsetTop
            bottomMargin = offsetBottom
        case .underStatusBar:
            topMargin = statusBarHeight + offsetTop
            bottomMargin = offsetBottom
        case .aboveTabbar:
            topMargin = offsetTop
            bottomMargin = tabbarHeight + offsetBottom
        case .underNavigationBar:
            topMargin = statusBarHeight + navigationBarHeight + offsetTop
            bottomMargin = offsetBottom
        case .aboveTabbarAndUnderNavigationBar:
            topMargin = statusBarHeight + navigationBarHeight + offsetTop
            bottomMargin = offsetBottom + tabbarHeight
        case .aboveTabbarAndUnderStatusBar:
            topMargin = statusBarHeight + offsetTop
            bottomMargin = offsetBottom + tabbarHeight
        }

        errorView = ErrorView(message: content ?? "Không thể tải dữ liệu")
        view.addSubview(errorView!)
        errorView?.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(topMargin)
            make.bottom.equalToSuperview().offset(-bottomMargin)
        }
        errorView?.delegate = delegate
        view.bringSubviewToFront(errorView!)
    }

    func hideErrorView() {
        errorView?.removeFromSuperview()
        errorView = nil
    }
}
// MARK: - UIGestureRecognizerDelegate
extension BaseViewController {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer else {
            return true
        }
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
