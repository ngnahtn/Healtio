//
//  
//  S5Spo2DetailInteractorInput.swift
//  1SKConnect
//
//  Created by Be More on 28/12/2021.
//
//

import UIKit
import RealmSwift

class S5Spo2DetailInteractorInput {
    weak var output: S5Spo2DetailInteractorOutputProtocol?
    private let spO2ListModelDAO = GenericDAO<S5SpO2ListRecordModel>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    var hrNotificationToken: NotificationToken?
    var spO2ListRecordModel: S5SpO2ListRecordModel?

    private func onSpO2ListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let spO2List = self.spO2ListModelDAO.getObject(with: profile.id) {
            self.output?.onFinishedGetSpO2List(model: spO2List)
        } else {
            self.output?.onFinishedGetSpO2List(model: nil)
        }
    }
    
    deinit {
        self.hrNotificationToken?.invalidate()
    }
}

// MARK: - S5Spo2DetailInteractorInputProtocol
extension S5Spo2DetailInteractorInput: S5Spo2DetailInteractorInputProtocol {
    func startObserver() {
        self.spO2ListModelDAO.registerToken(token: &self.hrNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onSpO2ListChange()
        }
    }
}
