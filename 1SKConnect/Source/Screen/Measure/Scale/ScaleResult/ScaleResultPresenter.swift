//
//  
//  ScaleResultPresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//
//

import UIKit

class ScaleResultPresenter {

    var bodyFat: BodyFat?

    weak var view: ScaleResultViewProtocol?
    private var interactor: ScaleResultInteractorInputProtocol
    private var router: ScaleResultRouterProtocol

    init(interactor: ScaleResultInteractorInputProtocol,
         router: ScaleResultRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - extending ScaleResultPresenter: ScaleResultPresenterProtocol -
extension ScaleResultPresenter: ScaleResultPresenterProtocol {
    func onGoToScaleResultDetail(with weightDetail: DetailsItemProtocol) {
        guard let `bodyFat` = bodyFat else {
            return
        }
        self.router.onGoToScaleResultDetail(with: weightDetail, bodyFat: bodyFat)
    }

    func onViewDidLoad() {
        guard let `bodyFat` = bodyFat else {
            return
        }
        view?.reloadData(with: bodyFat)
    }

    func onCloseButtonDidTapped() {
        router.dismiss()
    }
}

// MARK: - ScaleResultPresenter: ScaleResultInteractorOutput -
extension ScaleResultPresenter: ScaleResultInteractorOutputProtocol {

}
