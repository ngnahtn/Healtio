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
    }
    
    // MARK: - Action
    
}

// MARK: - S5HeartRateDetailViewProtocol
extension S5HeartRateDetailViewController: S5HeartRateDetailViewProtocol {
    func reloadDataWithTimeType(_ timeType: TimeFilterType) {
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension S5HeartRateDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
}

// MARK: - UITableViewDataSource
extension S5HeartRateDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: S5HeartRateDetailTableViewCell.self, for: indexPath)
        cell.model = self.presenter.model
        return cell
    }
}

extension S5HeartRateDetailViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.setFilterTime(with: filterType)
    }
}
