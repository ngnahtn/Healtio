//
//  
//  HomeConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//
//

import UIKit

// MARK: View -
protocol HomeViewProtocol: AnyObject {
    func reloadData(with devices: [DeviceModel])
    func reloadActivitiesTableView()
    func reloadDeviceCell(at index: IndexPath)
    func reloadHeaderData()
}

// MARK: Interactor -
protocol HomeInteractorInputProtocol {
    func startObserver()
}

protocol HomeInteractorOutputProtocol: AnyObject {
    func onConnectDeviceChange(_ connectDevices: [DeviceModel])
    func onMoveActivitiesChange(_ activities: [ActivityData])
    func onOtherActivitiesChange(_ activities: [ActivityData])
    func onSignificanceActivitiesChange(_ activities: [ActivityData])
    func onDeviceActivitiesChange(_ activities: [ActivityData])
}
// MARK: Presenter -
protocol HomePresenterProtocol {
    func onViewWillAppear()
    func onViewDidLoad()
    func numberOfSection() -> Int
    func numberOfRow(in section: Int) -> Int
    func heightOfHeader(in section: Int) -> CGFloat
    func itemForRow(at index: IndexPath) -> ActivityData?
    func didSelectedItem(at index: IndexPath)
    func onButtonConnectDeviceDidTapped()
    func onButtonAdDeviceDidTapped()
    func onSelectedDevice(at index: Int)
    func onLinkDeviceDidTapped()
    func getActivityFilterType() -> ActivityFilterType
    func didSelectActivityFilterType(type: ActivityFilterType)
    func didSelectedDevice(at index: IndexPath)
}

// MARK: Router -
protocol HomeRouterProtocol {
    func gotoDeviceViewController()
    func gotoDeviceDetailsViewController(_ device: DeviceModel)
    func showResultViewController(with activity: ActivityData)
}
