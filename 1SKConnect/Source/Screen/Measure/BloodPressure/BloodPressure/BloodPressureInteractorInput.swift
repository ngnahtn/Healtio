//
//  
//  BloodPressureInteractorInput.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/02/2021.
//
//

import UIKit
import RealmSwift

class BloodPressureInteractorInput {
    weak var output: BloodPressureInteractorOutputProtocol?
    var profileNotificationToken: NotificationToken?
    var bloodPresureNotificationToken: NotificationToken?
    var deviceNotificationToken: NotificationToken?
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let deviceListDAO = GenericDAO<DeviceList>()
    private let bloodPressureListModelDAO = GenericDAO<BloodPressureListModel>()
    var configService: ConfigServiceProtocol?

    private func registerToken() {
        deviceListDAO.registerToken(token: &deviceNotificationToken) { [weak self] in
            let connectedDeviceList = self?.deviceListDAO.getObject(with: SKKey.connectedDevice)
            self?.output?.onConnectDeviceListChanged(with: connectedDeviceList?.devices.array ?? [])
        }

        self.profileListDAO.registerToken(token: &profileNotificationToken) { [weak self] in
            guard let self = self else { return }
            self.onBloodPressureListChange()
        }

        self.bloodPressureListModelDAO.registerToken(token: &self.bloodPresureNotificationToken) { [weak self] in
            guard let self = self else { return }
            self.onBloodPressureListChange()
        }
    }

    private func onBloodPressureListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let bloodPressureList = bloodPressureListModelDAO.getObject(with: profile.id) {
            self.output?.onBloodPressureListChange(with: bloodPressureList.bloodPressureList.array)
        } else {
            self.output?.onBloodPressureListChange(with: [])
        }
    }

    deinit {
        deviceNotificationToken?.invalidate()
        profileNotificationToken?.invalidate()
        bloodPresureNotificationToken?.invalidate()
    }

}

// MARK: - BloodPressureInteractorInput - BloodPressureInteractorInputProtocol -
extension BloodPressureInteractorInput: BloodPressureInteractorInputProtocol {
    func syncListData(with userId: String, accessToken: String, page: Int, limit: Int) {
        ConfigService.share.getBpSync(with: userId, accessToken: accessToken, page: page, limit: limit) { data, status, message in
            self.output?.onSyncFinished(with: data, status: status, message: message, page: page)
        }
    }

    func handleSync() {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        let bloodPressureList = bloodPressureListModelDAO.getObject(with: currentProfile.id)
        // filter out the synchronized data
        let bloodPressures = bloodPressureList?.bloodPressureList.array.filter { String.isNilOrEmpty($0.syncId) }
        let bpSyncModel = BloodPressureSyncModel(currentProfile, bp: bloodPressures ?? [])
        let accessToken = currentProfile.linkAccount?.accessToken
        let bpDeleteSynchronizedId = currentProfile.bpDeleteSyncId.array.uniqued()

        let MAX_API = bpDeleteSynchronizedId.isEmpty ? 1 : 2
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

        ConfigService.share.createBpSync(with: bpSyncModel, accessToken: accessToken ?? "") { [weak self] data, status, message in
            guard let `self` = self else { return }
            if status {
                dLogDebug(data ?? "Nil")
                if data?.meta?.code == 200 {
                    let dateUpdated = R.string.localizable.sync_last_date(Date().hourString, Date().minuteString, Date().dayString, Date().monthString, Date().yearString)
                    self.handleSaveDate(dateUpdated)
                    guard let bpSyncModel = data?.data else {
                        return
                    }
                    self.handleUpdateBloodPressure(with: bpSyncModel)
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

        if !bpDeleteSynchronizedId.isEmpty {
            ConfigService.share.syncDelete(with: [], with: bpDeleteSynchronizedId, accessToken: accessToken ?? "") { data, _, _ in
                if data?.meta?.code == 200 {
                    // remove all deleted id
                    self.profileListDAO.update {
                        currentProfile.bpDeleteSyncId.removeAll()
                    }
                    finalStatus = true
                } else {
                    finalStatus = false
                }
                numberApi += 1
            }
        }
    }

    func deleteBloodPressureModel(_ bloodPressure: BloodPressureModel) {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile,
              let bloodPressureList = bloodPressureListModelDAO.getObject(with: currentProfile.id),
              let index = bloodPressureList.bloodPressureList.firstIndex(where: { $0.date == bloodPressure.date }) else {
            return
        }
        bloodPressureListModelDAO.update {
            bloodPressureList.bloodPressureList.remove(at: index)
        }

        guard let linkAccount = currentProfile.linkAccount else {
            // save sync id
            self.handleSaveDeletedSynchronizedData(with: bloodPressure.syncId, to: currentProfile)
            return
        }
        
        if  !String.isNilOrEmpty(bloodPressure.syncId) {
            // save sync id
            self.handleSaveDeletedSynchronizedData(with: bloodPressure.syncId, to: currentProfile)
        }
        
        if  !String.isNilOrEmpty(bloodPressure.syncId) {
            // if user enable auto sync delete synchronized data
            ConfigService.share.syncDelete(with: [], with: [bloodPressure.syncId], accessToken: linkAccount.accessToken ?? "", completion: { data, _, _ in
                if data?.meta?.code == 200 {
                    let dateUpdated = R.string.localizable.sync_last_date(Date().hourString, Date().minuteString, Date().dayString, Date().monthString, Date().yearString)
                    self.handleSaveDate(dateUpdated)
                } else {
                    dLogDebug("[DELETE FAILED]")
                }
            })
        }
    }

    func saveBloodPressure(_ bloodPressure: BloodPressureModel, biolight: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let bloodPressureList = bloodPressureListModelDAO.getObject(with: profile.id) {
            bloodPressureListModelDAO.update {
                bloodPressureList.bloodPressureList.insert(bloodPressure, at: 0)
            }
        } else {
            let bloodPressureList = BloodPressureListModel(profile: profile, device: biolight, bloodPressureList: [bloodPressure])
            bloodPressureListModelDAO.add(bloodPressureList)
        }
    }

    func startObserver() {
        registerToken()
    }
}

// MARK: Helpers
extension BloodPressureInteractorInput {
    private func handleSaveDeletedSynchronizedData(with id: String, to profile: ProfileModel) {
        if  !String.isNilOrEmpty(id) {
            self.profileListDAO.update {
                profile.bpDeleteSyncId.append(id)
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

    private func handleUpdateBloodPressure(with models: BloodPressureSyncModel) {
        guard let bloodPressure = models.bloodPressure else {
            return
        }
        var bp = [BloodPressureModel]()
        for data in bloodPressure {
            let bloodpressure = BloodPressureModel(data)
            bp.append(bloodpressure)
        }

        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile, let bloodPressureList = bloodPressureListModelDAO.getObject(with: currentProfile.id) else {
            return
        }

        bloodPressureListModelDAO.update {
            for data1 in bloodPressureList.bloodPressureList.array {
                for data2 in bp where data1.createAt == data2.createAt {
                    if String.isNilOrEmpty(data1.syncId) {
                        data1.syncId = data2.syncId
                    }
                }
            }
        }
    }
}
