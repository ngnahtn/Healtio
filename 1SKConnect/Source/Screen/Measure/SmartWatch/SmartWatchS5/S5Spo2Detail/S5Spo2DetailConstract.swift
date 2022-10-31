//
//  
//  S5Spo2DetailConstract.swift
//  1SKConnect
//
//  Created by Be More on 28/12/2021.
//
//

import UIKit

// MARK: - View
protocol S5Spo2DetailViewProtocol: AnyObject {
    func reloadDataWithTimeType(_ timeType: TimeFilterType)
}

// MARK: - Presenter
protocol S5Spo2DetailPresenterProtocol {
    var model: S5SpO2Detail { get }
    
    func onViewDidLoad()
    func setFilterTime(with type: TimeFilterType)
}

// MARK: - Interactor Input
protocol S5Spo2DetailInteractorInputProtocol {
    func startObserver()
}

// MARK: - Interactor Output
protocol S5Spo2DetailInteractorOutputProtocol: AnyObject {
    func onFinishedGetSpO2List(model: S5SpO2ListRecordModel?)
}

// MARK: - Router
protocol S5Spo2DetailRouterProtocol {

}
