//
//  
//  S5HeartRateDetailConstract.swift
//  1SKConnect
//
//  Created by Be More on 27/12/2021.
//
//

import UIKit

// MARK: - View
protocol S5HeartRateDetailViewProtocol: AnyObject {
    func reloadDataWithTimeType(_ timeType: TimeFilterType)
}

// MARK: - Presenter
protocol S5HeartRateDetailPresenterProtocol {
    var model: S5HeartRateDetail { get }
    
    func onViewDidLoad()
    func setFilterTime(with type: TimeFilterType)
}

// MARK: - Interactor Input
protocol S5HeartRateDetailInteractorInputProtocol {
    func startObserver()
}

// MARK: - Interactor Output
protocol S5HeartRateDetailInteractorOutputProtocol: AnyObject {
    func onFinishedGetHrList(model: S5HeartRateListRecordModel?)
}

// MARK: - Router
protocol S5HeartRateDetailRouterProtocol {
}
