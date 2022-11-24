//
//  Sequence+Extension.swift
//  1SKConnect
//
//  Created by Be More on 24/08/2021.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniquedElement() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
