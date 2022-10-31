//
//  
//  S5NotificationSettingViewController.swift
//  1SKConnect
//
//  Created by Be More on 25/01/2022.
//
//

import UIKit

class S5NotificationSettingViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var noticeSwitch: SKSwitch = {
        let deviceSwitch = SKSwitch()
        deviceSwitch.tintColor = UIColor(hex: "E7ECF0")
        deviceSwitch.onTintColor = UIColor(hex: "AEEBEC")
        deviceSwitch.offTintColor = R.color.background()!
        deviceSwitch.thumbTintOnColor = R.color.mainColor()!
        deviceSwitch.thumbTintOffColor = .white
        deviceSwitch.thumbSize = CGSize(width: 22, height: 22)
        deviceSwitch.addTarget(self, action: #selector(onNoticeChange(_:)), for: .valueChanged)
        return deviceSwitch
    }()

    var presenter: S5NotificationSettingPresenterProtocol!
    
    private func createOtherDeviceSectionHeader() -> UIView {
        let header = UIView()
        header.backgroundColor = .white
        
        let titleLabel: UILabel = UILabel()
        titleLabel.text = R.string.localizable.notification()
        titleLabel.textColor = R.color.title()
        titleLabel.font = R.font.robotoRegular(size: 16)
        
        header.addSubview(titleLabel)
        titleLabel.anchor(top: header.topAnchor,
                          left: header.leftAnchor,
                          paddingTop: 18,
                          paddingLeft: 16)
        
        header.addSubview(self.noticeSwitch)
        self.noticeSwitch.centerY(inView: titleLabel)
        self.noticeSwitch.anchor(right: header.rightAnchor, paddingRight: 16)
        self.noticeSwitch.setDimensions(width: 42, height: 14)
        
        let descriptionLabel: UILabel = UILabel()
        descriptionLabel.text = R.string.localizable.s5_setting_type_notice_title()
        descriptionLabel.textColor = R.color.subTitle()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = R.font.robotoRegular(size: 12)
        
        header.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor,
                                left: header.leftAnchor,
                                right: header.rightAnchor,
                                paddingTop: 6,
                                paddingLeft: 16,
                                paddingRight: 16)
        
        let topView = UIView()
        topView.backgroundColor = R.color.background()
        header.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(5)
        }
        
        return header
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
        self.noticeSwitch.isOn = self.presenter.noticeValue
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.onViewWillDisappear()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title = R.string.localizable.notification()
        self.tableView.registerNib(ofType: S5NotificationSettingTableViewCell.self)
    }
    
    // MARK: - Action
    @objc func onNoticeChange(_ sender: SKSwitch) {
        self.presenter.onSwitchNotice(isOn: sender.isOn)
    }
}

// MARK: - S5NotificationSettingViewProtocol
extension S5NotificationSettingViewController: S5NotificationSettingViewProtocol {
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension S5NotificationSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
}

// MARK: - UITableViewDataSource
extension S5NotificationSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.settingValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: S5NotificationSettingTableViewCell.self, for: indexPath)
        cell.notice = self.presenter.noticeValue
        cell.model = self.presenter.settingValue[indexPath.row]
        cell.seperatorView.isHidden = indexPath.row == self.presenter.settingValue.count - 1
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.createOtherDeviceSectionHeader()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 110
    }
}

extension S5NotificationSettingViewController: S5NotificationSettingTableViewCellDelegate {
    func setOn(on: Bool, at cell: S5NotificationSettingTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            self.presenter.setOn(on: on, at: indexPath)
        }
    }
}
