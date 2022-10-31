//
//  SyncInteractorInput.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import Foundation
import RealmSwift

class SyncInteractorInput {
    weak var output: SyncInteractorOutputProtocol?
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
extension SyncInteractorInput: SyncInteractorInputProtocol {
    func registerToken() {
        profileListDAO.registerToken(token: &profileNotificationToken) { [weak self] in
            self?.onProfileListChange()
        }
    }
}
