//
//  SleepReminderTableViewCell.swift
//  1SKConnect
//
//  Created by Nguyễn Anh Tuấn on 15/12/2022.
//

import UIKit

class SleepReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    private lazy var sleepReminderSwitch: SKSwitch = {
        let deviceSwitch = SKSwitch()
        deviceSwitch.tintColor = UIColor(hex: "E7ECF0")
        deviceSwitch.onTintColor = UIColor(hex: "AEEBEC")
        deviceSwitch.offTintColor = R.color.background()!
        deviceSwitch.thumbTintOnColor = R.color.mainColor()!
        deviceSwitch.thumbTintOffColor = .white
        deviceSwitch.thumbSize = CGSize(width: 22, height: 22)
        deviceSwitch.addTarget(self, action: #selector(onSwitchValueChange(_:)), for: .valueChanged)
        return deviceSwitch
    }()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpSleepReminder()
        // Initialization code
    }
    
    private func setUpSleepReminder() {
        self.addSubview(sleepReminderSwitch)
        sleepReminderSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(self.snp.trailing).offset(-16)
            make.width.equalTo(42)
            make.height.equalTo(14)
        }

        self.sleepReminderSwitch.isOn = false
    }
    
    @objc func onSwitchValueChange(_ sender: SKSwitch) {
    }
}
