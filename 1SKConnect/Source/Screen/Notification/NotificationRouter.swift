//
//  
//  NotificationRouter.swift
//  1SK
//
//  Created by tuyenvx on 25/02/2021.
//
//

import UIKit

class NotificationRouter: BaseRouter {
    static func setupModule() -> NotificationViewController {
        let viewController = NotificationViewController()
        let router = NotificationRouter()
        let interactorInput = NotificationInteractorInput()
        let presenter = NotificationPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        interactorInput.configService = ConfigService()
        router.viewController = viewController
        return viewController
    }
}

// MARK: - NotificationRouter: NotificationRouterProtocol -
extension NotificationRouter: NotificationRouterProtocol {
}
