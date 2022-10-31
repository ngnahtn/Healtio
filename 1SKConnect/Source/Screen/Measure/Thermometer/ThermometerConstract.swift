//
//  
//  ThermometerConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//
//

import UIKit

// MARK: View -
protocol ThermometerViewProtocol: AnyObject {

}

// MARK: Interactor -
protocol ThermometerInteractorInputProtocol {

}

protocol ThermometerInteractorOutputProtocol: AnyObject {
}
// MARK: Presenter -
protocol ThermometerPresenterProtocol {
    func onViewDidLoad()
    func onButtonScanDidTapped()
}

// MARK: Router -
protocol ThermometerRouterProtocol {

}
