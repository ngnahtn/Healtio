//
//  ZHJSleep+Extension.swift
//  1SKConnect
//
//  Created by TrungDN on 13/12/2021.
//

import Foundation
import TrusangBluetooth

extension ZHJSleep {
    func splitSleep() -> [ZHJSleep] {
        let kEndTime = " 11:00"
        let kBeginTime = " 21:00"
        // End of the second night of the previous day's sleep time node, 09:00 can be customized to other times, the default is 9 o'clock
        let yesterdayEndTime = self.dateTime + kEndTime
        // Today's midnight sleep start time node, 21:00 can be customized to other times, the default is 21:00
        let todayBeginTime = self.dateTime + kBeginTime
        
        // Sleep data model of the previous day and the middle of the night
        let model1 = ZHJSleep()
        model1.details = self.details.filter { $0.dateTime.compare(yesterdayEndTime) == .orderedAscending
            || $0.dateTime.compare(yesterdayEndTime) == .orderedSame }
        model1.dateTime = self.dateTime
        model1.mid = self.mid
        model1.countingSleepTypeDuration()
        
        let model2 = ZHJSleep()
        model2.details = self.details.filter { $0.dateTime.compare(todayBeginTime) == .orderedDescending
            || $0.dateTime.compare(todayBeginTime) == .orderedSame }
        model2.dateTime = DateClass.dateStringOffset(from: self.dateTime, offset: 1)
        model2.mid = self.mid
        model2.countingSleepTypeDuration()
        
        return [model1, model2]
    }
    
    func countingSleepTypeDuration() {
        self.beginDuration = self.details.filter { $0.type == 5 }.reduce(0) { $0 + $1.duration }
        self.lightDuration = self.details.filter { $0.type == 2 }.reduce(0) { $0 + $1.duration }
        self.deepDuration = self.details.filter { $0.type == 3 }.reduce(0) { $0 + $1.duration }
        self.awakeDuration = self.details.filter { $0.type == 1 }.reduce(0) { $0 + $1.duration }
        self.REMDuration = self.details.filter { $0.type == 4 }.reduce(0) { $0 + $1.duration }
    }
}
