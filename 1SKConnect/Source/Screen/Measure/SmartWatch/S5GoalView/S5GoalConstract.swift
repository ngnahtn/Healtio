//
//  
//  S5GoalConstract.swift
//  1SKConnect
//
//  Created by admin on 17/12/2021.
//
//

import UIKit
import SwiftUI

// MARK: - View
protocol S5GoalViewProtocol: AnyObject {
    func getGoal(with goal: Int)
}

// MARK: - Presenter
protocol S5GoalPresenterProtocol {

    var safeAreaBottom: CGFloat { get }

    func onViewDidLoad()
    func saveGoal(with value: Int)
}

// MARK: - Interactor Input
protocol S5GoalInteractorInputProtocol {

    func startObserver()
    func startSaveGoal(with goal: Int)
}

// MARK: - Interactor Output
protocol S5GoalInteractorOutputProtocol: AnyObject {
    func getGoal(with goal: Int)
}

// MARK: - Router
protocol S5GoalRouterProtocol {
}
