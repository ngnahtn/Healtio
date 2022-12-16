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
    @IBOutlet weak var tableView: UITableView!
    var presenter: SettingPresenterProtocol!
    var isOpenNotificationSetting = false
    let notificationManager = LocalNotificationManager()

    private lazy var sleepReminderSwitch: SKSwitch = {
        let deviceSwitch = SKSwitch()
        deviceSwitch.tintColor = UIColor(hex: "E7ECF0")
        deviceSwitch.onTintColor = UIColor(hex: "AEEBEC")
        deviceSwitch.offTintColor = R.color.background()!
        deviceSwitch.thumbTintOnColor = R.color.mainColor()!
        deviceSwitch.thumbTintOffColor = .white
        deviceSwitch.thumbSize = CGSize(width: 22, height: 22)
        deviceSwitch.isOn = LocalNotificationManager.shared.numberOfNoti == 0 ? false : true
        deviceSwitch.addTarget(self, action: #selector(onSwitchValueChange(_:)), for: .valueChanged)
        return deviceSwitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
        setUpTableView()
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
        
        if LocalNotificationManager.shared.numberOfNoti == 0 {
            self.isOpenNotificationSetting = false

            DispatchQueue.main.async {
                self.sleepReminderViewHeightConstraint.constant = 50
                self.tableView.reloadData()
                self.view.layoutIfNeeded()
            }
        } else {
            self.isOpenNotificationSetting = true

            DispatchQueue.main.async {
                self.sleepReminderViewHeightConstraint.constant = 150
                self.tableView.reloadData()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(ofType: SleepReminderTableViewCell.self)
        tableView.separatorStyle = .none
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
        if !sender.isOn {
            self.isOpenNotificationSetting = false
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    self.tableView.reloadData()
                    self.sleepReminderViewHeightConstraint.constant = 50
                    self.view.updateConstraints()
                    self.view.layoutIfNeeded()
                }
            }
            
        } else {
            LocalNotificationManager.shared.removePendingNotificationRequests([])
            self.isOpenNotificationSetting = true
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    self.tableView.reloadData()
                    self.sleepReminderViewHeightConstraint.constant = 150
                    self.view.updateConstraints()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

// MARK: SettingViewController - SettingViewProtocol -
extension SettingViewController: SettingViewProtocol {

}

// MARK: SettingViewController - UITableViewDelegate -
extension SettingViewController: UITableViewDelegate {
    
}

// MARK: SettingViewController - UITableViewDelegate -
extension SettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOpenNotificationSetting {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: SleepReminderTableViewCell.self, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
