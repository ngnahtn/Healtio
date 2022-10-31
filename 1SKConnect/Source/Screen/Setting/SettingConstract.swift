//
//  
//  SettingConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//
//

import UIKit

// MARK: View -
protocol SettingViewProtocol: AnyObject {

}

// MARK: Interactor -
protocol SettingInteractorInputProtocol {

}

protocol SettingInteractorOutputProtocol: AnyObject {
}

// MARK: Presenter -
protocol SettingPresenterProtocol {
    func onViewDidLoad()
    func onButtonProfileDidTapped()
    func onButtonDeviceDidTapped()
    func onButtonSyncDidTap()
    func onButtonIntroduceDidTapped()
}

// MARK: Router -
protocol SettingRouterProtocol {
    func gotoHealthProfileDetails(with profile: ProfileModel?, state: InfomationScreenEditableState)
    func gotoProfileListViewController()
    func gotoDeviceViewController()
    func gotoSyncViewController()
    func gotoIntroduceViewController()
}
