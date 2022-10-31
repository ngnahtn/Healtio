//
//  SyncSettingInteractorInput.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import Foundation

class SyncSettingInteractorInput {
    let porfileListDAO = GenericDAO<ProfileListModel>()
    weak var output: SyncSettingInteractorOutputProtocol?
}

// MARK: - SyncSettingInteractorOutputProtocol
extension SyncSettingInteractorInput: SyncSettingInteractorInputProtocol {
    func handleGetSyncData(with index: IndexPath?) {
        guard let index = index, let currentProfile = self.porfileListDAO.getFirstObject()?.profiles[index.row] else {
            return
        }
        if let linkAccount = currentProfile.linkAccount {
            ConfigService.share.sync(with: linkAccount.uuid, accessToken: "", page: 1, limit: 1000000) { data, status, message in
                self.output?.onSyncFinished(with: data, status: status, message: message, page: 1)
            }
        }
        
    }
    
    func handleSyncSwitch(at index: IndexPath?, isOn: Bool) {
        guard let index = index else { return }
        let profileList = porfileListDAO.getFirstObject()
        porfileListDAO.update {
            profileList?.profiles[index.row].enableAutomaticSync = isOn
        }
        if isOn {
            self.handleSync(with: index)
        }
    }

    func handleSync(with index: IndexPath?) {
        self.handleSync(at: index)
    }
}

// MARK: Helpers
extension SyncSettingInteractorInput {
    private func handleSync(at index: IndexPath?) {
        let profileListDAO = GenericDAO<ProfileListModel>()
        let bodyFatListDAO = GenericDAO<BodyFatList>()
        guard let index = index, let currentProfile = profileListDAO.getFirstObject()?.profiles[index.row] else {
            return
        }
        let bodyFatList = bodyFatListDAO.getObject(with: currentProfile.id)

        // filter out the synchronized data
        let bodyFats = bodyFatList?.bodyfats.array.filter { String.isNilOrEmpty($0.syncId) }
        let syncModel = BodyFatSyncModel(currentProfile, bodyFat: bodyFats ?? [])
        let accessToken = currentProfile.linkAccount?.accessToken
        dLogDebug("ACCESS_TOKEN: \(accessToken ?? "Empty")")
        let deleteSynchronizedId = currentProfile.deleteSyncId.array.uniqued()
        let bpDeleteSynchronizedId = currentProfile.bpDeleteSyncId.array.uniqued()

        let MAX_API = deleteSynchronizedId.isEmpty || bpDeleteSynchronizedId.isEmpty  ? 1 : 2
        var finalStatus = true
        var numberApi = 0 {
            didSet {
                if numberApi == MAX_API {
                    if finalStatus {
                        dLogDebug("[SUCCESS]: \(R.string.localizable.sync_success())")
                    } else {
                        dLogError("[ERROR]: \(R.string.localizable.sync_fail())")
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
                    self.handleSaveDate(dateUpdated, at: index)
                    guard let syncModel = data?.data else {
                        return
                    }
                    self.handleUpdateBodyFat(with: syncModel, at: index)
                    finalStatus = true
                } else {
                    finalStatus = false
                }
            } else {
                dLogError("[ERROR]: \(message)")
                finalStatus = false
            }
            numberApi += 1
        }

        if !deleteSynchronizedId.isEmpty || !bpDeleteSynchronizedId.isEmpty {
            ConfigService.share.syncDelete(with: deleteSynchronizedId, with: bpDeleteSynchronizedId, accessToken: accessToken ?? "") { data, _, _ in
                if data?.meta?.code == 200 {
                    // remove all deleted id
                    profileListDAO.update {
                        currentProfile.deleteSyncId.removeAll()
                        currentProfile.bpDeleteSyncId.removeAll()
                    }
                    finalStatus = true
                } else {
                    finalStatus = false
                }
                numberApi += 1
            }
        }

        let bloodPressureListDAO = GenericDAO<BloodPressureListModel>()
        guard let currentProfile =
                profileListDAO.getFirstObject()?.profiles[index.row] else {
                    return
                }
        let bloodPressureList = bloodPressureListDAO.getObject(with: currentProfile.id)
        // filter out the synchronized data
        let bloodPressures = bloodPressureList?.bloodPressureList.array.filter { String.isNilOrEmpty($0.syncId) }
        let bpSyncModel = BloodPressureSyncModel(currentProfile, bp: bloodPressures ?? [])

        let MAX_BP_API = 1
        var finalBpStatus = true
        var numberBpApi = 0 {
            didSet {
                if numberBpApi == MAX_BP_API {
                    if finalBpStatus {
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
                        self.handleSaveDate(dateUpdated, at: index)
                    guard let bpSyncModel = data?.data else {
                        return
                    }
                    self.handleUpdateBloodPressure(with: bpSyncModel, at: index)
                    finalBpStatus = true
                } else {
                    finalBpStatus = false
                }
            } else {
                dLogError("[ERROR]: \(message)")
                finalBpStatus = false
            }
            numberBpApi += 1
        }
    }

    private func handleSaveDate(_ dateString: String, at index: IndexPath) {
        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let currentProfile = profileListDAO.getFirstObject()?.profiles[index.row] else {
            return
        }
        profileListDAO.update {
            currentProfile.lastSyncDate = dateString
        }
        output?.onSyncDateUpdate(with: dateString)
    }

    private func handleUpdateBodyFat(with models: BodyFatSyncModel, at index: IndexPath) {
        guard let smartScale = models.smartScale else { return }
        var bodyFats = [BodyFat]()
        for data in smartScale {
            let bodyFat = BodyFat(data)
            bodyFats.append(bodyFat)
        }

        let profileListDAO = GenericDAO<ProfileListModel>()
        let bodyFatListDAO = GenericDAO<BodyFatList>()
        guard let currentProfile = profileListDAO.getFirstObject()?.profiles[index.row], let bodyFatList = bodyFatListDAO.getObject(with: currentProfile.id) else {
            return
        }

        bodyFatListDAO.update {
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

    private func handleUpdateBloodPressure(with models: BloodPressureSyncModel, at index: IndexPath) {
        guard let bloodPressure = models.bloodPressure else {
            return
        }
        var bp = [BloodPressureModel]()
        for data in bloodPressure {
            let bloodpressure = BloodPressureModel(data)
            bp.append(bloodpressure)
        }
        let profileListDAO = GenericDAO<ProfileListModel>()
        let bloodPressureListDAO = GenericDAO<BloodPressureListModel>()

        guard let currentProfile = profileListDAO.getFirstObject()?.profiles[index.row], let bloodPressureList = bloodPressureListDAO.getObject(with: currentProfile.id) else {
            return
        }

        bloodPressureListDAO.update {
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
