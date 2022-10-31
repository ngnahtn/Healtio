//
//  
//  IntroducePresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/04/2021.
//
//

import UIKit

class IntroducePresenter {

    weak var view: IntroduceViewProtocol?
    private var interactor: IntroduceInteractorInputProtocol
    private var router: IntroduceRouterProtocol

    init(interactor: IntroduceInteractorInputProtocol,
         router: IntroduceRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - IntroducePresenterProtocol
extension IntroducePresenter: IntroducePresenterProtocol {
    func onViewDidLoad() {
        
    }
}

// MARK: - IntroducePresenter: IntroduceInteractorOutput -
extension IntroducePresenter: IntroduceInteractorOutputProtocol {

}
