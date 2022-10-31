//
//  BaseResponse.swift
//  1SKConnect
//
//  Created by Be More on 24/08/2021.
//

import Foundation
import SwiftyJSON

class BaseResponse {
    var status: Int = 0
    var message: String = ""
    var total: Int = 0

    init(_ json: JSON) {
        self.status = json["status"].intValue
        self.message = json["message"].stringValue
        self.total = json["total"].intValue
    }
}
