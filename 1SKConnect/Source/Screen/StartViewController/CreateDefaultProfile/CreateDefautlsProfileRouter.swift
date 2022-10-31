//
//  
//  CreateDefautlsProfileRouter.swift
//  1SKConnect
//
//  Created by tuyenvx on 12/04/2021.
//
//

import UIKit

class CreateDefautlsProfileRouter: BaseRouter {
    static func setupModule(with delegate: CreateDefautlsProfilePresenterDelegate?) -> CreateDefautlsProfileViewController {
        let viewController = CreateDefautlsProfileViewController()
        viewController.modalPresentationStyle = .overFullScreen
        let router = CreateDefautlsProfileRouter()
        let interactorInput = CreateDefautlsProfileInteractorInput()
        let presenter = CreateDefautlsProfilePresenter(interactor: interactorInput, router: router)
        //
        let newProfile = ProfileModel()
        newProfile.id = ProfileModel.genNewID()
        newProfile.gender.value = .male
        newProfile.relation.value = .yourSelf
        presenter.profile = newProfile
        presenter.newProfile = ProfileModel(value: newProfile)
        presenter.state = .new
        presenter.delegate = delegate
        //
        viewController.presenter = presenter
        presenter.view = viewController
        interactorInput.output = presenter
        router.viewController = viewController
        return viewController
    }
}

// MARK: - CreateDefautlsProfileRouterProtocol
extension CreateDefautlsProfileRouter: CreateDefautlsProfileRouterProtocol {
    func showMainViewController() {
        viewController?.dismiss(animated: true, completion: nil)
    }

    func showPicker(with type: SelectionType, profile: ProfileModel?) {
        guard let `viewController` = viewController as? CreateDefautlsProfileViewController else {
            return
        }
        let pickerViewController = PickerViewController.loadFromNib()
        pickerViewController.modalPresentationStyle = .overFullScreen
        pickerViewController.type = type
        pickerViewController.profile = profile
        pickerViewController.delegate = viewController
        viewController.present(pickerViewController, animated: false, completion: nil)
    }

    func showAlert(type: AlertType, delegate: AlertViewControllerDelegate?) {
        let alertVC = AlertViewController.loadFromNib()
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.delegate = delegate
        viewController?.present(alertVC, animated: false, completion: nil)
    }
}
