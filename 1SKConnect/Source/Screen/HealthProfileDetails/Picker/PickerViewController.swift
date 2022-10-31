//
//  PickerViewController.swift
//  SK365
//
//  Created by tuyenvx on 6/2/20.
//  Copyright © 2020 Elcom. All rights reserved.
//

import UIKit

protocol PickerViewControllerDelegate: AnyObject {
    func pickerDidPickValue(of type: SelectionType, at index: Int)
    func didPickDate(_ date: Date)
}

class PickerViewController: BaseViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var bottomViewBottomConstraint: NSLayoutConstraint!
    var type: SelectionType = .birthday
    var profile: ProfileModel?
    var userGender: Gender?

    private let numberOfBloodGroupItem = BloodGroup.allCases.count
    private let numberOfMonths = MonthGroup.allCases.count
    private var relationshipItems: [Relationship] = []
    private let numberOfActivityIndexItem = ActivityIndex.allCases.count
    private let mutiplerNumber = 98 // mutilplier data to make infinity date picker

    private var numberOfRelationshipItem: Int {
        return Relationship.getItems(with: profile?.gender.value ?? .male, userGender: userGender).count
    }

    weak var delegate: PickerViewControllerDelegate?

    var safeAreaBottom: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            return window.safeAreaInsets.bottom
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.bottom ?? 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottomViewBottomConstraint.constant = 0
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        })
    }

    private func setupUI() {
        bottomView.roundCorners(cornes: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
                                radius: Constant.Number.roundCornerRadius)
        switch type {
        case .birthday:
            setupDatePicker()
            titleLabel.text = L.chooseBirthday.localized
        case .bloodGroup:
            setupPicker()
            setupBloodGroupPicker()
            titleLabel.text = L.chooseBloodGroup.localized
        case .relationship:
            setupPicker()
            setupRelationshipPicker()
            titleLabel.text = L.chooseRelationship.localized
        case .weightActivity:
            setupPicker()
            setupActivityIndexPicker()
            titleLabel.text = "Chọn tần suất vận động"
        case .month:
            setupPicker()
            titleLabel.text = "Chọn số tháng"
            setUpMonthGroupPicker()
        default:
            return
        }
        topView.roundCorners(cornes: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 25)
        bottomViewBottomConstraint.constant = -276 - safeAreaBottom
    }

    private func setupDatePicker() {
        pickerView.isHidden = true
        datePicker.isHidden = false
        datePicker.maximumDate = Date()
        datePicker.minimumDate = "1/01/1820".toDate(.dmySlash)!
        if let birthday = profile?.birthday?.toDate(.ymd) {
            datePicker.setDate(birthday, animated: true)
        } else {
            datePicker.setDate("15/06/1985".toDate(.dmySlash)!, animated: true)
        }
//        if let birthday = userInfo?.birthDay?.toDate(.dmySlash) {
//            datePicker.setDate(birthday, animated: true)
//        }
        datePicker.backgroundColor = R.color.background()
        datePicker.setValue(R.color.title()!, forKeyPath: "textColor")
    }

    private func setupPicker() {
        datePicker.isHidden = true
        pickerView.isHidden = false
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.setValue(R.color.title(), forKeyPath: "textColor")
    }

    private func setupBloodGroupPicker() {
        let blood = profile != nil ? profile?.blood.value : nil
        var row = 0
        if let `blood` = blood, let index = BloodGroup.allCases.firstIndex(of: blood) {
            row = index
        }
        row += (mutiplerNumber / 2) * numberOfBloodGroupItem
        pickerView.selectRow(row, inComponent: 0, animated: false)
    }

    private func setUpMonthGroupPicker() {
        var row: Int = MonthGroup.allCases.firstIndex(of: .one) ?? 0
        row += (mutiplerNumber / 2) + numberOfMonths
        pickerView.selectRow(row, inComponent: 0, animated: false)
    }

    private func setupActivityIndexPicker() {
        var row = 0
        if let intensityActivity = profile?.intensityActivity.value,
           let activityIndex = ActivityIndex(rawValue: intensityActivity),
           let index = ActivityIndex.allCases.firstIndex(of: activityIndex) {
            row = index
        }
        row += (mutiplerNumber / 2) * numberOfActivityIndexItem
        pickerView.selectRow(row, inComponent: 0, animated: false)
    }

    private func setupRelationshipPicker() {
        relationshipItems = Relationship.getItems(with: profile?.gender.value ?? .male, userGender: userGender)
        let relationship = profile?.relation.value
        var row = 0
        if let `relationship` = relationship, let index = relationshipItems.firstIndex(of: relationship) {
            row = index
        }
        row += (mutiplerNumber / 2) * numberOfRelationshipItem
        pickerView.selectRow(row, inComponent: 0, animated: false)
    }
    // MARK: - Action
    private func hide() {
        bottomViewBottomConstraint.constant = -276 - safeAreaBottom
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }

    @IBAction func transparentViewDidTapped(_ sender: Any) {
        hide()
    }

    @IBAction func buttonCloseDidTapped(_ sender: Any) {
        hide()
    }

    @IBAction func buttonDoneDidTapped(_ sender: Any) {
        switch type {
        case .birthday:
//            profile?.birthday = datePicker.date.toString(.ymd)
//            userInfo?.birthDay = datePicker.date.toString(.dmySlash)
            delegate?.didPickDate(datePicker.date)
        case .relationship:
            let index = pickerView.selectedRow(inComponent: 0) % numberOfRelationshipItem
            profile?.relation.value = relationshipItems[index]
            delegate?.pickerDidPickValue(of: type, at: index)
        case .bloodGroup:
            let index = pickerView.selectedRow(inComponent: 0) % numberOfBloodGroupItem
            profile?.blood.value = BloodGroup.allCases[index]
            delegate?.pickerDidPickValue(of: type, at: index)
        case .weightActivity:
            let index = pickerView.selectedRow(inComponent: 0) % numberOfActivityIndexItem
            profile?.intensityActivity.value = ActivityIndex.allCases[index].rawValue
            delegate?.pickerDidPickValue(of: type, at: index)
        case .month:
            let index = pickerView.selectedRow(inComponent: 0) % numberOfMonths
            self.delegate?.pickerDidPickValue(of: type, at: index)
        default:
            break
        }
        hide()
    }
}
// MARK: - PickerView DataSource
extension PickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch type {
        case .bloodGroup, .relationship, .weightActivity, .month:
            return 1
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch type {
        case .relationship:
            return mutiplerNumber * numberOfRelationshipItem
        case .bloodGroup:
            return mutiplerNumber * numberOfBloodGroupItem
        case .weightActivity:
            return mutiplerNumber * numberOfActivityIndexItem
        case .month:
            return mutiplerNumber * numberOfMonths
        default:
            return 0
        }
    }
}
// MARK: - PickerView Delegate
extension PickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch type {
        case .relationship:
            let index = row % numberOfRelationshipItem
            return relationshipItems[index].getName()
        case .bloodGroup:
            let index = row % numberOfBloodGroupItem
            return BloodGroup.allCases[index].name
        case .weightActivity:
            let index = row % numberOfActivityIndexItem
            return ActivityIndex.allCases[index].name
        case .month:
            let index = row % numberOfMonths
            return MonthGroup.allCases[index].rawValue
        default:
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let numberOfItem = pickerView.numberOfRows(inComponent: component) / mutiplerNumber
        if row < numberOfItem || row >= numberOfItem * 2 {
            var newRow = row % numberOfItem
            newRow += numberOfItem * (mutiplerNumber % 2)
            pickerView.selectRow(newRow, inComponent: component, animated: false)
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 42
    }
}
