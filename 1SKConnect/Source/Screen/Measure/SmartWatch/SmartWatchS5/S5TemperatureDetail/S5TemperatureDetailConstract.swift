//
//  
//  S5TemperatureDetailConstract.swift
//  1SKConnect
//
//  Created by TrungDN on 28/12/2021.
//
//

import UIKit

// MARK: - View
protocol S5TemperatureDetailViewProtocol: AnyObject {
    func reloadDataWithTimeType(_ timeType: TimeFilterType)
}

// MARK: - Presenter
protocol S5TemperatureDetailPresenterProtocol {
    var model: S5TemperatureDetail { get }
    
    func onViewDidLoad()
    func setFilterTime(with type: TimeFilterType)
}

// MARK: - Interactor Input
protocol S5TemperatureDetailInteractorInputProtocol {
    func startObserver()
}

// MARK: - Interactor Output
protocol S5TemperatureDetailInteractorOutputProtocol: AnyObject {
    func onTempListChange(model: S5TemperatureListRecordModel?)
}

// MARK: - Router
protocol S5TemperatureDetailRouterProtocol {

}
