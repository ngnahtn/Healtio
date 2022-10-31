//
//  
//  S5TemperatureDetailInteractorInput.swift
//  1SKConnect
//
//  Created by TrungDN on 28/12/2021.
//
//

import UIKit
import RealmSwift

class S5TemperatureDetailInteractorInput {
    weak var output: S5TemperatureDetailInteractorOutputProtocol?
    private let tempListModelDAO = GenericDAO<S5TemperatureListRecordModel>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    var hrNotificationToken: NotificationToken?
    
    private func onTempListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let tempList = self.tempListModelDAO.getObject(with: profile.id) {
            self.output?.onTempListChange(model: tempList)
        } else {
            self.output?.onTempListChange(model: nil)
        }
    }
    
    deinit {
        self.hrNotificationToken?.invalidate()
    }
}

// MARK: - S5TemperatureDetailInteractorInputProtocol
extension S5TemperatureDetailInteractorInput: S5TemperatureDetailInteractorInputProtocol {
    func startObserver() {
        self.tempListModelDAO.registerToken(token: &self.hrNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onTempListChange()
        }
    }
}
