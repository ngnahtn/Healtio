//
//  
//  S5HeartRateDetailRouter.swift
//  1SKConnect
//
//  Created by Be More on 27/12/2021.
//
//

import UIKit

class S5HeartRateDetailRouter {
    weak var viewController: S5HeartRateDetailViewController?
    static func setupModule(with timeType: TimeFilterType) -> S5HeartRateDetailViewController {
        let viewController = S5HeartRateDetailViewController()
        let router = S5HeartRateDetailRouter()
        let interactorInput = S5HeartRateDetailInteractorInput()
        let presenter = S5HeartRateDetailPresenter(interactor: interactorInput, router: router)
        presenter.hrDetail = S5HeartRateDetail(timeType: timeType)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5HeartRateDetailRouterProtocol
extension S5HeartRateDetailRouter: S5HeartRateDetailRouterProtocol {
    
}
