//
//  
//  StartConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//
//

import UIKit

// MARK: View -
protocol StartViewProtocol: AnyObject {

}

// MARK: Interactor -
protocol StartInteractorInputProtocol {
    func getNumberNotification(_ token: String)
}

protocol StartInteractorOutputProtocol: AnyObject {
    func onGetNumberNotificationFinished(with totalNotificationNumber: Int)
}
// MARK: Presenter -
protocol StartPresenterProtocol {
    func onViewDidLoad()
    func onViewDidAppear()
}

// MARK: Router -
protocol StartRouterProtocol {
    func showMainTabbarController()
    func showCreateProfileViewController(delegate: CreateDefautlsProfilePresenterDelegate?)
}
