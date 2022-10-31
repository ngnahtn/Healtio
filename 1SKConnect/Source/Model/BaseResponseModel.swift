//
//  BaseResponseModel.swift
//  1SKConnect
//
//  Created by TrungDN on 30/11/2021.
//

import Foundation
import SwiftyJSON

class BaseResponseModel {

    var meta: MetaModel?

    init(_ json: JSON) {
        meta = MetaModel(json["meta"])
    }

}

class MetaModel {
    var code: Int
    var message: String
    var total: Int

    init(_ json: JSON) {
        total = json["total"].intValue
        code = json["code"].intValue
        message = json["message"].stringValue
    }
}
