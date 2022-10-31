//
//  CBPeripheral+Extension.swift
//  1SKConnect
//
//  Created by Be More on 16/09/2021.
//

import CoreBluetooth

extension CBPeripheral {
    var mac: String {
        return identifier.uuidString
    }
}
