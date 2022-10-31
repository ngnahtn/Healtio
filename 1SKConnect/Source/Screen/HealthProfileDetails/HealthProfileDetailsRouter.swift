//
//  
//  HealthProfileDetailsRouter.swift
//  1SK
//
//  Created by tuyenvx on 05/02/2021.
//
//

import UIKit
import ContactsUI

class HealthProfileDetailsRouter: BaseRouter {
    static func setupModule(with profile: ProfileModel?, state: InfomationScreenEditableState) -> HealthProfileDetailsViewController {
        let viewController = HealthProfileDetailsViewController()
        viewController.hidesBottomBarWhenPushed = true
        let router = HealthProfileDetailsRouter()
        let interactorInput = HealthProfileDetailsInteractorInput()
        let presenter = HealthProfileDetailsPresenter(interactor: interactorInput, router: router)
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.profile = profile
        if let `profile` = profile {
            presenter.newProfile = ProfileModel(value: profile)
        } else {
            let newProfile = ProfileModel()
            newProfile.id = ProfileModel.genNewID()
            newProfile.gender.value = .male
            presenter.profile = newProfile
            presenter.newProfile = ProfileModel(value: newProfile)
        }
        presenter.state = state
        interactorInput.output = presenter
//        interactorInput.myHealthService = MyHealthService()
//        interactorInput.uploadService = UploadService()
        router.viewController = viewController
        return viewController
    }
}

// MARK: - HealthProfileDetailsRouter: HealthProfileDetailsRouterProtocol -
extension HealthProfileDetailsRouter: HealthProfileDetailsRouterProtocol {
    func back() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    func showPicker(with type: SelectionType, profile: ProfileModel? = nil, userGender: Gender?) {
        guard let `viewController` = viewController as? HealthProfileDetailsViewController else {
            return
        }
        let pickerViewController = PickerViewController.loadFromNib()
        pickerViewController.modalPresentationStyle = .overFullScreen
        pickerViewController.type = type
        pickerViewController.profile = profile
        pickerViewController.userGender = userGender
        pickerViewController.delegate = viewController
        viewController.present(pickerViewController, animated: false, completion: nil)
    }

    func showContactPicker(delegate: CNContactPickerDelegate) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
        contactPicker.delegate = delegate
        viewController?.present(contactPicker, animated: true, completion: nil)
    }

    func showAlert(type: AlertType, delegate: AlertViewControllerDelegate?) {
        let alertVC = AlertViewController.loadFromNib()
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.type = type
        alertVC.delegate = delegate
        viewController?.present(alertVC, animated: false, completion: nil)
    }
}
