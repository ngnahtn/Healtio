//
//  
//  SmartWatchExercisePresenter.swift
//  1SKConnect
//
//  Created by admin on 13/12/2021.
//
//

import UIKit
import RealmSwift

class SmartWatchExercisePresenter {

    weak var view: SmartWatchExerciseViewProtocol?
    private var interactor: SmartWatchExerciseInteractorInputProtocol
    private var router: SmartWatchExerciseRouterProtocol

    // excercise properties
    var excerciseData: StepRecordModel? {
        didSet {
            view?.reloadExcerciseData()
        }
    }
    
    var wmyStepDetail: S5WMYExcerciseDetail? {
        didSet {
            guard wmyStepDetail != nil else {
                return
            }
            view?.reloadExcerciseData()
        }
    }

    // sport properties
    private let sportListModelDAO = GenericDAO<S5SportListRecordModel>()
    private let profileListDAO = GenericDAO<ProfileListModel>()
    var sportNotificationToken: NotificationToken?
    var sportRecordList: [S5SportRecordModel]?
    var sportRecordListDay: [S5SportRecordModel]? {
        didSet {
            view?.reloadExcerciseData()
        }
    }
    // calculation properties
    var timeType: TimeFilterType = .day {
        didSet {
            view?.reloadExcerciseData()
        }
    }
    
    var smartWatch: DeviceModel!
    var currentIndex: Int = 0
    var isDataMax: Bool = true
    var isDataMin: Bool = true

    init(interactor: SmartWatchExerciseInteractorInputProtocol,
         router: SmartWatchExerciseRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    deinit {
        self.sportNotificationToken?.invalidate()
    }
}

// MARK: - SmartWatchExercisePresenterProtocol
extension SmartWatchExercisePresenter: SmartWatchExercisePresenterProtocol {
    var wmyModel: S5WMYExcerciseDetail {
        if let wmyStep = self.wmyStepDetail {
            return wmyStep
        } else {
            return S5WMYExcerciseDetail(timeType: self.timeType)
        }
    }
    
    var sportNumber: Int {
        guard let records = self.sportRecordListDay else { return 0}
        return records.count
    }

    var sportDuration: Int {
        guard let records = self.sportRecordListDay else { return 0}
        return records.map { $0.duration }.reduce(0, +)
    }

    var sportDayRecords: [S5SportRecordModel]? {
        return self.sportRecordListDay
    }

    var isMax: Bool {
        return self.isDataMax
    }

    var isMin: Bool {
        return self.isDataMin
    }
    
    var timeDefault: TimeFilterType {
        return self.timeType
    }

    var excercise: StepRecordModel? {
        return self.excerciseData
    }

    /// handle Excercise Data when day changes
    /// - Parameter actionType: DayChangeActionType
    func onDayDidChange(_ actionType: TimeChangeActionType) {
        switch actionType {
        case .next:
            guard let unwrappedModel = self.wmyStepDetail else { return }
            guard let listRecord = unwrappedModel.stepList else { return }
            let record = listRecord.stepList.array
            if !record.isEmpty {
                if currentIndex <= 0 {
                    return
                } else {
                    self.currentIndex -= 1
                    if self.currentIndex == 0 {
                        self.isDataMin = true
                    } else {
                        self.isDataMin = false
                    }
                    self.isDataMax = false
                    self.excerciseData = record[self.currentIndex]
                }
            }
        case .previous:
            guard let unwrappedModel = self.wmyStepDetail else { return }
            guard let listRecord = unwrappedModel.stepList else { return }
            let record = listRecord.stepList.array
            if !record.isEmpty {
                if currentIndex >= record.count - 1 {
                    return
                } else {
                    self.currentIndex += 1
                    if self.currentIndex == record.count - 1 {
                        self.isDataMax = true
                    } else {
                        self.isDataMax = false
                    }
                    self.isDataMin = false
                    self.excerciseData = record[self.currentIndex]
                }
            }
        }
        guard let data = self.excerciseData else { return }
        let defaultDate = data.dateTime.toDate(.ymd) ?? Date()
        self.handleSportData(with: defaultDate)
    }

    func handleDataWithTimeType(_ timeType: TimeFilterType) {
        self.timeType = timeType
        self.wmyStepDetail?.timeType = timeType
    }

    func onViewDidLoad() {
        registerToken()
        self.interactor.startObserver()
    }
}

// MARK: - SmartWatchExerciseInteractorOutput 
extension SmartWatchExercisePresenter: SmartWatchExerciseInteractorOutputProtocol {
    func onFinishedGetStepList(model: StepListRecordModel?) {
        guard let model = model else {
            self.wmyStepDetail?.stepList = nil
            return
        }
        self.wmyStepDetail = S5WMYExcerciseDetail(timeType: self.timeType, stepList: model)
        guard let unwrappedModel = self.wmyStepDetail else { return }
        guard let listRecord = unwrappedModel.stepList else { return }
        if !listRecord.stepList.isEmpty {
            self.excerciseData = listRecord.stepList.array[0]
        }
        if listRecord.stepList.count <= 1 {
            self.isDataMax = true
        } else {
            self.isDataMax = false
        }
        self.onSportListChange()
    }
    
}

// MARK: - Helpers
extension SmartWatchExercisePresenter {

    private func registerToken() {
        self.sportListModelDAO.registerToken(token: &self.sportNotificationToken) { [weak self] in
            guard let `self` = self else { return }
            self.onSportListChange()
        }
    }

    // Handle SportList Change()
    private func onSportListChange() {
        guard let profile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if let sportList = self.sportListModelDAO.getObject(with: profile.id) {
            self.sportRecordList = sportList.sportList.array
            guard let records = sportRecordList else { return }
            let uniquePosts = checkDoubleRecords(in: records)

            guard let unwrappedModel = self.wmyStepDetail else { return }
            guard let listRecord = unwrappedModel.stepList else { return }
            let stepRecords = listRecord.stepList.array
            let todayDate = stepRecords[0].dateTime.toDate(.ymd) ?? Date()
            if todayDate.isInToday == true {
                self.sportRecordListDay = uniquePosts.filter { $0.dateTime.toDate(.ymdhm)?.isInToday == true }
            } else {
                self.sportRecordListDay = uniquePosts.filter { $0.dateTime.toDate(.ymdhm)?.isInSameDay(as: todayDate) == true }
            }
            
        }
    }

    // handle SportData when time change
    private func handleSportData(with date: Date) {
        guard let records = sportRecordList else { return }
        let uniquePosts = checkDoubleRecords(in: records)
        self.sportRecordListDay = uniquePosts.filter { $0.dateTime.toDate(.ymdhm)?.isInSameDay(as: date) == true }
    }
    
    // handle duplicate Sport Data
    private func checkDoubleRecords(in records: [S5SportRecordModel]) -> [S5SportRecordModel] {
        let filterList = records.filter({ $0.deviceMac == smartWatch.mac })
        var uniquePosts = [S5SportRecordModel]()
        for post in filterList {
            if !uniquePosts.contains(where: {$0.dateTime == post.dateTime }) {
                uniquePosts.append(post)
            }
        }
        return uniquePosts
    }
}
