//
//  BloodPressureListRecordModel.swift
//  1SKConnect
//
//  Created by TrungDN on 15/12/2021.
//

import RealmSwift

class BloodPressureListRecordModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    
    let bloodPressureList = List<BloodPressureRecordModel>()
    
    init(profile: ProfileModel, device: DeviceModel, bloodPressureList: [BloodPressureRecordModel]) {
        super.init()
        self.id = profile.id
        self.device = device
        self.bloodPressureList.append(objectsIn: bloodPressureList)
    }
    
    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    func getYearGarphData(of type: TimeFilterType) -> [[[BloodPressureRecordModel]]] {
        var joinedArray: [[[BloodPressureRecordModel]]] = []
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

    func getGraphData(of type: TimeFilterType) -> [[BloodPressureRecordModel]] {
        var joinedArray: [[BloodPressureRecordModel]] = []
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
    
    private func processDataForGraphView(isSameGroup: (BloodPressureRecordModel, [BloodPressureRecordModel]) -> Bool) -> [[BloodPressureRecordModel]] {
        var joinedArray: [[BloodPressureRecordModel]] = []
        var temp: [BloodPressureRecordModel] = []
        for bp in bloodPressureList.array.reversed() {
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

    private func processDataForGraphView(isSameSmallGroup: (BloodPressureRecordModel, [BloodPressureRecordModel]) -> Bool, isSameLargeGroup: ([BloodPressureRecordModel], [[BloodPressureRecordModel]]) -> Bool) -> [[[BloodPressureRecordModel]]] {
        var joinedArray: [[[BloodPressureRecordModel]]] = []
        var largeTemp: [[BloodPressureRecordModel]] = []
        var smallTemp: [BloodPressureRecordModel] = []
        for bp in bloodPressureList.array.reversed() {
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

        var temp: [[BloodPressureRecordModel]] = []
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
