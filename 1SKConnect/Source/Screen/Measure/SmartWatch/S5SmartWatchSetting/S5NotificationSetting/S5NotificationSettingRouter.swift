//
//  
//  S5NotificationSettingRouter.swift
//  1SKConnect
//
//  Created by Be More on 25/01/2022.
//
//

import UIKit
import TrusangBluetooth

class S5NotificationSettingRouter {
    weak var viewController: S5NotificationSettingViewController?
    static func setupModule(noticeStatus: ZHJDeviceConfig) -> S5NotificationSettingViewController {
        let viewController = S5NotificationSettingViewController()
        let router = S5NotificationSettingRouter()
        let interactorInput = S5NotificationSettingInteractorInput()
        let presenter = S5NotificationSettingPresenter(interactor: interactorInput, router: router)
        presenter.deviceConfig = noticeStatus
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - S5NotificationSettingRouterProtocol
extension S5NotificationSettingRouter: S5NotificationSettingRouterProtocol {
    
}
