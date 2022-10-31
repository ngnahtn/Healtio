//
//  GarphsCollectionViewCell.swift
//  1SKConnect
//
//  Created by Be More on 07/09/2021.
//

import UIKit

class GarphsCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties
    private lazy var timeRangeLabel: UILabel = createTimeRangeLabel()
    lazy var graphView: GraphView = createGraphView()
    var fromDate: Date?
    var toDate: Date = Date()

    var bodyFatModel: GarphsBodyFatCollectionViewCellModel? {
        didSet {
            self.setupBodyFatData()
        }
    }

    var waveformModel: GarphsWaveformCollectionViewCellModel? {
        didSet {
            self.setupWaveformData()
        }
    }

    var bloodPressureModel: GarphsBloodPressureCollectionViewCellModel? {
        didSet {
            self.setupBloodPressureData()
        }
    }

    // MARK: - Innitializer.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpViews()
    }
}

// MARK: - Helpers
extension GarphsCollectionViewCell {
    private func setUpViews() {
        self.addSubview(timeRangeLabel)
        timeRangeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(16)
        }

        self.contentView.addSubview(self.graphView)
        graphView.snp.makeConstraints { (make) in
            make.top.equalTo(timeRangeLabel.snp.bottom).offset(15)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }

    private func getAverageTime(of date: Date, type: TimeFilterType) -> Double {
        switch type {
        case .day:
            let dateComponent = DateComponents(hour: date.hour)
            return date.startOfDay.addComponent(dateComponent).timeIntervalSince1970
        case .week:
            let dateComponent = DateComponents(hour: 0)
            return date.startOfDay.addComponent(dateComponent).timeIntervalSince1970
        case .month:
            let dateComponent = DateComponents(hour: 0)
            return date.startOfDay.addComponent(dateComponent).timeIntervalSince1970
        case .year:
            return date.startOfMonth.timeIntervalSince1970
        }
    }

    private func updateTimeRangeLabel(_ range: (Double, Double), timeFilterType: TimeFilterType) {
        var `range` = range
        if range.0 == 0 && range.1 == 0 {
            let startRange = timeFilterType.getStartRangeValue(of: Date()).timeIntervalSince1970
            let endRange = timeFilterType.getEndRangeValue(of: Date()).timeIntervalSince1970
            range = (startRange, endRange)
        }
        let lowDate = range.0.toDate().startOfDay
        let highDate = range.1.toDate().startOfDay
        var timeRangeString = ""
        switch timeFilterType {
        case .day, .week, .month:
            if lowDate.isSameDay(with: highDate) && lowDate.isSameDay(with: Date()) {
                timeRangeString = L.today.localized
                self.fromDate = nil
                self.toDate = lowDate
            } else if lowDate.isSameDay(with: highDate) {
                timeRangeString = lowDate.toString(.dmySlash)
                self.fromDate = nil
                self.toDate = lowDate
            } else {
                let lowDateString = lowDate.toString(.dmySlash)
                let highDateString = highDate.toString(.dmySlash)
                timeRangeString = "\(lowDateString) - \(highDateString)"
                self.fromDate = lowDate
                self.toDate = highDate
            }
        case .year:
            let lowDateString = lowDate.toString(.mySlash)
            let highDateString = highDate.toString(.mySlash)
            timeRangeString = "\(lowDateString) - \(highDateString)"
            self.fromDate = lowDate
            self.toDate = highDate
        }
        self.timeRangeLabel.text = timeRangeString
    }
}

// MARK: - create UI
extension GarphsCollectionViewCell {
    private func createGraphView() -> GraphView {
        let graphView = GraphView()
        return graphView
    }

    private func createTimeRangeLabel() -> UILabel {
        let timeRangeLabel = UILabel()
        timeRangeLabel.textColor = R.color.subTitle()
        timeRangeLabel.font = R.font.robotoRegular(size: 14)
        return timeRangeLabel
    }
}

// MARK: - setup data
extension GarphsCollectionViewCell {
    /// Set body fat data.
    private func setupBodyFatData() {
        guard let model = self.bodyFatModel else {
            return
        }
        let measureData = WeightMeasurementModel(with: model.data)
        let dataSource = [
            measureData.weightValue,
            measureData.muscleValue,
            measureData.boneValue,
            measureData.waterValue,
            measureData.proteinValue,
            measureData.fatValue,
            measureData.subcutaneousFatValue
        ]
        let times = model.data.compactMap { return getAverageTime(of: $0[0].timestamp.toDate(), type: model.timeType) }
        self.graphView.setPoints(dataSource[model.selectedIndex.item].points, measurementType: dataSource[model.selectedIndex.item].measurentType, measurementData: dataSource[model.selectedIndex.item].measuremntData, times: times, type: model.timeType)
        DispatchQueue.main.async {
            self.updateTimeRangeLabel(self.graphView.getVisbleRange(), timeFilterType: model.timeType)
        }
    }

    /// Set waveform data.
    private func setupWaveformData() {
        guard let model = self.waveformModel else {
            return
        }
        let times = model.data.compactMap { return getAverageTime(of: $0[0].timeCreated.toDate(), type: model.timeType) }
        self.graphView.setPoints(model.getPoints(), times: times, type: model.timeType)
        DispatchQueue.main.async {
            self.updateTimeRangeLabel(self.graphView.getVisbleRange(), timeFilterType: model.timeType)
        }
    }

    /// Set blood pressure data.
    private func setupBloodPressureData() {
        guard let model = self.bloodPressureModel else {
            return
        }
        let times = model.data.compactMap { return getAverageTime(of: $0[0].date.toDate(), type: model.timeType) }
        self.graphView.setPoints(model.getPoints(), times: times, type: model.timeType, deviceType: .biolightBloodPressure)
        DispatchQueue.main.async {
            self.updateTimeRangeLabel(self.graphView.getVisbleRange(), timeFilterType: model.timeType)
        }
    }
}
