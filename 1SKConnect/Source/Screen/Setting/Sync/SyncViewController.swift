//
//  SyncViewController.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import UIKit

class SyncViewController: BaseViewController {
    // MARK: - Properties
    @IBOutlet weak var syncUserTableView: UITableView!
    var presenter: SyncPresenter!

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.onViewDidLoad()
        self.setupDefaults()
    }
}

// MARK: - Helpers
extension SyncViewController {
    private func setupDefaults() {
        setupTableView()
        navigationItem.title = L.syncData.localized
    }

    private func setupTableView() {
        syncUserTableView.registerNib(ofType: SyncTableViewCell.self)
        syncUserTableView.estimatedRowHeight = 70
        syncUserTableView.backgroundColor = .white
        syncUserTableView.contentInset.top = 8
    }
}

// MARK: - SyncViewProtocol
extension SyncViewController: SyncViewProtocol {
    func reloadData() {
        self.syncUserTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension SyncViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRow(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: SyncTableViewCell.self, for: indexPath)
        cell.model = presenter.itemForRow(at: indexPath)
        return cell
    }
}
// MARK: - UITableViewDelegate
extension SyncViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.onItemDidSelected(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
