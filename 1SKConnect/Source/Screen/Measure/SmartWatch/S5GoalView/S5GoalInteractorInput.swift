//
//  
//  S5GoalInteractorInput.swift
//  1SKConnect
//
//  Created by admin on 17/12/2021.
//
//

import UIKit
import RealmSwift
import TrusangBluetooth

class S5GoalInteractorInput {
    weak var output: S5GoalInteractorOutputProtocol?
    var stepNotificationToken: NotificationToken?
    
    // listDAO properties
    var profileListDAO = GenericDAO<ProfileListModel>()
    var stepRecordListDAO = GenericDAO<StepListRecordModel>()
    
    // model properties
    var stepRecordModel: [StepRecordModel]?
    
    // s5 processor properties and component
    let goalTargetProcessor = ZHJSportTargetProcessor()
    var goalTarget = ZHJSportTarget()

    deinit {
        self.stepNotificationToken?.invalidate()
    }
    
    private func registerToken() {
        self.stepRecordListDAO.registerToken(token: &self.stepNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onStepListChange()
        }
    }

    // handle read goal value
    private func startReadGoalState() {
        self.goalTargetProcessor.readSportTarget { [weak self] sportTarget in
            guard let `self` = self else { return }
            self.goalTarget = sportTarget
            if sportTarget.stepTarget.enable == true {
                guard let recordModel = self.stepRecordModel else {
                    self.output?.getGoal(with: sportTarget.stepTarget.value)
                    return
                }
                if !recordModel.isEmpty {
                    if recordModel[0].dateTime.toDate(.ymd)?.isInToday == true {
                        self.output?.getGoal(with: SKUserDefaults.shared.currentStepGoal)
                    } else {
                        self.output?.getGoal(with: sportTarget.stepTarget.value)
                    }
                }
            } else {
                self.output?.getGoal(with: 0)
            }
        }
    }

    private func onStepListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let stepList = stepRecordListDAO.getObject(with: profile.id) {
            self.stepRecordModel = stepList.stepList.array
        }
    }
}

// MARK: - S5GoalInteractorInputProtocol
extension S5GoalInteractorInput: S5GoalInteractorInputProtocol {

    func startSaveGoal(with goal: Int) {
        guard let records = self.stepRecordModel else {
            output?.getGoal(with: goal)
            self.writeGoalToDevice(with: goal)
            return
        }

        if !records.isEmpty {
            let todayDate = records[0].dateTime.toDate(.ymd)
            if todayDate?.isInToday == true {
                if goal != 0 {
                    self.writeGoal(with: goal)
                }
                output?.getGoal(with: goal)
                self.writeGoalToDevice(with: goal)
            } else {
                output?.getGoal(with: goal)
                self.writeGoalToDevice(with: goal)
            }
        }
    }
    
    func startObserver() {
        self.registerToken()
        self.startReadGoalState()
    }
}

// MARK: - Helpers
extension S5GoalInteractorInput {
    
    
    /// write goal value to Local
    /// - Parameter value: goal value : Int
    func writeGoal(with value: Int) {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let stepList = stepRecordListDAO.getObject(with: profile.id) {
            stepRecordListDAO.update {
                SKUserDefaults.shared.currentStepGoal = value
                stepList.stepList[0].goal = value
            }
        }
    }

    
    /// send goalValue to s5Device
    /// - Parameter value: goal value: Int
    func writeGoalToDevice(with value: Int) {
        if value != 0 {
            goalTarget.stepTarget.value = value
        }
        goalTarget.stepTarget.enable = (value == 0) ? false : true
        goalTargetProcessor.writeSportTarget( goalTarget ) { (_) in
            let userInfo = ["isOn": (value == 0) ? false : true]
            kNotificationCenter.post(name: .s5GoalSettingChange, object: nil, userInfo: userInfo)
        }
    }
}
