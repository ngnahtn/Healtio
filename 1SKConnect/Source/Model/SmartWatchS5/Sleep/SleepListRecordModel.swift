//
//  SleepListRecordModel.swift
//  1SKConnect
//
//  Created by TrungDN on 17/12/2021.
//

import RealmSwift

class SleepListRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    let sleepList = List<SleepRecordModel>()
    
    init(profile: ProfileModel, device: DeviceModel, sleepList: [SleepRecordModel]) {
        super.init()
        self.id = profile.id
        self.device = device
        self.sleepList.append(objectsIn: sleepList)
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    func getYearGarphData(of type: TimeFilterType) -> [[[SleepRecordModel]]] {
        var joinedArray: [[[SleepRecordModel]]] = []
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

    func getGraphData(of type: TimeFilterType) -> [[SleepRecordModel]] {
        var joinedArray: [[SleepRecordModel]] = []
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
            joinedArray = self.processDataForGraphView(isSameGroup: { bp, bps in
                return bp.dateTime.toDate(.ymd)!.isInSameYear(as: bps.last!.dateTime.toDate(.ymd)!)
            })
        }
        return joinedArray
    }
    
    private func processDataForGraphView(isSameGroup: (SleepRecordModel, [SleepRecordModel]) -> Bool) -> [[SleepRecordModel]] {
        var joinedArray: [[SleepRecordModel]] = []
        var temp: [SleepRecordModel] = []
        for bp in sleepList.array.reversed() {
            if !temp.isEmpty {
                if isSameGroup(bp, temp) {
                    temp.append(bp)
                } else {
                    joinedArray.append(temp)
                    temp = [bp]
                }
            } else { // temp empty
                temp.append(bp)
            }
        }
        if !temp.isEmpty {
            joinedArray.append(temp)
        }
        return joinedArray
    }

    private func processDataForGraphView(isSameSmallGroup: (SleepRecordModel, [SleepRecordModel]) -> Bool, isSameLargeGroup: ([SleepRecordModel], [[SleepRecordModel]]) -> Bool) -> [[[SleepRecordModel]]] {
        var joinedArray: [[[SleepRecordModel]]] = []
        var largeTemp: [[SleepRecordModel]] = []
        var smallTemp: [SleepRecordModel] = []
        for bp in sleepList.array.reversed() {
            if !smallTemp.isEmpty {
                if isSameSmallGroup(bp, smallTemp) {
                    smallTemp.append(bp)
                } else {
                    largeTemp.append(smallTemp)
                    smallTemp = [bp]
                }
            } else { // temp empty
                smallTemp.append(bp)
            }
        }
        if !smallTemp.isEmpty {
            largeTemp.append(smallTemp)
        }

        var temp: [[SleepRecordModel]] = []
        for listBp in largeTemp {
            if !temp.isEmpty {
                if isSameLargeGroup(listBp, temp) {
                    temp.append(listBp)
                } else {
                    joinedArray.append(temp)
                    temp = [listBp]
                }
            } else { // temp empty
                temp.append(listBp)
            }
        }

        if !temp.isEmpty {
            joinedArray.append(temp)
        }

        return joinedArray
    }
}
