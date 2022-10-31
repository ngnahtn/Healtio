//
//  
//  WeightMeasuringRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit

class WeightMeasuringRouter: BaseRouter {
    static func setupModule(with scale: DeviceModel) -> WeightMeasuringViewController {
        let viewController = WeightMeasuringViewController()
        viewController.modalPresentationStyle = .overFullScreen
        let router = WeightMeasuringRouter()
        let interactorInput = WeightMeasuringInteractorInput()
        let presenter = WeightMeasuringPresenter(interactor: interactorInput, router: router)
        presenter.scale = scale
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - WeightMeasuringRouterProtocol
extension WeightMeasuringRouter: WeightMeasuringRouterProtocol {
    func dismiss() {
        viewController?.dismiss(animated: true, completion: nil)
    }

    func onGoToScaleResultDetail(with weightDetail: DetailsItemProtocol, bodyFat: BodyFat) {
        let scaleResultDetailViewController = ScaleResultDetailRouter.setupModule(with: weightDetail, bodyFat: bodyFat)
        viewController?.navigationController?.pushViewController(scaleResultDetailViewController, animated: true)
    }
}
