//
//  
//  TrackingConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 30/03/2021.
//
//

import UIKit

// MARK: View -
protocol TrackingViewProtocol: class {
    func reloadData()
    func setNoDeviceViewHidden(_ isHidden: Bool)
}

// MARK: Interactor -
protocol TrackingInteractorInputProtocol {
    func startObserver()
}

protocol TrackingInteractorOutputProtocol: AnyObject {
    func onMoveActivitiesChange(_ activities: [ActivityData])
    func onOtherActivitiesChange(_ activities: [ActivityData])
    func onSignificanceActivitiesChange(_ activities: [ActivityData])
    func onDeviceActivitiesChange(_ activities: [ActivityData])
    func onLinkDeviceChange(_ devices: [DeviceModel])
}
// MARK: Presenter -
protocol TrackingPresenterProtocol {
    func onViewDidLoad()
    func numberOfSection() -> Int
    func numberOfRow(in section: Int) -> Int
    func heightOfHeader(in section: Int) -> CGFloat 
    func itemForRow(at index: IndexPath) -> ActivityData?
    func didSelectedItem(at index: IndexPath)
    func getActivityFilterType() -> ActivityFilterType
    func onLinkDeviceButtonDidTapped()
    func didSelectActivityFilterType(type: ActivityFilterType)
    func didSelectedDevice(at index: IndexPath)
}

// MARK: Router -
protocol TrackingRouterProtocol {
    func showDeviceViewController()
    func showResultViewController(activity: ActivityData)
    func gotoDeviceDetailsViewController(_ device: DeviceModel)
}
