//
//  
//  S5BloodPressureDetailInteractorInput.swift
//  1SKConnect
//
//  Created by TrungDN on 27/12/2021.
//
//

import UIKit
import RealmSwift

class S5BloodPressureDetailInteractorInput {
    weak var output: S5BloodPressureDetailInteractorOutputProtocol?
    private let bloodPressureListModelDAO = GenericDAO<BloodPressureListRecordModel>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    var bloodPressureNotificationToken: NotificationToken?
    
    private func onBloodPressureListDidChange() {
        guard let profile = self.profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let bpList = self.bloodPressureListModelDAO.getObject(with: profile.id) {
            self.output?.onBloodPressureListDidChange(model: bpList)
        } else {
            self.output?.onBloodPressureListDidChange(model: nil)
        }
    }
    
    deinit {
        self.bloodPressureNotificationToken?.invalidate()
    }
}

// MARK: - S5BloodPressureDetailInteractorInputProtocol
extension S5BloodPressureDetailInteractorInput: S5BloodPressureDetailInteractorInputProtocol {
    func startObserver() {
        self.bloodPressureListModelDAO.registerToken(token: &self.bloodPressureNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onBloodPressureListDidChange()
        }
    }
}
