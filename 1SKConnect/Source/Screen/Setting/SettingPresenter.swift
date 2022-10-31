//
//  
//  SettingPresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//
//

import UIKit
import RealmSwift

class SettingPresenter {
    private let profileListDAO = GenericDAO<ProfileListModel>()

    weak var view: SettingViewProtocol?
    private var interactor: SettingInteractorInputProtocol
    private var router: SettingRouterProtocol

    init(interactor: SettingInteractorInputProtocol,
         router: SettingRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - extending SettingPresenter: SettingPresenterProtocol -
extension SettingPresenter: SettingPresenterProtocol {
    func onViewDidLoad() {
    }

    func onButtonProfileDidTapped() {
        let profileList = profileListDAO.getFirstObject()
        guard let profiles = profileList?.profiles, profiles.count > 0 else {
            router.gotoHealthProfileDetails(with: nil, state: .new)
            return
        }
        router.gotoProfileListViewController()
    }

    func onButtonDeviceDidTapped() {
        router.gotoDeviceViewController()
    }

    func onButtonSyncDidTap() {
        self.router.gotoSyncViewController()
    }

    func onButtonIntroduceDidTapped() {
        router.gotoIntroduceViewController()
    }
}

// MARK: - SettingPresenter: SettingInteractorOutput -
extension SettingPresenter: SettingInteractorOutputProtocol {

}
