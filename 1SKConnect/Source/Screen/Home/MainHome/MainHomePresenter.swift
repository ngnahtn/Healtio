//
//  
//  MainHomePresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit

class MainHomePresenter {
    var type: ChildViewType = .home
    private var profileList: [ProfileModel] = []
    private var currentProfile: ProfileModel?
    private var isShowingProfileCollectionView = false

    weak var view: MainHomeViewProtocol?
    private var interactor: MainHomeInteractorInputProtocol
    private var router: MainHomeRouterProtocol

    init(interactor: MainHomeInteractorInputProtocol,
         router: MainHomeRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    private func hideProfileView() {
        isShowingProfileCollectionView = false
        view?.setProfileCollectionViewHidden(true)
    }
}

// MARK: - MainHomePresenterProtocol
extension MainHomePresenter: MainHomePresenterProtocol {
    var childType: ChildViewType {
        return self.type
    }

    func onViewDidLoad() {
        view?.updateView(with: type)
        interactor.registerToken()
    }

    func numberOfRow(in section: Int) -> Int {
        return profileList.count
    }

    func itemForRow(at index: IndexPath) -> ProfileModel? {
        guard index.row < profileList.count else {
            return nil
        }
        return profileList[index.row]
    }

    func didSelectedItem(at index: Int) {

    }

    func onButtonAvatarDidTapped() {
        isShowingProfileCollectionView = !isShowingProfileCollectionView
        view?.setProfileCollectionViewHidden(!isShowingProfileCollectionView)
    }

    func onBackgroundDidTapped() {
        hideProfileView()
    }

    func onButtonHomeDidTapped() {
        router.gotoHomeViewController()
    }

    func onProfileDidSelected(at index: Int) {
        hideProfileView()
        let profile = profileList[index]
        interactor.updateSelectedProfile(with: profile)
        isShowingProfileCollectionView = false
        view?.setProfileCollectionViewHidden(true)
    }

    func onAddProfileCellDidSelected() {
        hideProfileView()
        router.gotoHealthProfileDetails(with: nil, state: .new)
    }

    func isCurrentProfile(_ profile: ProfileModel?) -> Bool {
        guard let `profile` = profile else {
            return false
        }
        return profile.id == currentProfile?.id
    }
}

// MARK: - MainHomePresenter: MainHomeInteractorOutput -
extension MainHomePresenter: MainHomeInteractorOutputProtocol {
    func onProfileListDidChanged(_ profileList: ProfileListModel?) {
        guard let profiles = profileList?.profiles.array, profiles.count > 0 else {
            view?.reloadData(with: nil)
            return
        }
        if let `currentProfile` = profileList?.currentProfile, self.currentProfile != currentProfile {
            self.currentProfile = currentProfile
        }
        self.profileList = profiles
        self.view?.reloadData(with: self.currentProfile)
    }
}

extension MainHomePresenter {
    enum ChildViewType {
        case home
        case tracking
        case scale(DeviceModel)
        case spO2(DeviceModel)
        case bo(DeviceModel)
        case smartWatchS5(DeviceModel)
    }
}
