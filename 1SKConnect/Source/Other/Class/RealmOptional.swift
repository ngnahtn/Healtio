//
//  RealmOptional.swift
//  1SKConnect
//
//  Created by tuyenvx on 30/03/2021.
//

import Foundation
import RealmSwift

class RealmIntOptional: Object, Codable {
    private var numeric = RealmOptional<Int>()

    required public convenience init(from decoder: Decoder) throws {
        self.init()

        let singleValueContainer = try decoder.singleValueContainer()
        if singleValueContainer.decodeNil() == false {
            let value = try singleValueContainer.decode(Int.self)
            numeric = RealmOptional(value)
        }
    }

    var value: Int? {
        get {
            return numeric.value
        }

        set {
            numeric.value = newValue
        }
    }
}

class RealmDoubleOptional: Object, Codable {
    private var numeric = RealmOptional<Double>()

    required public convenience init(from decoder: Decoder) throws {
        self.init()

        let singleValueContainer = try decoder.singleValueContainer()
        if singleValueContainer.decodeNil() == false {
            let value = try singleValueContainer.decode(Double.self)
            numeric = RealmOptional(value)
        }
    }

    override init() {
        super.init()
    }

    init(number: Double) {
        super.init()
        self.value = number
    }

    var value: Double? {
        get {
            return numeric.value
        }
        set {
            numeric.value = value
        }
    }

    static func isEqual(_ lhs: RealmDoubleOptional?, _ rhs: RealmDoubleOptional?) -> Bool {
        return Double.equal(lhs?.numeric.value ?? 0, rhs?.numeric.value ?? 0)
    }
}
