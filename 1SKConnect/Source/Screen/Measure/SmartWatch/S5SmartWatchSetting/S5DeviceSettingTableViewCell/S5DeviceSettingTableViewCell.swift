//
//  S5DeviceSettingTableViewCell.swift
//  1SKConnect
//
//  Created by Be More on 24/01/2022.
//

import UIKit

protocol S5MainSettingTableViewCellDelegate: AnyObject {
    func setOn(on: Bool, atType: S5SettingType )
}

class S5DeviceSettingTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nextIconImageView: UIImageView!
    @IBOutlet weak var slashView: UIView!
    
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
        customSwitch.addTarget(self, action: #selector(onNoticeChange(_:)), for: .touchUpInside)
        return customSwitch
    }()
    
    var model: S5SettingDataSource? {
        didSet {
            self.setData()
        }
    }
    weak var delegate: S5MainSettingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.contentView.addSubview(self.noticeSwitch)
        self.noticeSwitch.centerY(inView: titleLabel)
        self.noticeSwitch.anchor(right: contentView.rightAnchor, paddingRight: 16)
        self.noticeSwitch.setDimensions(width: 42, height: 14)
    }

    @objc func onNoticeChange(_ sender: SKCustomSwitch) {
        guard let model = self.model else { return }
        self.delegate?.setOn(on: sender.isOn, atType: model.type)
    }
}

extension S5DeviceSettingTableViewCell {
    private func setData() {
        guard let model = self.model else { return }
        self.titleLabel.text = model.title
        
        if model.type == .version {
            self.statusLabel.text = model.description
        } else {
            if let status = model.status {
                self.noticeSwitch.setOn(on: status, animated: false)
                self.statusLabel.text = status ? R.string.localizable.smart_watch_s5_is_on() : R.string.localizable.smart_watch_s5_is_off()
            }
        }

        switch model.type {
        case .alert:
            self.nextIconImageView.isHidden = false
            self.noticeSwitch.isHidden = true
            self.statusLabel.isHidden = false
            self.slashView.isHidden = false
        case .alarm:
            self.nextIconImageView.isHidden = false
            self.noticeSwitch.isHidden = true
            self.slashView.isHidden = false
            self.statusLabel.isHidden = true
        case .remindActivity:
            self.nextIconImageView.isHidden = false
            self.noticeSwitch.isHidden = true
            self.slashView.isHidden = false
            self.statusLabel.isHidden = true
        case .remindWater:
            self.nextIconImageView.isHidden = false
            self.noticeSwitch.isHidden = true
            self.slashView.isHidden = false
            self.statusLabel.isHidden = true
        case .goal:
            self.nextIconImageView.isHidden = false
            self.noticeSwitch.isHidden = true
            self.slashView.isHidden = true
            self.statusLabel.isHidden = false
        case .heartRate:
            self.nextIconImageView.isHidden = true
            self.noticeSwitch.isHidden = false
            self.statusLabel.isHidden = true
            self.slashView.isHidden = false
            self.statusLabel.isHidden = true
        case .temperature:
            self.nextIconImageView.isHidden = true
            self.noticeSwitch.isHidden = false
            self.statusLabel.isHidden = true
            self.slashView.isHidden = false
            self.statusLabel.isHidden = true
        case .turnWrist:
            self.nextIconImageView.isHidden = true
            self.noticeSwitch.isHidden = false
            self.statusLabel.isHidden = true
            self.slashView.isHidden = false
            self.statusLabel.isHidden = true
        case .findWatch:
            self.nextIconImageView.isHidden = true
            self.noticeSwitch.isHidden = true
            self.slashView.isHidden = true
            self.statusLabel.isHidden = true
        case .watchFace:
            self.nextIconImageView.isHidden = false
            self.noticeSwitch.isHidden = true
            self.slashView.isHidden = false
            self.statusLabel.isHidden = true
        case .version:
            self.nextIconImageView.isHidden = true
            self.noticeSwitch.isHidden = true
            self.slashView.isHidden = false
            self.statusLabel.isHidden = false
        case .reset:
            self.nextIconImageView.isHidden = true
            self.noticeSwitch.isHidden = true
            self.slashView.isHidden = true
            self.statusLabel.isHidden = true
        }
    }
}
