//
//  
//  SmartWatchExerciseViewController.swift
//  1SKConnect
//
//  Created by admin on 13/12/2021.
//
//

import UIKit

class SmartWatchExerciseViewController: BaseViewController {

    var presenter: SmartWatchExercisePresenterProtocol!
    @IBOutlet weak var exerciseTableView: UITableView!
    @IBOutlet weak var timeFillterType: SKTimeFilterView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
        
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title = R.string.localizable.smart_watch_s5_exercise()
        self.setUpTableView()
        self.timeFillterType.delegate = self
        self.timeFillterType.defaultType = self.presenter.timeDefault
    }

    private func setUpTableView() {
        exerciseTableView.registerNib(ofType: SportTableViewCell.self)
        exerciseTableView.registerNib(ofType: ExerciseDetailTableViewCell.self)
        exerciseTableView.registerNib(ofType: ExcerciseDetailWMYTableViewCell.self)
        exerciseTableView.dataSource = self
        exerciseTableView.delegate = self
        exerciseTableView.separatorStyle = .none
    }
    // MARK: - Action
}

// MARK: - SmartWatchExerciseViewProtocol
extension SmartWatchExerciseViewController: SmartWatchExerciseViewProtocol {

    func reloadExcerciseData() {
        DispatchQueue.main.async {
            self.exerciseTableView.reloadData()
        }
    }

}

// MARK: - S5ExerciseProtocol
extension SmartWatchExerciseViewController: ExcerciseDetailTBVCellProtocol {
    func onChangeTimeTypePressed(_ type: TimeChangeActionType) {
        self.presenter.onDayDidChange(type)
    }
}

// MARK: - TableViewDelegate
extension SmartWatchExerciseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let timeType = self.presenter.timeDefault
        if timeType == .day {
            if indexPath.row == 0 {
                return 666
            } else {
                return 100
            }
        } else {
            return 450
        }
    }
}

// MARK: - TableViewDataSource
extension SmartWatchExerciseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let timeType = self.presenter.timeDefault
        if timeType == .day {
            guard let records = self.presenter.sportDayRecords else { return 1 }
            return 1 + records.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timeType = self.presenter.timeDefault
        if timeType == .day {
            if indexPath.row == 0 {
                let cell = tableView.dequeueCell(ofType: ExerciseDetailTableViewCell.self, for: indexPath)
                cell.model = presenter.excercise
                cell.isMax = presenter.isMax
                cell.isMin = presenter.isMin
                cell.sportDuration = self.presenter.sportDuration
                cell.sportNumber = self.presenter.sportNumber
                cell.delegate = self
                return cell
            } else {
                let cell = tableView.dequeueCell(ofType: SportTableViewCell.self, for: indexPath)
                if let records = self.presenter.sportDayRecords {
                    cell.recordModel = records[indexPath.row - 1]
                }
                return cell
            }
        } else {
            let cell = tableView.dequeueCell(ofType: ExcerciseDetailWMYTableViewCell.self, for: indexPath)
            cell.model = self.presenter.wmyModel
            return cell
        }
    }
}

// MARK: - TimeFilterViewDelegate
extension SmartWatchExerciseViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.handleDataWithTimeType(filterType)
    }
}
