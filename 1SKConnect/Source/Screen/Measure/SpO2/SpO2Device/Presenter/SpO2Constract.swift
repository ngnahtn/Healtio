//
//  
//  SpO2Constract.swift
//  1SKConnect
//
//  Created by Be More on 1/10/2021.
//
//

import UIKit

// MARK: View -
protocol SpO2ViewProtocol: AnyObject {
    func updateConnectState(_ isConnect: Bool)
    func setIndicatorHidden(_ isHidden: Bool)
    func updateGraphView(times: [Double], type: TimeFilterType)
    func updateData(with waveform: ViatomRealTimeWaveform)
    func reloadTableViewData()
    func setStopMeasuring()
    func updateBatteryView(with level: Int)
    // garp view
    func updateGraphView(with data: [[[WaveformModel]]], timeType: TimeFilterType, deviceType: DeviceType)
    
    // load files
    func loadFileView(hide: Bool, of device: DeviceModel)
    func updateDowloadProgress(progess: Float)
}

// MARK: Interactor -
protocol SpO2InteractorInputProtocol {
    func registerToken()
    func saveWaveformList(_ waveformList: WaveformListModel, spO2: DeviceModel)
    func saveLoadedFileName(fileName: String, of devive: DeviceModel)
    func onDeleteWaveformListModel(_ waveForm: WaveformListModel)
}

protocol SpO2InteractorOutputProtocol: AnyObject {
    func onSpo2DataListChange(waveforms: [WaveformListModel])
}

// MARK: Presenter -
protocol SpO2PresenterProtocol {
    var safeAreaBottom: CGFloat { get }
    var isConnected: Bool { get }
    var device: DeviceModel { get }
    func onViewDidLoad()
    func onButtonMeasurementDidTapped(stop: Bool)
    func onFilterViewDidSelected(_ filterViewType: TimeFilterType)
    func onDeleteItem(at index: IndexPath)

    // table view protocol
    func tableViewNumberOfRows() -> Int
    func tableWaveformFor(rowAt indexPath: IndexPath) -> WaveformListModel?
    func tableViewDidSelect(rowAt indexPath: IndexPath)
}

// MARK: Router -
protocol SpO2RouterProtocol: BaseRouterProtocol {
    func showTurnOnBleAlert()
    func goToSpO2DetailValue(with waveform: WaveformListModel)
}
