//
//  
//  S5WaterSettingConstract.swift
//  1SKConnect
//
//  Created by TrungDN on 08/02/2022.
//
//

import UIKit
import TrusangBluetooth

// MARK: - View
protocol S5WaterSettingViewProtocol: AnyObject {
    func reloadData()
}

// MARK: - Presenter
protocol S5WaterSettingPresenterProtocol {
    var drinkWaterConfig: ZHJDrinkWaterConfig? { get }
    
    func onViewDidLoad()
}

// MARK: - Interactor Input
protocol S5WaterSettingInteractorInputProtocol {
    func readDrinkWaterConfig()
    func writeDrinkWaterConfig(drinkWaterConfig: ZHJDrinkWaterConfig)
}

// MARK: - Interactor Output
protocol S5WaterSettingInteractorOutputProtocol: AnyObject {
    func readDrinkWaterConfig(drinkWaterConfig: ZHJDrinkWaterConfig)
    func writeDrinkWaterConfig(error: ZHJBLEError)
}

// MARK: - Router
protocol S5WaterSettingRouterProtocol {

}
