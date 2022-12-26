//
//  
//  SettingViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//
//

import UIKit
import SnapKit

class SettingViewController: BaseViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var sleepReminderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sleepReminderView: UIView!
    @IBOutlet weak var sleepTitle: UILabel!
    var presenter: SettingPresenterProtocol!
    var isOpenNotificationSetting = false
    var remiderDatas: [ReminderModel] = []
    let notificationManager = LocalNotificationManager()

    private lazy var sleepReminderSwitch: SKSwitch = {
        let deviceSwitch = SKSwitch()
        deviceSwitch.tintColor = UIColor(hex: "E7ECF0")
        deviceSwitch.onTintColor = UIColor(hex: "AEEBEC")
        deviceSwitch.offTintColor = R.color.background()!
        deviceSwitch.thumbTintOnColor = R.color.mainColor()!
        deviceSwitch.thumbTintOffColor = .white
        deviceSwitch.thumbSize = CGSize(width: 22, height: 22)
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            if setting.authorizationStatus == .notDetermined {
                deviceSwitch.isOn = false
            } else {
                deviceSwitch.isOn = LocalNotificationManager.shared.number == 0 ? false : true
            }
        }
        deviceSwitch.addTarget(self, action: #selector(onSwitchValueChange(_:)), for: .valueChanged)
        return deviceSwitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
        setUpSleepReminder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    // MARK: - Setup
    private func setupDefaults() {
        topView.addShadow(width: 0, height: 4, color: .black, radius: 4, opacity: 0.1)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionLabel.text = "Ver \(appVersion ?? "")"
    }
    
    private func setUpSleepReminder() {
        sleepReminderView.addSubview(sleepReminderSwitch)
        sleepReminderSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(sleepTitle.snp.centerY)
            make.trailing.equalTo(sleepReminderView.snp.trailing).offset(-16)
            make.width.equalTo(42)
            make.height.equalTo(14)
        }
    }
    // MARK: - Action

    @IBAction func onProfileButtonDidTapped(_ sender: Any) {
        presenter.onButtonProfileDidTapped()
    }

    @IBAction func onDeviceButtonDidTapped(_ sender: Any) {
        presenter.onButtonDeviceDidTapped()
    }

    @IBAction func onSyncButtonDidTap(_ sender: UIButton) {
        self.presenter.onButtonSyncDidTap()
    }

    @IBAction func onIntroduceButtonDidTapped(_ sender: Any) {
        presenter.onButtonIntroduceDidTapped()
    }
    
    @objc func onSwitchValueChange(_ sender: SKSwitch) {
        LocalNotificationManager.shared.removePendingNotificationRequests([])
        if sender.isOn {
            var component1 = Calendar.current.dateComponents([.hour, .minute], from: Date())
            component1.hour = 12
            component1.minute = 0
            var component2 = Calendar.current.dateComponents([.hour, .minute], from: Date())
            component2.hour = 22
            component2.minute = 0
            
            LocalNotificationManager.shared.notifications = [
                LocalNotificationModel(id: "01", title: R.string.localizable.take_a_nap_notification_title(), body: R.string.localizable.sleep_notification_body(), dateTime: component1),
                LocalNotificationModel(id: "02", title: R.string.localizable.sleep_notification_title(), body: R.string.localizable.sleep_notification_body(), dateTime: component2)
            ]
        }
    }
}

// MARK: SettingViewController - SettingViewProtocol -
extension SettingViewController: SettingViewProtocol {

}

// MARK: SettingViewController - UITableViewDelegate -
extension SettingViewController: UITableViewDelegate {
    
}
