//
//  
//  ScaleResultConstract.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//
//

import UIKit

// MARK: View -
protocol ScaleResultViewProtocol: AnyObject {
    func reloadData(with bodyFat: BodyFat)
}

// MARK: Interactor -
protocol ScaleResultInteractorInputProtocol {

}

protocol ScaleResultInteractorOutputProtocol: AnyObject {
}
// MARK: Presenter -
protocol ScaleResultPresenterProtocol {
    func onViewDidLoad()
    func onCloseButtonDidTapped()
    func onGoToScaleResultDetail(with weightDetail: DetailsItemProtocol)
}

// MARK: Router -
protocol ScaleResultRouterProtocol {
    func dismiss()
    func onGoToScaleResultDetail(with weightDetail: DetailsItemProtocol, bodyFat: BodyFat)
}
