//
//  S5GoalVDataSource.swift
//  1SKConnect
//
//  Created by admin on 08/02/2022.
//

import Foundation

struct S5GoalDataSource {
    var value: Int
    var title: String
    
    init(value: Int) {
        self.value = value
        if value == 0 {
            self.title = "Huỷ mục tiêu"
        } else {
            self.title = value.stringValue
        }
    }
}
