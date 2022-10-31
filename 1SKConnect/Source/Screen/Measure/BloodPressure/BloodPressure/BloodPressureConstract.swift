//
//  
//  BloodPressureConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/02/2021.
//
//

import UIKit

// MARK: View -
protocol BloodPressureViewProtocol: AnyObject {
    func updateGraphView(times: [Double], type: TimeFilterType)
    func getValueWhenMeasuring(with value: Int)
    func tableViewReloadData()
    func updateConnectState(_ isConnected: Bool)
    func setIndicatorHidden(_ isHidden: Bool)
    func getMeasurementState(_ state: BloodPressureMeasurementState)

    // garp view
    func updateGraphView(with data: [[[BloodPressureModel]]], timeType: TimeFilterType, deviceType: DeviceType)
}

// MARK: Interactor -
protocol BloodPressureInteractorInputProtocol {
    func startObserver()
    func saveBloodPressure(_ bloodPressure: BloodPressureModel, biolight: DeviceModel)
    func deleteBloodPressureModel(_ bloodPressure: BloodPressureModel)
    func handleSync()
    func syncListData(with userId: String, accessToken: String, page: Int, limit: Int)
}

protocol BloodPressureInteractorOutputProtocol: AnyObject {
    func onConnectDeviceListChanged(with devices: [DeviceModel])
    func onBloodPressureListChange(with bloodPressureList: [BloodPressureModel])
    func onSyncFinished(with message: String)
    func onSyncFinished(with data: BloodPressureSyncBaseModel?, status: Bool, message: String, page: Int)
}
// MARK: Presenter -
protocol BloodPressurePresenterProtocol {
    var safeAreaBottom: CGFloat { get }
    func onViewDidLoad()
    func onButtonStartDidTapped()
    func showBioLightDataSelected(with data: BloodPressureModel?, and errorText: String)
    func onButtonSyncDidTapped()
    func onButtonSettingBLEDidTapped()
    func onButtonSettingLinkTapped()
    func onViewDidAppear()

    // filter view
    func onFilterViewDidSelected(_ filterViewType: TimeFilterType)

    // Table view
    func tableViewNumberOfRow(in section: Int) -> Int
    func tableViewCellForRow(at index: IndexPath) -> BloodPressureModel?
    func onDeleteItem(at index: IndexPath)
}

// MARK: Router -
protocol BloodPressureRouterProtocol {
    func showLinkAccountAlert()
    func openAppSetting()
    func openLinkSetting()
    func gotoBloodPressureResultViewController(with data: BloodPressureModel?, and errorText: String)
}
