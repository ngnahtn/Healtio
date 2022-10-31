//
//  
//  MainHomeConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit

// MARK: View -
protocol MainHomeViewProtocol: AnyObject {
    func reloadData(with currentProfile: ProfileModel?)
    func setProfileCollectionViewHidden(_ isHidden: Bool)
    func updateView(with type: MainHomePresenter.ChildViewType)
}

// MARK: Interactor -
protocol MainHomeInteractorInputProtocol {
    func registerToken()
    func updateSelectedProfile(with profile: ProfileModel)
}

protocol MainHomeInteractorOutputProtocol: AnyObject {
    func onProfileListDidChanged(_ profileList: ProfileListModel?)
}
// MARK: Presenter -
protocol MainHomePresenterProtocol {
    var childType: MainHomePresenter.ChildViewType { get }

    func onViewDidLoad()
    func numberOfRow(in section: Int) -> Int
    func itemForRow(at index: IndexPath) -> ProfileModel?
    func didSelectedItem(at index: Int)
    func onButtonAvatarDidTapped()
    func onBackgroundDidTapped()
    func onButtonHomeDidTapped()
    func onProfileDidSelected(at index: Int)
    func onAddProfileCellDidSelected()
    func isCurrentProfile(_ profile: ProfileModel?) -> Bool
}

// MARK: Router -
protocol MainHomeRouterProtocol {
    func gotoHealthProfileDetails(with profile: ProfileModel?, state: InfomationScreenEditableState)
    func gotoHomeViewController()
}
