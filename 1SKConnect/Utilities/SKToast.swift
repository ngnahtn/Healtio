//
//  SKToast.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import UIKit
import SnapKit

class SKToast {
    private var toastView = UIView()
    private var contentLabel = UILabel()
    private var timer: Timer?
    private let animationTime = Constant.Number.animationTime

    static let shared = SKToast()
    private init() {
        setupUI()
    }

    func setupUI() {
        toastView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(5)
        }
        toastView.cornerRadius = 6
        toastView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        toastView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.textColor = .white
        // contentLabel.font = SKFont.helvetica.ofSize(size: 16)
        contentLabel.textAlignment = .center
    }

    func showToast(content: String = "Đã có lỗi xảy ra") {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(toastView)
        toastView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
        }
        contentLabel.text = content
        UIView.animate(withDuration: animationTime, animations: {
            self.toastView.alpha = 1
        }, completion: { _ in
            self.startTimer()
        })
    }

    func showToast(content: String, on viewController: UIViewController) {
        viewController.view.addSubview(toastView)
        toastView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
        }
        contentLabel.text = content
        UIView.animate(withDuration: animationTime, animations: {
            self.toastView.alpha = 1
        }, completion: { _ in
            self.startTimer()
        })
    }

    func showErrorMessage(with error: APIError) {
        if error.statusCode == -999 { // Cancel
            return
        } else {
            showToast(content: error.message)
        }
    }

    @objc private func hide() {
        UIView.animate(withDuration: animationTime, animations: {
            self.toastView.alpha = 0
        }, completion: { (_) in
            self.contentLabel.text = ""
            self.toastView.removeFromSuperview()
            self.endTimer()
        })
    }

    private func startTimer() {
        endTimer()
        timer = Timer.scheduledTimer(timeInterval: 2,
                                     target: self,
                                     selector: #selector(hide),
                                     userInfo: nil,
                                     repeats: false)
    }

    private func endTimer() {
        timer?.invalidate()
        timer = nil
    }
}
