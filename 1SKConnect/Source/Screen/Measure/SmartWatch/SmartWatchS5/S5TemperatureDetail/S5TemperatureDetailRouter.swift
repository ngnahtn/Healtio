//
//  
//  S5TemperatureDetailRouter.swift
//  1SKConnect
//
//  Created by TrungDN on 28/12/2021.
//
//

import UIKit

class S5TemperatureDetailRouter {
    weak var viewController: S5TemperatureDetailViewController?
    static func setupModule(with timeType: TimeFilterType) -> S5TemperatureDetailViewController {
        let viewController = S5TemperatureDetailViewController()
        let router = S5TemperatureDetailRouter()
        let interactorInput = S5TemperatureDetailInteractorInput()
        let presenter = S5TemperatureDetailPresenter(interactor: interactorInput, router: router)
        presenter.temperatureDetail = S5TemperatureDetail(timeType: timeType)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5TemperatureDetailRouterProtocol
extension S5TemperatureDetailRouter: S5TemperatureDetailRouterProtocol {
    
}
