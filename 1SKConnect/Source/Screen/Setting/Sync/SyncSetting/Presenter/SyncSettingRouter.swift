//
//  SyncSettingRouter.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import Foundation
import SwiftyJSON

class SyncSettingRouter {
    weak var viewController: SyncSettingViewController?
    static func setupModule(with profile: ProfileModel, at index: IndexPath) -> SyncSettingViewController {
        let viewController = SyncSettingViewController()
        let router = SyncSettingRouter()
        let inputInteractor = SyncSettingInteractorInput()
        let presenter = SyncSettingPresenter(inputInteractor: inputInteractor, router: router)
        presenter.profile = profile
        presenter.profileIndex = index
        presenter.view = viewController
        viewController.presenter = presenter
        inputInteractor.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - SyncSettingRouterProtocol
extension SyncSettingRouter: SyncSettingRouterProtocol {

    func presentDownloadView(_ index: IndexPath?) {
        guard let index = index else { return }
        let downloadViewController = DownloadDataViewController(with: index)
        downloadViewController.delegate = self.viewController
        downloadViewController.modalPresentationStyle = .overFullScreen
        self.viewController?.present(downloadViewController, animated: false, completion: nil)
    }

    func showAlert(type: AlertType, delegate: AlertViewControllerDelegate?) {
        let alertVC = AlertViewController(type: type)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.delegate = delegate
        viewController?.present(alertVC, animated: false, completion: nil)
    }

    func handleUnlink(at index: IndexPath?, completion: (() -> Void)) {
        guard let index = index else { return }
        let porfileListDAO = GenericDAO<ProfileListModel>()
        let profileList = porfileListDAO.getFirstObject()
        porfileListDAO.update {
            if profileList?.profiles[index.row].linkAccount != nil {
                profileList?.profiles[index.row].linkAccount = nil
                profileList?.profiles[index.row].enableAutomaticSync = false
                profileList?.profiles[index.row].lastSyncDate = ""
                completion()
            }
        }
    }

    func handleLink() {
    }

    func handleSaveLinkedAccount(with user: UserLoginModel?, at index: IndexPath?, isGoogleAccount: Bool, completion: (() -> Void)) {
        guard let user = user, let index = index else {
            self.viewController?.presentMessage(R.string.localizable.sync_link_failed())
            return
        }

        let linkAccount = LinkModel(loginModel: user)
        linkAccount.isGoogleAccount = isGoogleAccount
        let porfileListDAO = GenericDAO<ProfileListModel>()
        let profileList = porfileListDAO.getFirstObject()

        for profile in profileList?.profiles.array ?? [] where linkAccount.uuid == profile.linkAccount?.uuid {
            self.viewController?.presentMessage(R.string.localizable.sync_linked_user())
            return
        }

        for profile in profileList?.profiles.array ?? [] where linkAccount.uuid == profile.linkAccountId && profile.id != profileList?.profiles[index.row].id {
            self.viewController?.presentMessage(R.string.localizable.sync_linked_user())
            return
        }

        if String.isNilOrEmpty(profileList?.profiles[index.row].linkAccountId) {
            porfileListDAO.update {
                if profileList?.profiles[index.row].linkAccount == nil {
                    profileList?.profiles[index.row].linkAccount = linkAccount
                    profileList?.profiles[index.row].linkAccountId = linkAccount.uuid
                    completion()
                }
            }
        } else {
            if profileList?.profiles[index.row].linkAccountId == linkAccount.uuid {
                porfileListDAO.update {
                    if profileList?.profiles[index.row].linkAccount == nil {
                        profileList?.profiles[index.row].linkAccount = linkAccount
                        completion()
                    }
                }
            } else {
                self.viewController?.presentMessage(R.string.localizable.sync_linked())
                return
            }
        }
    }

    func handleShowUnlinkMessage(_ message: String, handler: ((UIAlertAction) -> Void)?) {
        self.viewController?.presentMessage(message, handler: handler)
    }

    func handleShowSyncSwitchMessage(_ message: String, handler: ((UIAlertAction) -> Void)?) {
        self.viewController?.presentMessage(message, cancelHandler: handler)
    }
}
