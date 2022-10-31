//
//  
//  HomePresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//
//

import UIKit
import RealmSwift
import VTO2Lib

class HomePresenter: NSObject {
    private var devices: [DeviceModel] = []
    private var moveActivities: [ActivityData] = []
    private var otherActivities: [ActivityData] = []
    private var significanceActivities: [ActivityData] = []
    private var deviceActivities: [ActivityData] = []
    private var activityFilterType: ActivityFilterType = .activity
    private var activityTypes: [ActivityGroup] = ActivityGroup.allCases

    weak var view: HomeViewProtocol?
    private var interactor: HomeInteractorInputProtocol
    private var router: HomeRouterProtocol
    private var hasData: Bool {
        return !otherActivities.isEmpty &&
        !significanceActivities.isEmpty &&
        !moveActivities.isEmpty &&
        !deviceActivities.isEmpty
    }

    init(interactor: HomeInteractorInputProtocol,
         router: HomeRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    @objc func onDeviceConnectionChanged(_ sender: Notification) {
        guard let mac = sender.userInfo?[SKKey.mac] as? String,
              let index = devices.firstIndex(where: { $0.mac == mac }) else {
            return
        }
        let indexPath = IndexPath(row: index, section: DeviceViewController.Section.device.rawValue)
        view?.reloadDeviceCell(at: indexPath)
    }
}

// MARK: - HomePresenter: HomePresenterProtocol -
extension HomePresenter: HomePresenterProtocol {

    func onViewDidLoad() {
        kNotificationCenter.addObserver(self, selector: #selector(onDeviceConnectionChanged(_:)), name: .deviceConnectionChanged, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(onBleStateChanged(_:)), name: .bleStateChanged, object: nil)
        interactor.startObserver()
    }
    
    @objc func onBleStateChanged(_ sender: Notification) {
        self.view?.reloadHeaderData()
    }

    func onViewWillAppear() {
        BluetoothManager.shared.scanForDevice()
    }
    
    func numberOfSection() -> Int {
        switch activityFilterType {
        case .activity:
            return 3
        case .deviceActivity:
            return 1
        }
    }
    
    func heightOfHeader(in section: Int) -> CGFloat {
        switch activityFilterType {
        case .activity:
            if section == 0 {
                return !moveActivities.isEmpty ? 20 : 0
            } else {
                 return 20
            }
        case .deviceActivity:
            return 0
        }
    }

    func numberOfRow(in section: Int) -> Int {
        switch activityFilterType {
        case .activity:
            if section == 0 {
                // case moveActivities
                return !moveActivities.isEmpty ? moveActivities.count : 0
            } else if section == 1 {
                // case other
                return !otherActivities.isEmpty ? otherActivities.count : 1
            } else {
                // case significanceActivities
                return !significanceActivities.isEmpty ? significanceActivities.count : 3 //
            }
        case .deviceActivity:
            return !deviceActivities.isEmpty ? deviceActivities.count : 3 // DeviceType.allCases.count
        }
    }

    func itemForRow(at index: IndexPath) -> ActivityData? {
        switch activityFilterType {
        case .activity:
            if index.section == 0 {
                // case moveActivites
                if moveActivities.isEmpty {
                    return nil
                }
                return self.moveActivities[index.row]
            } else if index.section == 1 {
                // case other
                if otherActivities.isEmpty {
                    return nil
                }
                return self.otherActivities[index.row]
            } else {
                // case vitalSignas
                if significanceActivities.isEmpty {
                    return nil
                }
                return self.significanceActivities[index.row]
            }
        case .deviceActivity:
            return !deviceActivities.isEmpty ? deviceActivities[index.row] : nil
        }
    }

    func didSelectedItem(at index: IndexPath) {
        switch activityFilterType {
        case .activity:
            if index.section == 0 {
                // case moveActivites
                if moveActivities.isEmpty {
                    return
                }
                router.showResultViewController(with: moveActivities[index.row])
            } else if index.section == 1 {
                // case other
                if otherActivities.isEmpty {
                    return
                }
                router.showResultViewController(with: otherActivities[index.row])
            } else {
                // case significanceActivities
                if significanceActivities.isEmpty {
                    return
                }
                router.showResultViewController(with: significanceActivities[index.row])
            }
        case .deviceActivity:
            if deviceActivities.isEmpty {
                return
            }
            let activityData = deviceActivities[index.row]
            router.showResultViewController(with: activityData)
        }
    }

    func onButtonConnectDeviceDidTapped() {

    }

    func onButtonAdDeviceDidTapped() {
        router.gotoDeviceViewController()
    }

    func onSelectedDevice(at index: Int) {
        let device = devices[index]
        router.gotoDeviceDetailsViewController(device)
    }

    func onLinkDeviceDidTapped() {
        router.gotoDeviceViewController()
    }

    func getActivityFilterType() -> ActivityFilterType {
        return activityFilterType
    }

    func didSelectActivityFilterType(type: ActivityFilterType) {
        self.activityFilterType = type
        view?.reloadActivitiesTableView()
    }

    func didSelectedDevice(at index: IndexPath) {
        if let device = deviceActivities[index.row].device {
            router.gotoDeviceDetailsViewController(device)
        }
    }
}

// MARK: - Selectors
extension HomePresenter {
    @objc private func handleGetSpO2DeviceInfo() {
        
    }
}

// MARK: - HomePresenter: HomeInteractorOutput -
extension HomePresenter: HomeInteractorOutputProtocol {
    func onMoveActivitiesChange(_ activities: [ActivityData]) {
        self.moveActivities = activities
    }

    func onOtherActivitiesChange(_ activities: [ActivityData]) {
        self.otherActivities = activities
    }

    func onSignificanceActivitiesChange(_ activities: [ActivityData]) {
        self.significanceActivities = activities
        view?.reloadActivitiesTableView()
    }

    func onConnectDeviceChange(_ connectDevices: [DeviceModel]) {
        self.devices = connectDevices
        view?.reloadData(with: devices)
    }

    func onDeviceActivitiesChange(_ activities: [ActivityData]) {
        self.deviceActivities = activities
        view?.reloadActivitiesTableView()
    }
}
