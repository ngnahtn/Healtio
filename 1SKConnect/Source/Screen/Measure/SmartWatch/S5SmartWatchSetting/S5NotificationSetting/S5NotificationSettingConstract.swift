//
//  
//  S5NotificationSettingConstract.swift
//  1SKConnect
//
//  Created by Be More on 25/01/2022.
//
//

import UIKit
import TrusangBluetooth

// MARK: - View
protocol S5NotificationSettingViewProtocol: AnyObject {
    func reloadData()
}

// MARK: - Presenter
protocol S5NotificationSettingPresenterProtocol {

    // properties
    var noticeValue: Bool { get }
    var settingValue: [S5AppNoticeSettig] { get }
    
    // s5AppNotice
    func onSwitchNotice(isOn: Bool)
    func setOn(on: Bool, at cell: IndexPath)

    // life cycle
    func onViewDidLoad()
    func onViewWillDisappear()
}

// MARK: - Interactor Input
protocol S5NotificationSettingInteractorInputProtocol {

    // get s5ApNoticeState
    func readNotice()
}

// MARK: - Interactor Output
protocol S5NotificationSettingInteractorOutputProtocol: AnyObject {

    // read s5ApNoticeState
    func onReadNoticeFinished(notice: ZHJMessageNotice)
}

// MARK: - Router
protocol S5NotificationSettingRouterProtocol {
}
