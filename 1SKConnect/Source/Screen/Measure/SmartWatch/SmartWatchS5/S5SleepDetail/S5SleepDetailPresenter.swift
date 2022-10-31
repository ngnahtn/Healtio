//
//  
//  S5SleepDetailPresenter.swift
//  1SKConnect
//
//  Created by TrungDN on 30/12/2021.
//
//

import UIKit

class S5SleepDetailPresenter {

    weak var view: S5SleepDetailViewProtocol?
    private var interactor: S5SleepDetailInteractorInputProtocol
    private var router: S5SleepDetailRouterProtocol
    
    var sleepDetail: S5SleepDetail? {
        didSet {
            guard let sleepDetail = sleepDetail else {
                return
            }
            self.view?.reloadDataWithTimeType(sleepDetail.timeType)
        }
    }

    init(interactor: S5SleepDetailInteractorInputProtocol,
         router: S5SleepDetailRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - S5SleepDetailPresenterProtocol
extension S5SleepDetailPresenter: S5SleepDetailPresenterProtocol {
    var model: S5SleepDetail {
        if let data = self.sleepDetail {
            return data
        } else {
            return S5SleepDetail(timeType: .day)
        }
    }
    
    func setFilterTime(with type: TimeFilterType) {
        self.sleepDetail?.timeType = type
    }
    
    func onViewDidLoad() {
        self.interactor.startObserver()
    }
}

// MARK: - S5SleepDetailInteractorOutput 
extension S5SleepDetailPresenter: S5SleepDetailInteractorOutputProtocol {
    func onSleepListDidChange(model: SleepListRecordModel?) {
        self.sleepDetail?.dataValues = model
    }
}
