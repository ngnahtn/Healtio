//
//  
//  SpO2ViewController.swift
//  1SKConnect
//
//  Created by Be More on 1/10/2021.
//
//

import UIKit

class SpO2ViewController: BaseViewController {

    // MARK: - Properties
    // IBOutlet
    @IBOutlet weak var turnOnBLEAlertView: UIView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet var spO2TableView: UITableView!
    var progressView: UIProgressView?
    var alertView: UIAlertController?

    // NSLayoutConstraint
    @IBOutlet weak var turnOnBLEAlertViewHeightConstraint: NSLayoutConstraint!
    var presenter: SpO2PresenterProtocol!
    private lazy var header: SpO2TableViewHeader = createHeaderView()

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDefaults()
        self.presenter.onViewDidLoad()
    }
}

// MARK: - Helpers
extension SpO2ViewController {
    private func setupDefaults() {
        setupTableView()
        turnOnBLEAlertView.roundCorners(cornes: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24)
    }

    private func setupTableView() {
        spO2TableView.registerNib(ofType: SpO2TableViewCell.self)
        spO2TableView.dataSource = self
        spO2TableView.delegate = self
        spO2TableView.prefetchDataSource = self
        spO2TableView.tableHeaderView = header
        spO2TableView.estimatedRowHeight = 64
        spO2TableView.contentInset.bottom = 20
        spO2TableView.backgroundColor = .white
    }

    private func createHeaderView() -> SpO2TableViewHeader {
        let headerView = SpO2TableViewHeader(frame: CGRect(origin: .zero,
                                                             size: CGSize(width: Constant.Screen.width,
                                                                          height: 636)),
                                             isConnected: self.presenter.isConnected)
        headerView.device = self.presenter.device
        headerView.delegate = self
        headerView.setTimeFilterDelegate(self)
        return headerView
    }

    @IBAction func onBackgroundDidTapped(_ sender: Any) {
        hide()
    }

    func show() {
        transparentView.isHidden = false
        turnOnBLEAlertViewHeightConstraint.constant = self.presenter.safeAreaBottom + 230
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

// MARK: - SpO2ViewProtocol
extension SpO2ViewController: SpO2ViewProtocol {
    func loadFileView(hide: Bool, of device: DeviceModel) {
        let title = "SpO2 monitor - Vivatom - \(device.name) - \(device.mac.suffix(4).pairs.joined(separator: ":"))"
        let message = R.string.localizable.spO2_download_files_downloading()
        let paddingTop: CGFloat = 18.33
        let paddingBottom: CGFloat = 10
        if !hide {
            self.alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
            present(alertView!, animated: true, completion: {
                let margin: CGFloat = 8.0
                let heightForTitle = title.height(withConstrainedWidth: self.alertView!.view.frame.width - 16 * 2, font: UIFont.systemFont(ofSize: 17, weight: .semibold))
                let heightForMessage = message.height(withConstrainedWidth: self.alertView!.view.frame.width - 16 * 2, font: UIFont.systemFont(ofSize: 13, weight: .regular))
                let rect = CGRect(x: margin, y: paddingTop + heightForTitle + heightForMessage + paddingBottom, width: self.alertView!.view.frame.width - margin * 2.0, height: 2.0)
                self.progressView = UIProgressView(frame: rect)
                self.progressView?.progress = 0
                self.progressView?.tintColor = self.view.tintColor
                self.alertView!.view.addSubview(self.progressView!)
            })
        } else {
            self.alertView?.dismiss(animated: true, completion: nil)
            self.alertView = nil
        }
    }

    func updateDowloadProgress(progess: Float) {
        self.progressView?.progress = progess
    }
    
    func setStopMeasuring() {
        self.header.setStopMeasuring()
    }

    func updateGraphView(with data: [[[WaveformModel]]], timeType: TimeFilterType, deviceType: DeviceType) {
        DispatchQueue.main.async {
            self.header.setData(data, timeType: timeType, deviceType: deviceType)
        }
    }

    func updateData(with waveform: ViatomRealTimeWaveform) {
        self.header.updateData(with: waveform)
    }

    func updateConnectState(_ isConnect: Bool) {
        self.header.setConnectButtonState(isConnect)
    }

    func setIndicatorHidden(_ isHidden: Bool) {
        header.setIndicatorHidden(isHidden)
    }

    func updateGraphView(times: [Double], type: TimeFilterType) {
        DispatchQueue.main.async {
            self.header.setPoints(WeightMeasurementModel(), times: times, type: type)
        }
    }

    func reloadTableViewData() {
        DispatchQueue.main.async {
            self.spO2TableView.reloadData()
        }
    }

    func updateBatteryView(with level: Int) {
        self.header.updateInitialBattery(at: level)
    }
}

// MARK: - TimeFilterViewDelegate
extension SpO2ViewController: TimeFilterViewDelegate {
    func filterTypeDidSelected(_ filterType: TimeFilterType) {
        self.presenter.onFilterViewDidSelected(filterType)
    }
}

// MARK: - SpO2TableViewHeaderDelegate
extension SpO2ViewController: SpO2TableViewHeaderDelegate {
    func onButtonMeasureDidTapped(stop: Bool) {
        self.presenter.onButtonMeasurementDidTapped(stop: stop)
    }

    func onButtonSyncDidTapped() {
        dLogDebug("Sync")
    }
}

// MARK: - UITableViewDelegate
extension SpO2ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.tableViewDidSelect(rowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { _, _, _ in
            self.presenter.onDeleteItem(at: indexPath)
        }
        // here set your image and background color
        let deleteImageWidth: CGFloat = 19
        let deleteImageHeigh: CGFloat = 23.67
        deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: deleteImageHeigh + 16, height: 67)).image { _ in
            R.image.ic_delete()!.draw(in: CGRect(x: 0, y: (67 / 2) - (deleteImageHeigh / 2), width: deleteImageWidth, height: deleteImageHeigh))
        }
        deleteAction.backgroundColor = .white
        return UISwipeActionsConfiguration(actions: [deleteAction])
      }
}

// MARK: - UITableViewDataSource
extension SpO2ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.tableViewNumberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: SpO2TableViewCell.self, for: indexPath)
        cell.model = self.presenter.tableWaveformFor(rowAt: indexPath)
        return cell
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension SpO2ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    }
}
