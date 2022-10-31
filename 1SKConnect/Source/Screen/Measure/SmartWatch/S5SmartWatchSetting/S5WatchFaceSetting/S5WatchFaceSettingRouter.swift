//
//  
//  S5WatchFaceSettingRouter.swift
//  1SKConnect
//
//  Created by admin on 10/02/2022.
//
//

import UIKit

class S5WatchFaceSettingRouter {
    weak var viewController: S5WatchFaceSettingViewController?
    static func setupModule() -> S5WatchFaceSettingViewController {
        let viewController = S5WatchFaceSettingViewController()
        let router = S5WatchFaceSettingRouter()
        let interactorInput = S5WatchFaceSettingInteractorInput()
        let presenter = S5WatchFaceSettingPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5WatchFaceSettingRouterProtocol
extension S5WatchFaceSettingRouter: S5WatchFaceSettingRouterProtocol {
    
}
