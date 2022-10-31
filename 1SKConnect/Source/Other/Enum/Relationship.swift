//
//  Relationship.swift
//  1SKConnect
//
//  Created by tuyenvx on 30/03/2021.
//

import Foundation
import RealmSwift

enum Relationship: Int, Codable, RealmEnum, CaseIterable {
    case yourSelf = 0
    case wife
    case husband
    case daughter
    case son
    case father
    case mother
    case other

    func getName() -> String {
        switch self {
        case .yourSelf:
            return L.yourself.localized
        case .father:
            return L.father.localized
        case .mother:
            return L.mother.localized
        case .wife:
            return L.wife.localized
        case .husband:
            return L.husband.localized
        case .daughter:
            return L.daughter.localized
        case .son:
            return L.son.localized
        case .other:
            return L.other.localized
        }
    }

    static func getItems(with gender: Gender, userGender: Gender?) -> [Relationship] {
        switch (gender, userGender) {
        case (.male, .male):
            return [.son, .father, .other]
        case (.male, _):
            return [.husband, .son, .father, .other]
        case (.female, .female):
            return [.daughter, .mother, .other]
        case (.female, _):
            return [.wife, .daughter, .mother, .other]
        }
    }
}
