//
//  DetailsItemProtocol.swift
//  1SKConnect
//
//  Created by Be More on 12/11/2021.
//

import UIKit
import RealmSwift

protocol DetailsItemProtocol {
    var title: String? { get }
    var navigationTitle: String { get }
    var description: String { get }
    var unit: String { get }
    var status: String? { get }
    var statusCode: String? { get }
    var color: UIColor? { get }
    var value: Double { get }
    var maxValue: Double { get }
    var minValue: Double { get }
    var valueScale: [Double] { get }
    var descriptionSacle: [String] { get }
}

extension DetailsItemProtocol {
    var value: Double {
        let mirror = Mirror(reflecting: self)
        if let associatedValue = mirror.children.first?.value as? Double {
            return associatedValue
        }
        return 0
    }
}
