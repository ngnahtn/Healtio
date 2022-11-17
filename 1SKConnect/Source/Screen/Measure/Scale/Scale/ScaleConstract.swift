//
//  
//  ScaleConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit

// MARK: View -
protocol ScaleViewProtocol: AnyObject {
    func reloadData()
    func updateGraphView(times: [Double], type: TimeFilterType)
    func updateGraphView(with data: [[[BodyFat]]], timeType: TimeFilterType, deviceType: DeviceType)
    func updateConnectState(_ isConnect: Bool)
    func setScaleImage(image: UIImage?)
    func setIndicatorHidden(_ isHidden: Bool)
    func setTypes(_ types: [TimeFilterType])
    func updateHeader(with isUnlinkDevice: Bool)
    func getVisibleIndexPath() -> [IndexPath]?
    func showAlert(with message: String)
}

// MARK: Interactor -
protocol ScaleInteractorInputProtocol {
    func startObserver()
    func deleteBodyFat(_ bodyfat: BodyFat)
    func getCurrentProfile() -> ProfileModel?
}

protocol ScaleInteractorOutputProtocol: AnyObject {
    func onBodyFatListDidChanged(with bodyfatList: BodyFatList?)
    func onConnectDeviceListChanged(with devices: [DeviceModel])
}

// MARK: Presenter -
protocol ScalePresenterProtocol {
    var filterTimesScale: TimeScaleModel { get set }
    var safeAreaBottom: CGFloat { get }
    var isShowBLEConnection: Bool { get set }
    func onViewDidLoad()
    func onViewDidDisappear()
    func numberOfRow(in section: Int) -> Int
    func itemForRow(at index: IndexPath) -> BodyFat?
    func onItemDidSelected(at index: IndexPath)
    func onDeleteItem(at index: IndexPath)
    func onButtonConnectDidTapped()
    func onButtonSyncDidTapped()
    func onButtonMeasureDidTapped()
    func onButtonSettingBLEDidTapped()
    func onButtonSettingLinkTapped()
    func onButtonCloseDidTapped()
    func onFilterViewDidSelected(_ filterViewType: TimeFilterType)
    func onPrefetchItem(at indexPaths: [IndexPath])
}

// MARK: Router -
protocol ScaleRouterProtocol: BaseRouterProtocol {
    func dismiss()
    func showTurnOnBleAlert()
    func showLinkAccountAlert()
    func hideTurnOnBleAlert()
    func openAppSetting()
    func openLinkSetting()
    func gotoWeightMeasuringViewController(_ scale: DeviceModel)
    func showResultViewController(bodyFat: BodyFat)
    func gotoDeviceViewController()
}
