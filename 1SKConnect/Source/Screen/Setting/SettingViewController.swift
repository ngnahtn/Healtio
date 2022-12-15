//
//  
//  SettingViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//
//

import UIKit

class SettingViewController: BaseViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    var presenter: SettingPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
    }
    // MARK: - Setup
    private func setupDefaults() {
        topView.addShadow(width: 0, height: 4, color: .black, radius: 4, opacity: 0.1)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionLabel.text = "Ver \(appVersion ?? "")"
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
    
    @IBAction func onSleepReminderButtonDidTapped(_ sender: Any) {
        presenter.onButtonSleepReminderDidTapped()
    }
}

// MARK: SettingViewController - SettingViewProtocol -
extension SettingViewController: SettingViewProtocol {

}
