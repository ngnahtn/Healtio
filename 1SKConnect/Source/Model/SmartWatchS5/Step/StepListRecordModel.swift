//
//  StepListRecordModel.swift
//  1SKConnect
//
//  Created by TrungDN on 15/12/2021.
//

import RealmSwift

class StepListRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?

    let stepList = List<StepRecordModel>()
    
    init(profile: ProfileModel, device: DeviceModel, stepList: [StepRecordModel]) {
        super.init()
        self.id = profile.id
        self.device = device
        self.stepList.append(objectsIn: stepList)
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    func getGraphData(of type: TimeFilterType) -> [[StepRecordModel]] {
        var joinedArray: [[StepRecordModel]] = []
        switch type {
        case .day:
            return []
        case .week:
            joinedArray = self.processDataForGraphView(isSameGroup: { bp, bps in
                return bp.dateTime.toDate(.ymd)!.isInSameWeek(as: bps.last!.dateTime.toDate(.ymd)!)
            })
        case .month:
            joinedArray = self.processDataForGraphView(isSameGroup: { bp, bps in
                return bp.dateTime.toDate(.ymd)!.isInSameMonth(as: bps.last!.dateTime.toDate(.ymd)!)
            })
        case .year:
            return []
        }
        return joinedArray
    }
    
    func getYearGarphData(of type: TimeFilterType) -> [[[StepRecordModel]]] {
        var joinedArray: [[[StepRecordModel]]] = []
        switch type {
        case .day:
            return []
        case .week:
            return []
        case .month:
            return []
        case .year:
            joinedArray = self.processDataForGraphView(isSameSmallGroup: { bodyFat, bodyFats in
                return bodyFat.timestamp.toDate().isSameMonth(with: bodyFats.last!.timestamp.toDate())
            }, isSameLargeGroup: { bodyFats, listBodyFats in
                return bodyFats.last!.timestamp.toDate().isInSameYear(as: listBodyFats.last!.last!.timestamp.toDate())
            })
        }
        return joinedArray
    }
    
    private func processDataForGraphView(isSameGroup: (StepRecordModel, [StepRecordModel]) -> Bool) -> [[StepRecordModel]] {
        var joinedArray: [[StepRecordModel]] = []
        var steps: [StepRecordModel] = []
        for step in stepList.array.reversed() {
            if !steps.isEmpty {
                if isSameGroup(step, steps) {
                    steps.append(step)
                } else {
                    joinedArray.append(steps)
                    steps = [step]
                }
            } else { // temp empty
                steps.append(step)
            }
        }
        if !steps.isEmpty {
            joinedArray.append(steps)
        }
        return joinedArray
    }

    private func processDataForGraphView(isSameSmallGroup: (StepRecordModel, [StepRecordModel]) -> Bool, isSameLargeGroup: ([StepRecordModel], [[StepRecordModel]]) -> Bool) -> [[[StepRecordModel]]] {
        var joinedArray: [[[StepRecordModel]]] = []
        var largeStep: [[StepRecordModel]] = []
        var smallStep: [StepRecordModel] = []
        for step in stepList.array.reversed() {
            if !smallStep.isEmpty {
                if isSameSmallGroup(step, smallStep) {
                    smallStep.append(step)
                } else {
                    largeStep.append(smallStep)
                    smallStep = [step]
                }
            } else { // temp empty
                smallStep.append(step)
            }
        }
        if !smallStep.isEmpty {
            largeStep.append(smallStep)
        }

        var step: [[StepRecordModel]] = []
        for listStep in largeStep {
            if !step.isEmpty {
                if isSameLargeGroup(listStep, step) {
                    step.append(listStep)
                } else {
                    joinedArray.append(step)
                    step = [listStep]
                }
            } else { // temp empty
                step.append(listStep)
            }
        }

        if !step.isEmpty {
            joinedArray.append(step)
        }

        return joinedArray
    }
}
