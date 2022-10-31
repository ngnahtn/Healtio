//
//  BLEDataHandler.swift
//  1SKConnect
//
//  Created by tuyenvx on 16/04/2021.
//

import CoreBluetooth

protocol ScaleBLEDataHandlerDelegate: AnyObject {
    func updateWeight(_ weight: Double)
    func finishData(_ bodyFat: BodyFat)
    func scaleDidOverload()
}

protocol BLEDataHandlerProtocol {
    func handlerData(_ data: [UInt8], of characteristic: CBCharacteristic, error: Error?)
}

protocol ScaleBLEDataHandler: AnyObject, BLEDataHandlerProtocol {
    var delegate: ScaleBLEDataHandlerDelegate? { get set }
}
