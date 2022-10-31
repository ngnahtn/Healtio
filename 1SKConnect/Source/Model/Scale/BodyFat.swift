//
//  BodyFat.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//

import RealmSwift

class BodyFat: Object {
    let ageOfBody = RealmOptional<Double>()
    let ageOfBodyRange = List<Double>()
    let bmi = RealmOptional<Double>()
    let bmiRange = List<Double>()
    let bmiWHORange = List<Double>()
    let bmr = RealmOptional<Double>()
    let bmrRange = List<Double>()
    let bodyShape = RealmOptional<Double>()
    let desirableWeight = RealmOptional<Double>()
    let fatFreeBodyWeight = RealmOptional<Double>()
    let fatToControl = RealmOptional<Double>()
    let levelOfVisceralFat = RealmOptional<Double>()// Mỡ nội tạng
    let levelOfVisceralFatRange = List<Double>()
    let idealWeight = RealmOptional<Double>()
    let obesityLevel = RealmOptional<Double>()
    let rateOfBurnFatMax = RealmOptional<Double>()
    let rateOfBurnFatMin = RealmOptional<Double>()
    let ratioOfFat = RealmOptional<Double>()
    let ratioOfMuscle = RealmOptional<Double>()
    let ratioOfFatRange = List<Double>()
    let ratioOfWater = RealmOptional<Double>()
    let ratioOfWaterRange = List<Double>()
    let ratioOfProtein = RealmOptional<Double>()
    let ratioOfProteinRange = List<Double>()
    let ratioOfSubcutaneousFat = RealmOptional<Double>()
    let ratioOfSubcutaneousFatRange = List<Double>()
    let ratioOfSkeletaMuscle = RealmOptional<Double>()
    let ratioOfSkeletaMuscleRange = List<Double>()
    let rValue = RealmOptional<Double>()
    let weight = RealmOptional<Double>()
    let weightRange = List<Double>()
    let weightWHORange = List<Double>()
    let weightOfFat = RealmOptional<Double>()
    let weightOfFatRange = List<Double>()
    let weightOfMuscle = RealmOptional<Double>()
    let weithOfMuscleRange = List<Double>()
    let weightOfWater = RealmOptional<Double>()
    let weightOfWaterRange = List<Double>()
    let weightOfProtein = RealmOptional<Double>()
    let weightOfProteinRange = List<Double>()
    let weightOfBone = RealmOptional<Double>()
    let weightOfBoneRange = List<Double>()
    let weightOfSkeletalMuscle = RealmOptional<Double>()
    let weightOfSkeletalMuscleRange = List<Double>()
    let weightToControl = RealmOptional<Double>()
    let muscleToControl = RealmOptional<Double>()
    let stateOfNutrition = RealmOptional<Double>()
    let fatGrade = RealmOptional<Double>()
    let lbw = RealmOptional<Double>()
    let bodyStandard = RealmOptional<Double>()
    let bodyType = RealmOptional<BodyType>()
    let caloriesPerDay = RealmOptional<Double>()
    let ratioOfHipRange = List<Double>()
    let score = RealmOptional<Double>()
    let impedance = RealmOptional<Int>()

    @objc dynamic var scale: DeviceModel?
    @objc dynamic var profileID: String = ""
    @objc dynamic var createAt: String = ""
    @objc dynamic var timestamp: Double = 0

    @objc dynamic var isSync: Bool = false
    @objc dynamic var syncId: String = ""

    @objc dynamic var bmrStatus: String = ""
    @objc dynamic var weightOfMuscleStatus: String = ""
    @objc dynamic var weightOfBoneStatus: String = ""
    @objc dynamic var ratioOfFatStatus: String = ""
    @objc dynamic var subcutaneousFatStatus: String = ""

    var deviceMac: String? {
        return scale?.mac
    }

    var deviceName: String? {
        return scale?.name
    }

    var deviceImage: UIImage? {
        return scale?.image
    }

    var bmiEnum: Bmi? {
        guard let `bmi` = bmi.value else {
            return nil
        }
        return Bmi(bmi: bmi)
    }

    var items: [DetailsItemProtocol] {
        var items: [DetailsItemProtocol] = []
        if let `bmi` = bmi.value, bmi != 0 {
            items.append(Bmi(bmi: bmi))
        }

        if let `bmr` = bmr.value, bmr != 0 {
            if let value = bmrRange.array.first {
                if bmr >= value {
                    items.append(Bmr.normal(bmr))
                } else {
                    items.append(Bmr.low(bmr))
                }
            } else {
                if !String.isNilOrEmpty(self.bmrStatus) {
                    items.append(Bmr(code: self.bmrStatus, value: bmr))
                }
            }
        }

        if let `weightOfMuscle` = weightOfMuscle.value, weightOfMuscle != 0 {
            let range = weithOfMuscleRange.array
            if range.count == 2 {
                if weightOfMuscle < range[0] {
                    items.append(Muscle.low(weightOfMuscle))
                } else if weightOfMuscle >= range[1] {
                    items.append(Muscle.high(weightOfMuscle))
                } else {
                    items.append(Muscle.medium(weightOfMuscle))
                }
            } else {
                if !String.isNilOrEmpty(self.weightOfMuscleStatus) {
                    items.append(Muscle(code: self.weightOfMuscleStatus, value: weightOfMuscle))
                }
            }
        }

        if let `weightOfBone` = weightOfBone.value, weightOfBone != 0 {
            let range = weightOfBoneRange
            if range.count == 2 {
                if weightOfBone < range[0] {
                    items.append(BoneMass.low(weightOfBone))
                } else if weightOfBone >= range[1] {
                    items.append(BoneMass.hight(weightOfBone))
                } else {
                    items.append(BoneMass.normal(weightOfBone))
                }
            } else {
                if !String.isNilOrEmpty(self.weightOfBoneStatus) {
                    items.append(BoneMass(code: self.weightOfMuscleStatus, value: weightOfBone))
                }
            }
        }

        if let `ratioOfWater` = ratioOfWater.value, ratioOfWater != 0 {
            items.append(Water(value: ratioOfWater))
        }

        if let `ratioOfProtein` = ratioOfProtein.value, ratioOfProtein != 0 {
            items.append(Protein(value: ratioOfProtein))
        }

        if let `ratioOfFat` = ratioOfFat.value, ratioOfFat != 0 {
            let range = ratioOfFatRange
            if range.count == 4 {
                if ratioOfFat < range[0] {
                    items.append(Fat.thin(ratioOfFat))
                } else if ratioOfFat < range[1] {
                    items.append(Fat.normal(ratioOfFat))
                } else {
                    items.append(Fat.fat(ratioOfFat))
                }
            } else {
                if !String.isNilOrEmpty(self.ratioOfFatStatus) {
                    items.append(Fat(code: self.ratioOfFatStatus, value: ratioOfFat))
                }
            }
        }

        if let `obesityLevel` = obesityLevel.value, obesityLevel != 0 {
            items.append(Obesity(value: obesityLevel))
        }

        if let `levelOfVisceralFat` = levelOfVisceralFat.value, levelOfVisceralFat != 0 {
            items.append(VFat(vFat: levelOfVisceralFat))
        }

        if let `ratioOfSubcutaneousFat` = ratioOfSubcutaneousFat.value, ratioOfSubcutaneousFat != 0 {
            let range = ratioOfSubcutaneousFatRange
            if range.count == 3 {
                if ratioOfSubcutaneousFat < range[0] {
                    items.append(SubcutaneousFat.low(ratioOfSubcutaneousFat))
                } else if ratioOfSubcutaneousFat < range[1] {
                    items.append(SubcutaneousFat.normal(ratioOfSubcutaneousFat))
                } else if ratioOfSubcutaneousFat < range[2] {
                    items.append(SubcutaneousFat.high(ratioOfSubcutaneousFat))
                } else {
                    items.append(SubcutaneousFat.veryHigh(ratioOfSubcutaneousFat))
                }
            } else {
                if !String.isNilOrEmpty(self.subcutaneousFatStatus) {
                    items.append(SubcutaneousFat(code: self.subcutaneousFatStatus, value: `ratioOfSubcutaneousFat`))
                }
            }
        }

        if let `lbw` = lbw.value, lbw != 0 {
            items.append(LBW(value: lbw))
        }

        if let `bodyStandard` = bodyStandard.value, bodyStandard != 0 {
            items.append(BodyStandard(value: bodyStandard))
        }

        if let `bodyType` = bodyType.value {
            items.append(bodyType)
        }
//        if let `bodyShape` = bodyShape.value, bodyShape != 0 {
//            items.append(Lbm(value: bodyShape))
//        }
//        if let `ageOfBody` = ageOfBody.value, ageOfBody > 0 {
//            items.append(BodyAge(value: ageOfBody))
//        }
//        if let `caloriesPerDay` = caloriesPerDay.value, caloriesPerDay != 0 {
//            items.append(Calories(value: caloriesPerDay))
//        }
        return items
    }

    override init() {
        super.init()
    }

    init(scale: DeviceModel) {
        super.init()
        self.scale = scale
    }

    init(bodyFat: HTBodyfat_NewSDK, hasError: Bool, impedance: Int) {
        super.init()
        self.impedance.value = impedance
        self.weight.value = bodyFat.thtWeightKg.doubleValue
        self.bmi.value = bodyFat.thtBMI.doubleValue
        self.bmiRange.append(objectsIn: getRangeList(of: bodyFat.thtBMIRatingList))
        self.idealWeight.value = bodyFat.thtIdealWeightKg.doubleValue
        self.bodyStandard.value = bodyFat.thtBodystandard.doubleValue
        self.bmr.value = Double(bodyFat.thtBMR)
        self.bmrRange.append(objectsIn: getRangeList(of: bodyFat.thtBMRRatingList))
        if !hasError {
            self.ratioOfFat.value = bodyFat.thtBodyfatPercentage.doubleValue
            self.ratioOfFatRange.append(objectsIn: getRangeList(of: bodyFat.thtBodyfatRatingList))
            self.ratioOfMuscle.value = bodyFat.thtMusclePercentage.doubleValue
            self.weightOfMuscle.value = bodyFat.thtMuscleKg.doubleValue
            self.weithOfMuscleRange.append(objectsIn: getRangeList(of: bodyFat.thtMuscleRatingList))
            self.weightOfBone.value = bodyFat.thtBoneKg.doubleValue
            self.weightOfBoneRange.append(objectsIn: getRangeList(of: bodyFat.thtBoneRatingList))
            self.ratioOfWater.value = bodyFat.thtWaterPercentage.doubleValue
            self.ratioOfWaterRange.append(objectsIn: getRangeList(of: bodyFat.thtWaterRatingList))
            self.ratioOfProtein.value = bodyFat.thtproteinPercentage.doubleValue
            self.ratioOfProteinRange.append(objectsIn: getRangeList(of: bodyFat.thtproteinRatingList))
            self.levelOfVisceralFat.value = bodyFat.thtVFAL.doubleValue
            self.levelOfVisceralFatRange.append(objectsIn: getRangeList(of: bodyFat.thtVFALRatingList))
            self.ratioOfSubcutaneousFat.value = bodyFat.thtBodySubcutaneousFat.doubleValue
            if bodyFat.thtSex == .male {
                ratioOfSubcutaneousFatRange.append(objectsIn: [8.6, 16.7, 20.7])
            } else {
                ratioOfSubcutaneousFatRange.append(objectsIn: [18.5, 26.7, 30.8])
            }
            self.bodyShape.value = Double(bodyFat.thtBodyScore)
            self.lbw.value = bodyFat.thtBodyLBW.doubleValue
            self.ageOfBody.value = Double(bodyFat.thtBodyAge)
            self.bodyType.value = BodyType(rawValue: bodyFat.thtBodyType.rawValue)
            self.obesityLevel.value = bodyFat.thtBMI.doubleValue
        }
        self.createAt = Date().toString(.hmsdMy)
        self.timestamp = Date().timeIntervalSince1970
        self.createStatus(with: self.items)
    }

    func createStatus(with items: [DetailsItemProtocol]) {
        self.bmrStatus = items[1].statusCode ?? ""

        if items.count > 3 {
            self.weightOfMuscleStatus = items[2].statusCode ?? ""
        } else {
            self.weightOfMuscleStatus = ""
        }

        if items.count > 4 {
            self.weightOfBoneStatus = items[3].statusCode ?? ""
        } else {
            self.weightOfBoneStatus = ""
        }

        if items.count > 7 {
            self.ratioOfFatStatus = items[6].statusCode ?? ""
        } else {
            self.ratioOfFatStatus = ""
        }

        if items.count > 10 {
            self.subcutaneousFatStatus = items[9].statusCode ?? ""
        } else {
            self.subcutaneousFatStatus = ""
        }
    }

    init(_ smartScale: SmartScale) {
        self.isSync = true
        self.scale = DeviceModel(name: smartScale.device ?? "", mac: smartScale.mac ?? "", deviceType: .scale, image: R.image.skSmartScale68())
        self.createAt = smartScale.createdAt?.toDate(.ymdhms)?.toString(.hmsdMy) ?? ""
        self.timestamp = self.createAt.toDate(.hmsdMy)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        self.obesityLevel.value = smartScale.fatLevel ?? 0
        self.bodyType.value = BodyType(code: smartScale.bodyType ?? "")

        // ageOfBody miss value
        self.ageOfBody.value = 0

        // body shape miss value
        self.bodyShape.value = 0
        self.lbw.value = smartScale.leanBodyMass ?? 0
        self.bmrRange.append(objectsIn: [])
        self.weithOfMuscleRange.append(objectsIn: [])
        self.weightOfBoneRange.append(objectsIn: [])
        self.ratioOfFatRange.append(objectsIn: [])

        self.bmrStatus = smartScale.statusBmr ?? ""
        self.weightOfMuscleStatus = smartScale.statusMuscle ?? ""
        self.weightOfBoneStatus = smartScale.statusBoneMass ?? ""
        self.ratioOfFatStatus = smartScale.statusFat ?? ""
        self.subcutaneousFatStatus = smartScale.statusSubcutaneousFat ?? ""

        self.ratioOfSubcutaneousFat.value = smartScale.subcutaneousFat ?? 0
        self.levelOfVisceralFat.value = smartScale.visceralFat ?? 0
        self.ratioOfProtein.value = smartScale.protein ?? 0
        self.ratioOfWater.value = smartScale.bodyWater ?? 0
        self.weightOfBone.value = smartScale.boneMass ?? 0
        self.weightOfMuscle.value = smartScale.muscleMass ?? 0

        self.ratioOfFat.value = smartScale.fat ?? 0
        self.bmr.value = smartScale.bmr ?? 0
        self.bmi.value = smartScale.bmi ?? 0
        self.weight.value = smartScale.weight ?? 0
        self.bodyStandard.value = smartScale.standartWeight ?? 0
        // body shape miss value
        self.ratioOfMuscle.value = 0

        self.syncId = smartScale.id ?? ""
    }

    private func getRangeList(of ratingList: [AnyHashable: Any]?) -> [Double] {
        let array = ratingList?.compactMap({ (dictionary) -> Double? in
            guard let value = dictionary.value as? Double else {
                return nil
            }
            return value
        }).sorted()
        return array ?? []
    }
}
