//
//  TimeFilterType.swift
//  1SKConnect
//
//  Created by tuyenvx on 14/04/2021.
//

import Foundation

enum TimeFilterType: CaseIterable {
    case day
    case week
    case month
    case year

    var name: String {
        switch self {
        case .day:
            return L.day.localized
        case .week:
            return L.week.localized
        case .month:
            return L.month.localized
        case .year:
            return L.year.localized
        }
    }

    func getStartRangeValue(of date: Date) -> Date {
        var startRangeDate: Date
        switch self {
        case .day:
            startRangeDate = date.startOfDay
        case .week:
            startRangeDate = date.startOfWeek
        case .month:
            startRangeDate = date.startOfMonth
        case .year:
            startRangeDate = date.startOfYear
        }
        return startRangeDate
    }

    func getEndRangeValue(of date: Date) -> Date {
        var endRangeDate: Date
        switch self {
        case .day:
            endRangeDate = date.endOfDay
        case .week:
            endRangeDate = date.endOfWeek
        case .month:
            endRangeDate = date.endOfMonth
        case .year:
            endRangeDate = date.endOfYear
        }
        return endRangeDate
    }

    func getNextStartRangeValue(of date: Date) -> Date {
        var startRangeDate: Date
        switch self {
        case .day:
            startRangeDate = date.nextDay
        case .week:
            startRangeDate = date.nextWeek
        case .month:
            startRangeDate = date.nextMonth
        case .year:
            startRangeDate = date.nextYear
        }
        return startRangeDate
    }

    func getPriviousStartRangeValue(of date: Date) -> Date {
        var endRangeDate: Date
        switch self {
        case .day:
            endRangeDate = date.previousDay
        case .week:
            endRangeDate = date.previousWeek
        case .month:
            endRangeDate = date.previousMonth
        case .year:
            endRangeDate = date.previousYear
        }
        return endRangeDate
    }

}

enum WeekDay: Int {
    case sun = 1
    case mon
    case tue
    case wed
    case thu
    case fri
    case sat

    var name: String {
        switch self {
        case .mon:
            return L.monday.localized
        case .tue:
            return L.tuesday.localized
        case .wed:
            return L.wednesday.localized
        case .thu:
            return L.thursday.localized
        case .fri:
            return L.friday.localized
        case .sat:
            return L.saturday.localized
        case .sun:
            return L.sunday.localized
        }
    }
}
