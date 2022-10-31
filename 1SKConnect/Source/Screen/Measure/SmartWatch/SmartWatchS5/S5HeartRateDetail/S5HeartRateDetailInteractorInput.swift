//
//  
//  S5HeartRateDetailInteractorInput.swift
//  1SKConnect
//
//  Created by Be More on 27/12/2021.
//
//

import UIKit
import RealmSwift

class S5HeartRateDetailInteractorInput {
    weak var output: S5HeartRateDetailInteractorOutputProtocol?
    private let hrListModelDAO = GenericDAO<S5HeartRateListRecordModel>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    var hrNotificationToken: NotificationToken?
    var hrListRecordModel: S5HeartRateListRecordModel?

    private func onHrListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let hrList = self.hrListModelDAO.getObject(with: profile.id) {
            self.output?.onFinishedGetHrList(model: hrList)
        } else {
            self.output?.onFinishedGetHrList(model: nil)
        }
    }

    deinit {
        self.hrNotificationToken?.invalidate()
    }
}

// MARK: - S5HeartRateDetailInteractorInputProtocol
extension S5HeartRateDetailInteractorInput: S5HeartRateDetailInteractorInputProtocol {
    func startObserver() {
        self.hrListModelDAO.registerToken(token: &self.hrNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onHrListChange()
        }
    }
}
