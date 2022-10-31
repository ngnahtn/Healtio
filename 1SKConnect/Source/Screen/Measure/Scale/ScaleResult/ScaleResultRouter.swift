//
//  
//  ScaleResultRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//
//

import UIKit

class ScaleResultRouter {
    weak var viewController: UIViewController?
    static func setupModule(with bodyFat: BodyFat) -> UIViewController {
        let viewController = ScaleResultViewController()
        viewController.modalPresentationStyle = .overFullScreen
        let router = ScaleResultRouter()
        let interactorInput = ScaleResultInteractorInput()
        let presenter = ScaleResultPresenter(interactor: interactorInput, router: router)
        presenter.bodyFat = bodyFat
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - ScaleResultRouter: ScaleResultRouterProtocol -
extension ScaleResultRouter: ScaleResultRouterProtocol {
    func onGoToScaleResultDetail(with weightDetail: DetailsItemProtocol, bodyFat: BodyFat) {
        let scaleResultDetailViewController = ScaleResultDetailRouter.setupModule(with: weightDetail, bodyFat: bodyFat)
        viewController?.navigationController?.pushViewController(scaleResultDetailViewController, animated: true)
    }

    func dismiss() {
        if let weightMesuringVC = viewController?.presentingViewController as? WeightMeasuringViewController,
           let baseNavigation = weightMesuringVC.presentingViewController {
            baseNavigation.dismiss(animated: true, completion: nil)
        } else {
            viewController?.dismiss(animated: true, completion: nil)
        }
    }
}
