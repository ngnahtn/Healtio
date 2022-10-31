//
//  
//  DeviceViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//
//

import UIKit
import SnapKit

class DeviceViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.color = R.color.mainColor()
        indicator.startAnimating()
        return indicator
    }()

    private lazy var findDeviceSwitch: SKSwitch = {
        let deviceSwitch = SKSwitch()
        deviceSwitch.tintColor = UIColor(hex: "E7ECF0")
        deviceSwitch.onTintColor = UIColor(hex: "AEEBEC")
        deviceSwitch.offTintColor = R.color.background()!
        deviceSwitch.thumbTintOnColor = R.color.mainColor()!
        deviceSwitch.thumbTintOffColor = .white
        deviceSwitch.thumbSize = CGSize(width: 22, height: 22)
        deviceSwitch.addTarget(self, action: #selector(onFindDeviceSwitchValueChange(_:)), for: .valueChanged)
        return deviceSwitch
    }()

    private lazy var footerView = createFooterView()
    var presenter: DevicePresenterProtocol!
    var findDeviceSwichTraillingConstraint: Constraint?
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefautls()
        presenter.onViewDidLoad()
        findDeviceSwitch.isOn = presenter.isScanningForDevice()
        onFindDeviceSwitchValueChange(findDeviceSwitch)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.onViewDidDisappear()
    }
    // MARK: - SetupDefaults
    private func setupDefautls() {
        setupTableView()
        setLeftBackButton()
        navigationItem.title = L.device.localized
    }

    private func setupTableView() {
        tableView.registerNib(ofType: DeviceTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 70
        tableView.tableFooterView = footerView
        tableView.backgroundColor = .white
        tableView.contentInset.top = 10
    }

    private func createFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Constant.Screen.width, height: findDeviceSwitch.isOn ? 30 : 0)))
        footerView.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        return footerView
    }

    private func createDeviceSectionHeader() -> UIView {
        let header = UIView()
        let titleLabel = UILabel()
        titleLabel.text = L.myDevice.localized
        titleLabel.textColor = R.color.title()
        titleLabel.font = R.font.robotoMedium(size: 18)
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(7)
            make.height.equalTo(21)
        }

        let noneLinkDeviceLabel = UILabel()
        noneLinkDeviceLabel.text = L.youDoNotHaveAnyDevice.localized
        noneLinkDeviceLabel.textColor = R.color.subTitle()
        noneLinkDeviceLabel.font = R.font.robotoRegular(size: 14)
        noneLinkDeviceLabel.textAlignment = .center
        header.addSubview(noneLinkDeviceLabel)
        noneLinkDeviceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
        return header
    }

    private func createOtherDeviceSectionHeader() -> UIView {
        let header = UIView()
        let topView = UIView()
        topView.backgroundColor = R.color.background()
        header.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(5)
        }
        let titleLabel = UILabel()
        titleLabel.textColor = R.color.title()
        titleLabel.font = R.font.robotoMedium(size: 18)
        titleLabel.text = L.findDevice.localized
        header.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(topView.snp.bottom).offset(12)
            make.height.equalTo(21)
        }

        header.addSubview(findDeviceSwitch)
        findDeviceSwitch.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(42)
            make.height.equalTo(14)
        }

        if !BluetoothManager.shared.checkBluetoothStatusAvailble() && presenter.isScanningForDevice() {
            let noBluetoothConnection = createBluetoothUnavailableView()
            header.addSubview(noBluetoothConnection)
            noBluetoothConnection.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().priority(.medium)
            }
        } else if presenter.scanDeviceHasTimeout() && presenter.numberOfRow(in: Section.otherDevice.rawValue) == 0 && presenter.isScanningForDevice() {
            let noDeviceView = createNoDeviceFoundView()
            header.addSubview(noDeviceView)
            noDeviceView.snp.makeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().priority(.medium)
            }
        }
        return header
    }

    private func createBluetoothUnavailableView() -> UIView {
        let bluetoothUnavailableView = UIView()
        let phoneBLEImageView = UIImageView(image: R.image.ic_phone_ble())
        bluetoothUnavailableView.addSubview(phoneBLEImageView)
        phoneBLEImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(77)
        }

        let titleLabel = UILabel()
        titleLabel.text = L.turnOnBluetoothMessageForLinkDevice.localized
        titleLabel.textColor = R.color.title()
        titleLabel.font = R.font.robotoRegular(size: 14)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        bluetoothUnavailableView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(phoneBLEImageView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().inset(30)
        }

        let settingButton = UIButton()
        settingButton.setTitle(L.setting.localized, for: .normal)
        settingButton.cornerRadius = 18
        settingButton.backgroundColor = R.color.mainColor()
        settingButton.addTarget(self, action: #selector(onSettingBluetoothButtonDidTapped), for: .touchUpInside)
        bluetoothUnavailableView.addSubview(settingButton)
        settingButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(142)
            make.height.equalTo(36)
        }
        return bluetoothUnavailableView
    }

    private func createNoDeviceFoundView() -> UIView {
        let noDeviceView = UIView()
        let noDeviceTitle = UILabel()
        noDeviceTitle.text = L.notFoundAnyDeviceMessage.localized
        noDeviceTitle.textColor = R.color.subTitle()
        noDeviceTitle.font = R.font.robotoRegular(size: 14)
        noDeviceTitle.textAlignment = .center
        noDeviceTitle.numberOfLines = 0
        noDeviceTitle.lineBreakMode = .byWordWrapping
        noDeviceView.addSubview(noDeviceTitle)
        noDeviceTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(90)
            make.leading.equalToSuperview().offset(46)
            make.trailing.equalToSuperview().inset(46)
            make.bottom.equalToSuperview()
        }
        return noDeviceView
    }

    // MARK: - Action
    @objc func onFindDeviceSwitchValueChange(_ sender: SKSwitch) {
        presenter.onFindDiviceToggleChanged(sender.isOn)
    }

    @objc func onSettingBluetoothButtonDidTapped() {
        presenter.onSettingButtonDidTapped()
    }
}

// MARK: - DeviceViewProtocol
extension DeviceViewController: DeviceViewProtocol {
    func reloadData() {
        tableView.reloadData()
        let height: CGFloat = findDeviceSwitch.isOn ? 30 : 0
        footerView.frame.size = CGSize(width: Constant.Screen.width, height: height)
        findDeviceSwitch.isOn = presenter.isScanningForDevice()
        if findDeviceSwitch.isOn && BluetoothManager.shared.checkBluetoothStatusAvailble() && BluetoothManager.shared.isScanning {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
    }

    func reloadTableViewSection(_ section: Section) {
        tableView.reloadSections(IndexSet(integer: section.rawValue), with: .automatic)
    }

    func reloadRow(at index: IndexPath) {
        tableView.reloadRows(at: [index], with: .automatic)
    }
}
// MARK: - Enum Section
extension DeviceViewController {
    enum Section: Int {
        case device
        case otherDevice
    }
}
// MARK: - UITableViewDataSource
extension DeviceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSection()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRow(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: DeviceTableViewCell.self, for: indexPath)
        let isLastCell = indexPath.row == presenter.numberOfRow(in: indexPath.section) - 1
        let isShowLoading = findDeviceSwitch.isOn && BluetoothManager.shared.checkBluetoothStatusAvailble() && BluetoothManager.shared.isScanning
        let isShowBottomLine = (!isLastCell) || (isShowLoading && indexPath.section == 1)
        cell.config(with: presenter.itemForRow(at: indexPath), isOtherDevice: indexPath.section == Section.otherDevice.rawValue, isShowBottomLine: isShowBottomLine)
        cell .delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DeviceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.onDidSelectItem(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = Section(rawValue: section)
        switch section {
        case .device:
            return createDeviceSectionHeader()
        case .otherDevice:
            return createOtherDeviceSectionHeader()
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionItem = Section(rawValue: section)
        switch sectionItem {
        case .device:
            let numberOfDevices = presenter.numberOfRow(in: section)
            return numberOfDevices != 0 ? 28 : 159
        case .otherDevice:
            if !BluetoothManager.shared.checkBluetoothStatusAvailble() && presenter.isScanningForDevice() {
                return 300
            } else if  presenter.scanDeviceHasTimeout() && presenter.numberOfRow(in: Section.otherDevice.rawValue) == 0 && presenter.isScanningForDevice() {
                return 190
            } else {
                return 38
            }
        default:
            return 0
        }
    }
}

// MARK: - DeviceTableViewCellDelegate
extension DeviceViewController: DeviceTableViewCellDelegate {
    func tableView(unlinkDeviceAt cell: DeviceTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        self.presenter.onUnLinkDevice(at: indexPath)
    }
}
