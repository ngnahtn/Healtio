//
//  
//  ProfileListConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit

// MARK: View -
protocol ProfileListViewProtocol: AnyObject {
    func reloadData()
}

// MARK: Interactor -
protocol ProfileListInteractorInputProtocol {
    func registerToken()
}

protocol ProfileListInteractorOutputProtocol: AnyObject {
    func onProfileListChanged(with profileList: ProfileListModel?)
}

// MARK: Presenter -
protocol ProfileListPresenterProtocol {
    func onViewDidLoad()
    func numberOfRow(in section: Int) -> Int
    func itemForRow(at index: IndexPath) -> ProfileModel?
    func onItemDidSelected(at index: IndexPath)
    func onButtonAddProfileDidTapped()
}

// MARK: Router -
protocol ProfileListRouterProtocol {
    func gotoHealthProfileDetails(with profile: ProfileModel?, state: InfomationScreenEditableState)
}
