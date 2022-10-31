//
//  HistoryWeightResultTableViewCell.swift
//  SK365
//
//  Created by tuyenvx on 6/12/20.
//  Copyright © 2020 Elcom. All rights reserved.
//

import UIKit

protocol HistoryWeightResultTableViewCellDelegate: AnyObject {
    func leftMenuStateDidOpen(cell: HistoryWeightResultTableViewCell)
    func leftMenuStateDidClose(cell: HistoryWeightResultTableViewCell)
    func didSelecteDeleteButton(cell: HistoryWeightResultTableViewCell)
}

class HistoryWeightResultTableViewCell: UITableViewCell {
    @IBOutlet private weak var bgView: UIView!
    @IBOutlet private weak var weightLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var expandButton: UIButton!
    @IBOutlet private weak var bgViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bgViewTraillingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var deleteButtonTrainlingConstraint: NSLayoutConstraint!

    private var syncIconWidth: CGFloat = 20
    private var isShowLeftMenu = false
    private let leftMenuWidth: CGFloat = 67

    weak var delegate: HistoryWeightResultTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupDefaults()
        addSwipeGesture()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hideLeftMenu(hasAnimation: false)

    }

    private func setupDefaults() {
        bgView.addShadow(width: 0, height: 4, color: .black, radius: 4, opacity: 0.1)
    }

    // MARK: - Action
    @IBAction private func buttonDeleteDidSelected(_ sender: Any) {
        delegate?.didSelecteDeleteButton(cell: self)
    }

    func config(with bodyFat: BodyFat?, isShowLeftMenu: Bool) {
        if isShowLeftMenu {
            showLeftMenu(hasAnimation: false)
        } else {
            hideLeftMenu(hasAnimation: false)
        }
        guard let `bodyFat` = bodyFat else {
            return
        }

        weightLabel.text = bodyFat.weight.value?.toString()
        if let bmi = bodyFat.bmiEnum {
            statusLabel.text = bmi.status
            statusLabel.textColor = bmi.color
        } else {
            statusLabel.text = ""
        }
        let createTime = Date(timeIntervalSince1970: bodyFat.timestamp)
        dateLabel.text = createTime.toString(.dmySlash)
        timeLabel.text = createTime.toString(.hm)
    }
}

// MARK: - Show Left Menu
extension HistoryWeightResultTableViewCell {
    private func addSwipeGesture() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeLeftGesture.direction = .left
        contentView.addGestureRecognizer(swipeLeftGesture)
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(gesture:)))
        swipeRightGesture.direction = .right
        contentView.addGestureRecognizer(swipeRightGesture)
    }

    @objc private func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            if !isShowLeftMenu {
                showLeftMenu()
            }
        case .right:
            if isShowLeftMenu {
                hideLeftMenu()
            }
        default:
            return
        }
    }

    func showLeftMenu(hasAnimation: Bool = true) {
        isShowLeftMenu = true
        bgViewLeadingConstraint.constant = -leftMenuWidth
        bgViewTraillingConstraint.constant = 0
        deleteButtonTrainlingConstraint.constant = 16
        if hasAnimation {
            UIView.animate(withDuration: Constant.Number.animationTime) {
                self.layoutIfNeeded()
            }
        }
        delegate?.leftMenuStateDidOpen(cell: self)
    }

    func hideLeftMenu(hasAnimation: Bool = true) {
        isShowLeftMenu = false
        bgViewLeadingConstraint.constant = 16
        bgViewTraillingConstraint.constant = 16
        deleteButtonTrainlingConstraint.constant = -leftMenuWidth
        if hasAnimation {
            UIView.animate(withDuration: Constant.Number.animationTime) {
                self.layoutIfNeeded()
            }
        }
        delegate?.leftMenuStateDidClose(cell: self)
    }
}
