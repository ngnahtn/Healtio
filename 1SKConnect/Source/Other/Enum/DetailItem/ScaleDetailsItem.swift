//
//  ScaleDetailsItem.swift
//  1SKConnect
//
//  Created by Elcom Corp on 15/11/2021.
//

import UIKit
import RealmSwift

// MARK: - BMI
enum Bmi: DetailsItemProtocol {
    case underWeight(Double)
    case normal(Double)
    case overWeight(Double)
    case fat(Double)

    init(bmi: Double) {
        if bmi < 18.5 {
            self = .underWeight(bmi)
        } else if bmi < 25 {
            self = .normal(bmi)
        } else if bmi < 30 {
            self = .overWeight(bmi)
        } else {
            self = .fat(bmi)
        }
    }

    var title: String? {
        return L.bmi.localized
    }

    var navigationTitle: String {
        return R.string.localizable.scale_result_detail_bmi()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_bmi_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.none.desciption
    }

    var status: String? {
        switch self {
        case .underWeight:
            return L.thin.localized
        case .normal:
            return R.string.localizable.scale_result_standar_description()
        case .overWeight:
            return L.overWeight.localized
        case .fat:
            return L.overWeightLevel1.localized
        }
    }

    var statusCode: String? {
        switch self {
        case .underWeight:
            return StatusCode.UNDER_WEIGHT.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .overWeight:
            return StatusCode.OVER_WEIGHT.rawValue
        case .fat:
            return StatusCode.FAT.rawValue
        }
    }

    var color: UIColor? {
        switch self {
        case .underWeight:
            return R.color.thin()
        case .normal:
            return R.color.standard()
        case .overWeight:
            return R.color.overweight()
        case .fat:
            return R.color.overweight1()
        }
    }

    var maxValue: Double {
        return 35
    }

    var minValue: Double {
        return 13.5
    }

    var valueScale: [Double] {
        return [18.5, 25, 30]
    }

    var descriptionSacle: [String] {
        return [R.string.localizable.thin(), R.string.localizable.scale_result_standar_description(), R.string.localizable.overWeight(), R.string.localizable.overWeightLevel1()]
    }

}

// MARK: - BMR
enum Bmr: DetailsItemProtocol {
    case low(Double)
    case normal(Double)
    case high(Double)

    init(value: Double) {
        if value < 1352 {
            self = .low(value)
        } else if value < 1953 {
            self = .normal(value)
        } else {
            self = .high(value)
        }
    }

    var navigationTitle: String {
         return R.string.localizable.scale_result_detail_bmr()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_bmr_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.kcal.desciption
    }

    init(code: String, value: Double) {
        switch code {
        case StatusCode.LOW.rawValue:
            self = .low(value)
        case StatusCode.NORMAL.rawValue:
            self = .normal(value)
        case StatusCode.HIGHT.rawValue:
            self = .high(value)
        default:
            self = .high(value)
        }
    }

    var title: String? {
        return L.bmr.localized
    }

    var status: String? {
        switch self {
        case .low:
            return L.low.localized
        case .normal:
            return R.string.localizable.scale_result_optimal_description()
        case .high:
            return L.high.localized
        }
    }

    var statusCode: String? {
        switch self {
        case .low:
            return StatusCode.LOW.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .high:
            return StatusCode.HIGHT.rawValue
        }
    }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.thin()
        case .normal:
            return R.color.standard()
        case .high:
            return R.color.red()
        }
    }

    var maxValue: Double {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return 0
        }
        let age = currentProfile.birthday?.toDate(.ymd)?.age() ?? 0
        if age <= 29 {
            return (currentProfile.gender.value == .male ? Double(1520) : Double(1110)) * 2
        } else if age >= 30 && age <= 39 {
            return (currentProfile.gender.value == .male ? Double(1530) : Double(1150)) * 2
        } else if age >= 40 && age <= 69 {
            return (currentProfile.gender.value == .male ? Double(1400) : Double(1100)) * 2
        } else {
            return (currentProfile.gender.value == .male ? Double(1290) : Double(1020)) * 2
        }
    }

    var minValue: Double {
        return 0
    }

    var valueScale: [Double] {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return []
        }
        let age = currentProfile.birthday?.toDate(.ymd)?.age() ?? 0
        if age <= 29 {
            return currentProfile.gender.value == .male ? [1520] : [1110]
        } else if age >= 30 && age <= 39 {
            return currentProfile.gender.value == .male ? [1530] : [1150]
        } else if age >= 40 && age <= 69 {
            return currentProfile.gender.value == .male ? [1400] : [1100]
        } else {
            return currentProfile.gender.value == .male ? [1290] : [1020]
        }
    }

    var descriptionSacle: [String] {
        return [R.string.localizable.low(), R.string.localizable.scale_result_optimal_description()]
    }
}

// MARK: - Muscle
enum Muscle: DetailsItemProtocol {

    case low(Double)
    case medium(Double)
    case high(Double)

    init(muscle: Double) {
        if muscle < -2 {
            self = .low(muscle)
        } else if muscle < 1 {
            self = .medium(muscle)
        } else {
            self = .high(muscle)
        }
    }

    init(code: String, value: Double) {
        switch code {
        case StatusCode.LOW.rawValue:
            self = .low(value)
        case StatusCode.NORMAL.rawValue:
            self = .medium(value)
        case StatusCode.HIGHT.rawValue:
            self = .high(value)
        default:
            self = .high(value)
        }
    }

    var title: String? {
        return L.muscle.localized
    }

    var navigationTitle: String {
        return R.string.localizable.scale_result_detail_muscle()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_muscle_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.weight.desciption
    }

    var status: String? {
        switch self {
        case .low:
            return L.low.localized
        case .medium:
            return R.string.localizable.scale_result_standar_description()
        case .high:
            return R.string.localizable.scale_result_find_description()
        }
    }

    var statusCode: String? {
        switch self {
        case .low:
            return StatusCode.LOW.rawValue
        case .medium:
            return StatusCode.NORMAL.rawValue
        case .high:
            return StatusCode.HIGHT.rawValue
        }
    }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.thin()
        case .medium:
            return R.color.standard()
        case .high:
            return R.color.good()
        }
    }

    var maxValue: Double {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return 0
        }
        return currentProfile.gender.value == .male ? 70 : 50
    }

    var minValue: Double {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return 0
        }
        return currentProfile.gender.value == .male ? 22 : 17
    }

    var valueScale: [Double] {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return []
        }
        return currentProfile.gender.value == .male ? [38, 54] : [28, 39]
    }

    var descriptionSacle: [String] {
        return [L.low.localized, R.string.localizable.scale_result_standar_description(), R.string.localizable.scale_result_find_description()]
    }
}

// MARK: - Bone Mask
enum BoneMass: DetailsItemProtocol {
    case low(Double)
    case normal(Double)
    case hight(Double)

    var title: String? {
        return L.bone.localized
    }

    var navigationTitle: String {
        return R.string.localizable.scale_result_detail_bone()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_bone_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.weight.desciption
    }

    var statusCode: String? {
        switch self {
        case .low:
            return StatusCode.LOW.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .hight:
            return StatusCode.HIGHT.rawValue
        }
    }

    var status: String? {
        switch self {
        case .low:
            return L.low.localized
        case .normal:
            return R.string.localizable.scale_result_standar_description()
        case .hight:
            return R.string.localizable.scale_result_find_description()
        }
    }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.thin()
        case .normal:
            return R.color.standard()
        case .hight:
            return R.color.good()
        }
    }

    init(code: String, value: Double) {
        switch code {
        case StatusCode.LOW.rawValue:
            self = .low(value)
        case StatusCode.NORMAL.rawValue:
            self = .normal(value)
        case StatusCode.HIGHT.rawValue:
            self = .hight(value)
        default:
            self = .hight(value)
        }
    }

    var maxValue: Double {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return 0
        }
        return currentProfile.gender.value == .male ? 3.2 : 2.5
    }

    var minValue: Double {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return 0
        }
        return currentProfile.gender.value == .male ? 2.5 : 1.8
    }

    var valueScale: [Double] {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return []
        }
        return currentProfile.gender.value == .male ? [2.9] : [2.2]
    }

    var descriptionSacle: [String] {
        return [L.low.localized, R.string.localizable.scale_result_standar_description(), R.string.localizable.scale_result_find_description()]
    }
}

// MARK: - Water
enum Water: DetailsItemProtocol {
    case low(Double)
    case normal(Double)
    case high(Double)

    init(value: Double) {
        if value < 53 {
            self = .low(value)
        } else if value < 67 {
            self = .normal(value)
        } else {
            self = .high(value)
        }
    }

    var title: String? {
        return L.water.localized
    }

    var navigationTitle: String {
        return R.string.localizable.scale_result_detail_water()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_water_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.percentage.desciption
    }

    var status: String? {
        switch self {
        case .low:
            return L.low.localized
        case .normal:
            return R.string.localizable.scale_result_standar_description()
        case .high:
            return R.string.localizable.scale_result_find_description()
        }
    }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.thin()
        case .normal:
            return R.color.standard()
        case .high:
            return R.color.good()
        }
    }

    var statusCode: String? {
        switch self {
        case .low:
            return StatusCode.LOW.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .high:
            return StatusCode.HIGHT.rawValue
        }
    }

    var maxValue: Double {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return 0
        }
        let age = currentProfile.birthday?.toDate(.ymd)?.age() ?? 0
        if age <= 18 {
            return 81
        } else if age >= 19 && age <= 45 {
            return 80
        } else {
            return 75
        }
    }

    var minValue: Double {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return 0
        }
        let age = currentProfile.birthday?.toDate(.ymd)?.age() ?? 0
        if age <= 18 {
            return 72
        } else if age >= 19 && age <= 45 {
            return 35
        } else {
            return 0
        }
    }

    var valueScale: [Double] {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return []
        }
        let age = currentProfile.birthday?.toDate(.ymd)?.age() ?? 0
        if age <= 18 {
            return [75, 78]
        } else if age >= 19 && age <= 45 {
            return [50, 65]
        } else {
            return [25, 50]
        }
    }

    var descriptionSacle: [String] {
        return [L.low.localized, R.string.localizable.scale_result_standar_description(), R.string.localizable.scale_result_find_description()]
    }
}

// MARK: - Protein
enum Protein: DetailsItemProtocol {
    case low(Double)
    case normal(Double)
    case high(Double)

    init(value: Double) {
        if value < 16 {
            self = .low(value)
        } else if value < 18 {
            self = .normal(value)
        } else {
            self = .high(value)
        }
    }

    var title: String? {
        return L.protein.localized
    }

    var navigationTitle: String {
        return R.string.localizable.scale_result_detail_protein()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_protein_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.percentage.desciption
    }

    var status: String? {
        switch self {
        case .low:
            return L.low.localized
        case .normal:
            return R.string.localizable.scale_result_standar_description()
        case .high:
            return R.string.localizable.high()
        }
    }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.thin()
        case .normal:
            return R.color.standard()
        case .high:
            return R.color.high()
        }
    }

    var statusCode: String? {
        switch self {
        case .low:
            return StatusCode.LOW.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .high:
            return StatusCode.HIGHT.rawValue
        }
    }

    var maxValue: Double {
        return 24
    }

    var minValue: Double {
        return 12
    }

    var valueScale: [Double] {
        return [16, 20]
    }

    var descriptionSacle: [String] {
        return [R.string.localizable.low(), R.string.localizable.scale_result_standar_description(), R.string.localizable.high()]
    }
}

// MARK: - Fat
enum Fat: DetailsItemProtocol {

    case thin(Double)
    case normal(Double)
    case fat(Double)

    init(fat: Double) {
        if fat < 18 {
            self = .thin(fat)
        } else if fat < 28 {
            self = .normal(fat)
        } else {
            self = .fat(fat)
        }
    }

    init(code: String, value: Double) {
        switch code {
        case StatusCode.THIN.rawValue:
            self = .thin(value)
        case StatusCode.NORMAL.rawValue:
            self = .normal(value)
        case StatusCode.FAT.rawValue:
            self = .fat(value)
        default:
            self = .fat(value)
        }
    }

    var title: String? {
        return L.fatPercent.localized
    }

    var navigationTitle: String {
        return R.string.localizable.scale_result_detail_fat()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_fat_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.percentage.desciption
    }

    var status: String? {
        switch self {
        case .thin:
            return L.low.localized
        case .normal:
            return R.string.localizable.scale_result_healthy_description()
        case .fat:
            return L.high.localized
        }
    }

    var statusCode: String? {
        switch self {
        case .thin:
            return StatusCode.THIN.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .fat:
            return StatusCode.FAT.rawValue
        }
    }

    var color: UIColor? {
        switch self {
        case .thin:
            return R.color.overweight()
        case .normal:
            return R.color.standard()
        case .fat:
            return R.color.overweight2()
        }
    }

    var maxValue: Double {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return 0
        }
        let age = currentProfile.birthday?.toDate(.ymd)?.age() ?? 0
        if age <= 39 {
            return currentProfile.gender.value == .male ? 30 : 43
        } else if age >= 40 && age <= 59 {
            return currentProfile.gender.value == .male ? 31 : 43
        } else {
            return currentProfile.gender.value == .male ? 35 : 46
        }
    }

    var minValue: Double {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return 0
        }
        let age = currentProfile.birthday?.toDate(.ymd)?.age() ?? 0
        if age <= 39 {
            return currentProfile.gender.value == .male ? 0 : 10
        } else if age >= 40 && age <= 59 {
            return currentProfile.gender.value == .male ? 0 : 13
        } else {
            return currentProfile.gender.value == .male ? 2 : 13
        }

    }

    var valueScale: [Double] {
        guard let currentProfile = GenericDAO<ProfileListModel>().getFirstObject()?.currentProfile else {
            return []
        }
        let age = currentProfile.birthday?.toDate(.ymd)?.age() ?? 0
        if age <= 39 {
            return currentProfile.gender.value == .male ? [8, 19] : [21, 32]
        } else if age >= 40 && age <= 59 {
            return currentProfile.gender.value == .male ? [11, 21] : [23, 33]
        } else {
            return currentProfile.gender.value == .male ? [13, 24] : [24, 35]
        }
    }

    var descriptionSacle: [String] {
        return [L.low.localized, R.string.localizable.scale_result_standar_description(), R.string.localizable.high()]
    }
}

// MARK: ObesityLevel
enum Obesity: DetailsItemProtocol {

    case underWeight(Double)
    case normal(Double)
    case overWeight(Double)
    case fat1(Double)
    case fat2(Double)
    case fat3(Double)

    init(value: Double) {
        if value < 18.5 {
            self = .underWeight(value)
        } else if value < 25 {
            self = .normal(value)
        } else if value < 30 {
            self = .overWeight(value)
        } else if value < 35 {
            self = .fat1(value)
        } else if value < 40 {
            self = .fat2(value)
        } else {
            self = .fat3(value)
        }
    }

    var title: String? {
        return L.obesityLevel.localized
    }

    var navigationTitle: String {
        return R.string.localizable.obesityLevel()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_obesity_level_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.none.desciption
    }

    var status: String? {
        switch self {
        case .underWeight:
            return L.thin.localized
        case .normal:
            return R.string.localizable.scale_result_standar_description()
        case .overWeight:
            return L.overWeight.localized
        case .fat1:
            return L.overWeightLevel1.localized
        case .fat2:
            return L.overWeightLevel2.localized
        case .fat3:
            return L.overWeightLevel3.localized
        }
    }

    var statusCode: String? {
        switch self {
        case .underWeight:
            return StatusCode.UNDER_WEIGHT.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .overWeight:
            return StatusCode.OVER_WEIGHT.rawValue
        case .fat1:
            return StatusCode.FAT_1.rawValue
        case .fat2:
            return StatusCode.FAT_2.rawValue
        case .fat3:
            return StatusCode.FAT_3.rawValue
        }
    }

    var color: UIColor? {
        switch self {
        case .underWeight:
            return R.color.thin()
        case .normal:
            return R.color.standard()
        case .overWeight:
            return R.color.overweight()
        case .fat1:
            return R.color.overweight1()
        case .fat2:
            return R.color.overweight2()
        case .fat3:
            return R.color.red()
        }
    }

    var maxValue: Double {
        return 40
    }

    var minValue: Double {
        return 13.5
    }

    var valueScale: [Double] {
        return [18.5, 25, 30, 35]
    }

    var descriptionSacle: [String] {
        return [R.string.localizable.thin(), R.string.localizable.scale_result_standar_description(), R.string.localizable.overWeight(), R.string.localizable.overWeightLevel1(), R.string.localizable.overWeightLevel2()]
    }
}

// MARK: - V-fat
enum VFat: DetailsItemProtocol {

    case healthy(Double)
    case dangerous(Double)
    case veryDangerous(Double)

    init(vFat: Double) {
        if vFat < 10 {
            self = .healthy(vFat)
        } else if vFat < 15 {
            self = .dangerous(vFat)
        } else {
            self = .veryDangerous(vFat)
        }
    }

    var title: String? {
        return L.visceralFat.localized
    }

    var navigationTitle: String {
        return L.visceralFat.localized
    }

    var description: String {
        return R.string.localizable.scale_result_detail_visceral_fat_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.none.desciption
    }

    var status: String? {
        switch self {
        case .healthy:
            return L.healthy.localized
        case .dangerous:
            return L.dangerous.localized
        case .veryDangerous:
            return L.veryDangerous.localized
        }
    }

    var statusCode: String? {
        switch self {
        case .healthy:
            return StatusCode.HEALTHY.rawValue
        case .dangerous:
            return StatusCode.DANGEROUS.rawValue
        case .veryDangerous:
            return StatusCode.VERY_DANGEROUS.rawValue
        }
    }

    var color: UIColor? {
        switch self {
        case .healthy:
            return R.color.standard()
        case .dangerous:
            return R.color.overweight1()
        case .veryDangerous:
            return R.color.overweight2()
        }
    }

    var maxValue: Double {
        return 20
    }

    var minValue: Double {
        return 5
    }

    var valueScale: [Double] {
        return [10, 15]
    }

    var descriptionSacle: [String] {
        return [R.string.localizable.healthy(), R.string.localizable.dangerous(), R.string.localizable.veryDangerous()]
    }
}

// MARK: - SubcutaneousFat
enum SubcutaneousFat: DetailsItemProtocol {
    case low(Double)
    case normal(Double)
    case high(Double)
    case veryHigh(Double)

    var navigationTitle: String {
        return R.string.localizable.detail_measurement_subcutaneous_fat()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_subcutaneous_fat_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.percentage.desciption
    }

    init(code: String, value: Double) {
        switch code {
        case StatusCode.LOW.rawValue:
            self = .low(value)
        case StatusCode.NORMAL.rawValue:
            self = .normal(value)
        case StatusCode.HIGHT.rawValue:
            self = .high(value)
        case StatusCode.VERY_HIGHT.rawValue:
            self = .veryHigh(value)
        default:
            self = .veryHigh(value)
        }
    }

    var title: String? {
        return L.subcutaneousFat.localized
    }

    var status: String? {
        switch self {
        case .low:
            return L.low.localized
        case .normal:
            return R.string.localizable.scale_result_standar_description()
        case .high:
            return L.high.localized
        case .veryHigh:
            return L.veryHigh.localized
        }
    }

    var statusCode: String? {
        switch self {
        case .low:
            return StatusCode.LOW.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .high:
            return StatusCode.HIGHT.rawValue
        case .veryHigh:
            return StatusCode.VERY_HIGHT.rawValue
        }
    }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.thin()
        case .normal:
            return R.color.standard()
        case .high:
            return R.color.overweight1()
        case .veryHigh:
            return R.color.overweight2()
        }
    }

    var maxValue: Double {
        return 28
    }

    var minValue: Double {
        return 0
    }

    var valueScale: [Double] {
        return [8.6, 16.7, 20.7]
    }

    var descriptionSacle: [String] {
        return [L.low.localized, R.string.localizable.scale_result_standar_description(), R.string.localizable.high(), R.string.localizable.veryHigh()]
    }
}

// MARK: LBM
enum Lbm: DetailsItemProtocol {
    case low(Double)
    case normal(Double)
    case high(Double)

    init(value: Double) {
        if value < 0 {
            self = .low(value)
        } else if value < 0 {
            self = .normal(value)
        } else {
            self = .high(value)
        }
    }

    var title: String? {
        return L.bodyShape.localized
    }

    var navigationTitle: String {
         return ""
    }

    var description: String {
        return ""
    }

    var unit: String {
        return WeightDetailMeasureUnit.none.desciption
    }

    var status: String? {
        switch self {
        case .low:
            return L.low.localized
        case .normal:
            return L.normal.localized
        case .high:
            return L.high.localized
        }
    }

    var statusCode: String? {
        switch self {
        case .low:
            return StatusCode.LOW.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .high:
            return StatusCode.HIGHT.rawValue
        }
    }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.yellow()
        case .normal:
            return R.color.blue()
        case .high:
            return R.color.red()
        }
    }

    var maxValue: Double {
        return 0
    }

    var minValue: Double {
        return 0
    }

    var valueScale: [Double] {
        return []
    }

    var descriptionSacle: [String] {
        return []
    }
}

// MARK: BodyAge
enum BodyAge: DetailsItemProtocol {
    case low(Double)
    case normal(Double)
    case high(Double)

    init(value: Double) {
        if value < 32 {
            self = .low(value)
        } else if value < 48 {
            self = .normal(value)
        } else {
            self = .high(value)
        }
    }

    var title: String? {
        return L.bodyAge.localized
    }

    var navigationTitle: String {
         return L.bodyAge.localized
    }

    var description: String {
        return ""
    }

    var unit: String {
        return WeightDetailMeasureUnit.none.desciption
    }

    var status: String? {
        switch self {
        case .low:
            return L.low.localized
        case .normal:
            return L.normal.localized
        case .high:
            return L.high.localized
        }
    }

    var statusCode: String? {
        switch self {
        case .low:
            return StatusCode.LOW.rawValue
        case .normal:
            return StatusCode.NORMAL.rawValue
        case .high:
            return StatusCode.HIGHT.rawValue
        }
    }

    var color: UIColor? {
        switch self {
        case .low:
            return R.color.yellow()
        case .normal:
            return R.color.blue()
        case .high:
            return R.color.red()
        }
    }

    var maxValue: Double {
        return 0
    }

    var minValue: Double {
        return 0
    }

    var valueScale: [Double] {
        return []
    }

    var descriptionSacle: [String] {
        return []
    }
}

// MARK: - BodyType
enum BodyType: Int, RealmEnum, DetailsItemProtocol, CaseIterable {
    case thin
    case lThinMuscle
    case muscular
    case lackofexercise
    case standard
    case standardMuscle
    case obesFat
    case lFatMuscle
    case muscleFat

    var title: String? {
        return L.bodyShape.localized
    }

    var navigationTitle: String {
        return L.bodyShape.localized
    }

    var description: String {
        return R.string.localizable.scale_result_detail_body_shape_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.none.desciption
    }

    var status: String? {
        return ""
    }

    var color: UIColor? {
        return .clear
    }

    var value: Double {
        return self.rawValue.doubleValue
    }

    var stringValue: String {
        switch self {
        case .thin:
            return L.thin.localized
        case .lThinMuscle:
            return L.lThinMuscle.localized
        case .muscular:
            return L.muscular.localized
        case .lackofexercise:
            return L.lackofexercise.localized
        case .standard:
            return L.standard.localized
        case .standardMuscle:
            return L.standardMuscle.localized
        case .obesFat:
            return L.obesFat.localized
        case .lFatMuscle:
            return L.lFatMuscle.localized
        case .muscleFat:
            return L.muscleFat.localized
        }
    }

    var statusCode: String? {
        switch self {
        case .thin:
            return StatusCode.THIN.rawValue
        case .lThinMuscle:
            return StatusCode.THIN_MUSCLE.rawValue
        case .muscular:
            return StatusCode.MUSCULAR.rawValue
        case .lackofexercise:
            return StatusCode.LACK_OF_EXERCISE.rawValue
        case .standard:
            return StatusCode.STANDARD.rawValue
        case .standardMuscle:
            return StatusCode.STANDARD_MUSCLE.rawValue
        case .obesFat:
            return StatusCode.OBES_FAT.rawValue
        case .lFatMuscle:
            return StatusCode.FAT_MUSCLE.rawValue
        case .muscleFat:
            return StatusCode.MUSCLE_FAT.rawValue
        }
    }

    init(code: String) {
        switch code {
        case "THIN":
            self = .thin
        case "THIN_MUSCLE":
            self = .lThinMuscle
        case "MUSCULAR":
            self = .muscular
        case "LACK_OF_EXERCISE":
            self = .lackofexercise
        case "STANDARD":
            self = .standard
        case "STANDARD_MUSCLE":
            self = .standardMuscle
        case "OBES_FAT":
            self = .obesFat
        case "FAT_MUSCLE":
            self = .lFatMuscle
        case "MUSCLE_FAT":
            self = .muscleFat
        default:
            self = .thin
        }
    }

    var maxValue: Double {
        return 0
    }

    var minValue: Double {
        return 0
    }

    var valueScale: [Double] {
        return []
    }

    var descriptionSacle: [String] {
        return []
    }

}
// MARK: - BodyStandard
struct BodyStandard: DetailsItemProtocol {
    var statusCode: String? = ""
    let status: String? = ""
    var value: Double
    let color: UIColor? = .clear
    var title: String? = L.bodyStandard.localized
    var navigationTitle: String {
        return R.string.localizable.detail_measurement_ideal()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_ideal_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.weight.desciption
    }

    init(value: Double) {
        self.value = value
    }

    var maxValue: Double {
        return 0
    }

    var minValue: Double {
        return 0
    }

    var valueScale: [Double] {
        return []
    }

    var descriptionSacle: [String] {
        return []
    }

}

// MARK: - LBW
struct LBW: DetailsItemProtocol {
    var statusCode: String? = ""
    let status: String? = ""
    var value: Double
    let color: UIColor? = .clear
    var title: String? = L.lbw.localized

    var navigationTitle: String {
        return R.string.localizable.scale_result_detail_lbw()
    }

    var description: String {
        return R.string.localizable.scale_result_detail_lbw_description()
    }

    var unit: String {
        return WeightDetailMeasureUnit.weight.desciption
    }

    init(value: Double) {
        self.value = value
    }

    var maxValue: Double {
        return 0
    }

    var minValue: Double {
        return 0
    }

    var valueScale: [Double] {
        return []
    }

    var descriptionSacle: [String] {
        return []
    }

}
