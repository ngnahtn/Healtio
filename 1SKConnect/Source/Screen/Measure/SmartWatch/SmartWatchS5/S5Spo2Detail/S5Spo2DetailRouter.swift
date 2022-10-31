//
//  
//  S5Spo2DetailRouter.swift
//  1SKConnect
//
//  Created by Be More on 28/12/2021.
//
//

import UIKit

class S5Spo2DetailRouter {
    weak var viewController: S5Spo2DetailViewController?
    static func setupModule(with timeType: TimeFilterType) -> S5Spo2DetailViewController {
        let viewController = S5Spo2DetailViewController()
        let router = S5Spo2DetailRouter()
        let interactorInput = S5Spo2DetailInteractorInput()
        let presenter = S5Spo2DetailPresenter(interactor: interactorInput, router: router)
        presenter.spO2Detail = S5SpO2Detail(timeType: timeType)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5Spo2DetailRouterProtocol
extension S5Spo2DetailRouter: S5Spo2DetailRouterProtocol {
    
}
