//
//  
//  S5SmartWatchSettingRouter.swift
//  1SKConnect
//
//  Created by Be More on 24/01/2022.
//
//

import UIKit
import TrusangBluetooth

class S5SmartWatchSettingRouter {
    weak var viewController: S5SmartWatchSettingViewController?
    static func setupModule(smartWatch: DeviceModel) -> S5SmartWatchSettingViewController {
        let viewController = S5SmartWatchSettingViewController()
        let router = S5SmartWatchSettingRouter()
        let interactorInput = S5SmartWatchSettingInteractorInput()
        let presenter = S5SmartWatchSettingPresenter(interactor: interactorInput, router: router)
        presenter.smartWatch = smartWatch
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5SmartWatchSettingRouterProtocol
extension S5SmartWatchSettingRouter: S5SmartWatchSettingRouterProtocol {

    func goToNotificationSetting(noticeStatus: ZHJDeviceConfig) {
        let vc = S5NotificationSettingRouter.setupModule(noticeStatus: noticeStatus)
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func goToGoalView() {
        let vc = S5GoalRouter.setupModule()
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToWaterView() {
        let vc = S5WaterSettingRouter.setupModule()
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToWatchFace() {
        let vc = S5WatchFaceSettingRouter.setupModule()
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
