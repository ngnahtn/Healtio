//
//  GarphsWaveformCollectionViewCellModel.swift
//  1SKConnect
//
//  Created by TrungDN on 15/11/2021.
//

import Foundation

struct GarphsWaveformCollectionViewCellModel {
    var data: [[WaveformModel]]
    var timeType: TimeFilterType
    
    func getPoints() -> [[Double]] {
        var points = [[Double]]()
        for i in 0 ..< data.count {
            var tempArray: [Double] = []
            let maxSpO2 = data[i].map { Double($0.spO2Value.value!) }.max()!
            let minSpO2 = data[i].map { Double($0.spO2Value.value!) }.min()!
            tempArray.append(maxSpO2)
            tempArray.append(minSpO2)
            points.append(tempArray)
        }
        return points
    }
}
