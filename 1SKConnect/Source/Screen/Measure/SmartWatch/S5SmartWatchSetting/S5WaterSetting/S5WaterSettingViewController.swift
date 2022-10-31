//
//  
//  S5WaterSettingViewController.swift
//  1SKConnect
//
//  Created by TrungDN on 08/02/2022.
//
//

import UIKit

class S5WaterSettingViewController: BaseViewController {
    
    var presenter: S5WaterSettingPresenterProtocol!
    
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
    
    private lazy var valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.text = "2000444444"
        valueLabel.textColor = R.color.title()
        valueLabel.font = R.font.robotoMedium(size: 36)
        return valueLabel
    }()
    
    private lazy var minusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.ic_minus(), for: .normal)
        button.addTarget(self, action: #selector(self.handleMinus(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.ic_plus(), for: .normal)
        button.addTarget(self, action: #selector(self.handleAdd(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var numbersOfCupLabel: UILabel = {
        let label = UILabel()
        label.text = "8"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = R.font.robotoMedium(size: 20)
        return label
    }()
    
    @IBOutlet weak var remindTableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title = R.string.localizable.s5_water_setting_title()
        self.remindTableView.registerNib(ofType: S5WaterRemindTableViewCell.self)
    }
    
    // MARK: - Action
    @objc private func handleMinus(_ sender: UIButton) {
        
    }
    
    @objc private func handleAdd(_ sender: UIButton) {
    }
    
    @objc func onNoticeChange(_ sender: SKSwitch) {
    }
}

// MARK: - Helpers
extension S5WaterSettingViewController {
    private func createOtherDeviceSectionHeader() -> UIView {
        let header = UIView()
        header.backgroundColor = .white
        
        let titleLabel: UILabel = UILabel()
        titleLabel.text = R.string.localizable.s5_water_setting_remind_title()
        titleLabel.textColor = R.color.title()
        titleLabel.font = R.font.robotoRegular(size: 14)
        titleLabel.textAlignment = .justified
        titleLabel.numberOfLines = 0
        
        header.addSubview(titleLabel)
        titleLabel.anchor(top: header.topAnchor,
                          left: header.leftAnchor,
                          paddingTop: 17,
                          paddingLeft: 16)
        
        header.addSubview(self.noticeSwitch)
        self.noticeSwitch.anchor(top: header.topAnchor,
                                 left: titleLabel.rightAnchor,
                                 right: header.rightAnchor,
                                 paddingTop: 17,
                                 paddingLeft: 10,
                                 paddingRight: 16)
        self.noticeSwitch.setDimensions(width: 42, height: 14)
        
        let descriptionLabel: UILabel = UILabel()
        descriptionLabel.text = R.string.localizable.s5_water_setting_remind()
        descriptionLabel.textColor = R.color.subTitle()
        descriptionLabel.font = R.font.robotoRegular(size: 12)
        descriptionLabel.textAlignment = .justified
        descriptionLabel.numberOfLines = 0
        
        header.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: titleLabel.bottomAnchor,
                                left: header.leftAnchor,
                                right: header.rightAnchor,
                                paddingTop: 8,
                                paddingLeft: 16,
                                paddingRight: 16)
        
        let goalTitleLabel: UILabel = UILabel()
        goalTitleLabel.text = R.string.localizable.s5_water_setting_goal()
        goalTitleLabel.textColor = R.color.title()
        goalTitleLabel.textAlignment = .justified
        goalTitleLabel.numberOfLines = 0
        goalTitleLabel.font = R.font.robotoMedium(size: 14)
        
        header.addSubview(goalTitleLabel)
        goalTitleLabel.anchor(top: descriptionLabel.bottomAnchor,
                              left: header.leftAnchor,
                              right: header.rightAnchor,
                              paddingTop: 8,
                              paddingLeft: 16,
                              paddingRight: 16)
        
        let waterView = UIView()
        waterView.backgroundColor = .white
        
        header.addSubview(waterView)
        waterView.anchor(top: goalTitleLabel.topAnchor, paddingTop: 28)
        waterView.centerXAnchor.constraint(equalTo: header.centerXAnchor).isActive = true
        
        let unitLabel: UILabel = UILabel()
        unitLabel.text = "ml"
        unitLabel.textColor = R.color.title()
        unitLabel.font = R.font.robotoMedium(size: 18)
        
        waterView.addSubview(self.valueLabel)
        self.valueLabel.anchor(top: waterView.topAnchor,
                               left: waterView.leftAnchor,
                               bottom: waterView.bottomAnchor)
        
        waterView.addSubview(unitLabel)
        unitLabel.anchor(top: waterView.topAnchor,
                         left: valueLabel.rightAnchor,
                         right: waterView.rightAnchor)
        
        let seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor(hex: "#C3C3C3")
        
        header.addSubview(seperatorLine)
        seperatorLine.anchor(top: valueLabel.bottomAnchor,
                             left: header.leftAnchor,
                             right: header.rightAnchor,
                             paddingTop: 17,
                             paddingLeft: 16,
                             paddingRight: 16,
                             height: 0.5)
        
        let waterVolumeLabel = UILabel()
        waterVolumeLabel.text = R.string.localizable.s5_water_setting_cup_volume()
        waterVolumeLabel.font = R.font.robotoMedium(size: 14)
        
        header.addSubview(waterVolumeLabel)
        waterVolumeLabel.anchor(top: seperatorLine.bottomAnchor,
                                left: header.leftAnchor,
                                paddingTop: 17,
                                paddingLeft: 16)
        
        let goalView = UIView()
        goalView.backgroundColor = .white
        goalView.layer.cornerRadius = 4
        goalView.layer.borderWidth = 0.5
        goalView.layer.borderColor = UIColor(red: 0.451, green: 0.463, blue: 0.471, alpha: 1).cgColor
        
        header.addSubview(goalView)
        goalView.anchor(left: waterVolumeLabel.rightAnchor,
                        paddingLeft: 16)
        goalView.centerYAnchor.constraint(equalTo: waterVolumeLabel.centerYAnchor).isActive = true
        goalView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        let cupValueLabel = UILabel()
        cupValueLabel.text = "250ml"
        cupValueLabel.textColor = R.color.title()
        cupValueLabel.font = R.font.robotoRegular(size: 14)
        
        goalView.addSubview(cupValueLabel)
        cupValueLabel.anchor(left: goalView.leftAnchor,
                             paddingLeft: 6)
        cupValueLabel.centerYAnchor.constraint(equalTo: goalView.centerYAnchor).isActive = true
        
        let dropDownImageView = UIImageView()
        dropDownImageView.image = R.image.ic_down()
        
        goalView.addSubview(dropDownImageView)
        dropDownImageView.setDimensions(width: 8, height: 4)
        dropDownImageView.anchor(left: cupValueLabel.rightAnchor,
                                 right: goalView.rightAnchor,
                                 paddingLeft: 22,
                                 paddingRight: 12)
        dropDownImageView.centerYAnchor.constraint(equalTo: goalView.centerYAnchor).isActive = true
        
        let cupNumberLabel: UILabel = UILabel()
        cupNumberLabel.text = R.string.localizable.s5_water_setting_cup_numbers()
        cupNumberLabel.font = R.font.robotoMedium(size: 14)
        
        header.addSubview(cupNumberLabel)
        cupNumberLabel.anchor(top: waterVolumeLabel.bottomAnchor,
                              left: header.leftAnchor,
                              paddingTop: 28,
                              paddingLeft: 16)
        
        header.addSubview(self.minusButton)
        self.minusButton.anchor(left: goalView.leftAnchor)
        self.minusButton.centerYAnchor.constraint(equalTo: cupNumberLabel.centerYAnchor).isActive = true
        self.minusButton.setDimensions(width: 20, height: 20)
        
        header.addSubview(self.addButton)
        self.addButton.anchor(right: goalView.rightAnchor)
        self.addButton.centerYAnchor.constraint(equalTo: cupNumberLabel.centerYAnchor).isActive = true
        self.addButton.setDimensions(width: 20, height: 20)
        
        header.addSubview(self.numbersOfCupLabel)
        self.numbersOfCupLabel.centerXAnchor.constraint(equalTo: goalView.centerXAnchor).isActive = true
        self.numbersOfCupLabel.centerYAnchor.constraint(equalTo: cupNumberLabel.centerYAnchor).isActive = true
        
        let topView = UIView()
        topView.backgroundColor = R.color.background()
        header.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(5)
        }
        
        return header
    }
    
}

// MARK: - S5WaterSettingViewProtocol
extension S5WaterSettingViewController: S5WaterSettingViewProtocol {
    func reloadData() {
        DispatchQueue.main.async {
            self.remindTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension S5WaterSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

// MARK: - UITableViewDataSource
extension S5WaterSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let waterConfig = self.presenter.drinkWaterConfig {
            return waterConfig.reminderArray.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: S5WaterRemindTableViewCell.self, for: indexPath)
        
        if let waterCongfig = self.presenter.drinkWaterConfig {
            if indexPath.row == waterCongfig.reminderArray.count - 1 {
                cell.seperatorView.isHidden = true
            } else {
                cell.seperatorView.isHidden = false
            }
            cell.titleLabel.text = "Cốc thứ \(indexPath.row)"
            cell.model = waterCongfig.reminderArray[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.createOtherDeviceSectionHeader()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 300
    }
}
