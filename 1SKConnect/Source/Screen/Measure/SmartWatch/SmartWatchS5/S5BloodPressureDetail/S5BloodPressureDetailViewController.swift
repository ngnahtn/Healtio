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
        self.navigationItem.title = R.string.localizable.bloodpressure()
    }
    
    // MARK: - Action
    
}

// MARK: - S5BloodPressureDetailViewProtocol
extension S5BloodPressureDetailViewController: S5BloodPressureDetailViewProtocol {
    func reloadDataWithTimeType(_ timeType: TimeFilterType) {
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension S5BloodPressureDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}

// MARK: - UITableViewDataSource
extension S5BloodPressureDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: S5BloodPressureDetailTableViewCell.self, for: indexPath)
        cell.model = presenter.model
        return cell
    }
}

extension S5BloodPressureDetailViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.setFilterTime(with: filterType)
    }
}
