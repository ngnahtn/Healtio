//
//  
//  S5BloodPressureDetailViewController.swift
//  1SKConnect
//
//  Created by TrungDN on 27/12/2021.
//
//

import UIKit

class S5BloodPressureDetailViewController: BaseViewController {

    @IBOutlet weak var timeFillterType: SKTimeFilterView!
    var presenter: S5BloodPressureDetailPresenterProtocol!
    @IBOutlet weak var detailTableView: UITableView!
    var lastData: BloodPressureDetailModel?
   
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.timeFillterType.delegate = self
        self.timeFillterType.defaultType = self.presenter.model.timeType
        self.detailTableView.registerNib(ofType: S5BloodPressureDetailTableViewCell.self)
        self.detailTableView.registerNib(ofType: RecentValueTableViewCell.self)
        self.detailTableView.registerNib(ofType: DescriptionTableViewCell.self)
        self.navigationItem.title = R.string.localizable.bloodpressure()
    }
    
    // MARK: - Action
    
}

// MARK: - S5BloodPressureDetailViewProtocol
extension S5BloodPressureDetailViewController: S5BloodPressureDetailViewProtocol {
    func reloadDataWithTimeType(_ timeType: TimeFilterType) {
        guard let records: [BloodPressureRecordModel] = self.presenter.model.dataValues?.bloodPressureList.array, let lastObject = records.first?.bloodPressureDetail.last else {
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
extension S5BloodPressureDetailViewController: UITableViewDelegate {
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
extension S5BloodPressureDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if lastData != nil {
            return 3
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            if let data = self.lastData {
                return data.state.listDescriptions.count
            }
            return 1
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueCell(ofType: S5BloodPressureDetailTableViewCell.self, for: indexPath)
            cell.model = presenter.model
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueCell(ofType: RecentValueTableViewCell.self, for: indexPath)
            cell.fetchData(with: self.lastData)
            return cell
        }
        let cell = tableView.dequeueCell(ofType: DescriptionTableViewCell.self, for: indexPath)
        guard let data = lastData else { return cell }
        cell.config(with: data.state.listDescriptions[indexPath.row])
        return cell
        
    }
}

extension S5BloodPressureDetailViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.setFilterTime(with: filterType)
    }
}
