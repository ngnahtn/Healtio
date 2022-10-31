//
//  Encodable+Extension.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import Foundation

extension Encodable {
    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let `data` = try? encoder.encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8) ?? nil
    }
}
