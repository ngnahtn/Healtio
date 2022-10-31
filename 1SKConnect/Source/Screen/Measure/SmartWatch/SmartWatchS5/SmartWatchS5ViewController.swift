//
//  
//  SmartWatchS5ViewController.swift
//  1SKConnect
//
//  Created by TrungDN on 07/12/2021.
//
//

import UIKit

class SmartWatchS5ViewController: BaseViewController {
    @IBOutlet weak var batteryViewContainer: UIView!
    private lazy var batteryView: SKBatteryView = createBatteryView()
    private lazy var chargeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.ic_charging()
        imageView.isHidden = true
        return imageView
    }()
    private lazy var batteryLevelLabel: UILabel = createBatteryLevelLabel()

    @IBOutlet weak var connectView: UIView!
    @IBOutlet weak var connectViewTitleLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var canClose = false
    var numberOfCell = CellType.allCases.count

    let refreshControl = UIRefreshControl()
    var presenter: SmartWatchS5PresenterProtocol!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }
    
    // MARK: - Setup
    private func setupInit() {
        self.setupTableView()
        self.setUpConstraints()
        kNotificationCenter.addObserver(self, selector: #selector(finishSaveData), name: .finishSaveData, object: nil)
    }

    deinit {
        kNotificationCenter.removeObserver(self, name: .finishSaveData, object: nil)
    }

    // MARK: - Action
    @objc func refresh(_ sender: AnyObject) {
        self.presenter.refeshData()
    }

    @objc private func finishSaveData() {
        self.refreshControl.endRefreshing()
    }
}

// MARK: - SmartWatchS5ViewProtocol
extension SmartWatchS5ViewController: SmartWatchS5ViewProtocol {
    func updateView(with state: Bool) {
        self.connectView.backgroundColor = state ? R.color.mainColor() : R.color.subTitle()
        self.connectViewTitleLabel.text = state ? R.string.localizable.connected() : R.string.localizable.disconnected()
    }

    func updateBattery(at level: Int) {
        if level == 255 {
            self.chargeImageView.isHidden = false
            self.batteryView.isHidden = true
            self.batteryLevelLabel.isHidden = true
        } else {
            self.chargeImageView.isHidden = true
            self.batteryView.isHidden = false
            self.batteryLevelLabel.isHidden = false
            self.batteryView.level = level
            self.batteryLevelLabel.text = "\(level)%"
        }
    }

    func reloadData(at cellType: CellType) {
        DispatchQueue.main.async {
            var indexPath: IndexPath
            switch cellType {
            case .exercise:
                indexPath = IndexPath(row: 0, section: 0)
            case .heartRate:
                indexPath = IndexPath(row: 1, section: 0)
            case .spO2:
                indexPath = IndexPath(row: 2, section: 0)
            case .bloodPressure:
                indexPath = IndexPath(row: 3, section: 0)
            case .temperature:
                self.canClose = true
                indexPath = IndexPath(row: 4, section: 0)
            case .sleep:
                indexPath = IndexPath(row: 5, section: 0)
            case .synthetic:
                indexPath = IndexPath(row: 6, section: 0)
            }
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}

// MARK: - Helpers
extension SmartWatchS5ViewController {
    private func setupTableView() {
        self.tableView.registerNib(ofType: S5ExerciseTableViewCell.self)
        self.tableView.registerNib(ofType: S5HeartRateTableViewCell.self)
        self.tableView.registerNib(ofType: S5SpO2TableViewCell.self)
        self.tableView.registerNib(ofType: S5TenperatureTableViewCell.self)
        self.tableView.registerNib(ofType: S5BloodPressureTableViewCell.self)
        self.tableView.registerNib(ofType: S5SleepTableViewCell.self)
        self.tableView.registerNib(ofType: SyntheticTableViewCell.self)
        
        refreshControl.attributedTitle = NSAttributedString(string: R.string.localizable.reloadData())
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    private func setUpConstraints() {
        self.batteryViewContainer.addSubview(self.batteryView)
        self.batteryView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(13)
            make.width.equalTo(30)
        }

        self.batteryViewContainer.addSubview(self.chargeImageView)
        self.chargeImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(13)
            make.width.equalTo(30)
        }
        
        self.batteryViewContainer.addSubview(self.batteryLevelLabel)
        self.batteryLevelLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.batteryView.snp.leading).offset(-6)
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - View creator
extension SmartWatchS5ViewController {
    private func createBatteryView() -> SKBatteryView {
        let view = SKBatteryView()
        view.batteryViewBorderColor = R.color.title()!
        view.batteryViewBorderWidth = 1
        view.batteryViewCornerRadius = 1
        view.highLevelColor = R.color.title()!
        view.terminalLengthRatio = 0.15
        view.terminalWidthRatio = 0.4
        view.isHidden = true
        view.level = 50
        view.direction = .maxXEdge
        return view
    }

    private func createBatteryLevelLabel() -> UILabel {
        let label = UILabel()
        label.isHidden = true
        label.font = R.font.robotoRegular(size: 11)
        label.textColor = R.color.title()
        return label
    }
}

// MARK: - UITableViewDelegate
extension SmartWatchS5ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = CellType.allCases[indexPath.row]
        if numberOfCell == 2 {
            if cellType == .exercise {
                self.presenter.prepareToPushToExcerciseView(with: .day)
            } else {
                return
            }
        } else {
            switch cellType {
            case .exercise:
                self.presenter.prepareToPushToExcerciseView(with: .day)
            case .heartRate:
                self.presenter.goToHeartRateDetail(with: .day)
            case .spO2:
                self.presenter.goToSpO2Detail(with: .day)
            case .bloodPressure:
                self.presenter.goToBloodPressureDetail(with: .day)
            case .temperature:
                self.presenter.goToTemperatureDetail(with: .day)
            case .sleep:
                self.presenter.goToSleepDetail(with: .day)
            case .synthetic:
                dLogDebug("synthetic")
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = CellType.allCases[indexPath.row]
        if numberOfCell == 2 {
            return 380
        } else {
            if cellType == .exercise {
                return 380
            } else if cellType == .synthetic {
                if String.isNilOrEmpty(self.presenter.syntheticData?.run) || self.presenter.syntheticData?.run == "-" {
                    return 340
                } else {
                    return 380
                }
            } else if cellType == .sleep {
                return 200
            } else {
                return 280
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension SmartWatchS5ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCell
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = CellType.allCases[indexPath.row]
        if numberOfCell == 2 {
            switch cellType {
            case .exercise:
                let cell = tableView.dequeueCell(ofType: S5ExerciseTableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.model = self.presenter.exerciseData
                return cell
            default:
                let cell = tableView.dequeueCell(ofType: SyntheticTableViewCell.self, for: indexPath)
                cell.model = self.presenter.syntheticData
                return cell
            }
        } else {
            switch cellType {
            case .exercise:
                let cell = tableView.dequeueCell(ofType: S5ExerciseTableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.model = self.presenter.exerciseData
                return cell
            case .heartRate:
                let cell = tableView.dequeueCell(ofType: S5HeartRateTableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.model = self.presenter.hrListData
                return cell
            case .spO2:
                let cell = tableView.dequeueCell(ofType: S5SpO2TableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.model = self.presenter.spO2ListData
                return cell
            case .bloodPressure:
                let cell = tableView.dequeueCell(ofType: S5BloodPressureTableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.model = self.presenter.bloodPressureListData
                return cell
            case .temperature:
                let cell = tableView.dequeueCell(ofType: S5TenperatureTableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.model = self.presenter.temperatureListData
                return cell
            case .sleep:
                let cell = tableView.dequeueCell(ofType: S5SleepTableViewCell.self, for: indexPath)
                cell.delegate = self
                cell.todaySleepData = self.presenter.sleepModelData
                return cell
            case .synthetic:
                let cell = tableView.dequeueCell(ofType: SyntheticTableViewCell.self, for: indexPath)
                cell.model = self.presenter.syntheticData
                return cell
            }
        }
        
    }
}

// MARK: - S5ExerciseTableViewCellDelegate
extension SmartWatchS5ViewController: S5ExerciseTableViewCellDelegate {
    func onChartDetailDidPressed(_ celltype: CellType) {
        self.presenter.prepareToPushToExcerciseView(with: .week)
    }
    
    func menu(isOpen: Bool) {
        // if sync finshed user can interact with number of cell
        if canClose {
            self.numberOfCell = isOpen ? CellType.allCases.count : 2
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - S5ExerciseTableViewCellDelegate
extension SmartWatchS5ViewController: ShowWeakDetailDelegate {
    func onShowWeekData(_ cell: UITableViewCell) {
        if cell is S5HeartRateTableViewCell {
            self.presenter.goToHeartRateDetail(with: .week)
        } else if cell is S5SpO2TableViewCell {
            self.presenter.goToSpO2Detail(with: .week)
        } else if cell is S5BloodPressureTableViewCell {
            self.presenter.goToBloodPressureDetail(with: .week)
        } else if cell is S5SleepTableViewCell {
            self.presenter.goToSleepDetail(with: .week)
        } else if cell is S5TenperatureTableViewCell {
            self.presenter.goToTemperatureDetail(with: .week)
        }
    }
}
