//
//  GarphsBloodPressureCollectionViewCellModel.swift
//  1SKConnect
//
//  Created by TrungDN on 22/11/2021.
//

import Foundation

struct GarphsBloodPressureCollectionViewCellModel {
    var data: [[BloodPressureModel]]
    var timeType: TimeFilterType

    func getPoints() -> [[Double]] {
        var points = [[Double]]()
        for i in 0 ..< data.count {
            var tempArray: [Double] = []
            let maxSys = data[i].map { Double($0.sys.value!) }.max()!
            let minSys = data[i].map { Double($0.sys.value!) }.min()!
            let maxDia = data[i].map { Double($0.dia.value!) }.max()!
            let minDia = data[i].map { Double($0.dia.value!) }.min()!
            if self.timeType == .day {
                tempArray.append(maxSys)
                tempArray.append(maxSys)
                tempArray.append(maxDia)
                tempArray.append(maxDia)
            } else {
                tempArray.append(maxSys)
                tempArray.append(minSys)
                tempArray.append(maxDia)
                tempArray.append(minDia)
            }
            points.append(tempArray)
        }
        return points
    }
}
