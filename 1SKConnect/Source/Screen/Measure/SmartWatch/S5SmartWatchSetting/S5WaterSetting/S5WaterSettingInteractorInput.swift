//
//  
//  S5WaterSettingInteractorInput.swift
//  1SKConnect
//
//  Created by TrungDN on 08/02/2022.
//
//

import UIKit
import TrusangBluetooth

class S5WaterSettingInteractorInput {
    weak var output: S5WaterSettingInteractorOutputProtocol?
    private let waterConfig: ZHJDrinkWaterConfigProcessor = ZHJDrinkWaterConfigProcessor()
}

// MARK: - S5WaterSettingInteractorInputProtocol
extension S5WaterSettingInteractorInput: S5WaterSettingInteractorInputProtocol {
    func readDrinkWaterConfig() {
        self.waterConfig.readDrinkWaterConfig { [weak self] waterConfig in
            guard let `self` = self else { return }
            self.output?.readDrinkWaterConfig(drinkWaterConfig: waterConfig)
        }
    }
    
    func writeDrinkWaterConfig(drinkWaterConfig: ZHJDrinkWaterConfig) {
        self.waterConfig.writeDrinkWaterConfig(drinkWaterConfig: drinkWaterConfig) { [weak self] errors in
            guard let `self` = self else { return }
            self.output?.writeDrinkWaterConfig(error: errors)
        }
    }
}
