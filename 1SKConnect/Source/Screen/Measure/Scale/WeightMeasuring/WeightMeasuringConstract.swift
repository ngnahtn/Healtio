//
//  
//  WeightMeasuringConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit

// MARK: View -
protocol WeightMeasuringViewProtocol: AnyObject {
    func update(with weight: Double)
    func setScaleImage(_ image: UIImage?)
    func update(with state: WeightMeasuringPresenter.State)
    func update(with bodyfat: BodyFat)
}

// MARK: Interactor -
protocol WeightMeasuringInteractorInputProtocol {
    func startObserver()
    func addBodyFat(_ bodyFat: BodyFat, scale: DeviceModel)
}

protocol WeightMeasuringInteractorOutputProtocol: AnyObject {
    func onProfileListChange(with profileList: ProfileListModel?)
}
// MARK: Presenter -
protocol WeightMeasuringPresenterProtocol {
    func onViewDidLoad()
    func onViewDidDisappear()
    func onButtonCloseDidTapped()
    func onGoToScaleResultDetail(with weightDetail: DetailsItemProtocol)
}

// MARK: Router -
protocol WeightMeasuringRouterProtocol: BaseRouter {
    func dismiss()
    func onGoToScaleResultDetail(with weightDetail: DetailsItemProtocol, bodyFat: BodyFat)
}
