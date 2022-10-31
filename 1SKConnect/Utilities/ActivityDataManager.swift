//
//  ActivityDataManager.swift
//  1SKConnect
//
//  Created by tuyenvx on 07/04/2021.
//

import Foundation
import RealmSwift
import SwiftUI

class ActivityDataManager {
    static let shared = ActivityDataManager()
    private var profileListToken: NotificationToken?
    private var bloodPressureListToken: NotificationToken?
    private var bodyFatListToken: NotificationToken?
    private var deviceListToken: NotificationToken?
    private var spO2ListToken: NotificationToken?
    private var sportListToken: NotificationToken?
    private var stepListToken: NotificationToken?
    private var s5BloodPressureListToken: NotificationToken?
    private var s5HRListToken: NotificationToken?
    private var s5SpO2ListToken: NotificationToken?

    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let bodyFatListDAO = GenericDAO<BodyFatList>()
    private let bloodPressureListDAO = GenericDAO<BloodPressureListModel>()
    private let s5BloodPressureListRecordDAO = GenericDAO<BloodPressureListRecordModel>()
    private let spO2ListDAO = GenericDAO<SpO2DataListModel>()
    private let sportListDAO = GenericDAO<S5SportListRecordModel>()
    private let stepListDAO = GenericDAO<StepListRecordModel>()
    private let s5HRListDAO = GenericDAO<S5HeartRateListRecordModel>()
    private let s5SpO2ListDAO = GenericDAO<S5SpO2ListRecordModel>()
    private let deviceListDAO = GenericDAO<DeviceList>()

    private init() {
        profileListDAO.registerToken(token: &profileListToken) { [weak self] in
            self?.onDataChanged()
        }
        bodyFatListDAO.registerToken(token: &bodyFatListToken) { [weak self] in
            self?.onDataChanged()
        }
        bloodPressureListDAO.registerToken(token: &bloodPressureListToken) { [weak self] in
            self?.onDataChanged()
        }
        deviceListDAO.registerToken(token: &deviceListToken) { [weak self] in
            self?.onDataChanged()
        }
        spO2ListDAO.registerToken(token: &spO2ListToken) { [weak self] in
            self?.onDataChanged()
        }
        sportListDAO.registerToken(token: &sportListToken) { [weak self] in
            self?.onDataChanged()
        }
        stepListDAO.registerToken(token: &stepListToken) { [weak self] in
            self?.onDataChanged()
        }
        s5BloodPressureListRecordDAO.registerToken(token: &s5BloodPressureListToken) { [weak self] in
            self?.onDataChanged()
        }
        s5HRListDAO.registerToken(token: &s5HRListToken) { [weak self] in
            self?.onDataChanged()
        }
        s5SpO2ListDAO.registerToken(token: &s5SpO2ListToken) { [weak self] in
            self?.onDataChanged()
        }
    }

    deinit {
        profileListToken?.invalidate()
        bodyFatListToken?.invalidate()
        deviceListToken?.invalidate()
        bloodPressureListToken?.invalidate()
        spO2ListToken?.invalidate()
        sportListToken?.invalidate()
        stepListToken?.invalidate()
        s5BloodPressureListToken?.invalidate()
        s5HRListToken?.invalidate()
    }

    private func onDataChanged() {
        kNotificationCenter.post(name: .activitiesDataChanged, object: nil)
    }

    func getActivities() -> [ActivityData] {
        var activitiesData: [ActivityData] = []
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return activitiesData
        }

        if let bodyFat = bodyFatListDAO.getObject(with: profile.id)?.bodyfats.array.max(by: {
            $0.createAt.toDate(.hmsdMy)?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate < $1.createAt.toDate(.hmsdMy)?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate
        }) {
            activitiesData.append(.scale(bodyFat))
        }

        if let bloodPressure = bloodPressureListDAO.getObject(with: profile.id)?.bloodPressureList.array.first {
            activitiesData.append(.bp(bloodPressure))
        }
        return activitiesData
    }

    func getMoveActivities() -> [ActivityData] {
        var activitiesData: [ActivityData] = []
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return activitiesData
        }
        if let stepList = stepListDAO.getObject(with: profile.id) {
            if let stepRecord = stepList.stepList.array.first(where: { $0.dateTime.toDate(.ymd)?.isInToday == true }) {
                activitiesData.append(.step(stepRecord))
            }
        }

        if let sportList = sportListDAO.getObject(with: profile.id) {
            let walkRecords = sportList.sportList.array.filter { $0.type == .walk}
            let runRecords = sportList.sportList.array.filter { $0.type == .run}
            let bikeRecords = sportList.sportList.array.filter { $0.type == .ride}
            let climbRecords = sportList.sportList.array.filter { $0.type == .climb}
            
            if !walkRecords.isEmpty {
                if let walkRecord = walkRecords.max(by: { $0.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSinceReferenceDate < $1.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSinceReferenceDate
                }) {
                    activitiesData.append(.sport(walkRecord))
                }
            }
            
            if !runRecords.isEmpty {
                if let runRecord = runRecords.max(by: { $0.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSinceReferenceDate < $1.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSinceReferenceDate
                }) {
                    activitiesData.append(.sport(runRecord))
                }
            }
            
            if !bikeRecords.isEmpty {
                if let bikeRecord = bikeRecords.max(by: { $0.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSinceReferenceDate < $1.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSinceReferenceDate
                }) {
                    activitiesData.append(.sport(bikeRecord))
                }
            }

            if !climbRecords.isEmpty {
                if let climRecord = climbRecords.max(by: { $0.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSinceReferenceDate < $1.dateTime.toDate(.ymdhm)?.timeIntervalSince1970 ?? Date().timeIntervalSinceReferenceDate
                }) {
                    activitiesData.append(.sport(climRecord))
                }
            }
        }
        return activitiesData
    }

    func getOtherActivities() -> [ActivityData] {
        var activitiesData: [ActivityData] = []
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return activitiesData
        }
        let bodyFat = bodyFatListDAO.getObject(with: profile.id)?.bodyfats.array.max(by: {
            $0.createAt.toDate(.hmsdMy)?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate < $1.createAt.toDate(.hmsdMy)?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate
        })
        activitiesData.append(.scale(bodyFat))

        return activitiesData
    }

    func getSignificanceActivities() -> [ActivityData] {
        var activitiesData: [ActivityData] = []
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return activitiesData
        }
        let bloodPressure = bloodPressureListDAO.getObject(with: profile.id)?.bloodPressureList.array.first
        let s5BpRecord = s5BloodPressureListRecordDAO.getObject(with: profile.id)?.bloodPressureList.array.first
        let spO2 = spO2ListDAO.getObject(with: profile.id)?.waveformList.array.first
        let s5HR = s5HRListDAO.getObject(with: profile.id)?.hrList.array.first
        let s5SpO2 = s5SpO2ListDAO.getObject(with: profile.id)?.spO2List.array.first

        // check Timestamp to show the nearest Value
        let bpDate = bloodPressure?.date ?? 0
        let spO2Date = spO2?.endTime ?? 0
        let s5HRDate = s5HR?.timestamp ?? 0
        let s5BpDate = s5BpRecord?.timestamp ?? 0
        let s5SpO2Date = s5SpO2?.timestamp ?? 0

        // get bloodPressureValue
        if bpDate >= s5BpDate {
            // get bp in Biolight
            activitiesData.append(.bp(bloodPressure))
        } else {
            // get bp in S5 SM
            activitiesData.append(.s5Bp(s5BpRecord))
        }
        
        // get spO2Value
        if spO2Date >= s5SpO2Date {
            // get spO2 in SpO2Device
            activitiesData.append(.spO2(spO2))
        } else {
            // get spO2 in S5 SM
            activitiesData.append(.s5SpO2(s5SpO2))
        }
        
        let maxDate = max(bpDate, spO2Date, s5HRDate)
        // get hrValue
        if maxDate == bpDate {
            // get hr in BioLight Device
            activitiesData.append(.bp(bloodPressure))
        } else if maxDate == spO2Date {
            // get hr in SpO2Device
            activitiesData.append(.spO2(spO2))
        } else {
            // get hr in S5 SM
            activitiesData.append(.s5HR(s5HR))
        }

        return activitiesData
    }

    func getDeviceActivities() -> [ActivityData] {
        var activitiesData: [ActivityData] = []
        guard let devices = deviceListDAO.getObject(with: SKKey.linkDevice)?.devices.array,
              let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return activitiesData
        }
        let bodyFats = bodyFatListDAO.getObject(with: profile.id)?.bodyfats.array
        let deviceBodyfats = devices.compactMap { (device) -> ActivityData? in
            let deviceBodyFat = bodyFats?.filter { $0.deviceMac == device.mac }
            if let bodyFat = deviceBodyFat?.max(by: {
                $0.createAt.toDate(.hmsdMy)?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate < $1.createAt.toDate(.hmsdMy)?.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate
            }) {
                return .scale(bodyFat)
            } else {
                if device.type == .scale {
                    let bodyFat = BodyFat(scale: device)
                    return .scale(bodyFat)
                } else {
                    return nil
                }
            }
        }
        activitiesData.append(contentsOf: deviceBodyfats)

        let bloodPressures = bloodPressureListDAO.getObject(with: profile.id)?.bloodPressureList.array
        let deviceBloodPressures = devices.compactMap { (device) -> ActivityData? in
            let deviceBloodPressure = bloodPressures?.filter { $0.deviceMac == device.mac }
            if let bloodPressure = deviceBloodPressure?.first {
                return .bp(bloodPressure)
            } else {
                if device.type == .biolightBloodPressure {
                    let bloodPressure = BloodPressureModel(biolight: device)
                    return .bp(bloodPressure)
                } else {
                    return nil
                }
            }
        }
        activitiesData.append(contentsOf: deviceBloodPressures)

        let spO2List = spO2ListDAO.getObject(with: profile.id)?.waveformList.array
        let deviceSpO2List = devices.compactMap { (device) -> ActivityData? in
            let deviceSpO2 = spO2List?.filter { $0.device?.mac == device.mac }
            if let spO2 = deviceSpO2?.first {
                return .spO2(spO2)
            } else {
                if device.type == .spO2 {
                    let spO2 = WaveformListModel(spO2: device)
                    return .spO2(spO2)
                } else {
                    return nil
                }
            }
        }
        activitiesData.append(contentsOf: deviceSpO2List)
        
        // devices step
        let step = stepListDAO.getObject(with: profile.id)?.stepList.array.first
        let stepData = ActivityData.step(step)

        activitiesData.append(contentsOf: [stepData])
        return activitiesData
    }
}
