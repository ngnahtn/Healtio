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
    
    init(_ heartRate: Int, and profile: ProfileModel?) {
        var age: Int = 18
        if let currentProfile = profile , let birthday = currentProfile.birthday?.toDate(.ymd)  {
            age = Date().year - birthday.year
        }
    }
    
    private func calculateState(with min: Int, and max: Int, and value: Int) {
        if
    }
    
    var title: String? { return "" }
    
    var navigationTitle: String {return "" }
    
    var description: String {return "" }
    
    var unit: String {return "" }
    
    var status: String? {return "" }
    
    var statusCode: String? {return "" }
    
    var color: UIColor? {return nil}
    
    var maxValue: Double {return 0}
    
    var minValue: Double {return 0}
    
    var valueScale: [Double] {return []}
    
    var descriptionSacle: [String] {return []}
}
