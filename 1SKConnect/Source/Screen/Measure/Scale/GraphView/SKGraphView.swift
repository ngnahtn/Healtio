//
//  SKGraphView.swift
//  1SKConnect
//
//  Created by tuyenvx on 14/04/2021.
//

import UIKit

protocol SKGraphViewDelegate: AnyObject {
    func updateBodyFatData(fromDate: Date?, toDate: Date)
}

class SKGraphView: UIView {
    private lazy var timeFilterView: TimeFilterView = TimeFilterView(frame: .zero)
    private lazy var timeRangeLabel: UILabel = createTimeRangeLabel()
    private var deviceType: DeviceType = .scale

    /// show measurement collectionView, set this property to `false` to hide measurement collectionView, default value is `true`
    var needShowMeasurementCollectionView: Bool = true {
        didSet {
            if !self.needShowMeasurementCollectionView {
                self.measurementCollectionView.removeFromSuperview()
            }
        }
    }

    weak var delegate: SKGraphViewDelegate?

    /// line chart.
    private lazy var emptyGarphView: GraphView = createGraphView()
    private lazy var measurementCollectionView: UICollectionView = createMeasurementCollectionView()
    private lazy var garphsColleciontView = createGarphsCollectionView()

    private let leadingOffset = 16
    private let timeFilterViewHeight = 36

    private var needSelectFirstIndex = true

    private var bodyFatModels: [GarphsBodyFatCollectionViewCellModel]? {
        didSet {
            if self.bodyFatModels != nil {
                DispatchQueue.main.async {
                    self.garphsColleciontView.reloadData()
                    // scroll to last graph.
                    self.garphsColleciontView.scrollToItem(at: IndexPath(item: self.bodyFatModels!.count - 1, section: 0), at: .centeredHorizontally, animated: false)
                    self.garphsColleciontView.performBatchUpdates(nil, completion: { _ in
                        for cell in self.garphsColleciontView.visibleCells {
                            if let cell = cell as? GarphsCollectionViewCell {
                                self.delegate?.updateBodyFatData(fromDate: cell.fromDate, toDate: cell.toDate)
                            }
                        }
                    })
                }
            }
        }
    }

    private var waveformModels: [GarphsWaveformCollectionViewCellModel]? {
        didSet {
            DispatchQueue.main.async {
                if self.waveformModels != nil {
                    self.garphsColleciontView.reloadData()
                    self.garphsColleciontView.scrollToItem(at: IndexPath(item: self.waveformModels!.count - 1, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
    }

    private var bloodPressureModels: [GarphsBloodPressureCollectionViewCellModel]? {
        didSet {
            DispatchQueue.main.async {
                if self.bloodPressureModels != nil {
                    self.garphsColleciontView.reloadData()
                    self.garphsColleciontView.scrollToItem(at: IndexPath(item: self.bloodPressureModels!.count - 1, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
    }

    private var selectedIndex = IndexPath(item: 0, section: 0) {
        didSet {
            var temp = self.bodyFatModels ?? []
            for i in 0 ..< temp.count {
                temp[i].selectedIndex = self.selectedIndex
            }
            self.bodyFatModels = temp
        }
    }

    private var times: [Double] = []
    private var dataSource: [WeightMeasurementValue] = [] {
        didSet {
            if needSelectFirstIndex {
                self.measurementCollectionView.reloadData()
                self.measurementCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
                needSelectFirstIndex = false
            }
        }
    }

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    // MARK: - Setup
    private func setupDefaults() {
        self.addSubview(timeFilterView)
        timeFilterView.cornerRadius = 16
        timeFilterView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(leadingOffset)
            make.trailing.equalToSuperview().inset(leadingOffset)
            make.height.equalTo(timeFilterViewHeight)
        }

        self.addSubview(timeRangeLabel)
        timeRangeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(timeFilterView.snp.bottom).offset(14)
            make.leading.equalTo(timeFilterView)
            make.height.equalTo(16)
        }

        self.addSubview(emptyGarphView)
        emptyGarphView.snp.makeConstraints { (make) in
            make.top.equalTo(timeRangeLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(130)
        }

        self.setUpColleciontView()
    }

    private func setUpColleciontView() {
        self.addSubview(garphsColleciontView)
        garphsColleciontView.snp.makeConstraints { (make) in
            make.top.equalTo(timeFilterView.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }

        self.addSubview(self.measurementCollectionView)
        self.measurementCollectionView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalTo(self.garphsColleciontView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        self.measurementCollectionView.registerNib(ofType: MeasurementCollectionViewCell.self)
        self.garphsColleciontView.registerCell(ofType: GarphsCollectionViewCell.self)
    }

    private func createTimeRangeLabel() -> UILabel {
        let timeRangeLabel = UILabel()
        timeRangeLabel.textColor = R.color.subTitle()
        timeRangeLabel.text = R.string.localizable.today()
        timeRangeLabel.font = R.font.robotoRegular(size: 14)
        return timeRangeLabel
    }

    private func createGraphView() -> GraphView {
        let graphView = GraphView()
        return graphView
    }

    // MARK: - Action
    func setFilterTypes(_ filterTypes: [TimeFilterType]) {
        timeFilterView.setFilterTypes(filterTypes)
    }

    func setPoints(_ data: WeightMeasurementModel, times: [Double], type: TimeFilterType) {
        self.dataSource = [
            data.weightValue,
            data.muscleValue,
            data.boneValue,
            data.waterValue,
            data.proteinValue,
            data.fatValue,
            data.subcutaneousFatValue
        ]
        self.times = times
        self.emptyGarphView.setEmptyPoints([], times: [], deviceType: self.deviceType)
    }

    func setTimeFilterDelegate(_ delegate: TimeFilterViewDelegate?) {
        timeFilterView.delegate = delegate
    }
}

// MARK: - Hepler
extension SKGraphView {
    private func createMeasurementCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 75, height: 36)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset.left = 16
        collectionView.contentInset.right = 16
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }

    private func createGarphsCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 160)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.layer.masksToBounds = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }

    /// Set body fat data
    /// - Parameters:
    ///   - data: body fat data
    ///   - type: time filter type
    func setData(_ data: [[[BodyFat]]], timeType: TimeFilterType, deviceType: DeviceType) {
        self.deviceType = .scale
        self.garphsColleciontView.isHidden = data.isEmpty
        let temp = data.compactMap { return GarphsBodyFatCollectionViewCellModel(data: $0, selectedIndex: self.selectedIndex, timeType: timeType) }
        self.bodyFatModels = temp
    }

    /// Set waveform data
    /// - Parameters:
    ///   - data: waveform data
    ///   - type: time filter type
    func setData(_ data: [[[WaveformModel]]], timeType: TimeFilterType, deviceType: DeviceType) {
        self.deviceType = .spO2
        self.garphsColleciontView.isHidden = data.isEmpty
        let temp = data.compactMap { return GarphsWaveformCollectionViewCellModel(data: $0, timeType: timeType) }
        self.waveformModels = temp
    }

    /// Set waveform data
    /// - Parameters:
    ///   - data: blood pressure data
    ///   - type: time filter type
    func setData(_ data: [[[BloodPressureModel]]], timeType: TimeFilterType, deviceType: DeviceType) {
        self.deviceType = .biolightBloodPressure
        self.garphsColleciontView.isHidden = data.isEmpty
        let temp = data.compactMap { return GarphsBloodPressureCollectionViewCellModel(data: $0, timeType: timeType) }
        self.bloodPressureModels = temp
    }
}

// MARK: - UICollectionViewDataSource
extension SKGraphView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.measurementCollectionView {
            return self.dataSource.count
        } else {
            switch self.deviceType {
            case .scale:
                return self.bodyFatModels?.count ?? 0
            case .spO2:
                return self.waveformModels?.count ?? 0
            case .biolightBloodPressure:
                return self.bloodPressureModels?.count ?? 0
            default:
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.measurementCollectionView {
            let cell = collectionView.dequeuCell(ofType: MeasurementCollectionViewCell.self, for: indexPath)
            cell.model = self.dataSource[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeuCell(ofType: GarphsCollectionViewCell.self, for: indexPath)
            switch self.deviceType {
            case .scale:
                cell.bodyFatModel = self.bodyFatModels?[indexPath.item]
            case .spO2:
                cell.waveformModel = self.waveformModels?[indexPath.item]
            case .biolightBloodPressure:
                cell.bloodPressureModel = self.bloodPressureModels?[indexPath.item]
            default:
                return UICollectionViewCell()
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SKGraphView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in self.garphsColleciontView.visibleCells {
            if let cell = cell as? GarphsCollectionViewCell {
                self.delegate?.updateBodyFatData(fromDate: cell.fromDate, toDate: cell.toDate)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.measurementCollectionView {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            self.selectedIndex = indexPath
        }
    }
}
