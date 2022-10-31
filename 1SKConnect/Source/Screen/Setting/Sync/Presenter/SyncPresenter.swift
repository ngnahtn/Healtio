//
//  SyncPresenter.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import Foundation

class SyncPresenter {
    private var profileList: ProfileListModel?
    private var currentProfile: ProfileModel?
    weak var view: SyncViewProtocol?
    private var interactor: SyncInteractorInputProtocol
    private var router: SyncRouterProtocol

    init(interactor: SyncInteractorInputProtocol,
         router: SyncRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - SyncPresenterProtocol
extension SyncPresenter: SyncPresenterProtocol {
    func onViewDidLoad() {
        self.interactor.registerToken()
    }
    
    func numberOfRow(in section: Int) -> Int {
        self.profileList?.profiles.count ?? 0
    }

    func itemForRow(at index: IndexPath) -> ProfileModel? {
        let profile = self.profileList?.profiles[index.row]
        return profile
    }

    func onItemDidSelected(at index: IndexPath) {
        self.router.gotoSyncSetting(with: self.profileList?.profiles[index.row], at: index)
    }
}

// MARK: - SyncInteractorOutputProtocol
extension SyncPresenter: SyncInteractorOutputProtocol {
    func onProfileListChanged(with profileList: ProfileListModel?) {
        self.profileList = profileList
        view?.reloadData()
    }
}
