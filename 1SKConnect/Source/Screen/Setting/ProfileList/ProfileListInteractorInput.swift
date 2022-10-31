//
//  
//  ProfileListInteractorInput.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit
import RealmSwift

class ProfileListInteractorInput {
    weak var output: ProfileListInteractorOutputProtocol?
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private var profileNotificationToken: NotificationToken?

    private func onProfileListChange() {
        let profileList = profileListDAO.getFirstObject()
        output?.onProfileListChanged(with: profileList)
    }

    deinit {
        profileNotificationToken?.invalidate()
    }
}

// MARK: - ProfileListInteractorInputProtocol
extension ProfileListInteractorInput: ProfileListInteractorInputProtocol {
    func registerToken() {
        profileListDAO.registerToken(token: &profileNotificationToken) { [weak self] in
            self?.onProfileListChange()
        }
    }
}
