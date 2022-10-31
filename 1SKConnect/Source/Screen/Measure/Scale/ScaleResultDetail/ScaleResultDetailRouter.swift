//
//  
//  ScaleResultDetailRouter.swift
//  1SKConnect
//
//  Created by Elcom Corp on 02/11/2021.
//
//

import UIKit

class ScaleResultDetailRouter {
    weak var viewController: UIViewController?
    static func setupModule(with weightDetail: DetailsItemProtocol, bodyFat: BodyFat) -> ScaleResultDetailViewController {
        let viewController = ScaleResultDetailViewController()
        let router = ScaleResultDetailRouter()
        let interactorInput = ScaleResultDetailInteractorInput()
        let presenter = ScaleResultDetailPresenter(interactor: interactorInput, router: router)
        presenter.weightDetail = weightDetail
        presenter.bodyFat = bodyFat
        print(bodyFat.impedance.value)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - ScaleResultDetailRouterProtocol
extension ScaleResultDetailRouter: ScaleResultDetailRouterProtocol {
    func onDismiss() {
        if let vc = viewController?.presentingViewController as? ScaleResultViewController,
           let baseNavigation = vc.presentingViewController {
            baseNavigation.dismiss(animated: true, completion: nil)
        } else {
            viewController?.dismiss(animated: true, completion: nil)
        }
    }
}
