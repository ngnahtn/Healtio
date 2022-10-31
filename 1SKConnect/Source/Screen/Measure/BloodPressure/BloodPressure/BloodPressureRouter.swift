//
//  
//  BloodPressureRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/02/2021.
//
//

import UIKit

class BloodPressureRouter: BaseRouter {
//    weak var viewController: UIViewController?
    static func setupModule(with bo: DeviceModel) -> BaseNavigationController {
        let viewController = BloodPressureViewController()
        let router = BloodPressureRouter()
        let interactorInput = BloodPressureInteractorInput()
        let presenter = BloodPressurePresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        presenter.biolight = bo
        let baseNavigationController = BaseNavigationController(rootViewController: viewController)
        baseNavigationController.setHiddenNavigationBarViewControllers([BloodPressureViewController.self])
        baseNavigationController.modalPresentationStyle = .fullScreen
        return baseNavigationController

    }
}

// MARK: - BloodPressureRouter: BloodPressureRouterProtocol -
extension BloodPressureRouter: BloodPressureRouterProtocol {
    func gotoBloodPressureResultViewController(with data: BloodPressureModel?, and errorText: String) {
        let vc = BloodPressureResultRouter.setupModule(with: data, and: errorText)
        vc.modalPresentationStyle = .overFullScreen
        viewController?.present(vc, animated: true)
    }

    func showLinkAccountAlert() {
        guard let `viewController` = viewController as? BloodPressureViewController else {
            return
        }
        viewController.show()
    }

    func openLinkSetting() {
        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile, let index: Int = profileListDAO.getFirstObject()?.profiles.array.firstIndex(of: currentProfile) else {
            return
        }

        let viewController = SyncSettingRouter.setupModule(with: currentProfile, at: IndexPath(row: index, section: 0))
        self.viewController?.present(viewController, animated: true, completion: nil)
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
}
