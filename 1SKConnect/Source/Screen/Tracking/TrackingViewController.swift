//
//  
//  TrackingViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 30/03/2021.
//
//

import UIKit
import SnapKit

class TrackingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activitySelectedHidenView: UIView!
    @IBOutlet weak var noDeviceView: UIView!
    private var activitySelectedView: ActivitiesSelectionView!
    private lazy var sectionHeader: ActivityHeader = ActivityHeader(frame: CGRect(origin: .zero, size: CGSize(width: Constant.Screen.width, height: 48)))

    private var activitySelectedViewHeightConstraint: Constraint?

    var presenter: TrackingPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()

    }
    // MARK: - Setup
    private func setupDefaults() {
        setupTableView()
        setupActivitySelectionView()
    }

    private func setupTableView() {
        tableView.registerNib(ofType: WeightActivityTableViewCell.self)
        tableView.registerNib(ofType: ScaleActivityTableViewCell.self)
        tableView.registerNib(ofType: SignificanceTBVCell.self)
        tableView.registerNib(ofType: BiolightDeviceTableViewCell.self)
        tableView.registerNib(ofType: ExcerciseActivityTBVCell.self)
        tableView.registerNib(ofType: S5SmartWatchDeviceTBVCell.self)
        tableView.registerNib(ofType: S5StepActivityTBVCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = sectionHeader
        tableView.estimatedRowHeight = 80
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        sectionHeader.onActivityFilterDidSelected = { [weak self] in
            guard let `self` = self else {
                return
            }
            let isExpand = self.sectionHeader.isExpand
            self.setActivitySelectedViewHidden(!isExpand)
        }
    }

    private func setupActivitySelectionView() {
        let activityView = UIView()
        activityView.clipsToBounds = true
        activitySelectedHidenView.addSubview(activityView)
        activityView.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader.filterButton.snp.bottom).inset(12)
            make.trailing.equalTo(sectionHeader.filterButton.snp.trailing).offset(12)
            make.width.equalTo(161)
            activitySelectedViewHeightConstraint = make.height.equalTo(0).constraint
        }
        activitySelectedView = ActivitiesSelectionView(frame: .zero)
        activitySelectedView.addShadowPath(rect: CGRect(origin: .zero, size: CGSize(width: 137, height: 73)), cornerRadius: 7, width: 0, height: 5, color: .black, radius: 6, opacity: 0.22)
        activityView.addSubview(activitySelectedView)
        activitySelectedView.setDelegate(self)
        activitySelectedView.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader.filterButton.snp.bottom).offset(3)
            make.trailing.equalTo(sectionHeader.filterButton.snp.trailing)
            make.width.equalTo(137)
            make.height.equalTo(73)
        }
    }

    private func createHeader(for section: Int) -> UIView {
        let header = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Constant.Screen.width, height: 32)))
        let titileLabel = UILabel()
        titileLabel.font = R.font.robotoMedium(size: 16)
        let title = ActivityGroup.allCases[section].name
        titileLabel.text = title
        titileLabel.textColor = R.color.title()
        header.addSubview(titileLabel)
        titileLabel.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        return header
    }
    // MARK: - Action
    private func setActivitySelectedViewHidden(_ isHidden: Bool) {
        if !isHidden {
            activitySelectedHidenView.isHidden = false
            activitySelectedView.superview?.isHidden = false
        }
        activitySelectedViewHeightConstraint?.update(offset: isHidden ? 0 : 103)
        UIView.animate(withDuration: Constant.Number.animationTime, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            if isHidden {
                self.activitySelectedHidenView.isHidden = true
                self.activitySelectedView.superview?.isHidden = true
            }
        }
    }

    @IBAction func buttonLinkDeviceDidTapped(_ sender: Any) {
        presenter.onLinkDeviceButtonDidTapped()
    }

    @IBAction func onBackgroundDidTapped(_ sender: Any) {
        sectionHeader.updateExpandState(false)
        setActivitySelectedViewHidden(true)
    }
}

// MARK: - TrackingViewProtocol
extension TrackingViewController: TrackingViewProtocol {
    func reloadData() {
        tableView.reloadData()
        sectionHeader.config(with: presenter.getActivityFilterType())
    }

    func setNoDeviceViewHidden(_ isHidden: Bool) {
        noDeviceView.isHidden = isHidden
    }
}
// MARK: - UITableViewDataSource
extension TrackingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSection()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRow(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let filterType = presenter.getActivityFilterType()
        switch filterType {
        case .activity:
            let item = presenter.itemForRow(at: indexPath)
            switch item {
            case .step(let stepRecord):
                let cell = tableView.dequeueCell(ofType: S5StepActivityTBVCell.self, for: indexPath)
                cell.stepRecord = stepRecord
                return cell
            case .sport(let sport):
                let cell = tableView.dequeueCell(ofType: ExcerciseActivityTBVCell.self, for: indexPath)
                cell.config(with: sport)
                return cell
            case .scale(let bodyFat):
                let cell = tableView.dequeueCell(ofType: WeightActivityTableViewCell.self, for: indexPath)
                cell.config(with: bodyFat)
                return cell
            case .bp(let bloodpressure):
                let cell = tableView.dequeueCell(ofType: SignificanceTBVCell.self, for: indexPath)
                cell.config(with: bloodpressure, and: indexPath.row)
                return cell
            case .s5Bp(let record):
                let cell = tableView.dequeueCell(ofType: SignificanceTBVCell.self, for: indexPath)
                cell.configS5BloodPressure(with: record)
                return cell
            case .spO2(let waveform):
                let cell = tableView.dequeueCell(ofType: SignificanceTBVCell.self, for: indexPath)
                cell.configWaveForm(with: waveform, and: indexPath.row)
                return cell
            case .s5SpO2(let record):
                let cell = tableView.dequeueCell(ofType: SignificanceTBVCell.self, for: indexPath)
                cell.configS5SpO2(with: record)
                return cell
            case .s5HR(let record):
                let cell = tableView.dequeueCell(ofType: SignificanceTBVCell.self, for: indexPath)
                cell.configS5HR(with: record)
                return cell
            case .none:
                if indexPath.section == 0 {
                    let cell = tableView.dequeueCell(ofType: ExcerciseActivityTBVCell.self, for: indexPath)
                    cell.config(with: nil)
                    return cell
                } else if indexPath.section == 1 {
                    let cell = tableView.dequeueCell(ofType: WeightActivityTableViewCell.self, for: indexPath)
                    cell.config(with: nil)
                    return cell
                } else {
                    let cell = tableView.dequeueCell(ofType: SignificanceTBVCell.self, for: indexPath)
                    cell.config(with: nil, and: indexPath.row)
                    return cell
                }
            }
        case .deviceActivity:
            let item = presenter.itemForRow(at: indexPath)
            switch item {
            case .s5HR(_), .s5SpO2(_), .s5Bp(_), .sport(_):
                let cell = tableView.dequeueCell(ofType: S5SmartWatchDeviceTBVCell.self, for: indexPath)
                return cell
            case .step(let step):
                let cell = tableView.dequeueCell(ofType: S5SmartWatchDeviceTBVCell.self, for: indexPath)
                cell.delegate = self
                cell.stepRecord = step
                return cell
            case .scale(let bodyFat):
                let cell = tableView.dequeueCell(ofType: ScaleActivityTableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.config(with: bodyFat)
                return cell
            case .bp(let bloodpressure):
                let cell = tableView.dequeueCell(ofType: BiolightDeviceTableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.config(with: bloodpressure)
                return cell
            case .spO2(let waveform):
                let cell = tableView.dequeueCell(ofType: BiolightDeviceTableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.configWaveForm(with: waveform)
                return cell
            case .none:
                if indexPath.row == 0 {
                    let cell = tableView.dequeueCell(ofType: ScaleActivityTableViewCell.self, for: indexPath)
                    cell.delegate = nil
                    cell.config(with: nil)
                    return cell
                } else {
                    let cell = tableView.dequeueCell(ofType: BiolightDeviceTableViewCell.self, for: indexPath)
                    cell.configDefaultValue(with: indexPath.row)
                    cell.delegate = nil
                    return cell
                }

            }
        }
    }
}

// MARK: - UITableViewDelegate
extension TrackingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectedItem(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let filterType = presenter.getActivityFilterType()
        switch filterType {
        case .activity:
            return createHeader(for: section)
        case .deviceActivity:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        self.presenter.heightOfHeader(in: section)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}
// MARK: - ActivitiesSelectionItemDelegate
extension TrackingViewController: ActivitiesSelectionItemDelegate {
    func itemDidSelected(_ filterType: ActivityFilterType) {
        activitySelectedView.currentActivityFilterType = filterType
        presenter.didSelectActivityFilterType(type: filterType)
        sectionHeader.updateExpandState(false)
        setActivitySelectedViewHidden(true)
    }
}
// MARK: - DeviceActivityTableViewCellDelegate
extension TrackingViewController: DeviceActivityTableViewCellDelegate {
    func onButtonDeviceDidTapped(_ cell: DeviceActivityTableViewCellProtocol) {
        guard let `cell` = cell as? UITableViewCell, let index = tableView.indexPath(for: cell) else {
            return
        }
        presenter.didSelectedDevice(at: index)
    }
}
