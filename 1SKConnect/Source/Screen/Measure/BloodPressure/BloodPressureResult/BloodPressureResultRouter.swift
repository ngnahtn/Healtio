//
//  
//  BloodPressureResultRouter.swift
//  1SKConnect
//
//  Created by admin on 19/11/2021.
//
//

import UIKit

class BloodPressureResultRouter: BaseRouter {
    
    static func setupModule(with data: BloodPressureModel?, and errorText: String, and isFromeHome: Bool) -> BloodPressureResultViewController {
        let viewController = BloodPressureResultViewController()
        let router = BloodPressureResultRouter()
        let interactorInput = BloodPressureResultInteractorInput()
        let presenter = BloodPressureResultPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        viewController.isFromHome = isFromeHome
        presenter.bloodPressureModel = data
        presenter.errorText = errorText
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - BloodPressureResultRouterProtocol
extension BloodPressureResultRouter: BloodPressureResultRouterProtocol {
    func measureAgain(from view: BloodPressureResultViewController) {
        view.dismiss(animated: true) {
            view.callBack?()
        }
    }
    
    func backToBloodPressureVC(from view: BloodPressureResultViewController) {
        view.dismiss(animated: true)
    }
}
