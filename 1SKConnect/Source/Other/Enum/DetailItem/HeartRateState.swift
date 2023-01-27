//
//  HeartRateState.swift
//  1SKConnect
//
//  Created by Nguyễn Anh Tuấn on 27/01/2023.
//

import Foundation

enum HeartRateState: DetailsItemProtocol {
    
    case low
    case normal
    case high
    
    init(_ heartRate: Int, and age: Int) {
        switch age {
        case 0:
            if heartRate < 80 {
                self = .low
            } else if heartRate > 160 {
                self = .high
            } else {
                self = .normal
            }
        case 1...2:
            if heartRate < 80 {
                self = .low
            } else if heartRate > 130 {
                self = .high
            } else {
                self = .normal
            }
        case 3...4:
            if heartRate < 80 {
                self = .low
            } else if heartRate > 120 {
                self = .high
            } else {
                self = .normal
            }
        case 5...6:
            if heartRate < 75 {
                self = .low
            } else if heartRate > 115 {
                self = .high
            } else {
                self = .normal
            }
        case 7...9:
            if heartRate < 70 {
                self = .low
            } else if heartRate > 110 {
                self = .high
            } else {
                self = .normal
            }
        default:
            if heartRate < 60 {
                self = .low
            } else if heartRate > 100 {
                self = .high
            } else {
                self = .normal
            }
        }
    }
    var listVitalSignsDescription: [VitalSignsDescriptionModel] {
        return [
            VitalSignsDescriptionModel(title: "Nhịp tim trung bình tối đa khi luyện tập: ", des: "Giá trị nhịp tim tối đa khi vận dụng 100 phần trăm sức lực trong quá trình luyện tập theo từng độ tuổi."),
            VitalSignsDescriptionModel(title: "Vùng nhịp tim thích hợp khi luyện tập: ", des: "Nhịp tim của một người sẽ nằm trong phạm vi này khi luyện tập ở cường độ 50 đến 85 phần trăm, còn được gọi là gắng sức.")
        ]
    }
    
    var title: String? { return "" }
    
    var navigationTitle: String {return "" }
    
    var description: String {return "" }
    
    var unit: String {return "" }
    
    var status: String? {
        switch self {
        case .low:
            return "Nhịp tim chậm"
        case .normal:
            return "Nhịp tim ổn định"
        case .high:
            return "Nhịp tim nhanh"
        }
    }
    
    var statusCode: String? {return "" }
    
    var color: UIColor? {return nil}
    
    var maxValue: Double {return 0}
    
    var minValue: Double {return 0}
    
    var valueScale: [Double] {return []}
    
    var descriptionSacle: [String] {return []}
}
