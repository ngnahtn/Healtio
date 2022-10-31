//
//  
//  S5WaterSettingRouter.swift
//  1SKConnect
//
//  Created by TrungDN on 08/02/2022.
//
//

import UIKit

class S5WaterSettingRouter {
    weak var viewController: S5WaterSettingViewController?
    static func setupModule() -> S5WaterSettingViewController {
        let viewController = S5WaterSettingViewController()
        let router = S5WaterSettingRouter()
        let interactorInput = S5WaterSettingInteractorInput()
        let presenter = S5WaterSettingPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5WaterSettingRouterProtocol
extension S5WaterSettingRouter: S5WaterSettingRouterProtocol {
    
}
