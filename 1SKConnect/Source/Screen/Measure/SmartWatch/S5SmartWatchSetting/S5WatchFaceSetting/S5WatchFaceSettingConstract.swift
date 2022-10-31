//
//  
//  S5WatchFaceSettingConstract.swift
//  1SKConnect
//
//  Created by admin on 10/02/2022.
//
//

import UIKit

// MARK: - View
protocol S5WatchFaceSettingViewProtocol: AnyObject {

}

// MARK: - Presenter
protocol S5WatchFaceSettingPresenterProtocol {
    func onViewDidLoad()
    
    var numberOfCell: Int { get }
    
    func onWatchFaceDidSelected()
    func sendDialToS5()
}

// MARK: - Interactor Input
protocol S5WatchFaceSettingInteractorInputProtocol {

}

// MARK: - Interactor Output
protocol S5WatchFaceSettingInteractorOutputProtocol: AnyObject {
    
}

// MARK: - Router
protocol S5WatchFaceSettingRouterProtocol {

}
