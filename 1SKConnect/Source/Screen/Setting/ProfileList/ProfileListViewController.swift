//
//  
//  ProfileListViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit

class ProfileListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var presenter: ProfileListPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
    }
    // MARK: - Setup
    private func setupDefaults() {
        setupTableView()
        navigationItem.title = L.healthProfile.localized
        setRightBarButton(style: .addProfile) { [weak self] _ in
            self?.presenter.onButtonAddProfileDidTapped()
        }
    }

    private func setupTableView() {
        tableView.registerNib(ofType: ProfileTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 70
        tableView.backgroundColor = .white
        tableView.contentInset.top = 8
    }
}

// MARK: - ProfileListViewProtocol
extension ProfileListViewController: ProfileListViewProtocol {
    func reloadData() {
        tableView.reloadData()
    }
}
// MARK: - UITableViewDataSource
extension ProfileListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRow(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: ProfileTableViewCell.self, for: indexPath)
        cell.config(with: presenter.itemForRow(at: indexPath))
        return cell
    }
}
// MARK: - UITableViewDelegate
extension ProfileListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.onItemDidSelected(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
