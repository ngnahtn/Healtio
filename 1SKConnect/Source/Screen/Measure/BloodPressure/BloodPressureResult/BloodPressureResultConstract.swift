//
//  
//  BloodPressureResultConstract.swift
//  1SKConnect
//
//  Created by admin on 19/11/2021.
//
//

import UIKit

// MARK: - View
protocol BloodPressureResultViewProtocol: AnyObject {
    func showData(with data: BloodPressureModel?, with errorText: String)

}

// MARK: - Presenter
protocol BloodPressureResultPresenterProtocol {
    func onViewDidLoad()
    func sendBackToBloodPressureVC(from view: BloodPressureResultViewController)
    func sendMeasureAgain(from view: BloodPressureResultViewController)
}

// MARK: - Interactor Input
protocol BloodPressureResultInteractorInputProtocol {

}

// MARK: - Interactor Output
protocol BloodPressureResultInteractorOutputProtocol: AnyObject {
    
}

// MARK: - Router
protocol BloodPressureResultRouterProtocol {
    func backToBloodPressureVC(from view: BloodPressureResultViewController)
    func measureAgain(from view: BloodPressureResultViewController)
}
