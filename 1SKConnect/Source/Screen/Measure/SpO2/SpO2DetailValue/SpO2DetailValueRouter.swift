//
//  
//  SpO2DetailValueRouter.swift
//  1SKConnect
//
//  Created by TrungDN on 16/11/2021.
//
//

import UIKit

class SpO2DetailValueRouter: BaseRouter {
    static func setupModule(with waveform: WaveformListModel) -> SpO2DetailValueViewController {
        let viewController = SpO2DetailValueViewController()
        let router = SpO2DetailValueRouter()
        let interactorInput = SpO2DetailValueInteractorInput()
        let presenter = SpO2DetailValuePresenter(interactor: interactorInput, router: router)
        presenter.waveformList = waveform
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - SpO2DetailValueRouterProtocol
extension SpO2DetailValueRouter: SpO2DetailValueRouterProtocol {
    
}
