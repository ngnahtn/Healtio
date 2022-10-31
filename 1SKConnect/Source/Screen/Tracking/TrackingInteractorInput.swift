//
//  
//  TrackingInteractorInput.swift
//  1SKConnect
//
//  Created by tuyenvx on 30/03/2021.
//
//

import UIKit
import RealmSwift

class TrackingInteractorInput {
    private var deviceListDAO = GenericDAO<DeviceList>()
    private var token: NotificationToken?

    weak var output: TrackingInteractorOutputProtocol?

    private func registerToken() {
        deviceListDAO.registerToken(token: &token) { [weak self] in
            self?.onDeviceListChange()
        }
    }

    @objc func onDeviceListChange() {
        let linkDevice = deviceListDAO.getObject(with: SKKey.linkDevice)?.devices.array ?? []
        output?.onLinkDeviceChange(linkDevice)
    }

    @objc func onActivitiesDataChanged() {
        let deviceActivities = ActivityDataManager.shared.getDeviceActivities()
        output?.onDeviceActivitiesChange(deviceActivities)
        let moveActivities = ActivityDataManager.shared.getMoveActivities()
        output?.onMoveActivitiesChange(moveActivities)
        let otherActivities = ActivityDataManager.shared.getOtherActivities()
        output?.onOtherActivitiesChange(otherActivities)
        let significance = ActivityDataManager.shared.getSignificanceActivities()
        output?.onSignificanceActivitiesChange(significance)
    }

    deinit {
        token?.invalidate()
    }
}

// MARK: - TrackingInteractorInputProtocol
extension TrackingInteractorInput: TrackingInteractorInputProtocol {
    func startObserver() {
        kNotificationCenter.addObserver(self, selector: #selector(onActivitiesDataChanged), name: .activitiesDataChanged, object: nil)
        onActivitiesDataChanged()
        registerToken()
    }
}
