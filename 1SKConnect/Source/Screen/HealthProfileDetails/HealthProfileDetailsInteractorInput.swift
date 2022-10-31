//
//  
//  HealthProfileDetailsInteractorInput.swift
//  1SK
//
//  Created by tuyenvx on 05/02/2021.
//
//

import UIKit
import RealmSwift

class HealthProfileDetailsInteractorInput {
    weak var output: HealthProfileDetailsInteractorOutputProtocol?
    var profileListDAO = GenericDAO<ProfileListModel>()
    private var token: NotificationToken?

    func registerToken() {
        profileListDAO.registerToken(token: &token) { [weak self] in
            if let profileList = self?.profileListDAO.getFirstObject(),
               let userProfile = profileList.profiles.first(where: { $0.relation.value == .yourSelf }),
               let gender = userProfile.gender.value {
                self?.output?.onUserGenderDidChange(with: gender)
            }
        }
    }
}

// MARK: - HealthProfileDetailsInteractorInput - HealthProfileDetailsInteractorInputProtocol -
extension HealthProfileDetailsInteractorInput: HealthProfileDetailsInteractorInputProtocol {
    func addNotification() {
        registerToken()
    }
}
