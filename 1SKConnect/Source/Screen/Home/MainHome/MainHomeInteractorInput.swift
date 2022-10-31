//
//  
//  MainHomeInteractorInput.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit
import RealmSwift

class MainHomeInteractorInput {
    weak var output: MainHomeInteractorOutputProtocol?
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private var profileNotificationToken: NotificationToken?

    private func onProfileListChange() {
        let profileListModel = profileListDAO.getFirstObject()
        output?.onProfileListDidChanged(profileListModel)
    }

    deinit {
        profileNotificationToken?.invalidate()
    }

}

// MARK: - MainHomeInteractorInputProtocol
extension MainHomeInteractorInput: MainHomeInteractorInputProtocol {
    func registerToken() {
        profileListDAO.registerToken(token: &profileNotificationToken) { [weak self] in
            self?.onProfileListChange()
        }
    }

    func updateSelectedProfile(with profile: ProfileModel) {
        profileListDAO.update { [weak self] in
            self?.profileListDAO.getFirstObject()?.selectedID = profile.id
        }
    }
}
