//
//  ActivityHeader.swift
//  1SKConnect
//
//  Created by tuyenvx on 07/04/2021.
//

import UIKit
import SnapKit

class ActivityHeader: UIView {

    private var filterLabel: UILabel!
    var filterButton: UIButton!
    private var filterImageView: UIImageView!
    var isExpand = false
    var onActivityFilterDidSelected: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    private func setupDefaults() {
        backgroundColor = .white
        let activityFilterView = createActivityFilterView()
        addSubview(activityFilterView)
        activityFilterView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(28)
            make.width.greaterThanOrEqualTo(99)
            make.bottom.equalToSuperview().inset(8)
        }

        let titleLabel = UILabel()
        titleLabel.text = L.lastestInfo.localized
        titleLabel.font = R.font.robotoBold(size: 16)
        titleLabel.textColor = R.color.title()
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(activityFilterView.snp.centerY)
            make.leading.equalToSuperview().offset(16)
        }
    }

    private func createActivityFilterView() -> UIView {
        let filterView = UIView()
        filterView.cornerRadius = 14
        filterView.borderWidth = 1
        filterView.borderColor = UIColor(hex: "DEE5EA")
        filterLabel = UILabel()
        filterLabel.font = R.font.robotoRegular(size: 14)
        filterLabel.textColor = R.color.title()
        filterView.addSubview(filterLabel)
        filterLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
        }

        let imageView = UIImageView(image: R.image.ic_down())
        imageView.contentMode = .scaleAspectFit
        filterView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(11)
            make.leading.equalTo(filterLabel.snp.trailing).offset(6)
            make.width.equalTo(9)
        }
        filterImageView = imageView
        filterButton = UIButton()
        filterButton.addTarget(self, action: #selector(onFilterViewDidTapped), for: .touchUpInside)
        filterView.addSubview(filterButton)
        filterButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return filterView
    }

    @objc func onFilterViewDidTapped() {
        updateExpandState(!isExpand)
        onActivityFilterDidSelected?()
    }

    func config(with type: ActivityFilterType) {
        switch type {
        case .activity:
            filterLabel.text = L.measurementIndex.localized
        case .deviceActivity:
            filterLabel.text = L.deviceMeasurementIndex.localized
        }
        updateExpandState(false)
    }

    func updateExpandState(_ isExpand: Bool) {
        self.isExpand = isExpand
        filterImageView.image = isExpand ? R.image.ic_up() : R.image.ic_down()
    }
}
