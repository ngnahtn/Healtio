//
//  AlertViewController.swift
//  1SK
//
//  Created by tuyenvx on 26/02/2021.
//

import UIKit

protocol AlertViewControllerDelegate: AnyObject {
    func onButtonOKDidTapped(_ type: AlertType)
}

class AlertViewController: BaseViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    var type: AlertType = .turnOnBluetooth
    weak var delegate: AlertViewControllerDelegate?

    var safeAreaBottom: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            return window.safeAreaInsets.bottom
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.bottom ?? 0
        }
    }

    convenience init(type: AlertType) {
        self.init(nibName: String(describing: AlertViewController.self), bundle: nil)
        self.type = type
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addAlertView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }

    private func setupUI() {
        alertView.superview?.roundCorners(cornes: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24)
        alertViewHeightConstraint.constant = 0
    }

    private func addAlertView() {
        let alertView = AlertView(type: type)
        alertView.delegate = self
        self.alertView.addSubview(alertView)
        alertView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    @IBAction func backgroundDidTapped(_ sender: Any) {
        hide()
    }

    func show() {
        self.alertViewHeightConstraint.constant = type.bottomViewHeight + safeAreaBottom
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in

        })
    }

    func hide() {
        self.alertViewHeightConstraint.constant = 0
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }

    private func openAppSetting() {
        guard let settingURL = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingURL) else {
            return
        }
        UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
    }
}
// MARK: - AlertViewDelegate
extension AlertViewController: AlertViewDelegate {
    func cancelButtonDidTapped() {
        hide()
    }

    func okButtonDidTapped() {
        switch type {
        case .turnOnBluetooth:
            openAppSetting()
        case .unLinkDevice, .unlinkAccount:
            delegate?.onButtonOKDidTapped(type)
        case .deleteProfile:
            delegate?.onButtonOKDidTapped(type)
        }
        hide()
    }
}
