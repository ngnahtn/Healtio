//
//  SpO2DataHandler.swift
//  1SKConnect
//
//  Created by TrungDN on 29/11/2021.
//

import Foundation
import CoreBluetooth
import RealmSwift

enum SpO2State {
    case stop
    case measuring
}

final class SpO2DataHandler {
    static let shared = SpO2DataHandler()
    private var currentResponse: ViatomResponse?
    var spO2Status: SpO2State = .stop
    let spO2PeripheralGlobalDelegate = SpO2BLEPeripheralDelegate()
    var measuringWaveformModel = [WaveformModel]()
    private let deviceListDAO = GenericDAO<DeviceList>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let spO2DataListDAO = GenericDAO<SpO2DataListModel>()
    var startTime: Double = 0
    var measuringProfile: ProfileModel?
    var measuringDeviceMac: String = ""
    var fileList: [String] = []

    private init() {
    }

    func startMeasuring(_ peripheral: CBPeripheral) {
        self.startTime = Date().timeIntervalSince1970
        self.measuringProfile = profileListDAO.getFirstObject()?.currentProfile
        self.measuringDeviceMac = peripheral.mac
        self.spO2Status = .measuring

        self.spO2PeripheralGlobalDelegate.dataHandler = nil
        self.currentResponse = nil

        spO2PeripheralGlobalDelegate.dataHandler = { [weak self] (bytes, _, _) in
            guard let `self` = self else { return }
            if let response = ViatomResponse(bytes: bytes) {
                self.currentResponse = response
            } else {
                guard let result = self.currentResponse?.addData(bytes: bytes) else {
                    return
                }
                switch result {
                case (true, true):
                    // handle finish data
                    guard let data = self.currentResponse?.data else {
                        return
                    }
                    if data.count >= 4 {
                        if data[0] != 0 && data[1] != 0 {
                            let waveformData = ViatomRealTimeWaveform(bytes: data)
                            guard let spO2 = self.deviceListDAO.getObject(with: SKKey.connectedDevice)?.devices
                                    .first(where: { $0.mac == peripheral.mac}) else {
                                        break
                                    }
                            let waveformModel = WaveformModel(waveforms: waveformData, of: spO2)
                            self.measuringWaveformModel.append(waveformModel)
                            kNotificationCenter.post(name: .updateSpO2Data, object: nil, userInfo: waveformData.toDictionary())
                        }
                    }
                case(false, _):
                    self.currentResponse = nil
                default:
                    break
                }
            }
        }
    }

    func stopMeasuring(_ device: DeviceModel) {
        if self.measuringWaveformModel.count != 0 {
            let waveFormListModel = WaveformListModel(device: device, waveforms: self.measuringWaveformModel, startTime: self.startTime)
            self.saveWaveformList(waveFormListModel, spO2: device)
            self.measuringWaveformModel.removeAll()
            self.measuringProfile = nil
            self.measuringDeviceMac = ""
            self.spO2Status = .stop
            self.startTime = 0
        }
    }

    private func saveWaveformList(_ waveformList: WaveformListModel, spO2: DeviceModel) {
        guard let profile = self.measuringProfile else {
            return
        }
        if let spO2DataList = spO2DataListDAO.getObject(with: profile.id) {
            spO2DataListDAO.update {
                spO2DataList.waveformList.insert(waveformList, at: 0)
            }
        } else {
            let spO2DataList = SpO2DataListModel(profile: profile, device: spO2, waveformList: [waveformList])
            spO2DataListDAO.add(spO2DataList)
        }
    }
}
