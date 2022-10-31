//
//  
//  DevicePresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//
//

import UIKit

class DevicePresenter {

    private var devices: [DeviceModel] = []
    private var otherDevices: [DeviceModel] = []

    private let deviceListDAO = GenericDAO<DeviceList>()
    weak var view: DeviceViewProtocol?
    private var interactor: DeviceInteractorInputProtocol
    private var router: DeviceRouterProtocol
    private var isScanTimeout = false

    init(interactor: DeviceInteractorInputProtocol,
         router: DeviceRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    private func observerBLEState() {
        kNotificationCenter.addObserver(self, selector: #selector(onBLEStateChange(_:)), name: .bleStateChanged, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(onDeviceConnectionChanged(_:)), name: .deviceConnectionChanged, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(onScanDeviceReachTimeout(_:)), name: .scanDeviceReachTimeout, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(willEnterForeground), name: .willEnterForeground, object: nil)
    }

    @objc func onBLEStateChange(_ sender: Notification) {
        view?.reloadData()
    }

    @objc func onDeviceConnectionChanged(_ sender: Notification) {
        guard let mac = sender.userInfo?[SKKey.mac] as? String,
              let index = devices.firstIndex(where: { $0.mac == mac }) else {
            return
        }
        let indexPath = IndexPath(row: index, section: DeviceViewController.Section.device.rawValue)
        view?.reloadRow(at: indexPath)
    }

    @objc func onScanDeviceReachTimeout(_ sender: Notification) {
        isScanTimeout = true
        view?.reloadData()
    }

    @objc func willEnterForeground() {
        isScanTimeout = false
    }
}

// MARK: - DevicePresenterProtocol
extension DevicePresenter: DevicePresenterProtocol {
    func onViewDidLoad() {
        BluetoothManager.shared.checkBluetoothStatusAvailble()
        interactor.startObserver()
        observerBLEState()
        onFindDiviceToggleChanged(SKUserDefaults.shared.isSearchOtherDevice)
        // add test device
//        let deviceModel = DeviceModel(name: "Test Device", mac: "0000", deviceType: .scale, image: R.image.scales())
//        interactor.linkDevice(deviceModel)
    }

    func onViewDidDisappear() {
        BluetoothManager.shared.stopScan()
    }

    func numberOfSection() -> Int {
        return 2
    }

    func numberOfRow(in section: Int) -> Int {
        let section = DeviceViewController.Section(rawValue: section)
        switch section {
        case .device:
            return devices.count
        case .otherDevice:
            return SKUserDefaults.shared.isSearchOtherDevice ? otherDevices.count : 0
        default:
            return 0
        }
    }

    func itemForRow(at index: IndexPath) -> DeviceModel? {
        let section = DeviceViewController.Section(rawValue: index.section)
        switch section {
        case .device:
            return devices[index.row]
        case .otherDevice:
            return otherDevices[index.row]
        default:
            return nil
        }
    }

    func onDidSelectItem(at index: IndexPath) {
        guard let section = DeviceViewController.Section(rawValue: index.section) else {
            return
        }
        switch section {
        case .device:
            let device = devices[index.row]
            if device.type == .smartWatchS5 {
                self.router.goToSetting(smartWatch: device)
            } else {
                self.onUnLinkDevice(at: index)
            }
        case .otherDevice:
            let device = otherDevices[index.row]
            if device.type == .smartWatchS5 {
                if let isContainS5 = self.deviceListDAO.getObject(with: SKKey.connectedDevice)?.devices.contains(where: {$0.type == .smartWatchS5}) {
                    if !isContainS5 {
                        interactor.linkDevice(device)
                    } else {
                        self.router.showToast(content: R.string.localizable.linked_device())
                    }
                } else {
                    interactor.linkDevice(device)
                }
            } else {
                interactor.linkDevice(device)
            }
        }
    }

    func isScanningForDevice() -> Bool {
        return SKUserDefaults.shared.isSearchOtherDevice
    }

    func onFindDiviceToggleChanged(_ isOn: Bool) {
        isScanTimeout = false
        SKUserDefaults.shared.isSearchOtherDevice = isOn
        if isOn {
            BluetoothManager.shared.scanForDevice()
            view?.reloadData()
        } else {
            BluetoothManager.shared.stopScan()
            view?.reloadData()
        }
    }

    func onSettingButtonDidTapped() {
        router.openApplicationSetting()
    }

    func onUnLinkDevice(at index: IndexPath) {
        let device = devices[index.row]
        router.showAlert(type: .unLinkDevice(device), delegate: self)
    }

    func scanDeviceHasTimeout() -> Bool {
        return isScanTimeout
    }
}

// MARK: - DevicePresenter: DeviceInteractorOutput -
extension DevicePresenter: DeviceInteractorOutputProtocol {
    func onConnectDeviceChange(_ connectDevices: [DeviceModel]) {
        devices = connectDevices
        view?.reloadData()
    }

    func onOtherDeviceChange(_ otherDevices: [DeviceModel]) {
        self.otherDevices = otherDevices
        if SKUserDefaults.shared.isSearchOtherDevice {
            view?.reloadData()
        }
    }
}
// MARK: - AlertViewControllerDelegate
extension DevicePresenter: AlertViewControllerDelegate {
    func onButtonOKDidTapped(_ type: AlertType) {
        switch type {
        case .unLinkDevice(let device):
            interactor.unLinkDevice(device)
            SKToast.shared.showToast(content: "Đã bỏ liên kết với thiết bị")
        default:
            break
        }
    }
}
