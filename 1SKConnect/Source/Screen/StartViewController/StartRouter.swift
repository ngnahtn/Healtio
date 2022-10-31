//
//  
//  StartRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//
//

import UIKit

class StartRouter {
    weak var viewController: UIViewController?
    static func setupModule() -> StartViewController {
        let viewController = StartViewController()
        let router = StartRouter()
        let interactorInput = StartInteractorInput()
        let presenter = StartPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        interactorInput.configService = ConfigService()
        router.viewController = viewController
        return viewController
    }
}

// MARK: - StartRouter: StartRouterProtocol -
extension StartRouter: StartRouterProtocol {
    func showMainTabbarController() {
        let mainTabbarController = MainTabbarViewController()
        mainTabbarController.modalPresentationStyle = .overFullScreen
        if viewController?.presentedViewController != nil {
            viewController?.dismiss(animated: false, completion: {
                self.viewController?.present(mainTabbarController, animated: true, completion: nil)
            })
        } else {
            viewController?.present(mainTabbarController, animated: true, completion: nil)
        }
    }

    func showCreateProfileViewController(delegate: CreateDefautlsProfilePresenterDelegate?) {
        let createDefautltsProfileVC = CreateDefautlsProfileRouter.setupModule(with: delegate)
        viewController?.present(createDefautltsProfileVC, animated: true, completion: nil)
    }
}
