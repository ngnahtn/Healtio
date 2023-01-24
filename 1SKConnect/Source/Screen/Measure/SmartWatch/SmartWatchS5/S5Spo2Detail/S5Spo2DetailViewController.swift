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
    }
    
    // MARK: - Action
    
}

// MARK: - S5HeartRateDetailViewProtocol
extension S5Spo2DetailViewController: S5Spo2DetailViewProtocol {
    func reloadDataWithTimeType(_ timeType: TimeFilterType) {
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension S5Spo2DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}

// MARK: - UITableViewDataSource
extension S5Spo2DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: S5SpO2DetailTableViewCell.self, for: indexPath)
        cell.model = self.presenter.model
        return cell
    }
}

extension S5Spo2DetailViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.setFilterTime(with: filterType)
    }
}
