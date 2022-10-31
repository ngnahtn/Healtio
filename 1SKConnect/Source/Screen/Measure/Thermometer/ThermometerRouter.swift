//
//  
//  ThermometerRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//
//

import UIKit

class ThermometerRouter {
    weak var viewController: UIViewController?
    static func setupModule() -> ThermometerViewController {
        let viewController = ThermometerViewController()
        let router = ThermometerRouter()
        let interactorInput = ThermometerInteractorInput()
        let presenter = ThermometerPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - ThermometerRouter: ThermometerRouterProtocol -
extension ThermometerRouter: ThermometerRouterProtocol {
    
}
