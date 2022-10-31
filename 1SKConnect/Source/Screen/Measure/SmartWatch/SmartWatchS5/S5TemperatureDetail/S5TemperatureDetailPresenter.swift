//
//  
//  S5TemperatureDetailPresenter.swift
//  1SKConnect
//
//  Created by TrungDN on 28/12/2021.
//
//

import UIKit

class S5TemperatureDetailPresenter {

    weak var view: S5TemperatureDetailViewProtocol?
    private var interactor: S5TemperatureDetailInteractorInputProtocol
    private var router: S5TemperatureDetailRouterProtocol

    var temperatureDetail: S5TemperatureDetail? {
        didSet {
            guard let temperatureDetail = temperatureDetail else {
                return
            }
            self.view?.reloadDataWithTimeType(temperatureDetail.timeType)
        }
    }

    init(interactor: S5TemperatureDetailInteractorInputProtocol,
         router: S5TemperatureDetailRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - S5TemperatureDetailPresenterProtocol
extension S5TemperatureDetailPresenter: S5TemperatureDetailPresenterProtocol {
    var model: S5TemperatureDetail {
        if let data = self.temperatureDetail {
            return data
        } else {
            return S5TemperatureDetail(timeType: .day)
        }
    }

    func onViewDidLoad() {
        self.interactor.startObserver()
    }
    
    func setFilterTime(with type: TimeFilterType) {
        self.temperatureDetail?.timeType = type
    }
}

// MARK: - S5TemperatureDetailInteractorOutput 
extension S5TemperatureDetailPresenter: S5TemperatureDetailInteractorOutputProtocol {
    func onTempListChange(model: S5TemperatureListRecordModel?) {
        self.temperatureDetail?.dataValues = model
    }
}
