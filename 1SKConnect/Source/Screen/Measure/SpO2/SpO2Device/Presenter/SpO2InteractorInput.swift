//
//  
//  SpO2InteractorInput.swift
//  1SKConnect
//
//  Created by Be More on 1/10/2021.
//
//

import UIKit
import RealmSwift

class SpO2InteractorInput {
    weak var output: SpO2InteractorOutputProtocol?
    private let spO2DataListDAO = GenericDAO<SpO2DataListModel>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let deviceListDAO = GenericDAO<DeviceList>()
    var spO2DataNotificationToken: NotificationToken?
    var profileNotificationToken: NotificationToken?

    private func onSpo2DataListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let spO2DataList = spO2DataListDAO.getObject(with: profile.id) {
            self.output?.onSpo2DataListChange(waveforms: spO2DataList.waveformList.array)
        } else {
            self.output?.onSpo2DataListChange(waveforms: [])
        }
    }

    deinit {
        self.spO2DataNotificationToken?.invalidate()
        self.profileNotificationToken?.invalidate()
    }
}

// MARK: - SpO2InteractorInputProtocol
extension SpO2InteractorInput: SpO2InteractorInputProtocol {
    func saveLoadedFileName(fileName: String, of devive: DeviceModel) {
        deviceListDAO.update {
            devive.fileList.append(fileName)
        }
    }

    func onDeleteWaveformListModel(_ waveForm: WaveformListModel) {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile,
              let waveformList = spO2DataListDAO.getObject(with: currentProfile.id),
              let index = waveformList.waveformList.firstIndex(where: { $0.endTime == waveForm.endTime }) else {
            return
        }
        spO2DataListDAO.update {
            waveformList.waveformList.remove(at: index)
        }
    }

    func registerToken() {
        spO2DataListDAO.registerToken(token: &spO2DataNotificationToken) { [weak self] in
            self?.onSpo2DataListChange()
        }

        profileListDAO.registerToken(token: &profileNotificationToken) { [weak self] in
            kNotificationCenter.post(name: .changeProfile, object: nil)
            self?.onSpo2DataListChange()
        }
    }

    func saveWaveformList(_ waveformList: WaveformListModel, spO2: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
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
