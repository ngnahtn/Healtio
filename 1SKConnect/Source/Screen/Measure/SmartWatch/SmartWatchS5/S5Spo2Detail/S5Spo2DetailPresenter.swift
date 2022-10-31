//
//  
//  S5Spo2DetailPresenter.swift
//  1SKConnect
//
//  Created by Be More on 28/12/2021.
//
//

import UIKit

class S5Spo2DetailPresenter {

    weak var view: S5Spo2DetailViewProtocol?
    private var interactor: S5Spo2DetailInteractorInputProtocol
    private var router: S5Spo2DetailRouterProtocol
    
    var spO2Detail: S5SpO2Detail? {
        didSet {
            guard let spO2Detail = spO2Detail else {
                return
            }
            self.view?.reloadDataWithTimeType(spO2Detail.timeType)
        }
    }

    init(interactor: S5Spo2DetailInteractorInputProtocol,
         router: S5Spo2DetailRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - S5Spo2DetailPresenterProtocol
extension S5Spo2DetailPresenter: S5Spo2DetailPresenterProtocol {
    var model: S5SpO2Detail {
        if let spO2List = self.spO2Detail {
            return spO2List
        } else {
            return S5SpO2Detail(timeType: .day)
        }
    }
    
    func setFilterTime(with type: TimeFilterType) {
        self.spO2Detail?.timeType = type
    }
    
    func onViewDidLoad() {
        self.interactor.startObserver()
    }
}

// MARK: - S5Spo2DetailInteractorOutput 
extension S5Spo2DetailPresenter: S5Spo2DetailInteractorOutputProtocol {
    func onFinishedGetSpO2List(model: S5SpO2ListRecordModel?) {
        self.spO2Detail?.dataValues = model
    }
}
