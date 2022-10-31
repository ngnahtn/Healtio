//
//  
//  S5TemperatureDetailViewController.swift
//  1SKConnect
//
//  Created by TrungDN on 28/12/2021.
//
//

import UIKit

class S5TemperatureDetailViewController: BaseViewController {

    @IBOutlet weak var timeFillterType: SKTimeFilterView!
    @IBOutlet weak var detailTableView: UITableView!
    var presenter: S5TemperatureDetailPresenterProtocol!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title = R.string.localizable.smart_watch_s5_temperature()
        self.timeFillterType.delegate = self
        self.timeFillterType.defaultType = self.presenter.model.timeType
        self.detailTableView.registerNib(ofType: S5TemperatureDetailTableViewCell.self)
    }
    
    // MARK: - Action
    
}

// MARK: - S5HeartRateDetailViewProtocol
extension S5TemperatureDetailViewController: S5TemperatureDetailViewProtocol {
    func reloadDataWithTimeType(_ timeType: TimeFilterType) {
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension S5TemperatureDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
}

// MARK: - UITableViewDataSource
extension S5TemperatureDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: S5TemperatureDetailTableViewCell.self, for: indexPath)
        cell.model = self.presenter.model
        return cell
    }
}

extension S5TemperatureDetailViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.setFilterTime(with: filterType)
    }
}
