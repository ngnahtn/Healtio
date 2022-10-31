//
//  AlertView.swift
//  1SK
//
//  Created by tuyenvx on 26/02/2021.
//

import UIKit

protocol AlertViewDelegate: AnyObject {
    func cancelButtonDidTapped()
    func okButtonDidTapped()
}

class AlertView: UIView {
    private lazy var imageView = UIImageView()
    private lazy var contentLabel = UILabel()
    private lazy var cancelButton = UIButton()
    private lazy var okButton = UIButton()

    weak var delegate: AlertViewDelegate?
    private var type: AlertType = .turnOnBluetooth

    var imageViewWidth: CGFloat {
        switch type {
        case .turnOnBluetooth:
            return 116
        case .unLinkDevice(_), .unlinkAccount:
            return 126
        case .deleteProfile:
            return 142
        }
    }

    var imageViewHeight: CGFloat {
        switch type {
        case .turnOnBluetooth:
            return 79
        case .unLinkDevice(_), .unlinkAccount:
            return 60
        case .deleteProfile:
            return 90
        }
    }

    var imageViewTopOffset: CGFloat {
        switch type {
        case .turnOnBluetooth:
            return 28
        case .unLinkDevice(_), .unlinkAccount:
            return 47
        case .deleteProfile:
            return 21
        }
    }

    var imageViewBottomOffset: CGFloat {
        switch type {
        case .turnOnBluetooth:
            return 16
        case .unLinkDevice(_), .unlinkAccount:
            return 27
        case .deleteProfile:
            return 17
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    convenience init(type: AlertType) {
        self.init(frame: .zero)
        self.type = type
        setupDefautls()
        updateByAlertType(type)
    }

    // MARK: - Setup
    private func setupDefautls() {
        setupConstraint()
        setupImageView()
        setupContentLabel()
        setupCancelButton()
        setupOKButton()
    }

    private func setupConstraint() {
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(imageViewWidth)
            make.height.equalTo(imageViewHeight)
            make.top.equalToSuperview().offset(imageViewTopOffset)
        }

        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(imageViewBottomOffset)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }

        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(14)
            make.height.equalTo(35)
//            make.width.equalTo(142)
            make.leading.equalToSuperview().offset(37)
//            make.centerX.equalToSuperview().offset(-80)
        }

        addSubview(okButton)
        okButton.snp.makeConstraints { (make) in
            make.top.bottom.width.equalTo(cancelButton)
            make.leading.equalTo(cancelButton.snp.trailing).offset(18)
            make.trailing.equalToSuperview().inset(37)
            make.bottom.equalToSuperview().offset(-13).priority(249)
        }
    }

    private func setupImageView() {
        imageView.clipsToBounds = false
    }

    private func setupContentLabel() {
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.font = R.font.robotoRegular(size: 16)
        contentLabel.textColor = R.color.title()
        contentLabel.textAlignment = .center
    }

    private func setupCancelButton() {
        cancelButton.backgroundColor = R.color.subTitle()
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = R.font.robotoRegular(size: 16)
        cancelButton.cornerRadius = 4
        cancelButton.addTarget(self, action: #selector(onCancelButtonDidTapped), for: .touchUpInside)
    }

    private func setupOKButton() {
        okButton.backgroundColor = R.color.mainColor()
        okButton.setTitleColor(.white, for: .normal)
        okButton.titleLabel?.font = R.font.robotoRegular(size: 16)
        okButton.cornerRadius = 4
        okButton.addTarget(self, action: #selector(onOkButtonDidTapped), for: .touchUpInside)
    }
    // MARK: - Action
    @objc func onCancelButtonDidTapped() {
        delegate?.cancelButtonDidTapped()
    }

    @objc func onOkButtonDidTapped() {
        delegate?.okButtonDidTapped()
    }

    func updateByAlertType(_ type: AlertType) {
        self.type = type
        imageView.image = type.image
        contentLabel.text = type.content
        cancelButton.setTitle(type.cancelButtonTitle, for: .normal)
        okButton.setTitle(type.okButtonTitle, for: .normal)
    }
}
