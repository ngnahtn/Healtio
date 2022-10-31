//
//  
//  DeviceRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//
//

import UIKit

class DeviceRouter: BaseRouter {
    static func setupModule() -> DeviceViewController {
        let viewController = DeviceViewController()
        viewController.hidesBottomBarWhenPushed = true
        let router = DeviceRouter()
        let interactorInput = DeviceInteractorInput()
        let presenter = DevicePresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }

    private func gotoScaleViewController(_ scale: DeviceModel) {
        let scaleViewController = MainHomeRouter.setupModule(type: .scale(scale))
        let baseNavigation = BaseNavigationController(rootViewController: scaleViewController)
        baseNavigation.modalPresentationStyle = .fullScreen
        baseNavigation.setHiddenNavigationBarViewControllers([MainHomeViewController.self])
        viewController?.present(baseNavigation, animated: true, completion: nil)
    }
    
}

// MARK: - DeviceRouterProtocol
extension DeviceRouter: DeviceRouterProtocol {
    func goToSetting(smartWatch: DeviceModel) {
        let vc = S5SmartWatchSettingRouter.setupModule(smartWatch: smartWatch)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoDeviceDetailsViewController(_ device: DeviceModel) {
        switch device.type {
        case .scale:
            gotoScaleViewController(device)
        case .spO2:
            dLogDebug("[spO2]")
        case .biolightBloodPressure:
            dLogDebug("[bo]")
        case .smartWatchS5:
            dLogDebug("[Smart Watch]")
        }
    }

    func openApplicationSetting() {
        switch BluetoothManager.shared.centralManager.state {
        case .poweredOff:
            guard let settingURL = URL(string: "App-Prefs:root=General"),
                UIApplication.shared.canOpenURL(settingURL) else {
                return
            }
            UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
        case .unauthorized:
            guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(settingURL) else {
                return
            }
            UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
        default: break
        }
    }

    func showAlert(type: AlertType, delegate: AlertViewControllerDelegate?) {
        let alertVC = AlertViewController(type: type)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.delegate = delegate
        viewController?.present(alertVC, animated: false, completion: nil)
    }
}
