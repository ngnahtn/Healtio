//
//  LineChartLeftAxisFormatter.swift
//  1SKConnect
//
//  Created by TrungDN on 19/11/2021.
//

import Foundation
import Charts

enum ChartValueType {
    case spO2
    case pr
}

class LineChartLeftAxisFormatter: NSObject, IAxisValueFormatter {
    var type: ChartValueType!
    var cellType: CellType!

    init(type: ChartValueType) {
        self.type = type
    }
    
    init(type: CellType) {
        self.cellType = type
    }

    var labels: [Int: String] {
        if self.type == nil {
            if cellType == .heartRate || cellType == .bloodPressure {
                return [0: "0", 50: "50", 100: "100", 150: "150", 200: "200"]
            } else if cellType == .temperature {
                return [30: "30", 40: "40", 50: "50"]
            } else if cellType == .spO2 {
                return [0: "0", 50: "50", 100: "100"]
            } else {
                return [:]
            }
        } else {
            switch self.type {
            case .spO2:
                return [70: "70", 80: "80", 90: "90", 100: "100"]
            case .pr:
                return [30: "30", 60: "60", 90: "90", 120: "120", 150: "150"]
            case .none:
                return [:]
            }
        }
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int((value).rounded())] ?? ""
    }
}

public class TimeValueFormatter: NSObject, IAxisValueFormatter {
    var defaultDate: Date
    
    init(date: Date) {
        self.defaultDate = date
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var timestampValue = Double(round(10 * value) / 10)
        if timestampValue == defaultDate.nextDay.timeIntervalSince1970 {
            timestampValue = value - 60
        }

        let date = Date(timeIntervalSince1970: timestampValue)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(for: date) ?? ""
    }
}

public class NoneValueFormatter: NSObject, IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
       return ""
    }
}

public class BarChartLeftAxisFormatter: NSObject, IAxisValueFormatter {
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value == 0 {
            return ""
        } else {
            return value.toString()
        }
    }
}

public class DayValueFormatter: NSObject, IAxisValueFormatter {    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(for: date) ?? ""
    }
}

public class YearValueFormatter: NSObject, IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value == 0 || value >= 13 {
            return ""
        }
        return "T" + value.toString()
    }
}

public class WMYValueFormatter: NSObject, IAxisValueFormatter {
    var defaultDate: Date
    var timeType: TimeFilterType

    init(date: Date, type: TimeFilterType) {
        self.defaultDate = date
        self.timeType = type
    }
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch timeType {
        case .day:
            return ""
        case .week:
            if value == defaultDate.chartStartOfWeek!.timeIntervalSince1970 - 3600 * 24 {
                return ""
            }
            let date = Date(timeIntervalSince1970: value)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM"
            return formatter.string(for: date) ?? ""
        case .month:
            if value == defaultDate.startOfMonth.timeIntervalSince1970 - 3600 * 24 {
                let date = Date(timeIntervalSince1970: value + 3600 * 24)
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM"
                let label = formatter.string(for: date) ?? ""
                return "    \(label)"
            }
            
            let date = Date(timeIntervalSince1970: value)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM"
            return formatter.string(for: date) ?? ""
        case .year:
            return ""
        }
    }
}
