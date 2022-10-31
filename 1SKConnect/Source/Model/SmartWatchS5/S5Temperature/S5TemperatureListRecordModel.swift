//
//  S5TemperatureListRecordModel.swift
//  1SKConnect
//
//  Created by admin on 22/12/2021.
//

import RealmSwift

class S5TemperatureListRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    @objc dynamic var lastSyncDate: Double = 0
    let tempList = List<S5TemperatureRecordModel>()
    
    init(profile: ProfileModel, device: DeviceModel, tempList: [S5TemperatureRecordModel]) {
        super.init()
        self.lastSyncDate = Date().timeIntervalSince1970
        self.id = profile.id
        self.device = device
        self.tempList.append(objectsIn: tempList)
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    func getYearGarphData(of type: TimeFilterType) -> [[[S5TemperatureRecordModel]]] {
        var joinedArray: [[[S5TemperatureRecordModel]]] = []
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

    func getGraphData(of type: TimeFilterType) -> [[S5TemperatureRecordModel]] {
        var joinedArray: [[S5TemperatureRecordModel]] = []
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
    
    private func processDataForGraphView(isSameGroup: (S5TemperatureRecordModel, [S5TemperatureRecordModel]) -> Bool) -> [[S5TemperatureRecordModel]] {
        var joinedArray: [[S5TemperatureRecordModel]] = []
        var temp: [S5TemperatureRecordModel] = []
        for bp in tempList.array.reversed() {
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

    private func processDataForGraphView(isSameSmallGroup: (S5TemperatureRecordModel, [S5TemperatureRecordModel]) -> Bool, isSameLargeGroup: ([S5TemperatureRecordModel], [[S5TemperatureRecordModel]]) -> Bool) -> [[[S5TemperatureRecordModel]]] {
        var joinedArray: [[[S5TemperatureRecordModel]]] = []
        var largeTemp: [[S5TemperatureRecordModel]] = []
        var smallTemp: [S5TemperatureRecordModel] = []
        for bp in tempList.array.reversed() {
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

        var temp: [[S5TemperatureRecordModel]] = []
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
