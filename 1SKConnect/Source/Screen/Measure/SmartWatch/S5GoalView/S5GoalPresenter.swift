//
//  
//  S5GoalPresenter.swift
//  1SKConnect
//
//  Created by admin on 17/12/2021.
//
//

import UIKit

class S5GoalPresenter {

    weak var view: S5GoalViewProtocol?
    private var interactor: S5GoalInteractorInputProtocol
    private var router: S5GoalRouterProtocol

    init(interactor: S5GoalInteractorInputProtocol,
         router: S5GoalRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - S5GoalPresenterProtocol
extension S5GoalPresenter: S5GoalPresenterProtocol {

    var safeAreaBottom: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            return window.safeAreaInsets.bottom
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.bottom ?? 0
        }
    }

    func saveGoal(with value: Int) {
        self.interactor.startSaveGoal(with: value)
    }
    
    func onViewDidLoad() {
        interactor.startObserver()
    }
}

// MARK: - S5GoalInteractorOutput 
extension S5GoalPresenter: S5GoalInteractorOutputProtocol {
    func getGoal(with goal: Int) {
        view?.getGoal(with: goal)
    }
}
