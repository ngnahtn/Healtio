//
//  
//  BloodPressureResultPresenter.swift
//  1SKConnect
//
//  Created by admin on 19/11/2021.
//
//

import UIKit

class BloodPressureResultPresenter {

    weak var view: BloodPressureResultViewProtocol?
    private var interactor: BloodPressureResultInteractorInputProtocol
    private var router: BloodPressureResultRouterProtocol
    var bloodPressureModel: BloodPressureModel?
    var errorText = ""
    init(interactor: BloodPressureResultInteractorInputProtocol,
         router: BloodPressureResultRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - BloodPressureResultPresenterProtocol
extension BloodPressureResultPresenter: BloodPressureResultPresenterProtocol {
    func sendMeasureAgain(from view: BloodPressureResultViewController) {
        router.measureAgain(from: view)
    }
    
    func sendBackToBloodPressureVC(from view: BloodPressureResultViewController) {
        router.backToBloodPressureVC(from: view)
    }

    func onViewDidLoad() {
        getData()
    }
    private func getData() {
        view?.showData(with: bloodPressureModel, with: errorText)
    }
}

// MARK: - BloodPressureResultInteractorOutput 
extension BloodPressureResultPresenter: BloodPressureResultInteractorOutputProtocol {
}
