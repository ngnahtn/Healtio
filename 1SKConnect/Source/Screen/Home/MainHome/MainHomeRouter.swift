//
//  
//  MainHomeRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit

class MainHomeRouter {
    weak var viewController: UIViewController?
    static func setupModule(type: MainHomePresenter.ChildViewType) -> MainHomeViewController {
        let viewController = MainHomeViewController()
        viewController.modalPresentationStyle = .fullScreen
        let router = MainHomeRouter()
        let interactorInput = MainHomeInteractorInput()
        let presenter = MainHomePresenter(interactor: interactorInput, router: router)
        presenter.type = type
        switch type {
        case .scale, .spO2, .bo, .smartWatchS5:
            viewController.hidesBottomBarWhenPushed = true
        default:
            break
        }
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - MainHomeRouterProtocol
extension MainHomeRouter: MainHomeRouterProtocol {
    func gotoHealthProfileDetails(with profile: ProfileModel?, state: InfomationScreenEditableState) {
        let healthProfileDetailsVC = HealthProfileDetailsRouter.setupModule(with: profile, state: state)
        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(healthProfileDetailsVC, animated: true)
        } else if let tabbar = viewController?.presentingViewController as? MainTabbarViewController,
                  let navigationController = tabbar.selectedViewController as? BaseNavigationController {
            navigationController.pushViewController(healthProfileDetailsVC, animated: true)
        } else {

        }
    }

    func gotoHomeViewController() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
