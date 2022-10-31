//
//  StringProtocol+Extension.swift
//  1SKConnect
//
//  Created by Be More on 10/09/2021.
//

import Foundation

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.every(n: n).dropFirst().reversed() {
            insert(contentsOf: separator, at: index)
        }
    }
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        .init(unfoldSubSequences(limitedTo: n).joined(separator: separator))
    }
}
