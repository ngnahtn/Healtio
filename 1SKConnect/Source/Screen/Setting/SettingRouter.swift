//  
//  SettingRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//
//

import UIKit

class SettingRouter {
    weak var viewController: UIViewController?
    static func setupModule() -> SettingViewController {
        let viewController = SettingViewController()
        let router = SettingRouter()
        let interactorInput = SettingInteractorInput()
        let presenter = SettingPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - SettingRouter: SettingRouterProtocol -
extension SettingRouter: SettingRouterProtocol {
    func gotoHealthProfileDetails(with profile: ProfileModel?, state: InfomationScreenEditableState) {
        let healthProfileDetailsVC = HealthProfileDetailsRouter.setupModule(with: profile, state: state)
        viewController?.navigationController?.pushViewController(healthProfileDetailsVC, animated: true)
    }

    func gotoProfileListViewController() {
        let profileListVC = ProfileListRouter.setupModule()
        viewController?.navigationController?.pushViewController(profileListVC, animated: true)
    }

    func gotoDeviceViewController() {
        let deviceVC = DeviceRouter.setupModule()
        viewController?.navigationController?.pushViewController(deviceVC, animated: true)
    }

    func gotoSyncViewController() {
        let syncVC = SyncRouter.setUpModule()
        viewController?.navigationController?.pushViewController(syncVC, animated: true)
    }

    func gotoIntroduceViewController() {
        let introduceVC = IntroduceRouter.setupModule()
        viewController?.navigationController?.pushViewController(introduceVC, animated: true)
    }
    
    func gotoSleepRemiderViewController() {
       
    }
}
