//
//  S5SpO2ListRecordModel.swift
//  1SKConnect
//
//  Created by admin on 22/12/2021.
//

import RealmSwift

class S5SpO2ListRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    let spO2List = List<S5SpO2RecordModel>()
    
    init(profile: ProfileModel, device: DeviceModel, spO2List: [S5SpO2RecordModel]) {
        super.init()
        self.id = profile.id
        self.device = device
        self.spO2List.append(objectsIn: spO2List)
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    func getYearGarphData(of type: TimeFilterType) -> [[[S5SpO2RecordModel]]] {
        var joinedArray: [[[S5SpO2RecordModel]]] = []
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

    func getGraphData(of type: TimeFilterType) -> [[S5SpO2RecordModel]] {
        var joinedArray: [[S5SpO2RecordModel]] = []
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
    
    private func processDataForGraphView(isSameGroup: (S5SpO2RecordModel, [S5SpO2RecordModel]) -> Bool) -> [[S5SpO2RecordModel]] {
        var joinedArray: [[S5SpO2RecordModel]] = []
        var temp: [S5SpO2RecordModel] = []
        for bp in spO2List.array.reversed() {
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

    private func processDataForGraphView(isSameSmallGroup: (S5SpO2RecordModel, [S5SpO2RecordModel]) -> Bool, isSameLargeGroup: ([S5SpO2RecordModel], [[S5SpO2RecordModel]]) -> Bool) -> [[[S5SpO2RecordModel]]] {
        var joinedArray: [[[S5SpO2RecordModel]]] = []
        var largeTemp: [[S5SpO2RecordModel]] = []
        var smallTemp: [S5SpO2RecordModel] = []
        for bp in spO2List.array.reversed() {
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

        var temp: [[S5SpO2RecordModel]] = []
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
