//
//  SyncSettingPresenter.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import Foundation
import SwiftUI

class SyncSettingPresenter {

    var profile: ProfileModel?
    var profileIndex: IndexPath?

    let porfileListDAO = GenericDAO<ProfileListModel>()
    private let bodyFatListDAO = GenericDAO<BodyFatList>()
    
    private var router: SyncSettingRouter
    private var inputInteractor: SyncSettingInteractorInput
    weak var view: SyncSettingViewProtocol?

    init(inputInteractor: SyncSettingInteractorInput, router: SyncSettingRouter) {
        self.router = router
        self.inputInteractor = inputInteractor
    }
}

extension SyncSettingPresenter {
    func haveLinkedAccount() -> Bool {
        guard let profile = self.profile else {
            return false
        }
        return profile.linkAccount != nil
    }
}

// MARK: - SyncSettingPresenterProtocol
extension SyncSettingPresenter: SyncSettingPresenterProtocol {
    func getSyncData() {
        self.inputInteractor.handleGetSyncData(with: self.profileIndex)
    }
    
    func presentDownloadView() {
        self.router.presentDownloadView(self.profileIndex)
    }

    func saveLinkedAccount(with user: UserLoginModel?, isGoogleAccount: Bool) {
        self.router.handleSaveLinkedAccount(with: user, at: self.profileIndex, isGoogleAccount: isGoogleAccount, completion: { [weak self] in
            guard let `self` = self else { return }
            self.view?.handleUpdateView(didLinkAccount: self.haveLinkedAccount())
            self.view?.presentDownloadView()
        })
    }

    func didTapSync() {
        guard let view = self.view as? SyncSettingViewController else {
            return
        }
        view.showHud()
        self.inputInteractor.handleSync(with: self.profileIndex)
    }

    func onViewDidLoad() {
        guard let profile = self.profile else {
            return
        }
        self.view?.setProfileData(with: profile)
        self.view?.handleUpdateView(didLinkAccount: self.haveLinkedAccount())
        kNotificationCenter.post(name: .changeProfile, object: nil)
    }

    func didTapButtonLink() {
        if self.haveLinkedAccount() {
            self.router.showAlert(type: .unlinkAccount, delegate: self)
        }
    }

    func didSwitchSync() {
        if self.haveLinkedAccount() {
            guard let view = self.view as? SyncSettingViewController else {
                return
            }
            view.showHud()
            self.inputInteractor.handleSyncSwitch(at: self.profileIndex, isOn: true)
        } else {
            self.router.handleShowSyncSwitchMessage(R.string.localizable.alert_message_link()) { _ in
                self.view?.changeSwitchState()
            }
        }
    }

    func didSwitchOffSync() {
        self.inputInteractor.handleSyncSwitch(at: self.profileIndex, isOn: false)
    }

}

// MARK: - SyncSettingInteractorOutputProtocol
extension SyncSettingPresenter: AlertViewControllerDelegate {
    func onButtonOKDidTapped(_ type: AlertType) {
        self.router.handleUnlink(at: self.profileIndex, completion: {
            self.view?.handleUpdateView(didLinkAccount: self.haveLinkedAccount())
        })
    }
}

// MARK: - SyncSettingInteractorOutputProtocol
extension SyncSettingPresenter: SyncSettingInteractorOutputProtocol {
    func onSyncFinished(with data: SyncBaseModel?, status: Bool, message: String, page: Int) {
        if status {
            if data?.meta?.code == 200 {
                guard let data = data else { return }
                self.handleLoadmoreItems(data.data?.smartScale)
            } else {
                dLogError("[Error code]: \(data?.meta?.code ?? 0), [Error message]: \(data?.meta?.message ?? "")")
            }
        } else {
            dLogError("[Error code]: \(data?.meta?.code ?? 0), [Error message]: \(data?.meta?.message ?? "")")
        }
    }
    
    func onSyncDateUpdate(with date: String) {
        view?.onLastDateChange(with: date)
    }

    func onSyncFinished(with message: String) {
        guard let view = self.view as? SyncSettingViewController else {
            return
        }
        view.hideHud()
    }
    
    private func handleLoadmoreItems(_ items: [SmartScale]?) {
        guard let smartScale = items else { return }
        var bodyFats = [BodyFat]()
        for data in smartScale {
            var bodyFat: BodyFat?
            if data.impedance == 0 {
                bodyFat = BodyFat(data)
            } else {
                bodyFat = self.caculateBodyFatData(from: CGFloat(data.weight ?? 0), impedance: data.impedance!, syncId: data.id ?? "", createdAt: data.createdAt ?? "", deviceName: data.device ?? "", mac: data.mac ?? "")
            }
            if let bodyFat = bodyFat {
                bodyFats.append(bodyFat)
            }
        }

        guard let currentProfile = porfileListDAO.getFirstObject()?.profiles[self.profileIndex?.row ?? 0] else {
            return
        }

        if let bodyFatList = bodyFatListDAO.getObject(with: currentProfile.id) {
            bodyFatListDAO.update {
                for data1 in bodyFats {
                    var exist = false
                    for data2 in bodyFatList.bodyfats.array where data1.syncId == data2.syncId {
                        exist = true
                        break
                    }
                    if !exist {
                        var isDeleted = false
                        for data in currentProfile.deleteSyncId.array  where data == data1.syncId {
                            isDeleted = true
                            break
                        }
                        if !isDeleted {
                            bodyFatList.bodyfats.append(data1)
                        }
                    }
                }
            }
        } else {
            if !bodyFats.isEmpty {
                let scale = DeviceModel(name: bodyFats[0].scale?.name ?? "", mac: bodyFats[0].scale?.mac ?? "", deviceType: .scale, image: R.image.skSmartScale68())
                let bodyFatList = BodyFatList(profile: currentProfile, device: scale, bodyFats: bodyFats)
                bodyFatListDAO.add(bodyFatList)
            }
        }

    }
    
    /// Calculate body fat data
    /// - Parameters:
    ///   - weight: body weight
    ///   - impedance: impedance
    ///   - syncId: synnc id
    ///   - createdAt: time created
    /// - Returns: synchronized body fat data from server
    private func caculateBodyFatData(from weight: CGFloat, impedance: Int, syncId: String, createdAt: String, deviceName: String, mac: String) -> BodyFat? {
        guard let currentProfile = porfileListDAO.getFirstObject()?.currentProfile,
              let height = currentProfile.height.value,
              let birthday = currentProfile.birthday?.toDate(.ymd),
              let gender = currentProfile.gender.value else {
            return nil
        }

        let hTBodyfat = HTBodyfat_NewSDK()
        let sex = gender == .male ? THTSexType.male : .female
        let timeCreated = createdAt.toDate(.ymdhms) ?? Date()
        let age = timeCreated.year - birthday.year
        let errorType = hTBodyfat.getBodyfatWithweightKg(weight, heightCm: CGFloat(height), sex: sex, age: age, impedance: impedance)
        let bodyfat = BodyFat(bodyFat: hTBodyfat, hasError: errorType != .none, impedance: impedance)
        bodyfat.profileID = currentProfile.id
        let scale = DeviceModel(name: deviceName, mac: mac, deviceType: .scale, image: R.image.skSmartScale68())
        bodyfat.scale = scale
        bodyfat.isSync = true
        bodyfat.syncId = syncId
        bodyfat.createAt = timeCreated.toString(.hmsdMy)
        bodyfat.timestamp = timeCreated.timeIntervalSince1970
        return bodyfat
    }
}
