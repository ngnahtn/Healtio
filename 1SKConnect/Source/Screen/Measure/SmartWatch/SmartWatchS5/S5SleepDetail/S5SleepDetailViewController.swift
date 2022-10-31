//
//  
//  S5SleepDetailViewController.swift
//  1SKConnect
//
//  Created by TrungDN on 30/12/2021.
//
//

import UIKit

class S5SleepDetailViewController: BaseViewController {

    @IBOutlet weak var timeFillterType: SKTimeFilterView!
    @IBOutlet weak var detailTableView: UITableView!
    var presenter: S5SleepDetailPresenterProtocol!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title = R.string.localizable.smart_watch_s5_sleep()
        self.timeFillterType.delegate = self
        self.timeFillterType.defaultType = self.presenter.model.timeType
        self.detailTableView.registerNib(ofType: S5SleepDetailTableViewCell.self)
    }
    
    // MARK: - Action
    
}

// MARK: - S5SleepDetailViewProtocol
extension S5SleepDetailViewController: S5SleepDetailViewProtocol {
    func reloadDataWithTimeType(_ timeType: TimeFilterType) {
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
        }
    }
}

// MARK: - S5SleepDetailViewController
extension S5SleepDetailViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.setFilterTime(with: filterType)
    }
}

// MARK: - UITableViewDelegate
extension S5SleepDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.presenter.model.timeType == .day {
            return 240
        } else {
            return 200
        }
    }
}

// MARK: - UITableViewDataSource
extension S5SleepDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: S5SleepDetailTableViewCell.self, for: indexPath)
        cell.model = presenter.model
        return cell
    }
}
