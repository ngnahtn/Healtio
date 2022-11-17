//
//  
//  ScaleInteractorInput.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit
import RealmSwift

class ScaleInteractorInput {
    weak var output: ScaleInteractorOutputProtocol?
    var token: NotificationToken?
    var profileNotificationToken: NotificationToken?
    var deviceNotificationToken: NotificationToken?

    private let bodyfatListDAO = GenericDAO<BodyFatList>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let deviceListDAO = GenericDAO<DeviceList>()
    var configService: ConfigServiceProtocol?

    private func registerToken() {
        bodyfatListDAO.registerToken(token: &token) { [weak self] in
            self?.onBodyFatListChange()
        }

        profileListDAO.registerToken(token: &profileNotificationToken) { [weak self] in
            self?.onProfileListChange()
        }

        deviceListDAO.registerToken(token: &deviceNotificationToken) { [weak self] in
            let connectedDeviceList = self?.deviceListDAO.getObject(with: SKKey.connectedDevice)
            self?.output?.onConnectDeviceListChanged(with: connectedDeviceList?.devices.array ?? [])
        }
    }

    @objc func onBodyFatListChange() {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile,
              let bodyFatList = bodyfatListDAO.getObject(with: currentProfile.id) else {
            output?.onBodyFatListDidChanged(with: nil)
            return
        }
        output?.onBodyFatListDidChanged(with: bodyFatList)
    }

    private func onProfileListChange() {
        onBodyFatListChange()
    }

    deinit {
        token?.invalidate()
        profileNotificationToken?.invalidate()
        deviceNotificationToken?.invalidate()
    }
}

// MARK: - ScaleInteractorInputProtocol
extension ScaleInteractorInput: ScaleInteractorInputProtocol {
    func startObserver() {
        registerToken()
    }

    func deleteBodyFat(_ bodyfat: BodyFat) {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile,
              let bodyFatList = bodyfatListDAO.getObject(with: currentProfile.id),
              let index = bodyFatList.bodyfats.firstIndex(where: { $0.timestamp == bodyfat.timestamp }) else {
            return
        }
        bodyfatListDAO.update {
            bodyFatList.bodyfats.remove(at: index)
        }
    }
    
    func getCurrentProfile() -> ProfileModel? {
        return profileListDAO.getFirstObject()?.currentProfile
    }
}

// MARK: Helpers
extension ScaleInteractorInput {
    private func handleSaveDate(_ dateString: String) {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        profileListDAO.update {
            currentProfile.lastSyncDate = dateString
        }
    }

    private func handleUpdateBodyFat(with models: BodyFatSyncModel) {
        guard let smartScale = models.smartScale else { return }
        var bodyFats = [BodyFat]()
        for data in smartScale {
            let bodyFat = BodyFat(data)
            bodyFats.append(bodyFat)
        }

        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile, let bodyFatList = bodyfatListDAO.getObject(with: currentProfile.id) else {
            return
        }

        bodyfatListDAO.update {
            for data1 in bodyFatList.bodyfats.array {
                for data2 in bodyFats where data1.createAt == data2.createAt {
                    if String.isNilOrEmpty(data1.syncId) {
                        data1.syncId = data2.syncId
                        data1.isSync = true
                    }
                }
            }
        }
    }
}
