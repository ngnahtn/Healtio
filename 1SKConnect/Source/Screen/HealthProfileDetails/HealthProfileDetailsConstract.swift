//
//  
//  HealthProfileDetailsConstract.swift
//  1SK
//
//  Created by tuyenvx on 05/02/2021.
//
//

import UIKit
import ContactsUI

// MARK: View -
protocol HealthProfileDetailsViewProtocol: AnyObject {
    func updateView(with profile: ProfileModel?, state: InfomationScreenEditableState)
    func updateGenderAndRelation(with gender: Gender?, relation: Relationship?)
    func updatePhoneNumber(with phoneNumber: String?)
    func updateBottomButtonEnable(_ isEnable: Bool)
    func setHideKeyboardViewHidden(_ isHidden: Bool)
}

// MARK: Interactor -
protocol HealthProfileDetailsInteractorInputProtocol {
    func addNotification()
}

protocol HealthProfileDetailsInteractorOutputProtocol: AnyObject {
    func onUserGenderDidChange(with gender: Gender)
}
// MARK: Presenter -
protocol HealthProfileDetailsPresenterProtocol {
    func onViewDidLoad()
    func onButtonCloseDidTapped()
    func onButtonDeleteDidTapped()
    func onBottomButtonDidTapped()
    func onButtonContactDidTapped()
    func onSelectedLabelDidSelected(with type: SelectionType)

    func onAvatarChanged(with avatar: UIImage?)
    func onUserNameChanged(with name: String)
    func onBirthDayChanged(with birthday: String)
    func onGenderChanged(with gender: Gender)
    func onBloodGroupChanged(with bloodGroup: BloodGroup)
    func onHeightChanged(with height: Double?)
    func onWeightChanged(with weight: Double?)
    func onActivityIndexChanged(with activity: ActivityIndex)
    func onRelationshipChanged(with relation: Relationship)
    func onPhoneNumberChanged(with phoneNumber: String)
    func onEmailChanged(with email: String)
    func getRelationshipItems() -> [Relationship]
    func isYourSelfProfile() -> Bool
}

// MARK: Router -
protocol HealthProfileDetailsRouterProtocol: BaseRouterProtocol {
    func back()
//    func showSlectionViewController(with profile: ProfileModel?, type: SelectionType)
    func showPicker(with type: SelectionType, profile: ProfileModel?, userGender: Gender?)
    func showContactPicker(delegate: CNContactPickerDelegate)
    func showAlert(type: AlertType, delegate: AlertViewControllerDelegate?)
}
