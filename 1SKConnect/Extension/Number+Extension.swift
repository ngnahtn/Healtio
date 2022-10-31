//
//  Number+Extension.swift
//  1SKConnect
//
//  Created by tuyenvx on 09/03/2021.
//

import UIKit

extension CGFloat {
    func toString() -> String {
        let double = Double(self)
        return String(format: "%.2f", double)
    }
}

extension Int {
    
    var hourAndMinuteStringValue: String {
        return hourValue.stringValue + " " + R.string.localizable.hour() + " " + minuteValue.checkMinuteValueToString() + " " + R.string.localizable.minute()
    }

    /// calculate minutes value from Int
    var minuteValue: Int {
        return self%60
    }

    /// calculate hour value from Int
    var hourValue: Int {
        return self/60
    }
    ///  Convert Int to String
    /// - Returns: String of Int
    var stringValue: String {
        return String(self)
    }

    ///  Convert Int to Double
    /// - Returns: Double of Int
    var doubleValue: Double {
        return Double(self)
    }
    
    /// Get time string from second
    /// - Parameter unitCount: format of `[.second, .minute, .hour, .day, .weekOfMonth]` set this property to get the number of value max is 5
    /// - Returns: time string from int
    func toTimeSting(unitCount: Int = 3) -> String {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "vi")
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = unitCount
        formatter.unitsStyle = .full
        let formattedString = formatter.string(from: TimeInterval(self))!
        return formattedString
    }
    func checkMinuteValueToString() -> String {
        if self < 10 {
            return "0" + self.stringValue
        } else {
            return self.stringValue
        }
    }
}

extension Double {
    static func equal(_ lhs: Double, _ rhs: Double, numberAfterZero value: Int = 10) -> Bool {
      return lhs.roundTo(value) == rhs.roundTo(value)
    }

    func toString() -> String {
        let numberFormater = NumberFormatter()
        numberFormater.minimumFractionDigits = 0
        numberFormater.maximumFractionDigits = 2
        numberFormater.decimalSeparator = "."
        return numberFormater.string(from: self as NSNumber)!
    }

    func roundTo(_ value: Int = 1) -> Double {
      let offset = pow(10, Double(value))
      return (self * offset).rounded() / offset
    }

    var cgFloatValue: CGFloat {
        return CGFloat(self)
    }

    var intValue: Int {
        return Int(self)
    }

    func numberAsPercentage() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.percentSymbol = "%"
        //        formatter.maximumIntegerDigits = 0
        return formatter.string(from: NSNumber(value: self))!
    }
    
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func truncate(places: Int) -> Double {
        if self.isNaN || self.isInfinite { return 0 }
        let divisor = pow(10.0, Double(places))
        return Double(Int(self * divisor)) / divisor
    }
    
    func toTimeString(_ isFullFormat: Bool = false) -> String {
        let seconds = Int(self)
        let hour = seconds / 3600
        let minute = (seconds % 3600) / 60
        let second = ((seconds % 3600) % 60)
        if isFullFormat {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        }
        if hour == 0 {
            return String(format: "%02d:%02d", minute, second)
        }
        return String(format: "%d:%02d:%02d", hour, minute, second)
    }

    func toFullTimeString() -> String {
        let seconds = Int(self)
        let hour = seconds / 3600
        let minute = (seconds % 3600) / 60
        let second = ((seconds % 3600) % 60)
        if hour == 0 {
            return String(format: "%02d phút %02d giây", minute, second)
        }
        return String(format: "%d giờ %02d phút %02d giây", hour, minute, second)
    }
    
    func toHourMinuteString() -> String {
        let seconds = Int(self)
        let hour = seconds / 3600
        let minute = (seconds % 3600) / 60
        if hour == 0 {
            return String(format: "00:%02d", minute)
        }
        return String(format: "%d:%02d", hour, minute)
    }

    func toHourMinuteSecondString() -> String {
        let seconds = Int(self)
        let hour = seconds / 3600
        let minute = (seconds % 3600) / 60
        let second = ((seconds % 3600) % 60)
        if hour == 0 {
            return String(format: "00:%02d:%02d", minute, second)
        }
        return String(format: "%d:%02d:%02d", hour, minute, second)
    }
}

extension Float {
    func toString() -> String {
        let value = (self * 10).rounded(.toNearestOrAwayFromZero)
        return String(format: "%.1f", value / 10)

    }
    var intValue: Int {
        return Int(self)
    }
}

extension CGFloat {
    var doubleValue: Double {
        return Double(self)
    }
}

extension Numeric where Self: BinaryInteger {
    var doubleValue: Double {
        return Double(self)
    }

    var intValue: Int {
        return Int(self)
    }
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}
