//
//  BaseModel.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import Foundation

class BaseModel<T: Codable>: Codable {
    
    enum CodingKeys: String, CodingKey {
        case data
        case meta
    }
    
    var data: T?
    var meta: Meta?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent(T.self, forKey: .data)
        meta = try container.decodeIfPresent(Meta.self, forKey: .meta)
    }
    
}

class Meta: Codable {
    enum CodingKeys: String, CodingKey {
        case code
        case message
    }
    
    var code: Int?
    var message: String?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decodeIfPresent(Int.self, forKey: .code)
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
    
}
