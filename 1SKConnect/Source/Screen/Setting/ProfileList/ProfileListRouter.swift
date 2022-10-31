//
//  
//  ProfileListRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit

class ProfileListRouter {
    weak var viewController: UIViewController?
    static func setupModule() -> ProfileListViewController {
        let viewController = ProfileListViewController()
        viewController.hidesBottomBarWhenPushed = true
        let router = ProfileListRouter()
        let interactorInput = ProfileListInteractorInput()
        let presenter = ProfileListPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - ProfileListRouterProtocol
extension ProfileListRouter: ProfileListRouterProtocol {
    func gotoHealthProfileDetails(with profile: ProfileModel?, state: InfomationScreenEditableState) {
        let healthProfileDetailsVC = HealthProfileDetailsRouter.setupModule(with: profile, state: state)
        viewController?.navigationController?.pushViewController(healthProfileDetailsVC, animated: true)
    }
}
