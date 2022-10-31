//
//  APIError.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import Foundation

struct APIError: Error, Codable, CustomStringConvertible {
    var message: String
    var statusCode: Int

    init(message: String, statusCode: Int) {
        self.message = message
        self.statusCode = statusCode
    }

    var description: String {
        return "APIError code: \(statusCode), message: \(message)"
    }
}
