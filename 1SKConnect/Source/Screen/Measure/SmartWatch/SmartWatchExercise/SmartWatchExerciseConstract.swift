//
//  
//  SmartWatchExerciseConstract.swift
//  1SKConnect
//
//  Created by admin on 13/12/2021.
//
//

import UIKit

// MARK: - View
protocol SmartWatchExerciseViewProtocol: AnyObject {
    func reloadExcerciseData()
}

// MARK: - Presenter
protocol SmartWatchExercisePresenterProtocol {
    func onViewDidLoad()

    var excercise: StepRecordModel? { get }

    var wmyModel: S5WMYExcerciseDetail { get }

    var timeDefault: TimeFilterType { get }
    
    var sportDayRecords: [S5SportRecordModel]? { get }
    
    var sportDuration: Int { get }
    
    var sportNumber: Int { get }

    var isMax: Bool { get }

    var isMin: Bool { get }
    
    func handleDataWithTimeType(_ timeType: TimeFilterType)
    func onDayDidChange(_ actionType: TimeChangeActionType)
}

// MARK: - Interactor Input
protocol SmartWatchExerciseInteractorInputProtocol {
    func startObserver()
}

// MARK: - Interactor Output
protocol SmartWatchExerciseInteractorOutputProtocol: AnyObject {
    func onFinishedGetStepList(model: StepListRecordModel?)
    
}

// MARK: - Router
protocol SmartWatchExerciseRouterProtocol {
}
