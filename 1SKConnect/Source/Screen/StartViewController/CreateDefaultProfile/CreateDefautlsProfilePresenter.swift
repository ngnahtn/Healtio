//
//  
//  CreateDefautlsProfilePresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 12/04/2021.
//
//

import UIKit

protocol CreateDefautlsProfilePresenterDelegate: AnyObject {
    func didCreateDefaultProfile()
}

class CreateDefautlsProfilePresenter {
    weak var view: CreateDefautlsProfileViewProtocol?
    private var interactor: CreateDefautlsProfileInteractorInputProtocol
    private var router: CreateDefautlsProfileRouterProtocol

    init(interactor: CreateDefautlsProfileInteractorInputProtocol,
         router: CreateDefautlsProfileRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    var state: InfomationScreenEditableState = .new
    var profile: ProfileModel?
    var newProfile: ProfileModel?
    private var newAvatar: UIImage?
    let profileDAO = GenericDAO<ProfileModel>()
    private var profileListDAO = GenericDAO<ProfileListModel>()
    weak var delegate: CreateDefautlsProfilePresenterDelegate?

    // MARK: - Setup
    func addKeyboardObserver() {
        kNotificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIControl.keyboardWillShowNotification, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIControl.keyboardDidHideNotification, object: nil)
    }

    // MARK: - Action
    private func addNewProfile(_ profile: ProfileModel) {
        if let profileList = profileListDAO.getFirstObject() {
            profileListDAO.update { [weak profileList] in
                guard let profileList = profileList else { return }
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
        delegate?.didCreateDefaultProfile()
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

        if (newProfile.isDiffirent(with: profile) || newAvatar != nil) {// && newProfile.isFullRequireInfo().0 {
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
        //
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            DispatchQueue.main.async {
                switch setting.authorizationStatus {
                case .notDetermined:
                    self.requestNotificationAuthorization()
                case .authorized, .ephemeral:
                    break
                default:
                    break
                }
            }
        }
    }

    private func requestNotificationAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isSuccess, _) in
        }
    }

}

// MARK: - CreateDefautlsProfilePresenterProtocol
extension CreateDefautlsProfilePresenter: CreateDefautlsProfilePresenterProtocol {
    func onViewDidLoad() {
        addKeyboardObserver()
        view?.updateView(with: newProfile, state: state)
        updateSaveButtonState()
    }

    func onBottomButtonDidTapped() {
        switch state {
        case .new:
            createNewProfile()
        default:
            break
        }
    }

    func onSelectedLabelDidSelected(with type: SelectionType) {
        switch type {
        case .birthday, .bloodGroup, .relationship, .weightActivity:
            router.showPicker(with: type, profile: newProfile)
        default:
            break
//            router.showSlectionViewController(with: newProfile, type: type)
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
        if newProfile?.relation.value == .wife || newProfile?.relation.value == .husband {
            switch gender {
            case .male:
                newProfile?.relation.value = .husband
            case .female:
                newProfile?.relation.value = .wife
            }
        }
        view?.updateGenderAndRelation(with: newProfile?.gender.value, relation: newProfile?.relation.value)
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
}

// MARK: - CreateDefautlsProfilePresenter: CreateDefautlsProfileInteractorOutput -
extension CreateDefautlsProfilePresenter: CreateDefautlsProfileInteractorOutputProtocol {

}
