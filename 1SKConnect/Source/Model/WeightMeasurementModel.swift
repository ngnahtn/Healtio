//
//  WeightMeasurementModel.swift
//  1SKConnect
//
//  Created by Be More on 04/08/2021.
//

import Foundation

class WeightMeasurementModel {

    private var weightPoints = [Double]()
    private var musclePoints = [Double]()
    private var bonePoints = [Double]()
    private var idealWeightPoint = [Double]()

    private var waterPoints = [Double]()
    private var proteinPoints = [Double]()
    private var fatPoints = [Double]()
    private var subcutaneousFatPoints = [Double]()

    var weightValue: WeightMeasurementValue {
        return WeightMeasurementValue(title: R.string.localizable.detail_measurement_weight(), points: self.weightPoints, measurentType: .mass, measuremntData: .weightPoints)
    }

    var muscleValue: WeightMeasurementValue {
        return WeightMeasurementValue(title: R.string.localizable.detail_measurement_muscle(), points: self.musclePoints, measurentType: .mass, measuremntData: .musclePoints)
    }

    var boneValue: WeightMeasurementValue {
        return WeightMeasurementValue(title: R.string.localizable.detail_measurement_bone(), points: self.bonePoints, measurentType: .mass, measuremntData: .bonePoints)
    }

    var idealWeightValue: WeightMeasurementValue {
        return WeightMeasurementValue(title: R.string.localizable.detail_measurement_ideal(), points: self.idealWeightPoint, measurentType: .mass, measuremntData: .idealWeightPoint)
    }

    var waterValue: WeightMeasurementValue {
        return WeightMeasurementValue(title: R.string.localizable.detail_measurement_water(), points: self.waterPoints, measurentType: .percentage, measuremntData: .waterPoints)
    }

    var proteinValue: WeightMeasurementValue {
        return WeightMeasurementValue(title: R.string.localizable.detail_measurement_protein(), points: self.proteinPoints, measurentType: .percentage, measuremntData: .proteinPoints)
    }

    var fatValue: WeightMeasurementValue {
        return WeightMeasurementValue(title: R.string.localizable.detail_measurement_fat(), points: self.fatPoints, measurentType: .percentage, measuremntData: .fatPoints)
    }

    var subcutaneousFatValue: WeightMeasurementValue {
        return WeightMeasurementValue(title: R.string.localizable.detail_measurement_subcutaneous_fat(), points: self.subcutaneousFatPoints, measurentType: .percentage, measuremntData: .subcutaneousFatPoints)
    }

    convenience init() {
        self.init(with: [[]])
    }

    init(with data: [[BodyFat]]) {
        self.weightPoints = data.compactMap { [weak self] in
            guard let `self` = self else { return 0 }
            return self.getAvarageWeightPoint(of: $0)
        }
        self.musclePoints = data.compactMap { [weak self] in
            guard let `self` = self else { return 0  }
            return self.getAvarageMusclePoint(of: $0)
        }
        self.bonePoints = data.compactMap { [weak self] in
            guard let `self` = self else { return 0 }
            return self.getAvarageBonePoint(of: $0)
        }
        self.idealWeightPoint = data.compactMap { [weak self] in
            guard let `self` = self else { return 0 }
            return self.getAvarageIdealWeightPoint(of: $0)
        }
        self.waterPoints = data.compactMap { [weak self] in
            guard let `self` = self else { return 0 }
            return self.getAvarageWaterPoint(of: $0)
        }
        self.proteinPoints = data.compactMap { [weak self] in
            guard let `self` = self else { return 0 }
            return self.getAvarageProteinPoint(of: $0)
        }
        self.fatPoints = data.compactMap { [weak self] in
            guard let `self` = self else { return 0 }
            return self.getAvarageFatPoint(of: $0)
        }
        self.subcutaneousFatPoints = data.compactMap { [weak self] in
            guard let `self` = self else { return 0 }
            return self.getAvarageSubcutaneousFatPoint(of: $0)
        }
    }

    private func getAvarageWeightPoint(of bodyfats: [BodyFat]) -> Double {
        let points = bodyfats.compactMap({ $0.weight.value }).filter { $0 != 0 }
        let total = points.reduce(0, { $0 + $1 })
        return total / Double(points.count)
    }

    private func getAvarageMusclePoint(of bodyfats: [BodyFat]) -> Double {
        let points = bodyfats.compactMap({ $0.weightOfMuscle.value }).filter { $0 != 0 }
        let total = points.reduce(0, { $0 + $1 })
        return total / Double(points.count)
    }

    private func getAvarageBonePoint(of bodyfats: [BodyFat]) -> Double {
        let points = bodyfats.compactMap({ $0.weightOfBone.value }).filter { $0 != 0 }
        let total = points.reduce(0, { $0 + $1 })
        return total / Double(points.count)
    }

    private func getAvarageIdealWeightPoint(of bodyfats: [BodyFat]) -> Double {
        let points = bodyfats.compactMap({ $0.bodyStandard.value }).filter { $0 != 0 }
        let total = points.reduce(0, { $0 + $1 })
        return total / Double(points.count)
    }

    private func getAvarageWaterPoint(of bodyfats: [BodyFat]) -> Double {
        let points = bodyfats.compactMap({ $0.ratioOfWater.value }).filter { $0 != 0 }
        let total = points.reduce(0, { $0 + $1 })
        return total / Double(points.count)
    }

    private func getAvarageProteinPoint(of bodyfats: [BodyFat]) -> Double {
        let points = bodyfats.compactMap({ $0.ratioOfProtein.value }).filter { $0 != 0 }
        let total = points.reduce(0, { $0 + $1 })
        return total / Double(points.count)
    }

    private func getAvarageSubcutaneousFatPoint(of bodyfats: [BodyFat]) -> Double {
        let points = bodyfats.compactMap({ $0.ratioOfSubcutaneousFat.value }).filter { $0 != 0 }
        let total = points.reduce(0, { $0 + $1 })
        return total / Double(points.count)
    }

    private func getAvarageFatPoint(of bodyfats: [BodyFat]) -> Double {
        let points = bodyfats.compactMap({ $0.ratioOfFat.value}).filter { $0 != 0 }
        let total = points.reduce(0, { $0 + $1 })
        return total / Double(points.count)
    }
}

class WeightMeasurementValue {
    var points: [Double]
    var title: String
    var measurentType: MeasurementType
    var measuremntData: MeasurementData

    init(title: String, points: [Double], measurentType: MeasurementType, measuremntData: MeasurementData) {
        self.title = title
        self.points = points
        self.measurentType = measurentType
        self.measuremntData = measuremntData
    }
}
