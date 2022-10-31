//
//  
//  DeviceConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//
//

import UIKit

// MARK: View -
protocol DeviceViewProtocol: AnyObject {
    func reloadData()
    func reloadTableViewSection(_ section: DeviceViewController.Section)
    func reloadRow(at index: IndexPath)
}

// MARK: Interactor -
protocol DeviceInteractorInputProtocol {
    func startObserver()
    func linkDevice(_ device: DeviceModel)
    func unLinkDevice(_ device: DeviceModel)
}

protocol DeviceInteractorOutputProtocol: AnyObject {
    func onConnectDeviceChange(_ connectDevices: [DeviceModel])
    func onOtherDeviceChange(_ otherDevices: [DeviceModel])
}

// MARK: Presenter -
protocol DevicePresenterProtocol {
    func onViewDidLoad()
    func onViewDidDisappear()
    func numberOfSection() -> Int
    func numberOfRow(in section: Int) -> Int
    func itemForRow(at index: IndexPath) -> DeviceModel?
    func onDidSelectItem(at index: IndexPath)
    func isScanningForDevice() -> Bool
    func onFindDiviceToggleChanged(_ isOn: Bool)
    func onSettingButtonDidTapped()
    func onUnLinkDevice(at index: IndexPath)
    func scanDeviceHasTimeout() -> Bool
}

// MARK: Router -
protocol DeviceRouterProtocol: BaseRouterProtocol {
    func goToSetting(smartWatch: DeviceModel)
    func gotoDeviceDetailsViewController(_ device: DeviceModel)
    func openApplicationSetting()
    func showAlert(type: AlertType, delegate: AlertViewControllerDelegate?)
}
