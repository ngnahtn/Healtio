//
//  
//  HomeRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//
//

import UIKit
import RealmSwift

class HomeRouter: BaseRouter {
    var deviceListDAO = GenericDAO<DeviceList>()

    static func setupModule() -> HomeViewController {
        let viewController = HomeViewController()
        let router = HomeRouter()
        let interactorInput = HomeInteractorInput()
        let presenter = HomePresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }

    private func gotoScaleViewController(_ scale: DeviceModel) {
        let scaleViewController = MainHomeRouter.setupModule(type: .scale(scale))
        viewController?.navigationController?.pushViewController(scaleViewController, animated: true)
    }

    private func gotoSpO2ViewController(_ spO2: DeviceModel) {
        let scaleViewController = MainHomeRouter.setupModule(type: .spO2(spO2))
        viewController?.navigationController?.pushViewController(scaleViewController, animated: true)
    }

    private func gotoBoViewController(_ bo: DeviceModel) {
        let boViewController = MainHomeRouter.setupModule(type: .bo(bo))
        viewController?.navigationController?.pushViewController(boViewController, animated: true)
    }
    
    private func gotoSmartWatchS5ViewController(_ samrtWatch: DeviceModel) {
        let smartWatchViewController = MainHomeRouter.setupModule(type: .smartWatchS5(samrtWatch))
        viewController?.navigationController?.pushViewController(smartWatchViewController, animated: true)
    }

    private func showScaleResultViewController(bodyFat: BodyFat?) {
        guard let `bodyFat` = bodyFat else {
            return
        }
        guard bodyFat.weight.value != nil else { return }
        let resultViewController = UINavigationController(rootViewController: ScaleResultRouter.setupModule(with: bodyFat))
        resultViewController.modalPresentationStyle = .fullScreen
        if let weightMeasuringVC = viewController?.presentedViewController as? WeightMeasuringViewController {
            weightMeasuringVC.present(resultViewController, animated: true, completion: nil)
        } else {
            viewController?.present(resultViewController, animated: true, completion: nil)
        }
    }

    private func showBloodPressureResultViewController(bloodPressure: BloodPressureModel?) {
        guard bloodPressure != nil else {
            return
        }
        guard bloodPressure?.sys.value != nil else {return}
        let resultViewController = BloodPressureResultRouter.setupModule(with: bloodPressure, and: "", and: true)
        resultViewController.modalPresentationStyle = .fullScreen
        if let bloodPressureMeasureVC = viewController?.presentedViewController as? BloodPressureViewController {
            bloodPressureMeasureVC.present(resultViewController, animated: true, completion: nil)
        } else {
            viewController?.present(resultViewController, animated: true, completion: nil)
        }
    }

    private func showSpO2ResultViewController(waveform: WaveformListModel?) {
        guard let `waveform` = waveform  else {
            return
        }
        guard waveform.waveforms.array.last != nil else { return }
        let spO2DetailValue = SpO2DetailValueRouter.setupModule(with: waveform)
        viewController?.navigationController?.pushViewController(spO2DetailValue, animated: true)
    }

    /// check Devices in DB to navigate
    /// - Parameter device: DeviceModel
    private func checkDevice(with device: DeviceModel) {
        if let devices = self.deviceListDAO.getObject(with: SKKey.connectedDevice)?.devices.array {
            print(devices)
            self.gotoSmartWatchS5ViewController(device)
        } else {
            self.showToast(content: R.string.localizable.deviceIsUnPaired())
        }
    }
}

// MARK: - HomeRouter: HomeRouterProtocol -
extension HomeRouter: HomeRouterProtocol {
    func gotoDeviceViewController() {
        let deviceVC = DeviceRouter.setupModule()
        viewController?.parent?.navigationController?.pushViewController(deviceVC, animated: true)
    }

    func gotoDeviceDetailsViewController(_ device: DeviceModel) {
        switch device.type {
        case .scale:
            gotoScaleViewController(device)
        case .spO2:
            gotoSpO2ViewController(device)
        case .biolightBloodPressure:
            gotoBoViewController(device)
        case .smartWatchS5:
            self.checkDevice(with: device)
        }
    }

    func showResultViewController(with activity: ActivityData) {
        switch activity {
        case .scale(let bodyFat):
            guard let `bodyFat` = bodyFat else {
                return
            }
            guard bodyFat.weight.value != nil else { return }
            showScaleResultViewController(bodyFat: bodyFat)
        case .bp(let bloodpressure):
            guard let `bloodpressure` = bloodpressure else {return}
            guard bloodpressure.sys.value != nil else {return}
            showBloodPressureResultViewController(bloodPressure: bloodpressure)
        case .spO2(let waveform):
            guard let `waveform` = waveform else {
                return
            }
            guard waveform.waveforms.array.last != nil else { return }
            showSpO2ResultViewController(waveform: waveform)
        case .sport(let excercise):
            guard let `excercise` = excercise else {
                return
            }
            guard let device = excercise.s5SmartWatch else { return }
            gotoDeviceDetailsViewController(device)
        case .step(let step):
            guard let `step` = step else {
                return
            }
            guard let device = step.device else { return }
            gotoDeviceDetailsViewController(device)
        case .s5Bp(let record):
            guard let `record` = record else {
                return
            }
            guard let device = record.device else { return }
            gotoDeviceDetailsViewController(device)
        case .s5SpO2(let record):
            guard let `record` = record else {
                return
            }
            guard let device = record.device else { return }
            gotoDeviceDetailsViewController(device)
        case .s5HR(let record):
            guard let `record` = record else {
                return
            }
            guard let device = record.device else { return }
            gotoDeviceDetailsViewController(device)
        }
    }
}
