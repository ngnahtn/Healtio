//
//  SyncRounter.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import UIKit

class SyncRouter {
    weak var viewController: UIViewController?
    static func setUpModule() -> SyncViewController {
        let viewController = SyncViewController()
        let interactorInput = SyncInteractorInput()
        let router = SyncRouter()
        let presenter = SyncPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

extension SyncRouter: SyncRouterProtocol {
    func gotoSyncSetting(with profile: ProfileModel?, at index: IndexPath) {
        guard let userProfile = profile else { return }
        let viewController = SyncSettingRouter.setupModule(with: userProfile, at: index)
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}
