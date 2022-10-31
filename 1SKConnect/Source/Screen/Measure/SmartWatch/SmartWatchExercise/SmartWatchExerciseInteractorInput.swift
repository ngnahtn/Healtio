//
//  
//  SmartWatchExerciseInteractorInput.swift
//  1SKConnect
//
//  Created by admin on 13/12/2021.
//
//

import UIKit
import RealmSwift

class SmartWatchExerciseInteractorInput {
    weak var output: SmartWatchExerciseInteractorOutputProtocol?
    private let stepListModelDAO = GenericDAO<StepListRecordModel>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    var stepNotificationToken: NotificationToken?
    var stepListRecordModel: StepListRecordModel?

    private func onStepListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let stepList = self.stepListModelDAO.getObject(with: profile.id) {
            self.output?.onFinishedGetStepList(model: stepList)
        } else {
            self.output?.onFinishedGetStepList(model: nil)
        }
    }
    
    private func registerToken() {
        self.stepListModelDAO.registerToken(token: &self.stepNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onStepListChange()
        }
    }

    deinit {
        self.stepNotificationToken?.invalidate()
    }
    
}

// MARK: - SmartWatchExerciseInteractorInputProtocol
extension SmartWatchExerciseInteractorInput: SmartWatchExerciseInteractorInputProtocol {
    func startObserver() {
        registerToken()
    }
}
