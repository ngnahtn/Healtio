//
//  ApiUrlProtocol.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import Foundation

protocol ApiUrlProtocol {
    var path: String { get }
    var fullURLString: String { get }
    var url: URL! { get }
}

extension ApiUrlProtocol {
    var fullURLString: String {
        return "\(Constant.API.baseURL)/\(Constant.API.version)/\(path)"
    }

    var url: URL! {
        return URL(string: fullURLString)
    }
}
