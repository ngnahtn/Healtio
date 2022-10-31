//
//  
//  S5GoalRouter.swift
//  1SKConnect
//
//  Created by admin on 17/12/2021.
//
//

import UIKit

class S5GoalRouter {
    weak var viewController: S5GoalViewController?
    static func setupModule() -> S5GoalViewController {
        let viewController = S5GoalViewController()
        let router = S5GoalRouter()
        let interactorInput = S5GoalInteractorInput()
        let presenter = S5GoalPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5GoalRouterProtocol
extension S5GoalRouter: S5GoalRouterProtocol {
}
