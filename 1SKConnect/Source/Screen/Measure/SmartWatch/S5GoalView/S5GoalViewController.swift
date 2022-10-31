//
//  
//  S5GoalViewController.swift
//  1SKConnect
//
//  Created by admin on 17/12/2021.
//
//

import UIKit

class S5GoalViewController: BaseViewController {

    // UI properties
    @IBOutlet weak var goalView: UIView!
    @IBOutlet weak var goalValueLabel: UILabel!
    @IBOutlet weak var turnOnSetGoalView: UIView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var turnOnSetGoalViewBottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var stateLabel: UILabel!
    
    // calculate properties
    var s5GoalDataSource = [S5GoalDataSource]()
    var presenter: S5GoalPresenterProtocol!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    // MARK: - Setup
    private func setupInit() {
        goalView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleSelectedInView(_:))))
        self.setUpLayout()
    }
    
    private func setUpLayout() {
        self.turnOnSetGoalView.roundCorners(cornes: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24)
        self.navigationItem.title = R.string.localizable.smart_watch_s5_goal()
        self.setupPicker()
        self.setUpDataForPicker()
    }

    private func setupPicker() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        pickerView.setValue(R.color.title(), forKeyPath: "textColor")
    }
    
    private func setUpDataForPicker() {
        var s5GoalData = [S5GoalDataSource]()
        for i in 0...20 {
            let data = S5GoalDataSource(value: i * 1000)
            s5GoalData.append(data)
        }
        self.s5GoalDataSource = s5GoalData
    }

    // MARK: - Action
    @objc func handleSelectedInView(_ sender: UITapGestureRecognizer) {
        self.showSetGoalView()
    }

    @IBAction func handleCancelButton(_ sender: UIButton) {
        self.hideSetGoalView()
    }

    @IBAction func handleSetGoalButton(_ sender: UIButton) {
        let index = pickerView.selectedRow(inComponent: 0) % self.s5GoalDataSource.count
        let goal = s5GoalDataSource[index].value
        self.presenter.saveGoal(with: goal)
        self.hideSetGoalView()
    }
}

// MARK: - S5GoalViewProtocol
extension S5GoalViewController: S5GoalViewProtocol {
    func getGoal(with goal: Int) {
        if let index = self.s5GoalDataSource.firstIndex(where: { $0.value == goal}) {
            self.pickerView.selectRow(index, inComponent: 0, animated: false)
            self.stateLabel.text = (goal == 0) ? R.string.localizable.smart_watch_s5_goal_cancel() : (goal.stringValue + " " + R.string.localizable.smart_watch_s5_step())
        }
    }
}

extension S5GoalViewController {
    // show SetGoalView(
    func showSetGoalView() {
        transparentView.isHidden = false
        turnOnSetGoalViewBottomConstrain.constant = 0
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in })
    }

    // hide SetGoalView(
    func hideSetGoalView() {
        transparentView.isHidden = true
        turnOnSetGoalViewBottomConstrain.constant = -284 - self.presenter.safeAreaBottom
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in })
    }
}

// MARK: - PickerView DataSource
extension S5GoalViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.s5GoalDataSource.count
    }
}
// MARK: - PickerView Delegate
extension S5GoalViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.s5GoalDataSource[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 42
    }
}
