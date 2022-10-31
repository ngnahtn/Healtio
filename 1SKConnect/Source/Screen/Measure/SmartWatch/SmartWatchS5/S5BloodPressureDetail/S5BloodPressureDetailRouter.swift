//
//  
//  S5BloodPressureDetailRouter.swift
//  1SKConnect
//
//  Created by TrungDN on 27/12/2021.
//
//

import UIKit

class S5BloodPressureDetailRouter: BaseRouter {
    static func setupModule(with timeType: TimeFilterType) -> S5BloodPressureDetailViewController {
        let viewController = S5BloodPressureDetailViewController()
        let router = S5BloodPressureDetailRouter()
        let interactorInput = S5BloodPressureDetailInteractorInput()
        let presenter = S5BloodPressureDetailPresenter(interactor: interactorInput, router: router)
        presenter.bloodPressureDetail = S5BloodPressureDetail(timeType: timeType)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5BloodPressureDetailRouterProtocol
extension S5BloodPressureDetailRouter: S5BloodPressureDetailRouterProtocol {
    
}
