//
//  S5NotificationSettingTableViewCell.swift
//  1SKConnect
//
//  Created by Be More on 25/01/2022.
//

import UIKit

protocol S5NotificationSettingTableViewCellDelegate: AnyObject {
    func setOn(on: Bool, at cell: S5NotificationSettingTableViewCell)
}

class S5NotificationSettingTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    
    weak var delegate: S5NotificationSettingTableViewCellDelegate?
    
    var notice: Bool! {
        didSet {
            self.noticeSwitch.alpha = self.notice ? 1 : 0.5
            self.noticeSwitch.isUserInteractionEnabled = self.notice
        }
    }
    
    var model: S5AppNoticeSettig! {
        didSet {
            self.setData()
        }
    }
    
    private lazy var noticeSwitch: SKCustomSwitch = {
        let customSwitch = SKCustomSwitch()
        customSwitch.translatesAutoresizingMaskIntoConstraints = false
        customSwitch.onTintColor = UIColor(red: 0.682, green: 0.921, blue: 0.925, alpha: 1)
        customSwitch.offTintColor = UIColor(red: 0.906, green: 0.925, blue: 0.941, alpha: 1)
        customSwitch.cornerRadius = 7
        customSwitch.thumbCornerRadius = 11
        customSwitch.thumbSize = CGSize(width: 22, height: 22)
        customSwitch.padding = 0
        customSwitch.thumbOnTintColor = UIColor(red: 0, green: 0.761, blue: 0.773, alpha: 1)
        customSwitch.thumbOffTintColor = .white
        customSwitch.thumbShadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        customSwitch.animationDuration = 0.25
        customSwitch.addTarget(self, action: #selector(onNoticeChange(_:)), for: .valueChanged)
        return customSwitch
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.contentView.addSubview(self.noticeSwitch)
        self.noticeSwitch.centerY(inView: titleLabel)
        self.noticeSwitch.anchor(right: contentView.rightAnchor, paddingRight: 16)
        self.noticeSwitch.setDimensions(width: 42, height: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Action
    @objc func onNoticeChange(_ sender: SKCustomSwitch) {
        self.delegate?.setOn(on: sender.isOn, at: self)
    }
    
}

extension S5NotificationSettingTableViewCell {

    private func setData() {
        guard let model = self.model else {
            return
        }
        self.titleLabel.text = model.title
        self.noticeSwitch.setOn(on: model.status, animated: false)
    }
}
