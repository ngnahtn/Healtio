//
//  
//  SmartWatchExerciseRouter.swift
//  1SKConnect
//
//  Created by admin on 13/12/2021.
//
//

import UIKit

class SmartWatchExerciseRouter {
    weak var viewController: SmartWatchExerciseViewController?
    static func setupModule(with timeDefaul: TimeFilterType, device: DeviceModel) -> SmartWatchExerciseViewController {
        let viewController = SmartWatchExerciseViewController()
        let router = SmartWatchExerciseRouter()
        let interactorInput = SmartWatchExerciseInteractorInput()
        let presenter = SmartWatchExercisePresenter(interactor: interactorInput, router: router)
        presenter.smartWatch = device
        presenter.timeType = timeDefaul
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - SmartWatchExerciseRouterProtocol
extension SmartWatchExerciseRouter: SmartWatchExerciseRouterProtocol {
}
