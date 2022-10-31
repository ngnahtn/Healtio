//
//  
//  S5SleepDetailConstract.swift
//  1SKConnect
//
//  Created by TrungDN on 30/12/2021.
//
//

import UIKit

// MARK: - View
protocol S5SleepDetailViewProtocol: AnyObject {
    func reloadDataWithTimeType(_ timeType: TimeFilterType)
}

// MARK: - Presenter
protocol S5SleepDetailPresenterProtocol {
    var model: S5SleepDetail { get }
    
    func onViewDidLoad()
    func setFilterTime(with type: TimeFilterType)
}

// MARK: - Interactor Input
protocol S5SleepDetailInteractorInputProtocol {
    func startObserver()
}

// MARK: - Interactor Output
protocol S5SleepDetailInteractorOutputProtocol: AnyObject {
    func onSleepListDidChange(model: SleepListRecordModel?)
}

// MARK: - Router
protocol S5SleepDetailRouterProtocol: BaseRouterProtocol {

}
