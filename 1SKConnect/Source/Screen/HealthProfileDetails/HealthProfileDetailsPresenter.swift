//
//  
//  HealthProfileDetailsPresenter.swift
//  1SK
//
//  Created by tuyenvx on 05/02/2021.
//
//

import UIKit
import Contacts
import ContactsUI

class HealthProfileDetailsPresenter: NSObject {

    weak var view: HealthProfileDetailsViewProtocol?
    private var interactor: HealthProfileDetailsInteractorInputProtocol
    private var router: HealthProfileDetailsRouterProtocol

    var state: InfomationScreenEditableState = .new
    var profile: ProfileModel?
    var newProfile: ProfileModel?
    private var newAvatar: UIImage?
    let profileDAO = GenericDAO<ProfileModel>()
    private var profileListDAO = GenericDAO<ProfileListModel>()
    private var userGender: Gender?

    init(interactor: HealthProfileDetailsInteractorInputProtocol,
         router: HealthProfileDetailsRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    // MARK: - Setup
    func addKeyboardObserver() {
        kNotificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIControl.keyboardWillShowNotification, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIControl.keyboardWillHideNotification, object: nil)
    }
    // MARK: - Action
    private func addNewProfile(_ profile: ProfileModel) {
        if let profileList = profileListDAO.getFirstObject() {
            profileListDAO.update {
                profileList.profiles.append(profile)
                profileList.selectedID = profile.id
            }
        } else {
            let profileListModel = ProfileListModel(profiles: [profile])
            profileListModel.selectedID = profile.id
            profileListDAO.add(profileListModel)
        }
        self.profile = ProfileModel(value: profile)
        self.newProfile = ProfileModel(value: self.profile!)
        state = .normal
        view?.updateView(with: profile, state: state)
        router.back()
    }

    private func updateProfile(_ profile: ProfileModel) {
        profileDAO.add(profile)
        self.profile = ProfileModel(value: profile)
        self.newProfile = ProfileModel(value: self.profile!)
        state = .normal
        view?.updateView(with: profile, state: state)
        router.back()
    }

    private func updateSaveButtonState() {
        guard let `profile` = profile, let `newProfile` = newProfile else {
            view?.updateBottomButtonEnable(false)
            return
        }
        var isEnable = false
        if state == .normal {
            isEnable = true
        }

        if (newProfile.isDiffirent(with: profile) || newAvatar != nil) {
            isEnable = true
        }
        view?.updateBottomButtonEnable(isEnable)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        view?.setHideKeyboardViewHidden(false)
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        view?.setHideKeyboardViewHidden(true)
    }
    // MARK: - API
    private func createNewProfile() {
        guard let `newProfile` = newProfile,
              newProfile.isFullRequireInfo().0 else {
            router.showToast(content: self.newProfile?.isFullRequireInfo().1)
            return
        }
        if let `newAvatar` = newAvatar {
            newProfile.imageData = newAvatar.jpegData(compressionQuality: 1)
        }
        addNewProfile(newProfile)
    }

    private func updateAvatar(_ image: UIImage) {
//        interactor.uploadUserAvatar(image)
    }

    private func updateProfile() {
        guard let `profile` = profile, let `newProfile` = newProfile,
              newProfile.isFullRequireInfo().0 else {
            router.showToast(content: self.newProfile?.isFullRequireInfo().1)
            return
        }
        guard newProfile.isDiffirent(with: profile) || newAvatar != nil else {
            // show message
            return
        }
        if let `newAvatar` = newAvatar {
            newProfile.imageData = newAvatar.jpegData(compressionQuality: 1)
        }
        updateProfile(newProfile)
    }
    // MARK: - Helper
    private func updateNewProfileWithRelationShipAndGender() {
        guard let gender = newProfile?.gender.value,
              let relation = newProfile?.relation.value,
              let userGender = newProfile?.gender.value else {
            return
        }
        switch (gender, relation, userGender) {
        case (.male, .husband, .male):
            newProfile?.relation.value = .husband
        case (.male, .wife, _):
            newProfile?.relation.value = .husband
        case (.male, .daughter, _):
            newProfile?.relation.value = .son
        case (.male, .mother, _):
            newProfile?.relation.value = .father
        case (.female, .wife, .female):
            newProfile?.relation.value = .wife
        case (.female, .husband, _):
            newProfile?.relation.value = .wife
        case (.female, .son, _):
            newProfile?.relation.value = .daughter
        case (.female, .father, _):
            newProfile?.relation.value = .mother
        default:
            break
        }

        view?.updateGenderAndRelation(with: newProfile?.gender.value, relation: newProfile?.relation.value)
    }
}

// MARK: - extending HealthProfileDetailsPresenter: HealthProfileDetailsPresenterProtocol -
extension HealthProfileDetailsPresenter: HealthProfileDetailsPresenterProtocol {
    func onViewDidLoad() {
        addKeyboardObserver()
        view?.updateView(with: newProfile, state: state)
        updateSaveButtonState()
        interactor.addNotification()
    }

    func onButtonCloseDidTapped() {
        router.back()
    }
    func onButtonDeleteDidTapped() {
        router.showAlert(type: .deleteProfile, delegate: self)
    }

    func onBottomButtonDidTapped() {
        switch state {
        case .new:
            createNewProfile()
        case .normal:
            state = .edit
            view?.updateView(with: profile, state: state)
            updateSaveButtonState()
        case .edit:
            updateProfile()
        }
    }

    func onButtonContactDidTapped() {
        router.showContactPicker(delegate: self)
    }

    func onSelectedLabelDidSelected(with type: SelectionType) {
        switch type {
        case .birthday, .bloodGroup, .relationship, .weightActivity:
            router.showPicker(with: type, profile: newProfile, userGender: userGender)
        default:
            break
        }
    }

    func onAvatarChanged(with avatar: UIImage?) {
        newAvatar = avatar
        updateSaveButtonState()
    }

    func onUserNameChanged(with name: String) {
        newProfile?.name = name
        updateSaveButtonState()
    }

    func onBirthDayChanged(with birthday: String) {
        newProfile?.birthday = birthday
        updateSaveButtonState()
    }

    func onGenderChanged(with gender: Gender) {
        newProfile?.gender.value = gender
        updateNewProfileWithRelationShipAndGender()
        updateSaveButtonState()
    }

    func onBloodGroupChanged(with bloodGroup: BloodGroup) {
        newProfile?.blood.value = bloodGroup
        updateSaveButtonState()
    }

    func onHeightChanged(with height: Double?) {
        newProfile?.height.value = height
        updateSaveButtonState()
    }

    func onWeightChanged(with weight: Double?) {
        newProfile?.weight.value = weight
        updateSaveButtonState()
    }

    func onActivityIndexChanged(with activity: ActivityIndex) {
        newProfile?.intensityActivity.value = activity.rawValue
        updateSaveButtonState()
    }

    func onRelationshipChanged(with relation: Relationship) {
        newProfile?.relation.value = relation
        updateNewProfileWithRelationShipAndGender()
        updateSaveButtonState()
    }

    func onPhoneNumberChanged(with phoneNumber: String) {
        newProfile?.phone = phoneNumber
        updateSaveButtonState()
    }

    func onEmailChanged(with email: String) {
        newProfile?.email = email
        updateSaveButtonState()
    }

    func getRelationshipItems() -> [Relationship] {
        return Relationship.getItems(with: newProfile?.gender.value ?? .male, userGender: userGender)
    }

    func isYourSelfProfile() -> Bool {
        return profile?.relation.value == .yourSelf
    }
}

// MARK: - HealthProfileDetailsPresenter: HealthProfileDetailsInteractorOutput -
extension HealthProfileDetailsPresenter: HealthProfileDetailsInteractorOutputProtocol {
    func onUserGenderDidChange(with gender: Gender) {
        self.userGender = gender
    }
}
// MARK: - CNContactPickerDelegate
extension HealthProfileDetailsPresenter: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue
        onPhoneNumberChanged(with: phoneNumber ?? "")
        view?.updatePhoneNumber(with: phoneNumber)
    }

}
// MARK: - AlertViewControllerDelegate
extension HealthProfileDetailsPresenter: AlertViewControllerDelegate {
    func onButtonOKDidTapped(_ type: AlertType) {
        switch type {
        case .deleteProfile:
            guard let `profile` = profile else {
                return
            }
            profileListDAO.update { [weak self] in
                if let profileList = profileListDAO.getFirstObject(),
                   let index = profileList.profiles.firstIndex(of: profile) {
                    profileList.profiles.remove(at: index)
                    if profileList.selectedID == profile.id, let selectedProfile = profileList.profiles.first {
                        profileList.selectedID = selectedProfile.id
                    }
                    self?.router.back()
                    SKToast.shared.showToast(content: "Đã xoá hồ sơ")
                }
            }
        default:
            break
        }
    }
}
