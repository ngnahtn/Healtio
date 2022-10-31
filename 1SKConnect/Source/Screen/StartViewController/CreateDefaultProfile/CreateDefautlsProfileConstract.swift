//
//  
//  CreateDefautlsProfileConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 12/04/2021.
//
//

import UIKit

// MARK: View -
protocol CreateDefautlsProfileViewProtocol: AnyObject {
    func updateView(with profile: ProfileModel?, state: InfomationScreenEditableState)
    func updateGenderAndRelation(with gender: Gender?, relation: Relationship?)
    func updateBottomButtonEnable(_ isEnable: Bool)
    func setHideKeyboardViewHidden(_ isHidden: Bool)
}

// MARK: Interactor -
protocol CreateDefautlsProfileInteractorInputProtocol {

}

protocol CreateDefautlsProfileInteractorOutputProtocol: AnyObject {
}
// MARK: Presenter -
protocol CreateDefautlsProfilePresenterProtocol {
    func onViewDidLoad()
    func onBottomButtonDidTapped()
    func onSelectedLabelDidSelected(with type: SelectionType)
    func onAvatarChanged(with avatar: UIImage?)
    func onUserNameChanged(with name: String)
    func onBirthDayChanged(with birthday: String)
    func onGenderChanged(with gender: Gender)
    func onBloodGroupChanged(with bloodGroup: BloodGroup)
    func onHeightChanged(with height: Double?)
    func onWeightChanged(with weight: Double?)
}
// MARK: Router -
protocol CreateDefautlsProfileRouterProtocol: BaseRouterProtocol {
    func showMainViewController()
    func showPicker(with type: SelectionType, profile: ProfileModel?)
    func showAlert(type: AlertType, delegate: AlertViewControllerDelegate?)
}
