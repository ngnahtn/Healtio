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
    func handleSync() {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        let bodyFatList = bodyfatListDAO.getObject(with: currentProfile.id)

        // filter out the synchronized data
        let bodyFats = bodyFatList?.bodyfats.array.filter { String.isNilOrEmpty($0.syncId) }
        let syncModel = BodyFatSyncModel(currentProfile, bodyFat: bodyFats ?? [])
        let accessToken = currentProfile.linkAccount?.accessToken
        let deleteSynchronizedId = currentProfile.deleteSyncId.array.uniqued()
        let bpDeleteSynchronizedId = currentProfile.bpDeleteSyncId.array.uniqued()

        let MAX_API = deleteSynchronizedId.isEmpty ? 1 : 2
        var finalStatus = true
        var numberApi = 0 {
            didSet {
                if numberApi == MAX_API {
                    if finalStatus {
                        output?.onSyncFinished(with: R.string.localizable.sync_success())
                    } else {
                        output?.onSyncFinished(with: R.string.localizable.sync_fail())
                    }
                }
            }
        }

        ConfigService.share.sync(with: syncModel, accessToken: accessToken ?? "") { [weak self] data, status, message in
            guard let `self` = self else { return }
            if status {
                dLogDebug(data ?? "Nil")
                if data?.meta?.code == 200 {
                    let dateUpdated = R.string.localizable.sync_last_date(Date().hourString, Date().minuteString, Date().dayString, Date().monthString, Date().yearString)
                    self.handleSaveDate(dateUpdated)
                    guard let syncModel = data?.data else {
                        return
                    }
                    self.handleUpdateBodyFat(with: syncModel)
                    finalStatus = true
                } else {
                    finalStatus = false
                }
            } else {
                self.output?.onSyncFinished(with: message)
                finalStatus = false
            }
            numberApi += 1
        }

        if !deleteSynchronizedId.isEmpty {
            ConfigService.share.syncDelete(with: deleteSynchronizedId, with: bpDeleteSynchronizedId, accessToken: accessToken ?? "") { data, _, _ in
                if data?.meta?.code == 200 {
                    // remove all deleted id
                    self.profileListDAO.update {
                        currentProfile.deleteSyncId.removeAll()
                    }
                    finalStatus = true
                } else {
                    finalStatus = false
                }
                numberApi += 1
            }
        }
    }

    func syncListData(with userId: String, accessToken: String, page: Int, limit: Int) {
        configService?.sync(with: userId, accessToken: accessToken, page: page, limit: limit, completion: { data, status, message in
            self.output?.onSyncFinished(with: data, status: status, message: message, page: page)
        })
    }

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
        guard let linkAccount = currentProfile.linkAccount else {
            // save sync id
            self.handleSaveDeletedSynchronizedData(with: bodyfat.syncId, to: currentProfile)
            return
        }

        if  !String.isNilOrEmpty(bodyfat.syncId) {
            // save sync id
            self.handleSaveDeletedSynchronizedData(with: bodyfat.syncId, to: currentProfile)
        }
        
        if  !String.isNilOrEmpty(bodyfat.syncId) {
            // if user enable auto sync delete synchronized data
            configService?.syncDelete(with: [bodyfat.syncId], with: [], accessToken: linkAccount.accessToken ?? "", completion: { data, _, _ in
                if data?.meta?.code == 200 {
                    let dateUpdated = R.string.localizable.sync_last_date(Date().hourString, Date().minuteString, Date().dayString, Date().monthString, Date().yearString)
                    self.handleSaveDate(dateUpdated)
                } else {
                    dLogDebug("[DELETE FAILED]")
                }
            })
        }
    }
    
    func getCurrentProfile() -> ProfileModel? {
        return profileListDAO.getFirstObject()?.currentProfile
    }
}

// MARK: Helpers
extension ScaleInteractorInput {
    private func handleSaveDeletedSynchronizedData(with id: String, to profile: ProfileModel) {
        if  !String.isNilOrEmpty(id) {
            self.profileListDAO.update {
                profile.deleteSyncId.append(id)
            }
        }
    }

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
