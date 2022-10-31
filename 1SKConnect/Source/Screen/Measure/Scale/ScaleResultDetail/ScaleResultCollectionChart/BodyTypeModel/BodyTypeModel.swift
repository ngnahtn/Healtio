//
//  BodyTypeModel.swift
//  1SKConnect
//
//  Created by Elcom Corp on 05/11/2021.
//

import Foundation

class BodyTypeModel {
    var title: String
    var bodyType: BodyType
    var isSelected = false

    init(title: String, bodyType: BodyType) {
        self.title = title
        self.bodyType = bodyType
    }
}
