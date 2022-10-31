//
//  SyncSettingContract.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import Foundation

// MARK: View -
protocol SyncSettingViewProtocol: AnyObject {
    func setProfileData(with user: ProfileModel)
    func handleUpdateView(didLinkAccount: Bool)
    func changeSwitchState()
    func presentDownloadView()
    func onLastDateChange(with date: String)
}

// MARK: Interactor -
protocol SyncSettingInteractorInputProtocol {
    func handleSyncSwitch(at index: IndexPath?, isOn: Bool)
    func handleSync(with index: IndexPath?)
    
    func handleGetSyncData(with index: IndexPath?)
}

protocol SyncSettingInteractorOutputProtocol: AnyObject {
    func onSyncFinished(with message: String)
    func onSyncDateUpdate(with date: String)
    
    func onSyncFinished(with data: SyncBaseModel?, status: Bool, message: String, page: Int)
}

// MARK: Presenter -
protocol SyncSettingPresenterProtocol {
    func presentDownloadView()
    func onViewDidLoad()
    func didTapButtonLink()
    func didSwitchSync()
    func didSwitchOffSync()
    func didTapSync()
    func saveLinkedAccount(with user: UserLoginModel?, isGoogleAccount: Bool)
    
    func getSyncData()
}

// MARK: Router -
protocol SyncSettingRouterProtocol {
    func handleLink()
    func presentDownloadView(_ index: IndexPath?)
    func handleUnlink(at index: IndexPath?, completion: (() -> Void))
    func handleSaveLinkedAccount(with user: UserLoginModel?, at index: IndexPath?, isGoogleAccount: Bool, completion: (() -> Void))
    func handleShowUnlinkMessage(_ message: String, handler: ((UIAlertAction) -> Void)?)
    func handleShowSyncSwitchMessage(_ message: String, handler: ((UIAlertAction) -> Void)?)
    func showAlert(type: AlertType, delegate: AlertViewControllerDelegate?)
}
