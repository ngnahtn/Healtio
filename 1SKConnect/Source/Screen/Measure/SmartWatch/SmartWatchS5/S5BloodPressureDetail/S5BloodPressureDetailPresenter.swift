//
//  
//  S5BloodPressureDetailPresenter.swift
//  1SKConnect
//
//  Created by TrungDN on 27/12/2021.
//
//

import UIKit

class S5BloodPressureDetailPresenter {

    weak var view: S5BloodPressureDetailViewProtocol?
    private var interactor: S5BloodPressureDetailInteractorInputProtocol
    private var router: S5BloodPressureDetailRouterProtocol
    
    var bloodPressureDetail: S5BloodPressureDetail? {
        didSet {
            guard let bloodPressureDetail = bloodPressureDetail else {
                return
            }
            self.view?.reloadDataWithTimeType(bloodPressureDetail.timeType)
        }
    }

    init(interactor: S5BloodPressureDetailInteractorInputProtocol,
         router: S5BloodPressureDetailRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - S5BloodPressureDetailPresenterProtocol
extension S5BloodPressureDetailPresenter: S5BloodPressureDetailPresenterProtocol {
    var model: S5BloodPressureDetail {
        if let data = self.bloodPressureDetail {
            return data
        } else {
            return S5BloodPressureDetail(timeType: .day)
        }
    }

    func onViewDidLoad() {
        self.interactor.startObserver()
    }

    func setFilterTime(with type: TimeFilterType) {
        self.bloodPressureDetail?.timeType = type
    }
}

// MARK: - S5BloodPressureDetailInteractorOutput 
extension S5BloodPressureDetailPresenter: S5BloodPressureDetailInteractorOutputProtocol {
    func onBloodPressureListDidChange(model: BloodPressureListRecordModel?) {
        self.bloodPressureDetail?.dataValues = model
    }
}
