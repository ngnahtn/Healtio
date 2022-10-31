//
//  
//  SmartWatchS5Router.swift
//  1SKConnect
//
//  Created by TrungDN on 07/12/2021.
//
//

import UIKit

class SmartWatchS5Router: BaseRouter {
    static func setupModule(with smartWatch: DeviceModel) -> SmartWatchS5ViewController {
        let viewController = SmartWatchS5ViewController()
        let router = SmartWatchS5Router()
        let interactorInput = SmartWatchS5InteractorInput()
        let presenter = SmartWatchS5Presenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.smartWatch = smartWatch
        interactorInput.output = presenter
        interactorInput.syncS5Service = SyncS5Service()
        router.viewController = viewController
        return viewController
    }
}

// MARK: - SmartWatchS5RouterProtocol
extension SmartWatchS5Router: SmartWatchS5RouterProtocol {
    func goToSetting() {
//        let vc = S5SmartWatchSettingRouter.setupModule(smartWatch: <#DeviceModel#>)
//        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToSleepDetail(with timeType: TimeFilterType) {
        let vc = S5SleepDetailRouter.setupModule(with: timeType)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToTemperatureDetail(with timeType: TimeFilterType) {
        let vc = S5TemperatureDetailRouter.setupModule(with: timeType)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToSpO2Detail(with timeType: TimeFilterType) {
        let vc = S5Spo2DetailRouter.setupModule(with: timeType)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToHeartRateDetail(with timeType: TimeFilterType) {
        let vc = S5HeartRateDetailRouter.setupModule(with: timeType)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func goToExerciseView(with timeDefault: TimeFilterType, device: DeviceModel) {
        let vc = SmartWatchExerciseRouter.setupModule(with: timeDefault, device: device)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }

    func goToBloodPressureDetail(with timeType: TimeFilterType) {
        let vc = S5BloodPressureDetailRouter.setupModule(with: timeType)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
