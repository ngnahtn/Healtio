//
//  
//  S5BloodPressureDetailConstract.swift
//  1SKConnect
//
//  Created by TrungDN on 27/12/2021.
//
//

import UIKit

// MARK: - View
protocol S5BloodPressureDetailViewProtocol: AnyObject {
    func reloadDataWithTimeType(_ timeType: TimeFilterType)
}

// MARK: - Presenter
protocol S5BloodPressureDetailPresenterProtocol {
    var model: S5BloodPressureDetail { get }
    
    func onViewDidLoad()
    func setFilterTime(with type: TimeFilterType)
}

// MARK: - Interactor Input
protocol S5BloodPressureDetailInteractorInputProtocol {
    func startObserver()
}

// MARK: - Interactor Output
protocol S5BloodPressureDetailInteractorOutputProtocol: AnyObject {
    func onBloodPressureListDidChange(model: BloodPressureListRecordModel?)
}

// MARK: - Router
protocol S5BloodPressureDetailRouterProtocol {

}
