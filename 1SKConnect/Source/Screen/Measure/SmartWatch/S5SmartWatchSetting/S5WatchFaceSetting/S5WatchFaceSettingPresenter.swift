//
//  
//  S5WatchFaceSettingPresenter.swift
//  1SKConnect
//
//  Created by admin on 10/02/2022.
//
//

import UIKit

class S5WatchFaceSettingPresenter {

    weak var view: S5WatchFaceSettingViewProtocol?
    private var interactor: S5WatchFaceSettingInteractorInputProtocol
    private var router: S5WatchFaceSettingRouterProtocol

    init(interactor: S5WatchFaceSettingInteractorInputProtocol,
         router: S5WatchFaceSettingRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - S5WatchFaceSettingPresenterProtocol
extension S5WatchFaceSettingPresenter: S5WatchFaceSettingPresenterProtocol {

    var numberOfCell: Int {
        return 10
    }
    
    func onWatchFaceDidSelected() {
        
    }
    
    func sendDialToS5() {

    }
    
    func onViewDidLoad() {
        
    }
}

// MARK: - S5WatchFaceSettingInteractorOutput 
extension S5WatchFaceSettingPresenter: S5WatchFaceSettingInteractorOutputProtocol {

}
