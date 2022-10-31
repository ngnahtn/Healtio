//
//  HistoryBpResultTBVCell.swift
//  1SKConnect
//
//  Created by admin on 08/11/2021.
//

import UIKit
import SwiftUI

protocol HistoryBpResultTBVCellDelegate: AnyObject {
    func leftMenuStateDidOpen(cell: HistoryBpResultTBVCell)
    func leftMenuStateDidClose(cell: HistoryBpResultTBVCell)
    func didSelecteDeleteButton(cell: HistoryBpResultTBVCell)
}

class HistoryBpResultTBVCell: UITableViewCell {
    @IBOutlet weak var bpValueLabel: UILabel!
    @IBOutlet weak var hrValueLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconLoveImageView: UIImageView!
    @IBOutlet weak var iconSyncImageView: UIImageView!

    private var isShowLeftMenu = false
    private let leftMenuWidth: CGFloat = 67

    @IBOutlet private weak var bgViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bgViewTraillingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var deleteButtonTrainlingConstraint: NSLayoutConstraint!
    weak var delegate: HistoryBpResultTBVCellDelegate?

    var model: BloodPressureModel? {
        didSet {
            self.setupData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.bgView.addShadow(width: 0, height: 4, color: .black, radius: 4, opacity: 0.1)
        self.iconLoveImageView.image = self.iconLoveImageView.image?.withRenderingMode(.alwaysTemplate)
        self.addSwipeGesture()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hideLeftMenu(hasAnimation: false)

    }
    @IBAction func handleDeleteButton(_ sender: UIButton) {
        delegate?.didSelecteDeleteButton(cell: self)
    }
}

// MARK: - Helpers
extension HistoryBpResultTBVCell {
    /// Setup data
    func setupData() {

        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let item = self.model else { return }

        if profileListDAO.getFirstObject()?.currentProfile?.linkAccount == nil {
            self.iconSyncImageView.isHidden = true
        } else {
            self.iconSyncImageView.isHidden = true
        }

        self.bpValueLabel.text = "\(item.sys.value ?? 0)/\(item.dia.value ?? 0)/\(item.map.value ?? 0)"
        self.hrValueLabel.text = item.pr.value?.stringValue
        self.iconLoveImageView.tintColor = item.state.color
        self.bpValueLabel.textColor = item.state.color
        self.hrValueLabel.textColor = item.state.color
        let date = item.date.toDate()
        hourLabel.text = date.toString(.hm)
        dateLabel.text = date.toString(.dmySlash)
    }

    func config(isShowLeftMenu: Bool) {
        if isShowLeftMenu {
            showLeftMenu(hasAnimation: false)
        } else {
            hideLeftMenu(hasAnimation: false)
        }
    }
}

// MARK: - Show Left Menu
extension HistoryBpResultTBVCell {
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
