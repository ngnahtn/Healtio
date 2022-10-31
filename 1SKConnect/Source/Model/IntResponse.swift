//
//  IntResponse.swift
//  1SKConnect
//
//  Created by Be More on 24/08/2021.
//

import Foundation
import SwiftyJSON

class IntResponse: BaseResponseModel {
    var data: Int = 0

    override init(_ json: JSON) {
        super.init(json)
        let dataJson = json["data"]
        self.data = dataJson.intValue
    }
}
