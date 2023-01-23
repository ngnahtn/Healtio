//
//  
//  BloodPressureViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/02/2021.
//
//

import UIKit

class BloodPressureViewController: BaseViewController {
    var presenter: BloodPressurePresenterProtocol!
    private lazy var header: BloodPresureHeader = createHeaderView()
    private var currentSwipeCellIndex: Int?

    @IBOutlet weak var alertViewLabel: UILabel!
    @IBOutlet weak var alertIconImageView: UIImageView!
    @IBOutlet weak var turnOnBLEAlertView: UIView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var turnOnBLEAlertViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bpHomeTableView: UITableView!
    // MARK: - Life circle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.onViewDidAppear()
    }
    // MARK: - Setup
    private func setupDefaults() {
        setupTableView()
        turnOnBLEAlertView.roundCorners(cornes: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24)
        hideTurnOnBLEView()
    }

    private func createHeaderView() -> BloodPresureHeader {
        let headerView = BloodPresureHeader(frame: CGRect(origin: .zero,
                                                            size: CGSize(width: Constant.Screen.width, height: 600)))
        headerView.setTimeFilterDelegate(self)
        return headerView
    }

    private func setupTableView() {
        bpHomeTableView.registerNib(ofType: HistoryBpResultTBVCell.self)
        bpHomeTableView.dataSource = self
        bpHomeTableView.delegate = self
        bpHomeTableView.prefetchDataSource = self
        bpHomeTableView.separatorStyle = .none
        bpHomeTableView.showsVerticalScrollIndicator = false
        bpHomeTableView.showsHorizontalScrollIndicator = false
        header.delegate = self
        bpHomeTableView.tableHeaderView = header
    }
    
    public func measureAgain() {
        self.presenter.onButtonStartDidTapped()
    }
    // MARK: - Action
    func hideTurnOnBLEView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(transViewDidTap))
        tap.cancelsTouchesInView = false
        self.transparentView.addGestureRecognizer(tap)
    }

    @objc func transViewDidTap() {
        hide()

    }
    @IBAction func onCloseTurnOnBLEAlertButtonDidTapped(_ sender: Any) {
        hide()
    }

    @IBAction func onButtonSettingDidTapped(_ sender: Any) {
        if !BluetoothManager.shared.checkBluetoothStatusAvailble() {
            presenter.onButtonSettingBLEDidTapped()
        } else {
            self.presenter.onButtonSettingLinkTapped()
            self.hide()
        }
    }
    func hide() {
        self.transparentView.isHidden = true
        turnOnBLEAlertViewHeightConstraint.constant = 0
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
                self.view.layoutIfNeeded()
        }, completion: { _ in })
    }

    func show() {
        transparentView.isHidden = false
        if !BluetoothManager.shared.checkBluetoothStatusAvailble() {
            self.alertViewLabel.text = "Bật Bluetooth để 1SK-Connect có thể kết nối với thiết bị của bạn"
            self.alertIconImageView.image = R.image.ic_phone_ble()
        } else {
            self.alertViewLabel.text = "Bạn chưa liên kết tài khoản để đồng bộ. Vào mục cài đặt để đồng bộ"
            self.alertIconImageView.image = R.image.ic_link_2()
        }
        turnOnBLEAlertViewHeightConstraint.constant = self.presenter.safeAreaBottom + 151
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in })
    }
}

// MARK: - TimeFilterViewDelegate
extension BloodPressureViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.onFilterViewDidSelected(filterType)
    }
}

// MARK: BloodPressureViewController - BloodPressureViewProtocol -
extension BloodPressureViewController: BloodPressureViewProtocol {
    func updateGraphView(times: [Double], type: TimeFilterType) {
        DispatchQueue.main.async {
            self.header.setPoints(WeightMeasurementModel(), times: times, type: type)
        }
    }

    func getMeasurementState(_ state: BloodPressureMeasurementState) {
        self.header.updateMeasurementState(state)
    }

    func updateGraphView(with data: [[[BloodPressureModel]]], timeType: TimeFilterType, deviceType: DeviceType) {
        DispatchQueue.main.async {
            self.header.setData(data, timeType: timeType, deviceType: deviceType)
        }
    }

    func setIndicatorHidden(_ isHidden: Bool) {
        header.setIndicatorHidden(isHidden)
    }

    func updateConnectState(_ isConnected: Bool) {
        header.updateConnectState(isConnected)
    }

    func getValueWhenMeasuring(with value: Int) {
        header.getValueWhenMeasuring(with: value)
    }

    func tableViewReloadData() {
        currentSwipeCellIndex = nil
        DispatchQueue.main.async {
            self.bpHomeTableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate
extension BloodPressureViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bloodPressure = self.presenter.tableViewCellForRow(at: indexPath) else { return }
        presenter.showBioLightDataSelected(with: bloodPressure, and: "")
    }
}

// MARK: - UITableViewDataSource
extension BloodPressureViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.tableViewNumberOfRow(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: HistoryBpResultTBVCell.self, for: indexPath)
        cell.model = self.presenter.tableViewCellForRow(at: indexPath)
        cell.config(isShowLeftMenu: indexPath.row == currentSwipeCellIndex)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewPrefetchingDataSource
extension BloodPressureViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    }
}

// MARK: - TableViewHeaderDelegate
extension BloodPressureViewController: BloodPresureTableViewHeaderDelegate {

    func handleMeasureButtonDidTap() {
        self.presenter.onButtonStartDidTapped()
    }

    func handleSyncButtonDidTap() {
        self.presenter.onButtonSyncDidTapped()
    }
}

// MARK: - HistoryResultTableViewCellDelegate
extension BloodPressureViewController: HistoryBpResultTBVCellDelegate {
    func leftMenuStateDidOpen(cell: HistoryBpResultTBVCell) {
        guard let index = bpHomeTableView.indexPath(for: cell)?.row,
            index != currentSwipeCellIndex else {
                return
        }
        let previousIndexPath = IndexPath(row: currentSwipeCellIndex ?? -1, section: 0)
        if let previousCell = bpHomeTableView.cellForRow(at: previousIndexPath) as? HistoryBpResultTBVCell {
            previousCell.hideLeftMenu()
        }
        currentSwipeCellIndex = index
    }

    func leftMenuStateDidClose(cell: HistoryBpResultTBVCell) {
        guard let index = bpHomeTableView.indexPath(for: cell)?.row,
            index == currentSwipeCellIndex else {
            return
        }
        currentSwipeCellIndex = nil
    }

    func didSelecteDeleteButton(cell: HistoryBpResultTBVCell) {
        guard let indexPath = bpHomeTableView.indexPath(for: cell) else {
            return
        }
        presenter.onDeleteItem(at: indexPath)
    }
}
