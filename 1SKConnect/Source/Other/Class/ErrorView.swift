//
//  ErrorView.swift
//  1SKConnect
//
//  Created by tuyenvx on 21/05/2021.
//

import Foundation
import UIKit

protocol ErrorViewDelegate: AnyObject {
    func onRetryButtonDidTapped(_ errorView: UIView)
}


class ErrorView: UIView {

    private var errorMessage: String = ""
    weak var delegate: ErrorViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefatults()
    }

    convenience init(message: String) {
        self.init(frame: .zero)
        errorMessage = message
        setupDefatults()
    }

    private func setupDefatults() {
        backgroundColor = .white
        let view = UIView()
        addSubview(view)
        view.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(51)
        }
        let imageView = UIImageView(image: R.image.error())
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(147)
            make.height.equalTo(98)
        }
        // Title Label
        let titleLabel = createTitleLabel()

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(33)
            make.centerX.equalToSuperview()
        }
        // Content Label
        let contentLabel = createContentLabel()
        view.addSubview(contentLabel)

        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(0)
        }

        let retryButton = createRetryButton()
        view.addSubview(retryButton)

        retryButton.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(19)
            make.centerX.bottom.equalToSuperview()
            make.width.equalTo(146)
            make.height.equalTo(36)
        }
    }

    private func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Đã có lỗi xảy ra"
        titleLabel.font = R.font.robotoRegular(size: 16)
        titleLabel.textColor = R.color.darkText()
        titleLabel.textAlignment = .center
        return titleLabel
    }

    private func createContentLabel() -> UILabel {
        let contentLabel = UILabel()
        contentLabel.font = R.font.robotoRegular(size: 14)
        contentLabel.textColor = R.color.subTitle()
        contentLabel.textAlignment = .center
        contentLabel.text = errorMessage
        return contentLabel
    }

    private func createRetryButton() -> UIButton {
        let retryButton = UIButton()
        retryButton.backgroundColor = R.color.mainColor()
        retryButton.setTitle("Thử lại", for: .normal)
        retryButton.titleLabel?.font = R.font.robotoRegular(size: 16)
        retryButton.cornerRadius = 18
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.addTarget(self, action: #selector(buttonRetryDidTapped), for: .touchUpInside)
        return retryButton
    }

    @objc func buttonRetryDidTapped() {
        delegate?.onRetryButtonDidTapped(self)
    }
}
