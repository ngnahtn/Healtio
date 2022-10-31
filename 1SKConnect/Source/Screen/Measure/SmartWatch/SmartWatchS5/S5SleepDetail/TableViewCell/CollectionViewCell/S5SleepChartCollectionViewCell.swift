//
//  S5SleepChartCollectionViewCell.swift
//  1SKConnect
//
//  Created by Be More on 11/01/2022.
//

import UIKit
import Charts

protocol S5SleepChartCollectionViewCellDelegate: AnyObject {
    func onSelectNext(_ cell: UICollectionViewCell)
    func onSelectPrevious(_ cell: UICollectionViewCell)
}

class S5SleepChartCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var icPreviousImageView: UIImageView!
    @IBOutlet weak var icNextImageView: UIImageView!
    @IBOutlet weak var icMoonImageView: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet var dashViews: [SKDashedLineHorizonatalView]!
    
    @IBOutlet weak var chartViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    // dateTime
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    // duration
    @IBOutlet weak var deepSleepDurationLabel: UILabel!
    @IBOutlet weak var lightSleepDurationLabel: UILabel!
    
    @IBOutlet weak var remDurationLabel: UILabel!
    @IBOutlet weak var awakeDurationLabel: UILabel!
    
    weak var delegate: S5SleepChartCollectionViewCellDelegate?
    
    private lazy var sleepBarChart: BarChartView = self.createSleepChart(with: .day)

    var timeType: TimeFilterType = .day {
        didSet {
            let isShow = (timeType == .day) ? true : false
            self.showBarChart(with: isShow)
        }
    }
    var dayModel: SleepRecordModel? {
        didSet {
            self.setDayData()
        }
    }
    
    var weakModel: [SleepRecordModel]? {
        didSet {
            self.setWeekData()
        }
    }
    
    var monthModel: [SleepRecordModel]? {
        didSet {
            self.setMonthData()
        }
    }

    var yearModel: [[SleepRecordModel]]? {
        didSet {
            self.setYearData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.icNextImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleNext)))
        self.icPreviousImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handlePrevious)))
        self.chartContentView.addSubview(self.sleepBarChart)
        self.sleepBarChart.anchor(top: self.chartContentView.topAnchor,
                                  left: self.chartContentView.leftAnchor,
                                  bottom: self.chartContentView.bottomAnchor,
                                  right: self.chartContentView.rightAnchor,
                                  paddingTop: 0,
                                  paddingLeft: 0,
                                  paddingBottom: 0,
                                  paddingRight: 0)
        
        self.setUpDataWhenNil()
        self.setUpBarChartData([])
    }
    
    @objc private func handleNext() {
        self.delegate?.onSelectNext(self)
    }
    
    @objc private func handlePrevious() {
        self.delegate?.onSelectPrevious(self)
    }
    
    private func setDayData() {
        self.showBarChart(with: true)
        guard let dayModel = dayModel else {
            return
        }
        
        let date = dayModel.dateTime.toDate(.ymd) ?? Date()
        let dateStr = date.toString(.dayOfWeek)
        self.dateLabel.text = dateStr
        
        if !dayModel.sleeppDetail.isEmpty {
            let startDate = dayModel.sleeppDetail[0].dateTime.toDate(.ymdhm)?.toString(.hm)
            let endDate = dayModel.sleeppDetail[dayModel.sleeppDetail.count - 1].dateTime.toDate(.ymdhm)?.toString(.hm)
            let totalDuration = dayModel.awakeDuration + dayModel.beginDuration + dayModel.lightDuration + dayModel.deepDuration + dayModel.remDuration
            self.totalTimeLabel.text = R.string.localizable.smart_watch_s5_total_sleep_input(totalDuration.hourAndMinuteStringValue)
            self.startTimeLabel.text = startDate
            self.endTimeLabel.text = endDate
            self.deepSleepDurationLabel.text = dayModel.deepDuration.hourAndMinuteStringValue
            self.lightSleepDurationLabel.text = dayModel.lightDuration.hourAndMinuteStringValue
            self.remDurationLabel.text = dayModel.remDuration.hourAndMinuteStringValue
            self.awakeDurationLabel.text = dayModel.awakeDuration.hourAndMinuteStringValue
            
            DispatchQueue.main.async {
                self.sleepBarChart.xAxis.axisMinimum = 0
                self.sleepBarChart.xAxis.axisMaximum = Double(dayModel.sleeppDetail.count)
                self.setUpBarChartData(dayModel.sleeppDetail.array)
            }
        } else {
            setUpDataWhenNil()
            DispatchQueue.main.async {
                self.setUpBarChartData([])
            }
        }
    }

    private func setWeekData() {
        self.showBarChart(with: false)
        guard let model = self.weakModel else {
            return
        }
        if !model.isEmpty {
            let startOfWeek = model[0].dateTime.toDate(.ymd)!.startOfWeek.toString(.dayMonth)
            let endOfWeek = model[0].dateTime.toDate(.ymd)!.endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
            
            let awakeDuration = model.map { $0.awakeDuration }.reduce(0, +) / model.count
            let beginDuration = model.map { $0.beginDuration }.reduce(0, +) / model.count
            let lightDuration = model.map { $0.lightDuration }.reduce(0, +) / model.count
            let deepDuration = model.map { $0.deepDuration }.reduce(0, +) / model.count
            let remDuration = model.map { $0.remDuration }.reduce(0, +) / model.count
            
            self.deepSleepDurationLabel.text = deepDuration.hourAndMinuteStringValue
            self.lightSleepDurationLabel.text = lightDuration.hourAndMinuteStringValue
            self.remDurationLabel.text = remDuration.hourAndMinuteStringValue
            self.awakeDurationLabel.text = awakeDuration.hourAndMinuteStringValue
            
            let totalDuration = awakeDuration + beginDuration + lightDuration + deepDuration + remDuration
            self.totalTimeLabel.text = R.string.localizable.smart_watch_s5_average_sleep_input(totalDuration.hourAndMinuteStringValue)
        }
    }
    
    private func setMonthData() {
        self.showBarChart(with: false)
        guard let model = self.monthModel else { return }
        if !model.isEmpty {
            let startOfMonth = model[0].dateTime.toDate(.ymd)!.startOfMonth.toString(.dayMonth)
            let endOfMonth = model[0].dateTime.toDate(.ymd)!.endOfMonth.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth

            let awakeDuration = model.map { $0.awakeDuration }.reduce(0, +) / model.count
            let beginDuration = model.map { $0.beginDuration }.reduce(0, +) / model.count
            let lightDuration = model.map { $0.lightDuration }.reduce(0, +) / model.count
            let deepDuration = model.map { $0.deepDuration }.reduce(0, +) / model.count
            let remDuration = model.map { $0.remDuration }.reduce(0, +) / model.count
            
            self.deepSleepDurationLabel.text = deepDuration.hourAndMinuteStringValue
            self.lightSleepDurationLabel.text = lightDuration.hourAndMinuteStringValue
            self.remDurationLabel.text = remDuration.hourAndMinuteStringValue
            self.awakeDurationLabel.text = awakeDuration.hourAndMinuteStringValue
            
            let totalDuration = awakeDuration + beginDuration + lightDuration + deepDuration + remDuration
            self.totalTimeLabel.text = R.string.localizable.smart_watch_s5_average_sleep_input(totalDuration.hourAndMinuteStringValue)
        }
    }
    
    private func setYearData() {
        self.showBarChart(with: false)
        guard let model = self.yearModel else { return }
        if !model.isEmpty {
            let startOfMonth = model[0][0].dateTime.toDate(.ymd)!.startOfYear.toString(.dayMonth)
            let endOfMonth = model[0][0].dateTime.toDate(.ymd)!.endOfYear.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
            
            let awakeDuration = model.map { $0.map { $0.awakeDuration }.reduce(0, +) / $0.count }.reduce(0, +) / model.count
            let beginDuration = model.map { $0.map { $0.beginDuration }.reduce(0, +) / $0.count }.reduce(0, +) / model.count
            let lightDuration = model.map { $0.map { $0.lightDuration }.reduce(0, +) / $0.count }.reduce(0, +) / model.count
            let deepDuration = model.map { $0.map { $0.deepDuration }.reduce(0, +) / $0.count }.reduce(0, +) / model.count
            let remDuration = model.map { $0.map { $0.remDuration }.reduce(0, +) / $0.count }.reduce(0, +) / model.count
            
            self.deepSleepDurationLabel.text = deepDuration.hourAndMinuteStringValue
            self.lightSleepDurationLabel.text = lightDuration.hourAndMinuteStringValue
            self.remDurationLabel.text = remDuration.hourAndMinuteStringValue
            self.awakeDurationLabel.text = awakeDuration.hourAndMinuteStringValue
            
            let totalDuration = awakeDuration + beginDuration + lightDuration + deepDuration + remDuration
            self.totalTimeLabel.text = R.string.localizable.smart_watch_s5_average_sleep_input(totalDuration.hourAndMinuteStringValue)
        }
    }
    
    private func setUpBarChartData(_ detail: [SleepDetailModel]) {
        var beginDataEntry: [BarChartDataEntry] = []
        var remDataEntry: [BarChartDataEntry] = []
        var deepDataEntry: [BarChartDataEntry] = []
        var lightDataEntry: [BarChartDataEntry] = []
        var awakeDataEntry: [BarChartDataEntry] = []
        let yValue: Double = 150
        for item in detail {
            let xValue = Double(detail.firstIndex(of: item)!)
            if item.type.value == .begin {
                let chartData = BarChartDataEntry(x: xValue, y: yValue)
                beginDataEntry.append(chartData)
            } else if item.type.value == .rem {
                let chartData = BarChartDataEntry(x: xValue, y: yValue)
                remDataEntry.append(chartData)
            } else if item.type.value == .deep {
                let chartData = BarChartDataEntry(x: xValue, y: yValue)
                deepDataEntry.append(chartData)
            } else if item.type.value == .light {
                let chartData = BarChartDataEntry(x: xValue, y: yValue)
                lightDataEntry.append(chartData)
            } else if item.type.value == .awake {
                let chartData = BarChartDataEntry(x: xValue, y: yValue)
                awakeDataEntry.append(chartData)
            }
        }
        self.sleepBarChart.data = self.setUpBarChartData(beginDataEntry: beginDataEntry,
                                                         remDataEntry: remDataEntry,
                                                         deepDataEntry: deepDataEntry,
                                                         lightDataEntry: lightDataEntry,
                                                         awakeDataEntry: awakeDataEntry)
    }
    
    private func setUpBarChartData(beginDataEntry: [BarChartDataEntry],
                                   remDataEntry: [BarChartDataEntry],
                                   deepDataEntry: [BarChartDataEntry],
                                   lightDataEntry: [BarChartDataEntry],
                                   awakeDataEntry: [BarChartDataEntry]) -> BarChartData {
        var remSet: BarChartDataSet
        remSet = BarChartDataSet(entries: remDataEntry, label: "")
        remSet.colors = [UIColor(hex: "4CD864")]
        
        var deepSet: BarChartDataSet
        deepSet = BarChartDataSet(entries: deepDataEntry, label: "")
        deepSet.colors = [UIColor(hex: "54399F")]
        
        var lightSet: BarChartDataSet
        lightSet = BarChartDataSet(entries: lightDataEntry, label: "")
        lightSet.colors = [UIColor(hex: "914FC5")]
        
        var awakeSet: BarChartDataSet
        awakeSet = BarChartDataSet(entries: awakeDataEntry, label: "")
        awakeSet.colors = [UIColor(hex: "FEC63D")]
        
        let dataSet = BarChartData()
        dataSet.addDataSet(remSet)
        dataSet.addDataSet(deepSet)
        dataSet.addDataSet(lightSet)
        dataSet.addDataSet(awakeSet)
        dataSet.barWidth = 1
        dataSet.highlightEnabled = true
        self.sleepBarChart.animate(yAxisDuration: 1)
        self.sleepBarChart.setVisibleXRangeMaximum(7)
        dataSet.setDrawValues(false)
        return dataSet
    }

    private func createSleepChart(with timeType: TimeFilterType) -> BarChartView {
        // barChart setUp
        let barChart = BarChartView()
        barChart.delegate = self
        barChart.backgroundColor = .clear
        barChart.doubleTapToZoomEnabled = false
        barChart.isUserInteractionEnabled = true
        barChart.setScaleEnabled(false)
        barChart.legend.enabled = false
        barChart.xAxis.enabled = true
        barChart.leftAxis.enabled = false
        barChart.rightAxis.enabled = false
        barChart.leftAxis.axisMinimum = 0
        barChart.legend.textColor = .clear
        barChart.legend.verticalAlignment = .top
        barChart.clipsToBounds = false
        
        // xAxis properties
        let xAxis = barChart.xAxis
        xAxis.drawAxisLineEnabled = false
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = UIColor(hex: "737678")
        xAxis.axisLineColor = UIColor(hex: "D3DFE8")
        xAxis.gridColor = UIColor(hex: "D3DFE8")
        
        switch timeType {
        case .day:
            xAxis.setLabelCount(2, force: true)
            xAxis.valueFormatter = NoneValueFormatter()
            xAxis.axisMinimum = Date().startOfDay.timeIntervalSince1970
            xAxis.axisMaximum = Date().endOfDay.timeIntervalSince1970
            xAxis.granularity = 1
            barChart.setVisibleXRange(minXRange: 24 * 3600, maxXRange: 24 * 3600)
        case .week:
            xAxis.setLabelCount(8, force: true)
            xAxis.valueFormatter = WMYValueFormatter(date: Date().chartStartOfWeek!, type: .week)
            xAxis.axisMinimum = Date().chartStartOfWeek!.timeIntervalSince1970 - 3600 * 24
            xAxis.axisMaximum = Date().chartEndOfWeek!.timeIntervalSince1970
            xAxis.granularity = 3600 * 24
            barChart.setVisibleXRange(minXRange: 8 * 24 * 3600, maxXRange: 8 * 24 * 3600)
        case .month:
            let numberOfTotal = Date().numberOfDaysInMonth
            xAxis.valueFormatter = WMYValueFormatter(date: Date().startOfMonth, type: .month)
            xAxis.axisMinimum = Date().startOfMonth.startOfDay.timeIntervalSince1970 - 3600 * 24
            xAxis.axisMaximum = Date().endOfMonth.startOfDay.timeIntervalSince1970
            xAxis.granularity = 3600 * 24
            barChart.setVisibleXRange(minXRange: (Double(numberOfTotal) + 1) * 24 * 3600, maxXRange: (Double(numberOfTotal) + 1) * 24 * 3600)
        case .year:
            xAxis.valueFormatter = YearValueFormatter()
            xAxis.axisMinimum = 0
            xAxis.axisMaximum = 12
            xAxis.granularity = 1
            xAxis.setLabelCount(13, force: true)
        }
        
        xAxis.avoidFirstLastClippingEnabled = false
        return barChart
    }
    
}

// MARK: - ChartViewDelegate
extension S5SleepChartCollectionViewCell: ChartViewDelegate {
    
}

// MARK: - Helpers
extension S5SleepChartCollectionViewCell {
    private func setUpDataWhenNil() {
        self.totalTimeLabel.text = R.string.localizable.smart_watch_s5_total_sleep_input(R.string.localizable.hourAndMinuteEmty())
        self.startTimeLabel.text = "--:--"
        self.endTimeLabel.text = "--:--"
        self.deepSleepDurationLabel.text = R.string.localizable.hourAndMinuteEmty()
        self.lightSleepDurationLabel.text = R.string.localizable.hourAndMinuteEmty()
        self.remDurationLabel.text = R.string.localizable.hourAndMinuteEmty()
        self.awakeDurationLabel.text = R.string.localizable.hourAndMinuteEmty()
    }

    private func showBarChart(with show: Bool) {
        if show {
            self.chartViewHeightAnchor.constant = 50
            self.chartContentView.layoutIfNeeded()
            for item in dashViews {
                DispatchQueue.main.async {
                    item.isHidden = false
                    item.setup(item.width)
                }
            }
        } else {
            self.chartViewHeightAnchor.constant = 0
            self.chartContentView.layoutIfNeeded()
            for item in dashViews {
                DispatchQueue.main.async {
                    item.isHidden = true
                    item.removeSubLayer()
                }
            }
        }
        self.sleepBarChart.isHidden = !show
        self.startTimeLabel.isHidden = !show
        self.endTimeLabel.isHidden = !show
        self.icMoonImageView.isHidden = !show
    }
}
