//
//  Date+Extension.swift
//
//  Created by tuyenvx.
//

import UIKit

extension Date {
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    
    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }
    
    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }
    
    var isInThisYear: Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek: Bool { isInSameWeek(as: Date()) }
    
    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday: Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow: Bool { Calendar.current.isDateInTomorrow(self) }
    
    var isInTheFuture: Bool { self > Date() }
    var isInThePast: Bool { self < Date() }
}

extension Date {
    var calendar: Calendar {
        return Calendar(identifier: Calendar.Identifier.gregorian)
    }
    
    var numberOfDaysInMonth: Int {
        let range = calendar.range(of: .day, in: .month, for: self)!
        let numDays = range.count
        return numDays
    }
    
    var nextHour: Date {
        return calendar.date(byAdding: .hour, value: 1, to: self) ?? self
    }
    
    var previousDay: Date {
        return calendar.date(byAdding: .day, value: -1, to: self)!.startOfDay
    }
    
    var nextDay: Date {
        return calendar.date(byAdding: .day, value: 1, to: self)!.startOfDay
    }
    
    var startOfDay: Date {
        return calendar.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var component = DateComponents()
        component.hour = 23
        component.minute = 59
        component.second = 59
        return calendar.date(byAdding: component, to: startOfDay) ?? self
    }
    
    var startOfWeek: Date {
        let component = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        let sunday = calendar.date(from: component)!
        return calendar.date(byAdding: .day, value: 1, to: sunday)!
    }
    
    var endOfWeek: Date {
        let component = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        let sunday = calendar.date(from: component)!
        return calendar.date(byAdding: .day, value: 7, to: sunday)!.endOfDay
    }
    
    var chartStartOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var chartEndOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    var nextWeek: Date {
        return calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
    }
    
    var previousWeek: Date {
        return calendar.date(byAdding: .weekOfYear, value: -1, to: startOfWeek)!
    }
    
    var startOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfMonth: Date {
        let components = DateComponents(month: 1, day: -1)
        return self.startOfMonth.addComponent(components).endOfDay
    }
    
    var previousMonth: Date {
        return calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
    }
    
    var sixMonthsAgo: Date {
        return calendar.date(byAdding: .month, value: -6, to: Date())!
    }
    
    var scaleMonths: Date {
        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return calendar.date(byAdding: .month, value: -6, to: Date())!
        }
        return calendar.date(byAdding: .month, value: -(profile.scaleDowloadMonths.value ?? 6), to: Date())!
    }
    
    var spO2Months: Date {
        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return calendar.date(byAdding: .month, value: -1, to: Date())!
        }
        return calendar.date(byAdding: .month, value: -(profile.spO2DowloadMonths.value ?? 1), to: Date())!
    }
    
    var nextMonth: Date {
        return calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
    }
    
    var startOfYear: Date {
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components)!
    }
    
    var endOfYear: Date {
        var component = DateComponents()
        component.year = 1
        component.day = -1
        return calendar.date(byAdding: component, to: startOfYear)!.endOfDay
    }
    
    var previousYear: Date {
        return calendar.date(byAdding: .year, value: -1, to: startOfYear)!
    }
    
    var nextYear: Date {
        return calendar.date(byAdding: .year, value: 1, to: startOfYear)!
    }
    
    var year: Int {
        return calendar.component(.year, from: self)
    }
    
    var yearString: String {
        return "\(self.year)"
    }
    
    var month: Int {
        return calendar.component(.month, from: self)
    }
    
    var monthString: String {
        return "\(self.month)"
    }
    
    var weekDay: Int {
        return calendar.component(.weekday, from: self)
    }
    
    var day: Int {
        return calendar.component(.day, from: self)
    }
    
    var dayString: String {
        return "\(self.day)"
    }
    
    var second: Int {
        return calendar.component(.second, from: self)
    }
    
    var minute: Int {
        return calendar.component(.minute, from: self)
    }
    
    var minuteString: String {
        if self.minute / 10 == 0 {
            return "0\(self.minute)"
        } else {
            return "\(self.minute)"
        }
    }
    
    var hour: Int {
        return calendar.component(.hour, from: self)
    }
    
    var hourString: String {
        if self.hour / 10 == 0 {
            return "0\(self.hour)"
        } else {
            return "\(self.hour)"
        }
    }
    
    func isSameDay(with date: Date) -> Bool {
        return startOfDay == date.startOfDay
    }
    
    func isSameMonth(with date: Date) -> Bool {
        return year == date.year && month == date.month
    }
    
    func isSameMin(with date: Date) -> Bool {
        return isSameHour(with: date) && self.minute == date.minute
    }
    
    func isSameHour(with date: Date) -> Bool {
        return isSameDay(with: date) && hour == date.hour
    }
    
    func addComponent(_ component: DateComponents) -> Date {
        return calendar.date(byAdding: component, to: self) ?? self
    }
    
    func toString(_ format: Format = .ymd) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = format.rawValue
        dateFormater.locale = Locale(identifier: "vi")
        return dateFormater.string(from: self)
    }
    
    enum Format: String {
        case ymd = "yyyy-MM-dd"
        case dmy = "dd-MM-yyyy"
        case hmsdMy = "HH:mm:ss dd-MM-yyyy"
        case hmsdMySlash = "HH:mm:ss dd/MM/yyyy"
        case hm = "HH:mm"
        case hms = "HH:mm:ss"
        case dmyhms = "dd-MM-yyyy HH:mm:ss"
        case hmdmy = "HH:mm dd/MM/yyyy"
        case ms = "m:ss"
        case dmySlash = "dd/MM/yyyy"
        case dmyColon = "dd:MM:yyyy"
        case ymdSlash = "yyyy/MM/dd"
        case ymdhms = "yyyy-MM-dd HH:mm:ss"
        case ymdhm = "yyyy-MM-dd HH:mm"
        case day = "dd"
        case dayMonth = "dd/MM"
        case hour = "HH"
        case mySlash = "MM/yyyy"
        case dayOfWeek = "EEEE, dd/MM/yyyy"
    }
    
    func age() -> Int {
        var ageComponents: DateComponents!
        if #available(iOS 15, *) {
            ageComponents = calendar.dateComponents([.year], from: self, to: .now)
        } else {
            ageComponents = calendar.dateComponents([.year], from: self, to: Date())
        }
        return ageComponents.year!
    }
}

extension Date {
    /// Create date string for log functions
    /// - Parameters:
    /// - Returns: String
    func stringForLog() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        return df.string(from: self)
    }
    
    func time(to date: Date, unitCount: Int = 3) -> String {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "vi")
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = unitCount
        formatter.unitsStyle = .full
        return formatter.string(from: self, to: date) ?? ""
    }
}

extension TimeInterval {
    func toTimeFormat() -> String? {
        let formater = DateComponentsFormatter()
        formater.zeroFormattingBehavior = .pad
        formater.allowedUnits = [.minute, .second]
        if self > 3600 {
            formater.allowedUnits.insert(.hour)
        }
        return formater.string(from: self)
    }
    
    func toDate() -> Date {
        return Date(timeIntervalSince1970: self)
    }
}

// MARK: - Smart watch date extension
extension Date {
    func countOfDaysInMonth() -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let range = (calendar as NSCalendar?)?.range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: self)
        return (range?.length)!
    }
    
    func firstWeekDay() -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let firstWeekDay = (calendar as NSCalendar?)?.ordinality(of: NSCalendar.Unit.weekday, in: NSCalendar.Unit.weekOfMonth, for: self)
        return firstWeekDay! - 1
    }
    
    func isToday() -> Bool {
        let calendar = NSCalendar.current
        let com = calendar.dateComponents([.year, .month, .day], from: self)
        let comNow = calendar.dateComponents([.year, .month, .day], from: Date())
        return com.year == comNow.year && com.month == comNow.month && com.day == comNow.day
    }
    
    func isThisMonth() -> Bool {
        let calendar = NSCalendar.current
        let com = calendar.dateComponents([.year, .month, .day], from: self)
        let comNow = calendar.dateComponents([.year, .month, .day], from: Date())
        return com.year == comNow.year && com.month == comNow.month
    }
    
    func getCounts(type: Int) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.date(from: "2018-01-01")
        
        var count: Int = 0
        
        if type == 0 {
            let comps = Calendar.current.dateComponents([.day], from: startDate!, to: self)
            count = comps.day!
        }
        if type == 1 {
            let comps = Calendar.current.dateComponents([.day], from: startDate!, to: self)
            count = comps.day!/7
        }
        if type == 2 {
            let comps = Calendar.current.dateComponents([.month], from: startDate!, to: self)
            count = comps.month!
        }
        return count
    }
    
    func startOfThisWeek() -> Date {
        let calendar = NSCalendar.current
        let commponets = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        let startOfWeek = calendar.date(from: commponets)
        return startOfWeek!
    }
    
    func startOfCurrentMonth() -> Date {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        let startOfMonth = calendar.date(from: components)!
        return startOfMonth
    }
    
    func getDateFromCurrentMonth(offset: Int) -> Date? {
        let calendar = Calendar.current
        var coms = calendar.dateComponents([.year, .month, .day], from: self)
        coms.month = coms.month! - offset
        coms.day = 1
        return calendar.date(from: coms)
    }
    
    func getMonthHowManyDay() -> Range<Int> {
        return Calendar.current.range(of: .day, in: .month, for: self)!
    }
    
    func getMonthFirstDay() -> Date? {
        let calendar = Calendar.current
        var com = calendar.dateComponents([.year, .month, .day], from: self)
        com.day = 1
        return calendar.date(from: com)
    }

    func getMonthEndDay(returnEndTime: Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        components.second = -1
        components.timeZone = TimeZone.current
        let endOfMonth = calendar.date(byAdding: components, to: startOfCurrentMonth())!
        return endOfMonth
    }

    func getDay(offset: Int) -> Date? {
        let calendar = Calendar.current
        var com = calendar.dateComponents([.year, .month, .day], from: self)
        com.day = com.day! + offset
        return calendar.date(from: com)
    }
    
    func date2String() -> String? {
        let dateformatter = DateFormatter.init()
        dateformatter.dateFormat = "yyyy-MM-dd"
        return dateformatter.string(from: self)
    }
}

class DateClass {
    static func todayString() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        return dateFormat.string(from: Date())
    }
    
    static func todayIntegrateString() -> String {
        let dateFormat = DateFormatter()
        let locale = Locale(identifier: "vi")
        dateFormat.locale = locale
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormat.string(from: Date())
    }
    
    static func getNowTimeS() -> Int {
        let date = Date()
        let timeInterval: Int = Int(date.timeIntervalSince1970)
        return timeInterval
    }
    
    static func getCurrentTimeZone() -> Date {
        let date = Date()
        let zone = TimeZone.current
        let interval = zone.secondsFromGMT()
        let nowDate = date.addingTimeInterval(TimeInterval(interval))
        return nowDate
    }

    static func getZeroTimeZone() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormat.date(from: DateClass.todayString())
        return todayDate!
    }

    static func getCurrentInitTimeZone() -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let zone = TimeZone.current
        dateFormat.timeZone = zone
        let interval = zone.secondsFromGMT()
        let todayDate = dateFormat.date(from: DateClass.todayString())
        return todayDate!.addingTimeInterval(TimeInterval(interval))
    }

    static func timestampToStr(_ timestamp: Int, formatStr: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let zone = TimeZone.current
        let dateFormat = DateFormatter()

        let locale = Locale.current
        dateFormat.locale = locale
        dateFormat.dateFormat = formatStr
        dateFormat.timeZone = zone
        let str = dateFormat.string(from: date)
        return str
    }

    static func timeStrToTimestamp(_ timeStr: String, formatStr: String) -> Int {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = formatStr
        let locale = Locale.init(identifier: "vi")
        dateFormat.locale = locale
        let date = dateFormat.date(from: timeStr) ?? Date()
        let timestamp = Int(date.timeIntervalSince1970)
        return timestamp
    }

    static func timeStrToTimeStr(_ timeStr: String, formatStr: String, toFormatStr: String) -> String {
        let timestamp = DateClass.timeStrToTimestamp(timeStr, formatStr: formatStr)
        return DateClass.timestampToStr(timestamp, formatStr: toFormatStr)
    }

    static func getCurrentTimeStr(formatStr: String) -> String {
        let date = Date()
        let zone = TimeZone.current
        let dateFormat = DateFormatter()
        // 以中国为准
        let locale = Locale.init(identifier: "vi")
        dateFormat.locale = locale
        dateFormat.dateFormat = formatStr
        dateFormat.timeZone = zone
        let str = dateFormat.string(from: date)
        return str
    }
    
    static func dateStringOffset(from: String, offset: Int) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        guard let fromDate = dateFormat.date(from: from) else {
            return from
        }
        
        var cmps = Calendar.current.dateComponents([.year, .month, .day], from: fromDate)
        cmps.day = cmps.day! + offset
        let resultDate = Calendar.current.date(from: cmps)
        return dateFormat.string(from: resultDate!)
    }
    
    static func getTimeStrToDate(_ format: Date.Format, timeStr: String) -> Date {
        let zone = TimeZone.current
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format.rawValue
        dateFormat.timeZone = zone
        let locale = Locale.init(identifier: "vi")
        dateFormat.locale = locale
        return dateFormat.date(from: timeStr)!
    }
    
    static func getSpecialDays(dateStr: String, count: Int) -> [String] {
        var days = [String]()
        let dateformatter = DateFormatter.init()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date = dateformatter.date(from: dateStr)
        let calendar = Calendar.current
        
        for i in 0..<count {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date!)
            dateComponents.day = dateComponents.day! + i
            let newDate = calendar.date(from: dateComponents)
            let dateString = dateformatter.string(from: newDate!)
            days.append(dateString)
        }
        return days
    }
    
    static func startOfMonth(year: Int, month: Int) -> Date {
        let calendar = NSCalendar.current
        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calendar.date(from: startComps)!
        return startDate
    }

    static func endOfMonth(year: Int, month: Int, returnEndTime: Bool = false) -> Date {
        let calendar = NSCalendar.current
        var components = DateComponents()
        components.month = 1
        if returnEndTime {
            components.second = -1
        } else {
            components.day = -1
        }
        let endOfYear = calendar.date(byAdding: components,
                                      to: startOfMonth(year: year, month: month))!
        return endOfYear
    }
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let beginDate = self.getMorningDate()
        let endDate = toDate.getMorningDate()
        let components = Calendar.current.dateComponents([.day], from: beginDate, to: endDate)
        return components.day ?? 0
    }
    
    func getMorningDate() -> Date {
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return (calendar.date(from: components))!
    }
}
