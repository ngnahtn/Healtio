//
//  Formatter+Extension.swift
//  1SKConnect
//
//  Created by TrungDN on 31/12/2021.
//

import Foundation

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()
}
