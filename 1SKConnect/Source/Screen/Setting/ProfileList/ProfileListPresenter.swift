//
//  
//  ProfileListPresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit

class ProfileListPresenter {
    private var profileList: ProfileListModel?
    private var currentProfile: ProfileModel?

    weak var view: ProfileListViewProtocol?
    private var interactor: ProfileListInteractorInputProtocol
    private var router: ProfileListRouterProtocol

    init(interactor: ProfileListInteractorInputProtocol,
         router: ProfileListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - ProfileListPresenterProtocol
extension ProfileListPresenter: ProfileListPresenterProtocol {
    func onViewDidLoad() {
        interactor.registerToken()
    }

    func numberOfRow(in section: Int) -> Int {
        return profileList?.profiles.count ?? 0
    }

    func itemForRow(at index: IndexPath) -> ProfileModel? {
        return profileList?.profiles[index.row]
    }

    func onItemDidSelected(at index: IndexPath) {
        let profile = profileList?.profiles[index.row]
        router.gotoHealthProfileDetails(with: profile, state: .edit)
    }

    func onButtonAddProfileDidTapped() {
        router.gotoHealthProfileDetails(with: nil, state: .new)
    }
}

// MARK: - ProfileListPresenter: ProfileListInteractorOutput -
extension ProfileListPresenter: ProfileListInteractorOutputProtocol {
    func onProfileListChanged(with profileList: ProfileListModel?) {
        self.profileList = profileList
        view?.reloadData()
    }
}
