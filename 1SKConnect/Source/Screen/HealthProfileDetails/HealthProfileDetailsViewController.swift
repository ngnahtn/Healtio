//
//  
//  HealthProfileDetailsViewController.swift
//  1SK
//
//  Created by tuyenvx on 05/02/2021.
//
//

import UIKit
import DLRadioButton
import IQKeyboardManagerSwift

class HealthProfileDetailsViewController: BaseViewController, ImagePickable {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var changeAvatarButton: UIButton!
    @IBOutlet weak var nameSKTextField: SKTextField!
    @IBOutlet weak var birthDaySelectedLabel: SKTextField!
    @IBOutlet weak var maleRadioButton: DLRadioButton!
    @IBOutlet weak var femaleRadioButton: DLRadioButton!
    @IBOutlet weak var bloodSelectedLabel: SKTextField!
    @IBOutlet weak var heightSKTextField: SKTextField!
    @IBOutlet weak var weightSKTextField: SKTextField!

//    @IBOutlet weak var activityIndexSelectedLabel: SKTextField!
    @IBOutlet weak var relationShipSelectedLabel: SKTextField!
//    @IBOutlet weak var phoneTextField: UITextField!

    @IBOutlet weak var hideKeyboardView: UIView!

    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var cameraImageViewCenterYConstraint: NSLayoutConstraint!

    var presenter: HealthProfileDetailsPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.onViewDidLoad()
    }
    // MARK: - Setup
    private func setupUI() {
        setupNavigation()
        setupTextField()
        setupRadioButton()
        setupKeyboardToolBar()
        avatarImageView.superview?.roundCorners(cornes: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10)
//        bottomButton.superview?.addShadow(offSet: CGSize(width: 0, height: -5), color: .black, radius: 4, opacity: 0.09)
        bottomButton.backgroundColor = R.color.title()
    }

    private func setupNavigation() {
        setLeftBarButton(style: .back) { [weak self] (_) in
            self?.presenter.onButtonCloseDidTapped()
        }
        navigationItem.title = L.healthProfile.localized
    }

    private func setupTextField() {
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        birthDaySelectedLabel.delegate = self
        bloodSelectedLabel.delegate = self
        heightTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        weightTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        activityIndexSelectedLabel.delegate = self
        relationShipSelectedLabel.delegate = self
        nameSKTextField.setContentType(.name)
        nameSKTextField.setKeyboardType(.alphabet)
        nameTextField.autocapitalizationType = .words
        heightSKTextField.setKeyboardType(.decimalPad)
        weightSKTextField.setKeyboardType(.decimalPad)
        nameTextField.delegate = self
        weightTextField.delegate = self
        heightTextField.delegate = self
    }

    private func setupRadioButton() {
        maleRadioButton.addTarget(self, action: #selector(maleButtonDidTapped), for: .touchUpInside)
        femaleRadioButton.addTarget(self, action: #selector(femaleButtonDidTapped), for: .touchUpInside)
    }

    private func setupKeyboardToolBar() {
        let nameToolbarConfig = IQBarButtonItemConfiguration(title: L.next.localized, action: #selector(onNameTextFieldToolbarButtonDidTapped(_:)))
        nameTextField.addKeyboardToolbarWithTarget(target: self, titleText: nil, rightBarButtonConfiguration: nameToolbarConfig)
//        nameTextField.inputAccessoryView?.tintColor = R.color.title()
        let heightToolbarConfig = IQBarButtonItemConfiguration(title: L.ok.localized, action: #selector(onHeightFieldToolbarButtonDidTapped(_:)))
        heightTextField.addKeyboardToolbarWithTarget(target: self, titleText: nil, rightBarButtonConfiguration: heightToolbarConfig)
//        heightTextField.inputAccessoryView?.tintColor = R.color.title()
        let weightToolbarConfig = IQBarButtonItemConfiguration(title: L.ok.localized, action: #selector(onWeightTextFieldToolbarButtonDidTapped(_:)))
        weightTextField.addKeyboardToolbarWithTarget(target: self, titleText: nil, rightBarButtonConfiguration: weightToolbarConfig)
//        weightTextField.inputAccessoryView?.tintColor = R.color.title()
    }

    // MARK: - Action
    @IBAction func backgroundButtonDidTapped(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func buttonBackDidTapped(_ sender: Any) {
        presenter.onButtonCloseDidTapped()
    }

    @IBAction func buttonChangeAvatarDidTapped(_ sender: Any) {
        showSelectedImageSourceAlert(with: L.chooseImageFrom.localized, popoverRect: self.avatarImageView.frame, popoverView: self.view, allowsEditing: true)
    }
    @IBAction func onBottomButtonDidTapped(_ sender: Any) {
        presenter.onBottomButtonDidTapped()
    }

    @objc private func maleButtonDidTapped() {
        presenter.onGenderChanged(with: .male)
    }

    @objc private func femaleButtonDidTapped() {
        presenter.onGenderChanged(with: .female)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let newText = textField.text ?? ""
        switch textField {
        case nameTextField:
            presenter.onUserNameChanged(with: newText)
        case heightTextField:
            presenter.onHeightChanged(with: Double(newText))
        case weightTextField:
            presenter.onWeightChanged(with: Double(newText))
        default:
            break
        }
        updateTypeLabelHiddenState(of: textField)
    }

    @objc func onNameTextFieldToolbarButtonDidTapped(_ sender: Any) {
        didSelect(birthDaySelectedLabel)
    }

    @objc func onHeightFieldToolbarButtonDidTapped(_ sender: Any) {
        weightTextField.becomeFirstResponder()
    }

    @objc func onWeightTextFieldToolbarButtonDidTapped(_ sender: Any) {
        guard !presenter.isYourSelfProfile() else {
            view.endEditing(true)
            return
        }
        didSelect(relationShipSelectedLabel)
    }

    @objc func onEmailTextFieldToolbarButtonDidTapped(_ sender: Any) {
        view.endEditing(true)
        presenter.onBottomButtonDidTapped()
    }

    private func config(with profile: ProfileModel?) {
        guard let `profile` = profile else {
            return
        }
        avatarImageView.setImage(profile.image, placeHolder: nil)
        nameTextField.text = profile.name
        birthDaySelectedLabel.setValue(with: profile.birthday?.toDate(.ymd)?.toString(.dmySlash))
        updateGenderAndRelation(with: profile.gender.value, relation: profile.relation.value)
        bloodSelectedLabel.setValue(with: profile.blood.value?.name)
        heightTextField.text = profile.getHeightStringValue()
        weightTextField.text = profile.getWeightStringValue()
        if let intensityActivity = profile.intensityActivity.value,
           let activityIndex = ActivityIndex(rawValue: intensityActivity) {
//            activityIndexSelectedLabel.setValue(with: activityIndex.name)
        }
        for textField in [nameTextField, heightTextField, weightTextField] {
            updateTypeLabelHiddenState(of: textField)
        }
    }

    private func updateCameraImageViewPosition() {
        let hasAvatar = avatarImageView.image != nil && avatarImageView.image != R.image.ic_default_avatar()
        cameraImageViewCenterYConstraint.constant = hasAvatar ? 25 : 0
    }

    private func updateTypeLabelHiddenState(of textField: UITextField) {
        switch textField {
        case nameTextField:
            nameSKTextField.updateTypeLabelHiddenState()
        case heightTextField:
            heightSKTextField.updateTypeLabelHiddenState()
        case weightTextField:
            weightSKTextField.updateTypeLabelHiddenState()
        default:
            break
        }
    }
}

// MARK: HealthProfileDetailsViewController - HealthProfileDetailsViewProtocol -
extension HealthProfileDetailsViewController: HealthProfileDetailsViewProtocol {
    func updateView(with profile: ProfileModel?, state: InfomationScreenEditableState) {
        config(with: profile)
        switch state {
        case .new:
            bottomButton.setTitle(L.addNew.localized, for: .normal)
            navigationItem.rightBarButtonItem = nil
        case .normal:
            bottomButton.setTitle(L.update.localized, for: .normal)
            if profile?.relation.value != .yourSelf {
                setRightBarButton(style: .delete) { [weak self] _ in
                    self?.presenter.onButtonDeleteDidTapped()
                }
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        case .edit:
            bottomButton.setTitle(L.save.localized, for: .normal)
            if profile?.relation.value != .yourSelf {
                setRightBarButton(style: .delete) { [weak self] _ in
                    self?.presenter.onButtonDeleteDidTapped()
                }
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
        navigationItem.title = state != .new ? profile?.name : L.createProfile.localized
        let isEdit = state != .normal
        changeAvatarButton.isEnabled = isEdit
        nameSKTextField.setEnable(isEnable: isEdit)
        birthDaySelectedLabel.setEnable(isEnable: isEdit)
        bloodSelectedLabel.setEnable(isEnable: isEdit)
        heightSKTextField.setEnable(isEnable: isEdit)
        weightSKTextField.setEnable(isEnable: isEdit)
//        activityIndexSelectedLabel.setEnable(isEnable: isEdit)
        relationShipSelectedLabel.setEnable(isEnable: isEdit && profile?.relation.value != .yourSelf)
        bottomButton.isEnabled = state != .edit
        updateCameraImageViewPosition()
    }

    func updateGenderAndRelation(with gender: Gender?, relation: Relationship?) {
        if let `gender` = gender {
            maleRadioButton.isSelected = gender == .male
            femaleRadioButton.isSelected = gender == .female
        } else {
            maleRadioButton.isSelected = false
            femaleRadioButton.isSelected = false
        }
        if let `relation` = relation {
            relationShipSelectedLabel.setValue(with: relation.getName())
        }
    }

    func updatePhoneNumber(with phoneNumber: String?) {
    }

    func updateBottomButtonEnable(_ isEnable: Bool) {
        bottomButton.isEnabled = isEnable
        bottomButton.backgroundColor = isEnable ? R.color.mainColor() : R.color.disable()
    }

    func setHideKeyboardViewHidden(_ isHidden: Bool) {
        hideKeyboardView.isHidden = isHidden
    }
}
// MARK: - SKSelectedLabelDelegate
extension HealthProfileDetailsViewController: SKSelectedLabelDelegate {
    func didSelect(_ scrollDownLabel: SKTextField) {
        view.endEditing(true)
        switch scrollDownLabel {
        case birthDaySelectedLabel:
            presenter.onSelectedLabelDidSelected(with: .birthday)
        case bloodSelectedLabel:
            presenter.onSelectedLabelDidSelected(with: .bloodGroup)
//        case activityIndexSelectedLabel:
//            presenter.onSelectedLabelDidSelected(with: .weightActivity)
        case relationShipSelectedLabel:
            presenter.onSelectedLabelDidSelected(with: .relationship)
        default:
            break
        }
    }
}

// MARK: - PickerViewControllerDelegate
extension HealthProfileDetailsViewController: PickerViewControllerDelegate {
    func pickerDidPickValue(of type: SelectionType, at index: Int) {
        switch type {
        case .bloodGroup:
            let blood = BloodGroup.allCases[index]
            bloodSelectedLabel.setValue(with: blood.name)
            presenter.onBloodGroupChanged(with: blood)
        case .weightActivity:
            let activityIndex = ActivityIndex.allCases[index]
//            activityIndexSelectedLabel.setValue(with: activityIndex.name)
            presenter.onActivityIndexChanged(with: activityIndex)
        case .relationship:
            let relationship = presenter.getRelationshipItems()[index]
            presenter.onRelationshipChanged(with: relationship)
        default:
            break
        }
    }

    func didPickDate(_ date: Date) {
        birthDaySelectedLabel.setValue(with: date.toString(.dmySlash))
        presenter.onBirthDayChanged(with: date.toString(.ymd))
    }
}

// MARK: - UIImagePickerViewDelegate
extension HealthProfileDetailsViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        presenter.onAvatarChanged(with: image)
        avatarImageView.setImage(image, placeHolder: R.image.ic_default_avatar())
        updateCameraImageViewPosition()
    }
}
// MARK: - UITextFieldDelegate
extension HealthProfileDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            didSelect(birthDaySelectedLabel)
        default:
            break
        }
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case heightTextField:
            if textField.text?.contains(" cm") ?? false {
                textField.text?.removeLast(3)
            }
        case weightTextField:
            if textField.text?.contains(" kg") ?? false {
                textField.text?.removeLast(3)
            }
        default:
            break
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateTypeLabelHiddenState(of: textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTypeLabelHiddenState(of: textField)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case heightTextField:
            if let content = textField.text, !content.contains(" cm") && !content.isEmpty {
                textField.text?.append(" cm")
            }
        case weightTextField:
            if let content = textField.text, !content.contains(" kg") && !content.isEmpty {
                textField.text?.append(" kg")
            }
        default:
            break
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case heightTextField, weightTextField:
            if string == "." && textField.text?.contains(".") == true {
                return false
            }
            if string == "," {
                if textField.text?.contains(".") != true,
                   let text = textField.text, let changeRange = Range(range, in: text) {
                    let newText = text.replacingCharacters(in: changeRange, with: ".")
                    textField.text = newText
                }
                return false
            }
        case nameTextField:
            var `string` = string
            string.removeAll(where: {$0 == " "})
            if string.rangeOfCharacter(from: .letters) != nil || string == ""{
                return true
            } else {
                return false
            }
        default:
            break
        }
        return true
    }
}
extension HealthProfileDetailsViewController {
    private var nameTextField: UITextField {
        return nameSKTextField.titleTextField
    }

    private var heightTextField: UITextField {
        return heightSKTextField.titleTextField
    }

    private var weightTextField: UITextField {
        return weightSKTextField.titleTextField
    }
}
