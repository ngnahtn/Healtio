//
//  UIColor+Extention.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var rgbString = hex
        if rgbString.hasPrefix("#") {
            rgbString.removeFirst()
        }
        rgbString = rgbString.capitalized
        var rgb: UInt64 = 0
        Scanner(string: rgbString).scanHexInt64(&rgb)
        self.init(rgb: rgb, alpha: 1)
    }

    convenience init(hex: String, alpha: CGFloat) {
        var rgbString = hex
        if rgbString.hasPrefix("#") {
            rgbString.removeFirst()
        }
        var rgb: UInt64 = 0
        Scanner(string: rgbString).scanHexInt64(&rgb)
        self.init(rgb: rgb, alpha: alpha)
    }

    convenience init(rgb: UInt64, alpha: CGFloat) {
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgb & 0x0000FF) / 255.0,
                  alpha: alpha
        )
    }

    static func random() -> UIColor {
        return UIColor(
            red: .random(),
            green: .random(),
            blue: .random(),
            alpha: 1.0
        )
    }
}
