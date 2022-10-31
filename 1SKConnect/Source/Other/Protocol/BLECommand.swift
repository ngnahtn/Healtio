//
//  BLECommand.swift
//  1SKConnect
//
//  Created by tuyenvx on 23/03/2021.
//

import Foundation

protocol BLECommand {
    var bytes: [UInt8] { get }
}

extension BLECommand {
    func getData() -> Data {
        return Data(bytes)
    }
}
