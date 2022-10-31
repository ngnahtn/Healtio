//
//  
//  S5SleepDetailRouter.swift
//  1SKConnect
//
//  Created by TrungDN on 30/12/2021.
//
//

import UIKit

class S5SleepDetailRouter: BaseRouter {
    static func setupModule(with timeType: TimeFilterType) -> S5SleepDetailViewController {
        let viewController = S5SleepDetailViewController()
        let router = S5SleepDetailRouter()
        let interactorInput = S5SleepDetailInteractorInput()
        let presenter = S5SleepDetailPresenter(interactor: interactorInput, router: router)
        presenter.sleepDetail = S5SleepDetail(timeType: timeType)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5SleepDetailRouterProtocol
extension S5SleepDetailRouter: S5SleepDetailRouterProtocol {
    
}
