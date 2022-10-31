//
//  
//  S5SmartWatchSettingViewController.swift
//  1SKConnect
//
//  Created by Be More on 24/01/2022.
//
//

import UIKit
import TrusangBluetooth

class S5SmartWatchSettingViewController: BaseViewController {

    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet weak var turnOnResetView: UIView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var turnOnResetViewHeightConstrain: NSLayoutConstraint!
    var presenter: S5SmartWatchSettingPresenterProtocol!
    
    private let btProvider = ZHJBLEManagerProvider.shared
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.onViewWiilApear()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title =  R.string.localizable.setting() + " S5"
        self.turnOnResetView.roundCorners(cornes: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24)
        
        // set up table view
        self.settingTableView.registerNib(ofType: S5DeviceSettingTableViewCell.self)
        self.settingTableView.sectionHeaderHeight = 0
        self.settingTableView.sectionFooterHeight = 6
        self.settingTableView.delegate = self
        self.settingTableView.dataSource = self
    }
    
    // MARK: - Action
    @IBAction func handleCancelButton(_ sender: UIButton) {
        self.hideResetSetting()
    }
    
    @IBAction func handleConfirmButton(_ sender: UIButton) {
        self.presenter.resetS5Device()
    }
    
    // show resetView
    func showResetSetting() {
        transparentView.isHidden = false
        turnOnResetViewHeightConstrain.constant = self.presenter.safeAreaBottom + 110
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in })
    }

    // hide resetView
    func hideResetSetting() {
        transparentView.isHidden = true
        turnOnResetViewHeightConstrain.constant = 0
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in })
    }
}

// MARK: - S5SmartWatchSettingViewProtocol
extension S5SmartWatchSettingViewController: S5SmartWatchSettingViewProtocol {

    func hideReset() {
        self.hideResetSetting()
    }
    
    func reloadData(at index: IndexPath) {
        DispatchQueue.main.async {
            self.settingTableView.reloadRows(at: [index], with: .none)
        }
    }
}

// MARK: - UITableViewDelegate
extension S5SmartWatchSettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if btProvider.deviceState != .connected {
            return
        } 
        var settingType = S5SettingType.alert
        switch indexPath.section {
        case 0:
            settingType = s5Setting1stSectionDataSource[indexPath.row].type
        case 1:
            settingType = s5Setting2ndSectionDataSource[indexPath.row].type
        default:
            settingType = s5Setting3thSectionDataSource[indexPath.row].type
        }
        switch settingType {
        case .alert:
            self.presenter.goToNotificationSetting()
        case .alarm:
            print("alarm")
        case .remindActivity:
            print("remindActivity")
        case .remindWater:
            self.presenter.goToWaterView()
        case .goal:
            self.presenter.goToGoalView()
        case .heartRate:
            print("heartRate")
        case .temperature:
            print("temperature")
        case .turnWrist:
            print("turnWrist")
        case .findWatch:
            self.presenter.findS5Watch()
        case .watchFace:
            self.presenter.goToWatchFace()
        case .version:
            return
        case .reset:
            self.showResetSetting()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return s5Setting1stSectionDataSource.count
        case 1:
            return s5Setting2ndSectionDataSource.count
        default:
            return s5Setting3thSectionDataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.settingTableView.sectionFooterHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
}

// MARK: - UITableViewDataSource
extension S5SmartWatchSettingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: S5DeviceSettingTableViewCell.self, for: indexPath)
        switch indexPath.section {
        case 0:
            cell.model = s5Setting1stSectionDataSource[indexPath.row]
            cell.delegate = self
        case 1:
            cell.model = s5Setting2ndSectionDataSource[indexPath.row]
            cell.delegate = self
        default:
            cell.model = s5Setting3thSectionDataSource[indexPath.row]
            cell.delegate = self
        }
        return cell
    }
}

// MARK: - S5MainSettingTableViewCellDelegate
extension S5SmartWatchSettingViewController: S5MainSettingTableViewCellDelegate {
    
    func setOn(on: Bool, atType: S5SettingType) {
        self.presenter.setOn(on: on, atType: atType)
    }   
}
