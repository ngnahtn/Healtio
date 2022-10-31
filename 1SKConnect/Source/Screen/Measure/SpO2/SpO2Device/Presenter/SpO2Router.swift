//
//  
//  SpO2Router.swift
//  1SKConnect
//
//  Created by Be More on 1/10/2021.
//
//

import UIKit

class SpO2Router: BaseRouter {
    static func setupModule(with spO2: DeviceModel) -> SpO2ViewController {
        let viewController = SpO2ViewController()
        let router = SpO2Router()
        let interactorInput = SpO2InteractorInput()
        let presenter = SpO2Presenter(interactor: interactorInput, router: router)
        presenter.spO2 = spO2
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - SaturationOfPeripheralOxygenRouter: SpO2RouterProtocol -
extension SpO2Router: SpO2RouterProtocol {
    func showTurnOnBleAlert() {
        guard let `viewController` = viewController as? SpO2ViewController else {
            return
        }
        viewController.show()
    }

    func goToSpO2DetailValue(with waveform: WaveformListModel) {
        guard let `viewController` = viewController as? SpO2ViewController else {
            return
        }
        let spO2DetailValue = SpO2DetailValueRouter.setupModule(with: waveform)
        viewController.navigationController?.pushViewController(spO2DetailValue, animated: true)
    }
}
