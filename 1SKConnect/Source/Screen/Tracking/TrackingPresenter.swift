//
//  
//  TrackingPresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 30/03/2021.
//
//

import UIKit

class TrackingPresenter {

    private var moveActivities: [ActivityData] = []
    private var otherActivities: [ActivityData] = []
    private var significanceActivities: [ActivityData] = []
    private var deviceActivities: [ActivityData] = []
    private var activityFilterType: ActivityFilterType = .activity
    private var activityGroups: [ActivityGroup] = ActivityGroup.allCases
    weak var view: TrackingViewProtocol?
    private var interactor: TrackingInteractorInputProtocol
    private var router: TrackingRouterProtocol

    init(interactor: TrackingInteractorInputProtocol,
         router: TrackingRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - TrackingPresenterProtocol
extension TrackingPresenter: TrackingPresenterProtocol {
    func onViewDidLoad() {
        interactor.startObserver()
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
                return !moveActivities.isEmpty ? moveActivities.count : 0
            } else if section == 1 {
                return !otherActivities.isEmpty ? otherActivities.count : 1
            } else {
                return !significanceActivities.isEmpty ? significanceActivities.count : 4 //
            }
        case .deviceActivity:
            return !deviceActivities.isEmpty ? deviceActivities.count : 3
        }
    }

    func itemForRow(at index: IndexPath) -> ActivityData? {
        switch activityFilterType {
        case .activity:
//            guard let type = ActivityGroup(rawValue: index.section) else {
//                return nil
//            }
            if index.section == 0 {
                if moveActivities.isEmpty {
                    return nil
                }
                return self.moveActivities[index.row]
            } else if index.section == 1 {
                if otherActivities.isEmpty {
                    return nil
                }
                return self.otherActivities[index.row]
            } else {
                if significanceActivities.isEmpty {
                    return nil
                }
                return self.significanceActivities[index.row]
            }
//            switch type {
//            case .move:
//                return !moveActivities.isEmpty ? moveActivities[index.row] : nil
//            case .other:
//                return !otherActivities.isEmpty ? otherActivities[index.row] : nil
//            case .significance:
//                return !significanceActivities.isEmpty ? significanceActivities[index.row] : nil
//            }
//            return !otherActivities.isEmpty ? otherActivities[index.row] : nil
        case .deviceActivity:
            return !deviceActivities.isEmpty ? deviceActivities[index.row] : nil
        }
    }

    func didSelectedItem(at index: IndexPath) {
        switch activityFilterType {
        case .activity:
            if index.section == 0 {
                if moveActivities.isEmpty {
                    return
                }
                router.gotoDeviceDetailsViewController(moveActivities[index.row].device!)
            } else if index.section == 1 {
                if otherActivities.isEmpty {
                    return
                }
                router.showResultViewController(activity: otherActivities[index.row])
            } else {
                if significanceActivities.isEmpty {
                    return
                }
                router.showResultViewController(activity: significanceActivities[index.row])
            }
//            guard let type = ActivityGroup(rawValue: index.section) else {
//                return
//            }
//            var item: ActivityData
//            switch type {
//            case .move:
//                item = moveActivities[index.row]
//            case .other:
//                item = otherActivities[index.row]
//            case .significance:
//                item = significanceActivities[index.row]
//            }
//            router.showResultViewController(activity: item)
        case .deviceActivity:
            let bodyFat = deviceActivities[index.row]
            router.showResultViewController(activity: bodyFat)
        }
    }

    func getActivityFilterType() -> ActivityFilterType {
        return activityFilterType
    }

    func onLinkDeviceButtonDidTapped() {
        router.showDeviceViewController()
    }

    func didSelectActivityFilterType(type: ActivityFilterType) {
        self.activityFilterType = type
        view?.reloadData()
    }

    func didSelectedDevice(at index: IndexPath) {
        if let device = deviceActivities[index.row].device {
            router.gotoDeviceDetailsViewController(device)
        }
    }
}

// MARK: - TrackingPresenter: TrackingInteractorOutput -
extension TrackingPresenter: TrackingInteractorOutputProtocol {
    func onMoveActivitiesChange(_ activities: [ActivityData]) {
        self.moveActivities = activities
    }

    func onOtherActivitiesChange(_ activities: [ActivityData]) {
        self.otherActivities = activities
    }

    func onSignificanceActivitiesChange(_ activities: [ActivityData]) {
        self.significanceActivities = activities
        view?.reloadData()
    }

    func onDeviceActivitiesChange(_ activities: [ActivityData]) {
        self.deviceActivities = activities
        view?.reloadData()
    }

    func onLinkDeviceChange(_ devices: [DeviceModel]) {
        view?.setNoDeviceViewHidden(!devices.isEmpty)
    }
}
