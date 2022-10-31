//
//  ActivitiesSelectionView.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/05/2021.
//

import UIKit

class ActivitiesSelectionView: UIView {

    private lazy var stackView: UIStackView = createStackView()
    var currentActivityFilterType: ActivityFilterType = .activity {
        didSet {
            reload()
        }
    }
    var onFilterSelected: ((ActivityFilterType) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    private func setupDefaults() {
        let bgView = UIView()
        bgView.cornerRadius = 7
        bgView.backgroundColor = R.color.background()
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4).priority(.medium)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(4)        }
        bgView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        for activityFilterType in ActivityFilterType.allCases {
            let activitiesSelectionItem = ActivitiesSelectionItem(filterType: activityFilterType)
            let isSelected = activityFilterType == currentActivityFilterType
            activitiesSelectionItem.setSelected(isSelected)
            stackView.addArrangedSubview(activitiesSelectionItem)
        }
        backgroundColor = .clear
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.backgroundColor = R.color.background()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 1
        stackView.cornerRadius = 7
        return stackView
    }

    private func onItemSelected(activityFilterType: ActivityFilterType) {

    }

    func setDelegate(_ delegate: ActivitiesSelectionItemDelegate) {
        for view in stackView.arrangedSubviews.compactMap({ $0 as? ActivitiesSelectionItem}) {
            view.delegate = delegate
        }
    }

    private func reload() {
        for view in stackView.arrangedSubviews.compactMap({ $0 as? ActivitiesSelectionItem}) {
            let isSelected = view.type == currentActivityFilterType
            view.setSelected(isSelected)
        }
    }
}

protocol ActivitiesSelectionItemDelegate: AnyObject {
    func itemDidSelected(_ filterType: ActivityFilterType)
}

class ActivitiesSelectionItem: UIView {
    lazy var titleLabel = createTitleLabel()
    lazy var checkImageView = createCheckImageView()
    lazy var button = createButton()
    var type: ActivityFilterType = .activity

    weak var delegate: ActivitiesSelectionItemDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    convenience init(filterType: ActivityFilterType) {
        self.init(frame: .zero)
        self.type = filterType
        titleLabel.text = filterType.name
    }

    private func setupDefaults() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview().priority(.high)
        }

        addSubview(checkImageView)
        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(5)
            make.trailing.equalToSuperview().inset(10)
            make.width.equalTo(12)
            make.height.equalTo(10)
        }

        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        backgroundColor = .white
    }

    private func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.font = R.font.robotoRegular(size: 14)
        titleLabel.textColor = R.color.title()
        return titleLabel
    }

    private func createCheckImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func createButton() -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: #selector(onBackgroundDidSelected), for: .touchUpInside)
        return button
    }

    @objc func onBackgroundDidSelected() {
        delegate?.itemDidSelected(type)
    }

    func setSelected(_ isSelected: Bool) {
        checkImageView.image = isSelected ? R.image.ic_check() : nil
    }
}
