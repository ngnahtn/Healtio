//
//  CGFloat+Extension.swift
//  1SKConnect
//
//  Created by Be More on 08/09/2021.
//

import Foundation

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
