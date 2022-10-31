//
//  
//  WeightMeasuringInteractorInput.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit
import RealmSwift

class WeightMeasuringInteractorInput {
    weak var output: WeightMeasuringInteractorOutputProtocol?
    var profileNotificationToken: NotificationToken?

    private let bodyfatListDAO = GenericDAO<BodyFatList>()
    private let profileListDAO = GenericDAO<ProfileListModel>()

    private func registerToken() {
        profileListDAO.registerToken(token: &profileNotificationToken) { [weak self] in
            self?.onProfileListChange()
        }
    }

    private func onProfileListChange() {
        output?.onProfileListChange(with: profileListDAO.getFirstObject())
    }

    deinit {
        profileNotificationToken?.invalidate()
    }
}

// MARK: - WeightMeasuringInteractorInputProtocol
extension WeightMeasuringInteractorInput: WeightMeasuringInteractorInputProtocol {
    func startObserver() {
        registerToken()
    }

    func addBodyFat(_ bodyFat: BodyFat, scale: DeviceModel) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let bodyFatList = bodyfatListDAO.getObject(with: profile.id) {
            bodyfatListDAO.update {
                bodyFatList.bodyfats.append(bodyFat)
            }
        } else {
            let bodyFatList = BodyFatList(profile: profile, device: scale, bodyFats: [bodyFat])
            bodyfatListDAO.add(bodyFatList)
        }
    }
}
