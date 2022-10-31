//
//  Xib+Localization.swift
//  1SKConnect
//
//  Created by tuyenvx on 15/04/2021.
//

import Foundation
import UIKit

protocol Localizable {
    var localized: String { get }
    func localized(with argements: CVarArg...) -> String
}

extension String: Localizable {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        return String.localizedStringWithFormat(self.localized, arguments)
    }
}

protocol XIBLocalizable {
    var xibLocalizeKey: String? { get set }
}

extension UILabel: XIBLocalizable {
    @IBInspectable var xibLocalizeKey: String? {
        get { return nil}
        set {
            text = newValue?.localized
        }
    }
}

extension UIButton: XIBLocalizable {
    @IBInspectable var xibLocalizeKey: String? {
        get { return nil }
        set {
            setTitle(newValue?.localized, for: .normal)
        }
    }
}
