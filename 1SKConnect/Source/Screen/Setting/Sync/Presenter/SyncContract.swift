//
//  SyncContract.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import Foundation

// MARK: View -
protocol SyncViewProtocol: AnyObject {
    func reloadData()
}

// MARK: Interactor -
protocol SyncInteractorInputProtocol {
    func registerToken()
}

protocol SyncInteractorOutputProtocol: AnyObject {
    func onProfileListChanged(with profileList: ProfileListModel?)
}

// MARK: Presenter -
protocol SyncPresenterProtocol {
    func onViewDidLoad()
    func numberOfRow(in section: Int) -> Int
    func itemForRow(at index: IndexPath) -> ProfileModel?
    func onItemDidSelected(at index: IndexPath)
}

// MARK: Router -
protocol SyncRouterProtocol {
    func gotoSyncSetting(with profile: ProfileModel?, at index: IndexPath)
}
