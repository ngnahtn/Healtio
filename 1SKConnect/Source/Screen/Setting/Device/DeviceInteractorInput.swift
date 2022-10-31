//
//  
//  DeviceInteractorInput.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//
//

import UIKit
import RealmSwift
import TrusangBluetooth

class DeviceInteractorInput {
    private var deviceListDAO = GenericDAO<DeviceList>()
    
    private let sleepListModelDAO = GenericDAO<SleepListRecordModel>()
    private let stepListModelDAO = GenericDAO<StepListRecordModel>()
    private let heartRateListModelDAO = GenericDAO<S5HeartRateListRecordModel>()
    private let spO2ListModelDAO = GenericDAO<S5SpO2ListRecordModel>()
    private let tempListModelDAO = GenericDAO<S5TemperatureListRecordModel>()
    private let bloodPressureListModelDAO = GenericDAO<BloodPressureListRecordModel>()
    private let sportListModelDAO = GenericDAO<S5SportListRecordModel>()
    let btProvider = ZHJBLEManagerProvider.shared

    private var token: NotificationToken?

    weak var output: DeviceInteractorOutputProtocol?

    private func registerToken() {
        deviceListDAO.registerToken(token: &token) { [weak self] in
            self?.onDeviceListChange()
        }
    }

    @objc func onDeviceListChange() {
        let connectDevice = deviceListDAO.getObject(with: SKKey.connectedDevice)?.devices.array ?? []
        let otherDevice = deviceListDAO.getObject(with: SKKey.otherDevice)?.devices.array ?? []

        output?.onConnectDeviceChange(connectDevice)
        output?.onOtherDeviceChange(otherDevice)
    }

    deinit {
        token?.invalidate()
    }
}

// MARK: - DeviceInteractorInputProtocol
extension DeviceInteractorInput: DeviceInteractorInputProtocol {
    func startObserver() {
        registerToken()
    }

    func linkDevice(_ device: DeviceModel) {
        let otherDeviceList = deviceListDAO.getObject(with: SKKey.otherDevice)
        var connectDeviceList = deviceListDAO.getObject(with: SKKey.connectedDevice)
        var linkDeviceList = deviceListDAO.getObject(with: SKKey.linkDevice)
        if connectDeviceList == nil {
            connectDeviceList = DeviceList(id: SKKey.connectedDevice, devices: [])
            deviceListDAO.add(connectDeviceList!)
        }
        if linkDeviceList == nil {
            linkDeviceList = DeviceList(id: SKKey.linkDevice, devices: [])
            deviceListDAO.add(linkDeviceList!)
        }
        deviceListDAO.update {
            if let index = otherDeviceList?.devices.firstIndex(where: { $0.mac == device.mac }) {
                otherDeviceList?.devices.remove(at: index)
            }
            connectDeviceList?.devices.append(device)
            if !linkDeviceList!.devices.contains(where: { $0.mac == device.mac }) {
                linkDeviceList?.devices.append(device)
            }
        }
    }

    func unLinkDevice(_ device: DeviceModel) {
        let connectDeviceList = deviceListDAO.getObject(with: SKKey.connectedDevice)
        
        if btProvider.deviceState == .connected {
            btProvider.disconnectDevice { (p) in
                dLogDebug("Disconnected \(p.name)")
            }
        }

        deviceListDAO.update {
            if let index = connectDeviceList?.devices.firstIndex(where: { $0.mac == device.mac }) {
                connectDeviceList?.devices.remove(at: index)
            }
        }
        BluetoothManager.shared.disConnectDevice(device)
    }
}
