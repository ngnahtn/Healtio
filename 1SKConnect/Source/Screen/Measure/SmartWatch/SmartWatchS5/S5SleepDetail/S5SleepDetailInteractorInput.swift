//
//  
//  S5SleepDetailInteractorInput.swift
//  1SKConnect
//
//  Created by TrungDN on 30/12/2021.
//
//

import UIKit
import RealmSwift

class S5SleepDetailInteractorInput {
    weak var output: S5SleepDetailInteractorOutputProtocol?
    private let sleepListModelDAO = GenericDAO<SleepListRecordModel>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    var sleepNotificationToken: NotificationToken?
    
    private func onSleepListDidChange() {
        guard let profile = self.profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let slList = self.sleepListModelDAO.getObject(with: profile.id) {
            self.output?.onSleepListDidChange(model: slList)
        } else {
            self.output?.onSleepListDidChange(model: nil)
        }
    }
    
    deinit {
        self.sleepNotificationToken?.invalidate()
    }
}

// MARK: - S5SleepDetailInteractorInputProtocol
extension S5SleepDetailInteractorInput: S5SleepDetailInteractorInputProtocol {
    func startObserver() {
        self.sleepListModelDAO.registerToken(token: &self.sleepNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onSleepListDidChange()
        }
    }
}
