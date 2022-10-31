//
//  
//  ScaleViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit

class ScaleViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var turnOnBLEAlertView: UIView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var turnOnBLEAlertViewHeightConstraint: NSLayoutConstraint!
    private lazy var header: ScaleTableViewHeader = createHeaderView()
    private var currentSwipeCellIndex: Int?
    @IBOutlet weak var alertViewLabel: UILabel!
    @IBOutlet weak var alertIconImageView: UIImageView!

    var presenter: ScalePresenterProtocol!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.onViewDidDisappear()
    }

    // MARK: - Setup
    private func setupDefaults() {
        setupTableView()
        turnOnBLEAlertView.roundCorners(cornes: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24)
    }

    private func setupTableView() {
        tableView.registerNib(ofType: HistoryWeightResultTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        header.delegate = self
        tableView.tableHeaderView = header
        tableView.estimatedRowHeight = 64
        tableView.contentInset.bottom = 20
        tableView.backgroundColor = .white
    }

    private func createHeaderView() -> ScaleTableViewHeader {
        let headerView = ScaleTableViewHeader(frame: CGRect(origin: .zero,
                                                            size: CGSize(width: Constant.Screen.width, height: 610)))
        headerView.setTimeFilterDelegate(self)
        return headerView
    }

    // MARK: - Action
    @IBAction func buttonCloseDidTapped(_ sender: Any) {
        presenter.onButtonCloseDidTapped()
    }

    @IBAction func onCloseTurnOnBLEAlertButtonDidTapped(_ sender: Any) {
        hide()
    }

    @IBAction func onButtonSettingDidTapped(_ sender: Any) {
        if self.presenter.isShowBLEConnection {
            presenter.onButtonSettingBLEDidTapped()
        } else {
            self.presenter.onButtonSettingLinkTapped()
            self.hide()
        }
    }

    @IBAction func onBackgroundDidTapped(_ sender: Any) {
        hide()
    }

    func show() {
        if self.presenter.isShowBLEConnection {
            self.alertViewLabel.text = "Bật Bluetooth để 1SK-Connect có thể kết nối với thiết bị của bạn"
            self.alertIconImageView.image = R.image.ic_phone_ble()
        } else {
            self.alertViewLabel.text = "Bạn chưa liên kết tài khoản để đồng bộ. Vào mục cài đặt để đồng bộ"
            self.alertIconImageView.image = R.image.ic_link_2()
        }
        transparentView.isHidden = false
        turnOnBLEAlertViewHeightConstraint.constant = self.presenter.safeAreaBottom + 151
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in })
    }

    func hide() {
        transparentView.isHidden = true
        turnOnBLEAlertViewHeightConstraint.constant = 0
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in })
    }
}

// MARK: - ScaleViewProtocol
extension ScaleViewController: ScaleViewProtocol {
    func showAlert(with message: String) {
        self.presentMessage(message)
    }

    func getVisibleIndexPath() -> [IndexPath]? {
        return tableView.indexPathsForVisibleRows
    }

    func reloadData() {
        currentSwipeCellIndex = nil
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func updateGraphView(times: [Double], type: TimeFilterType) {
        DispatchQueue.main.async {
            self.header.setPoints(WeightMeasurementModel(), times: times, type: type)
        }
    }

    func updateGraphView(with data: [[[BodyFat]]], timeType: TimeFilterType, deviceType: DeviceType) {
        DispatchQueue.main.async {
            self.header.setData(data, timeType: timeType, deviceType: deviceType)
        }
    }

    func updateConnectState(_ isConnect: Bool) {
        header.setConnectButtonState(isConnect)
    }

    func setScaleImage(image: UIImage?) {
        header.setScaleImage(image)
    }

    func setIndicatorHidden(_ isHidden: Bool) {
        header.setIndicatorHidden(isHidden)
    }

    func setTypes(_ types: [TimeFilterType]) {
        header.setTypes(types)
    }

    func updateHeader(with isUnlinkDevice: Bool) {
        header.update(with: isUnlinkDevice)
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension ScaleViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
         self.presenter.onPrefetchItem(at: indexPaths)
    }
}

// MARK: - UITableViewDataSource
extension ScaleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRow(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: HistoryWeightResultTableViewCell.self, for: indexPath)
        let item = presenter.itemForRow(at: indexPath)
        cell.config(with: item, isShowLeftMenu: indexPath.row == currentSwipeCellIndex)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScaleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.onItemDidSelected(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - HistoryWeightResultTableViewCell Delegate
extension ScaleViewController: HistoryWeightResultTableViewCellDelegate {
    func leftMenuStateDidOpen(cell: HistoryWeightResultTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row,
            index != currentSwipeCellIndex else {
                return
        }
        let previousIndexPath = IndexPath(row: currentSwipeCellIndex ?? -1, section: 0)
        if let previousCell = tableView.cellForRow(at: previousIndexPath) as? HistoryWeightResultTableViewCell {
            previousCell.hideLeftMenu()
        }
        currentSwipeCellIndex = index
    }

    func leftMenuStateDidClose(cell: HistoryWeightResultTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row,
            index == currentSwipeCellIndex else {
            return
        }
        currentSwipeCellIndex = nil
    }

    func didSelecteDeleteButton(cell: HistoryWeightResultTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        presenter.onDeleteItem(at: indexPath)
    }
}

// MARK: - ScaleTableViewHeaderDelegate
extension ScaleViewController: ScaleTableViewHeaderDelegate {
    func updateBodyFatData(fromDate: Date?, toDate: Date) {
        self.presenter.filterTimesScale = TimeScaleModel(fromeDate: fromDate, toDate: toDate)
    }

    func onButtonSyncDidTapped() {
        self.presenter.onButtonSyncDidTapped()
    }

    func onButtonConnectDidTapped() {
        presenter.onButtonConnectDidTapped()
    }

    func onButtonMeasureDidTapped() {
        presenter.onButtonMeasureDidTapped()
    }
}

// MARK: - TimeFilterViewDelegate
extension ScaleViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        presenter.onFilterViewDidSelected(filterType)
    }
}
