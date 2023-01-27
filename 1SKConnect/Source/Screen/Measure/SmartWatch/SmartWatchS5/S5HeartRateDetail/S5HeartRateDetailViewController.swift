//
//  
//  S5HeartRateDetailViewController.swift
//  1SKConnect
//
//  Created by Be More on 27/12/2021.
//
//

import UIKit

class S5HeartRateDetailViewController: BaseViewController {

    @IBOutlet weak var timeFillterType: SKTimeFilterView!
    @IBOutlet weak var detailTableView: UITableView!
    var presenter: S5HeartRateDetailPresenterProtocol!
    var lastData: S5HeartRateDetailModel?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title = R.string.localizable.heartRate()
        self.timeFillterType.delegate = self
        self.timeFillterType.defaultType = self.presenter.model.timeType
        self.detailTableView.registerNib(ofType: S5HeartRateDetailTableViewCell.self)
        self.detailTableView.registerNib(ofType: RecentValueTableViewCell.self)
        self.detailTableView.registerNib(ofType: DescriptionTableViewCell.self)
    }
    
    // MARK: - Action
    
}

// MARK: - S5HeartRateDetailViewProtocol
extension S5HeartRateDetailViewController: S5HeartRateDetailViewProtocol {
    func reloadDataWithTimeType(_ timeType: TimeFilterType) {
        guard let records: [S5HeartRateRecordModel] = self.presenter.model.dataValues?.hrList.array, let lastObject = records.first?.hrDetail.last else {
            return
        }
        self.lastData = lastObject
        print(self.lastData)
        
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension S5HeartRateDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        } else if indexPath.section == 2 {
            return UITableView.automaticDimension
        }
        return 130
    }
}

// MARK: - UITableViewDataSource
extension S5HeartRateDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if lastData != nil {
            return 3
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            if let data = self.lastData {
                return data.state.listVitalSignsDescription.count
            }
            return 1
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueCell(ofType: S5HeartRateDetailTableViewCell.self, for: indexPath)
            cell.model = self.presenter.model
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueCell(ofType: DescriptionTableViewCell.self, for: indexPath)
            guard let data = lastData else { return cell}
            if indexPath.row == 0 {
                cell.configHrDescription(with: data.state.listVitalSignsDescription[indexPath.row], and: data.hrExerciseModel.maxHr.stringValue)
            } else {
                cell.configHrDescription(with: data.state.listVitalSignsDescription[indexPath.row], and: "\(data.hrExerciseModel.minHrRateZone) - \(data.hrExerciseModel.maxHrRateZone)")
            }
            return cell
        }
        let cell = tableView.dequeueCell(ofType: RecentValueTableViewCell.self, for: indexPath)
        cell.fetchHrData(with: self.lastData)
        return cell
    }
}

extension S5HeartRateDetailViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.setFilterTime(with: filterType)
    }
}
