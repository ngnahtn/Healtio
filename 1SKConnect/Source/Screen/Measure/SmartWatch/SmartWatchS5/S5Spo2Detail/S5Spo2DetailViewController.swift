//
//  
//  S5Spo2DetailViewController.swift
//  1SKConnect
//
//  Created by Be More on 28/12/2021.
//
//

import UIKit

class S5Spo2DetailViewController: BaseViewController {

    @IBOutlet weak var timeFillterType: SKTimeFilterView!
    @IBOutlet weak var detailTableView: UITableView!
    var presenter: S5Spo2DetailPresenterProtocol!
    var lastData: S5SpO2DetailModel?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title = R.string.localizable.smart_watch_s5_spO2()
        self.timeFillterType.delegate = self
        self.timeFillterType.defaultType = self.presenter.model.timeType
        self.detailTableView.registerNib(ofType: S5SpO2DetailTableViewCell.self)
        self.detailTableView.registerNib(ofType: RecentValueTableViewCell.self)
        self.detailTableView.registerNib(ofType: DescriptionTableViewCell.self)
    }
    
    // MARK: - Action
    
}

// MARK: - S5HeartRateDetailViewProtocol
extension S5Spo2DetailViewController: S5Spo2DetailViewProtocol {
    func reloadDataWithTimeType(_ timeType: TimeFilterType) {
        guard let records: [S5SpO2RecordModel] = self.presenter.model.dataValues?.spO2List.array, let lastObject = records.first?.spO2Detail.last else {
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
extension S5Spo2DetailViewController: UITableViewDelegate {
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
extension S5Spo2DetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if lastData != nil {
            return 3
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            if let data = self.lastData {
                return data.state.listDescription.count
            }
            return 1
        }
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueCell(ofType: S5SpO2DetailTableViewCell.self, for: indexPath)
            cell.model = self.presenter.model
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueCell(ofType: RecentValueTableViewCell.self, for: indexPath)
            cell.fetchSpO2Data(with: self.lastData)
            return cell
        }
        let cell = tableView.dequeueCell(ofType: DescriptionTableViewCell.self, for: indexPath)
        guard let data = lastData else { return cell }
        cell.config(with: data.state.listDescription[indexPath.row])
        return cell
    }
}

extension S5Spo2DetailViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.setFilterTime(with: filterType)
    }
}
