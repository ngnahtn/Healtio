//
//  
//  IntroduceRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/04/2021.
//
//

import UIKit

class IntroduceRouter {
    weak var viewController: IntroduceViewController?
    static func setupModule() -> IntroduceViewController {
        let viewController = IntroduceViewController()
        viewController.hidesBottomBarWhenPushed = true
        let router = IntroduceRouter()
        let interactorInput = IntroduceInteractorInput()
        let presenter = IntroducePresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - IntroduceRouterProtocol
extension IntroduceRouter: IntroduceRouterProtocol {
}
