//
//  
//  ScaleRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit
import CoreBluetooth

class ScaleRouter: BaseRouter {
    static func setupModule(with scale: DeviceModel) -> BaseNavigationController {
        let viewController = ScaleViewController()
        let router = ScaleRouter()
        let interactorInput = ScaleInteractorInput()
        let presenter = ScalePresenter(interactor: interactorInput, router: router)
        presenter.scale = scale
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        interactorInput.configService = ConfigService()
        router.viewController = viewController

        let baseNavigationController = BaseNavigationController(rootViewController: viewController)
        baseNavigationController.setHiddenNavigationBarViewControllers([ScaleViewController.self])
        baseNavigationController.modalPresentationStyle = .fullScreen
        return baseNavigationController
    }
}

// MARK: - ScaleRouterProtocol
extension ScaleRouter: ScaleRouterProtocol {
    func openLinkSetting() {
        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile, let index: Int = profileListDAO.getFirstObject()?.profiles.array.firstIndex(of: currentProfile) else {
            return
        }

        let viewController = SyncSettingRouter.setupModule(with: currentProfile, at: IndexPath(row: index, section: 0))
        self.viewController?.present(viewController, animated: true, completion: nil)
    }

    func showLinkAccountAlert() {
        guard let `viewController` = viewController as? ScaleViewController else {
            return
        }
        viewController.show()
    }

    func dismiss() {
        viewController?.dismiss(animated: true, completion: nil)
    }

    func showTurnOnBleAlert() {
        guard let `viewController` = viewController as? ScaleViewController else {
            return
        }
        viewController.show()
    }

    func hideTurnOnBleAlert() {
        guard let `viewController` = viewController as? ScaleViewController else {
            return
        }
        viewController.hide()
    }

    func openAppSetting() {
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

    func gotoWeightMeasuringViewController(_ scale: DeviceModel) {
        let weightMeasuringVC = UINavigationController(rootViewController: WeightMeasuringRouter.setupModule(with: scale))
        weightMeasuringVC.modalPresentationStyle = .overFullScreen
        viewController?.present(weightMeasuringVC, animated: true, completion: nil)
    }

    func showResultViewController(bodyFat: BodyFat) {
        let resultViewController = UINavigationController(rootViewController: ScaleResultRouter.setupModule(with: bodyFat))
        resultViewController.modalPresentationStyle = .fullScreen
        viewController?.present(resultViewController, animated: true, completion: nil)
    }

    func gotoDeviceViewController() {
        let deviceVC = DeviceRouter.setupModule()
        viewController?.parent?.navigationController?.pushViewController(deviceVC, animated: true)
    }
}
