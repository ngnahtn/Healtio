//
//  
//  S5HeartRateDetailPresenter.swift
//  1SKConnect
//
//  Created by Be More on 27/12/2021.
//
//

import UIKit

class S5HeartRateDetailPresenter {

    weak var view: S5HeartRateDetailViewProtocol?
    private var interactor: S5HeartRateDetailInteractorInputProtocol
    private var router: S5HeartRateDetailRouterProtocol
    
    var hrDetail: S5HeartRateDetail? {
        didSet {
            guard let hrDetail = hrDetail else {
                return
            }
            self.view?.reloadDataWithTimeType(hrDetail.timeType)
        }
    }

    init(interactor: S5HeartRateDetailInteractorInputProtocol,
         router: S5HeartRateDetailRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - S5HeartRateDetailPresenterProtocol
extension S5HeartRateDetailPresenter: S5HeartRateDetailPresenterProtocol {
    var model: S5HeartRateDetail {
        if let hr = self.hrDetail {
            return hr
        } else {
            return S5HeartRateDetail(timeType: .day)
        }
    }

    func onViewDidLoad() {
        self.interactor.startObserver()
    }

    func setFilterTime(with type: TimeFilterType) {
        self.hrDetail?.timeType = type
        
    }
}

// MARK: - S5HeartRateDetailInteractorOutput 
extension S5HeartRateDetailPresenter: S5HeartRateDetailInteractorOutputProtocol {
    func onFinishedGetHrList(model: S5HeartRateListRecordModel?) {
        self.hrDetail?.dataValues = model
    }
}
