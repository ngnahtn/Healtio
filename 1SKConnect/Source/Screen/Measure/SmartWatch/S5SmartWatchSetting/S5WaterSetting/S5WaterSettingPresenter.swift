//
//  
//  S5WaterSettingPresenter.swift
//  1SKConnect
//
//  Created by TrungDN on 08/02/2022.
//
//

import UIKit
import TrusangBluetooth

class S5WaterSettingPresenter {

    weak var view: S5WaterSettingViewProtocol?
    private var interactor: S5WaterSettingInteractorInputProtocol
    private var router: S5WaterSettingRouterProtocol
    
    private var waterConfig: ZHJDrinkWaterConfig? {
        didSet {
            self.view?.reloadData()
        }
    }

    init(interactor: S5WaterSettingInteractorInputProtocol, router: S5WaterSettingRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - S5WaterSettingPresenterProtocol
extension S5WaterSettingPresenter: S5WaterSettingPresenterProtocol {
    var drinkWaterConfig: ZHJDrinkWaterConfig? {
        return waterConfig
    }
    
    func onViewDidLoad() {
        self.interactor.readDrinkWaterConfig()
    }
}

// MARK: - S5WaterSettingInteractorOutput 
extension S5WaterSettingPresenter: S5WaterSettingInteractorOutputProtocol {
    func readDrinkWaterConfig(drinkWaterConfig: ZHJDrinkWaterConfig) {
        self.waterConfig = drinkWaterConfig
    }
    
    func writeDrinkWaterConfig(error: ZHJBLEError) {
        
    }
}
