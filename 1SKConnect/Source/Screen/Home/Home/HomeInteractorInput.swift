//
//  
//  HomeInteractorInput.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//
//

import UIKit
import RealmSwift

class HomeInteractorInput {
    private var deviceListDAO = GenericDAO<DeviceList>()
    private var token: NotificationToken?

    weak var output: HomeInteractorOutputProtocol?

    private func registerToken() {
        deviceListDAO.registerToken(token: &token) { [weak self] in
            self?.onDeviceListChange()
        }
    }

    @objc func onDeviceListChange() {
        let connectDevice = deviceListDAO.getObject(with: SKKey.connectedDevice)?.devices.array ?? []
        output?.onConnectDeviceChange(connectDevice)
    }

    @objc func onActivitiesDataChanged() {
        // device activities.
        let deviceActivities = ActivityDataManager.shared.getDeviceActivities()
        output?.onDeviceActivitiesChange(deviceActivities)
        
        // activities.
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

// MARK: - HomeInteractorInput - HomeInteractorInputProtocol -
extension HomeInteractorInput: HomeInteractorInputProtocol {
    func startObserver() {
        registerToken()
        kNotificationCenter.addObserver(self, selector: #selector(onActivitiesDataChanged), name: .activitiesDataChanged, object: nil)
        onActivitiesDataChanged()
    }
}
