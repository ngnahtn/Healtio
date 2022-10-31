//
//  String+Extension.swift
//
//  Created by tuyenvx.
//

import UIKit

extension String {
    var fullHTMLString: String? {
        return  """
            <!DOCTYPE html>
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=corver"/>
            </head>
            <body>
            \(self)
            </body>
            </html>
        """
    }

    func toTimeInterval() -> TimeInterval? {
        guard !self.isEmpty else {
            return nil
        }
        var interval: Double = 0

        let parts = self.components(separatedBy: ":")
        for (index, part) in parts.reversed().enumerated() {
            interval += (Double(part) ?? 0) * pow(Double(60), Double(index))
        }

        return interval
    }

    func toDate(_ format: Date.Format) -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = format.rawValue
        dateFormater.locale = Locale(identifier: "vi")
        return dateFormater.date(from: self)
    }

    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}

extension Optional where Wrapped == String {
    func toURLPath() -> String {
        if let id = self {
            return "/\(id)"
        } else {
            return ""
        }
    }
}

extension String {
    /// Check if a string nil or empty
    /// - Parameters:
    ///   - aString: input string
    /// - Returns: Bool
    static func isNilOrEmpty(_ aString: String?) -> Bool {
        return !(aString != nil && !"\(aString ?? "")".isEmpty)
    }

    /// Validate email
    /// - Returns: Void
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }

    /// Height for  text with fixed width
    /// - Parameters:
    ///   - width: fixed width
    ///   - font: font
    /// - Returns: CGFloat
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    /// Width for  text with fixed height
    /// - Parameters:
    ///   - height: fixed height
    ///   - font: font
    /// - Returns: CGFloat
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

// MARK: - Filename spo2
extension String {
    func filenameToDateString() -> String {
        if self.count == 14 {
            let year = self.substring(to: 4)
            let month = self.substring(with: 4..<6)
            let day = self.substring(with: 6..<8)
            let hour = self.substring(with: 8..<10)
            let min = self.substring(with: 10..<12)
            let sec = self.substring(with: 12..<14)
            return "\(year)-\(month)-\(day) \(hour):\(min):\(sec)"
        }
        return ""
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
