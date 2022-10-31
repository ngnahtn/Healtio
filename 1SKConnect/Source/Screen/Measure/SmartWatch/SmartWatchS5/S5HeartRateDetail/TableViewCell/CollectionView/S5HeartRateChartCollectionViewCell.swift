//
//  S5HeartRateChartCollectionViewCell.swift
//  1SKConnect
//
//  Created by Be More on 27/12/2021.
//

import UIKit
import Charts

protocol S5HeartRateChartCollectionViewCellDelegate: AnyObject {
    func onSelectNext(_ cell: UICollectionViewCell)
    func onSelectPrevious(_ cell: UICollectionViewCell)
}

class S5HeartRateChartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var icPreviousImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var icNextImageView: UIImageView!
    @IBOutlet weak var maxHrLabel: UILabel!
    @IBOutlet weak var minHrLabel: UILabel!
    @IBOutlet weak var viewContent: UIView!
    
    weak var delegate: S5HeartRateChartCollectionViewCellDelegate?
    
    private lazy var dayLineChartView = self.createLineChartView(timeType: .day)
    private lazy var weekLineChartView = self.createLineChartView(timeType: .week)
    private lazy var monthLineChartView = self.createLineChartView(timeType: .month)
    private lazy var yearLineChartView = self.createLineChartView(timeType: .year)
    
    var dayModel: S5HeartRateRecordModel? {
        didSet {
            self.setDayData()
        }
    }
    
    var weakModel: [S5HeartRateRecordModel]? {
        didSet {
            self.setWeekData()
        }
    }
    
    var monthModel: [S5HeartRateRecordModel]? {
        didSet {
            self.setMonthData()
        }
    }

    var yearModel: [[S5HeartRateRecordModel]]? {
        didSet {
            self.setYearData()
        }
    }

    var timeType: TimeFilterType = .day {
        didSet {
            self.weekLineChartView.isHidden = (timeType == .week) ? false : true
            self.dayLineChartView.isHidden = (timeType == .day) ? false : true
            self.monthLineChartView.isHidden = (timeType == .month) ? false : true
            self.yearLineChartView.isHidden = (timeType == .year) ? false : true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.createChart()
        self.icNextImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleNext)))
        self.icPreviousImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handlePrevious)))
    }
}

// MARK: - Selectors
extension S5HeartRateChartCollectionViewCell {
    /// Next
    @objc private func handleNext() {
        self.delegate?.onSelectNext(self)
    }
    
    /// Back
    @objc private func handlePrevious() {
        self.delegate?.onSelectPrevious(self)
    }
}

// MARK: - ChartViewDelegate
extension S5HeartRateChartCollectionViewCell: ChartViewDelegate {
}

// MARK: - Day chart
extension S5HeartRateChartCollectionViewCell {
    /// Set data model
    private func setDayData() {
        guard let model = self.dayModel else {
            self.setDayChartsData(data: [])
            return
        }
        let date = model.dateTime.toDate(.ymd) ?? Date()
        let dateStr = date.toString(.dayOfWeek)
        self.dateLabel.text = dateStr
        
        if !model.hrDetail.isEmpty {
            self.maxHrLabel.attributedText = self.getNSMutableAttributedString(for: "\(model.heartRateMax) bpm", description: R.string.localizable.smart_watch_s5_max_hr())
            self.minHrLabel.attributedText = self.getNSMutableAttributedString(for: "\(model.heartRateMin) bpm", description: R.string.localizable.smart_watch_s5_min_hr())
            DispatchQueue.main.async {
                self.dayLineChartView.xAxis.valueFormatter = TimeValueFormatter(date: model.dateTime.toDate(.ymd)!)
                self.dayLineChartView.xAxis.axisMinimum = model.dateTime.toDate(.ymd)!.startOfDay.timeIntervalSince1970
                self.dayLineChartView.xAxis.axisMaximum = model.dateTime.toDate(.ymd)!.endOfDay.timeIntervalSince1970
                self.setDayChartsData(data: model.vitalSigns)
            }
        } else {
            self.maxHrLabel.attributedText = self.getNSMutableAttributedString(for: "-- bpm", description: R.string.localizable.smart_watch_s5_max_hr())
            self.minHrLabel.attributedText = self.getNSMutableAttributedString(for: "-- bpm", description: R.string.localizable.smart_watch_s5_min_hr())
            DispatchQueue.main.async {
                self.setDayChartsData(data: [])
            }
        }
    }
    
    /// Set day chart data
    /// - Parameter data: `[VitalSign]`
    private func setDayChartsData(data: [VitalSign]) {
        if data.isEmpty {
            self.dayLineChartView.data = setLineChartData(with: [])
        } else {
            var chartDataValues: [ChartDataEntry] = []
            for data in data {
                let chartData = ChartDataEntry(x: data.timestamp, y: data.value)
                chartDataValues.append(chartData)
            }
            self.dayLineChartView.data = setLineChartData(with: chartDataValues)
        }
        self.dayLineChartView.setVisibleXRangeMaximum(7)
        self.setAnimateLine(with: .day)
    }

    /// Set data entry fo day chart
    /// - Parameter dataEntry: `[ChartDataEntry]`
    /// - Returns: `LineChartData`
    private func setLineChartData(with dataEntry: [ChartDataEntry]) -> LineChartData {
        let set = LineChartDataSet(entries: dataEntry, label: "")
        set.colors = [UIColor(hex: "FFA422")]
        
        set.fillColor = UIColor(hex: "FFA422", alpha: 0.3)
        set.lineWidth = 3
        set.drawCirclesEnabled = false
        set.drawFilledEnabled = true
        
        // if have one value add a dot
        if dataEntry.count == 1 {
            set.drawCirclesEnabled = true
            set.circleColors = [UIColor(hex: "FFA422")]
            set.circleRadius = 2
        }
        set.mode = (set.mode == .cubicBezier) ? .linear : .horizontalBezier
        let dataSet = LineChartData(dataSet: set)
        dataSet.setDrawValues(false)
        return dataSet
    }
}

// MARK: - Week chart
extension S5HeartRateChartCollectionViewCell {
    /// Set week data model
    private func setWeekData() {
        guard let data = self.weakModel else { return }
        if !data.isEmpty {
            let startOfWeek = data[0].dateTime.toDate(.ymd)!.startOfWeek.toString(.dayMonth)
            let endOfWeek = data[0].dateTime.toDate(.ymd)!.endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
            
            DispatchQueue.main.async {
                self.maxHrLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.map { $0.heartRateMax }.max()!) bpm", description: R.string.localizable.smart_watch_s5_max_hr())
                
                self.minHrLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.map { $0.heartRateMin }.min()!) bpm", description: R.string.localizable.smart_watch_s5_min_hr())
                
                self.weekLineChartView.xAxis.axisMinimum = data[0].dateTime.toDate(.ymd)!.chartStartOfWeek!.timeIntervalSince1970
                self.weekLineChartView.xAxis.axisMaximum = data[0].dateTime.toDate(.ymd)!.chartEndOfWeek!.timeIntervalSince1970
                self.setWeakChartsData(data: data)
            }
        } else {
            let startOfWeek = Date().startOfWeek.toString(.dayMonth)
            let endOfWeek = Date().endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
        }
    }
    
    /// Set week chart data
    /// - Parameter data: `[S5HeartRateRecordModel]`
    func setWeakChartsData(data: [S5HeartRateRecordModel]) {
        if data.isEmpty {
            self.weekLineChartView.data = setWMYLineChartData(with: [], and: [])
        } else {
            var maxDataValue: [ChartDataEntry] = []
            for data in data {
                let chartData = ChartDataEntry(x: data.timestamp, y: Double(data.heartRateMax))
                maxDataValue.append(chartData)
            }
            
            var minDataValue: [ChartDataEntry] = []
            for data in data {
                let chartData = ChartDataEntry(x: data.timestamp, y: Double(data.heartRateMin))
                minDataValue.append(chartData)
            }
            
            self.weekLineChartView.data = self.setWMYLineChartData(with: maxDataValue, and: minDataValue)
        }
        self.setAnimateLine(with: .week)
    }
}

// MARK: - Month chart
extension S5HeartRateChartCollectionViewCell {
    /// Set month data model
    private func setMonthData() {
        guard let data = self.monthModel else { return }
        if !data.isEmpty {
            let startOfWeek = data[0].dateTime.toDate(.ymd)!.startOfWeek.toString(.dayMonth)
            let endOfWeek = data[0].dateTime.toDate(.ymd)!.endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
            
            DispatchQueue.main.async {
                self.maxHrLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.map { $0.heartRateMax }.max()!) bpm", description: R.string.localizable.smart_watch_s5_max_hr())

                self.minHrLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.map { $0.heartRateMin }.min()!) bpm", description: R.string.localizable.smart_watch_s5_min_hr())
         
                self.monthLineChartView.xAxis.axisMinimum = data[0].dateTime.toDate(.ymd)!.startOfMonth.timeIntervalSince1970
                self.monthLineChartView.xAxis.axisMaximum = data[0].dateTime.toDate(.ymd)!.endOfMonth.timeIntervalSince1970
                self.monthLineChartView.setVisibleXRange(minXRange: Double(data[0].dateTime.toDate(.ymd)!.numberOfDaysInMonth) * 24 * 3600, maxXRange: Double(data[0].dateTime.toDate(.ymd)!.numberOfDaysInMonth) * 24 * 3600)
                self.setMonthChartsData(data: data)
            }
        } else {
            let startOfWeek = Date().startOfWeek.toString(.dayMonth)
            let endOfWeek = Date().endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
        }
    }
    
    /// Set month chart data
    /// - Parameter data: `[S5HeartRateRecordModel]`
    func setMonthChartsData(data: [S5HeartRateRecordModel]) {
        if data.isEmpty {
            self.monthLineChartView.data = setWMYLineChartData(with: [], and: [])
        } else {
            var maxDataValue: [ChartDataEntry] = []
            for data in data {
                let chartData = ChartDataEntry(x: data.timestamp, y: Double(data.heartRateMax))
                maxDataValue.append(chartData)
            }
            
            var minDataValue: [ChartDataEntry] = []
            for data in data {
                let chartData = ChartDataEntry(x: data.timestamp, y: Double(data.heartRateMin))
                minDataValue.append(chartData)
            }
            self.monthLineChartView.data = setWMYLineChartData(with: maxDataValue, and: minDataValue)
        }
        self.setAnimateLine(with: .month)
    }
}

// MARK: - year chart
extension S5HeartRateChartCollectionViewCell {
    /// Set month data model
    private func setYearData() {
        guard let data = self.yearModel else { return }
        if !data.isEmpty {
            let startOfMonth = data[0][0].dateTime.toDate(.ymd)!.startOfYear.toString(.dayMonth)
            let endOfMonth = data[0][0].dateTime.toDate(.ymd)!.endOfYear.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
            
            let maxHr = data.map { bp in
                return bp.map { bpData in
                    return bpData.heartRateMax
                }.max()!
            }.max()!
            
            let minHr = data.map { bp in
                return bp.map { bpData in
                    return bpData.heartRateMin
                }.min()!
            }.min()!
            
            self.maxHrLabel.attributedText = self.getNSMutableAttributedString(for: "\(maxHr) bpm", description: R.string.localizable.smart_watch_s5_max_hr())
            self.minHrLabel.attributedText = self.getNSMutableAttributedString(for: "\(minHr) bpm", description: R.string.localizable.smart_watch_s5_min_hr())
            DispatchQueue.main.async {
                self.setYearChartsData(data: data)
            }
        } else {
            let startOfMonth = Date().startOfYear.toString(.dayMonth)
            let endOfMonth = Date().endOfYear.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
        }
    }
    
    /// set year chart data
    /// - Parameter data: `[[S5HeartRateRecordModel]]`
    func setYearChartsData(data: [[S5HeartRateRecordModel]]) {
        if data.isEmpty {
            self.yearLineChartView.data = self.setWMYLineChartData(with: [], and: [])
        } else {
            var maxDataValue: [ChartDataEntry] = []
            for i in 0 ..< data.count {
                let chartData = ChartDataEntry(x: Double(data[i][0].timestamp.toDate().month), y: Double(data[i].map { $0.heartRateMax }.reduce(0, +) / data[i].count))
                maxDataValue.append(chartData)
            }
            
            var minDataValue: [ChartDataEntry] = []
            for i in 0 ..< data.count {
                let chartData = ChartDataEntry(x: Double(data[i][0].timestamp.toDate().month), y: Double(data[i].map { $0.heartRateMin }.reduce(0, +) / data[i].count))
                minDataValue.append(chartData)
            }
            
            self.yearLineChartView.data = self.setWMYLineChartData(with: maxDataValue, and: minDataValue)
            self.setAnimateLine(with: .year)
        }
    }
}

// MARK: - Helpers
extension S5HeartRateChartCollectionViewCell {
    /// Add constraints
    private func createChart() {
        [self.dayLineChartView, self.weekLineChartView, self.monthLineChartView, self.yearLineChartView].forEach { self.chartContentView.addSubview($0) }
        DispatchQueue.main.async {
            self.dayLineChartView.anchor(top: self.chartContentView.topAnchor,
                                      left: self.chartContentView.leftAnchor,
                                      bottom: self.chartContentView.bottomAnchor,
                                      right: self.chartContentView.rightAnchor,
                                      paddingTop: 0,
                                      paddingLeft: 0,
                                      paddingBottom: 0,
                                      paddingRight: 0)
            self.setDayChartsData(data: [])
            
            self.weekLineChartView.anchor(top: self.chartContentView.topAnchor,
                                      left: self.chartContentView.leftAnchor,
                                      bottom: self.chartContentView.bottomAnchor,
                                      right: self.chartContentView.rightAnchor,
                                      paddingTop: 0,
                                      paddingLeft: 0,
                                      paddingBottom: 0,
                                      paddingRight: 0)
            self.setWeakChartsData(data: [])

            self.monthLineChartView.anchor(top: self.chartContentView.topAnchor,
                                           left: self.chartContentView.leftAnchor,
                                           bottom: self.chartContentView.bottomAnchor,
                                           right: self.chartContentView.rightAnchor,
                                           paddingTop: 0,
                                           paddingLeft: 0,
                                           paddingBottom: 0,
                                           paddingRight: 0)
            self.setMonthChartsData(data: [])

            self.yearLineChartView.anchor(top: self.chartContentView.topAnchor,
                                           left: self.chartContentView.leftAnchor,
                                           bottom: self.chartContentView.bottomAnchor,
                                           right: self.chartContentView.rightAnchor,
                                           paddingTop: 0,
                                           paddingLeft: 0,
                                           paddingBottom: 0,
                                           paddingRight: 0)
            self.setYearChartsData(data: [])
        }
    }
    
    /// Create line chart
    /// - Parameter timeType: time filter type
    /// - Returns: `LineChartView`
    private func createLineChartView(timeType: TimeFilterType) -> LineChartView {
        let lineChart = LineChartView()
        lineChart.isUserInteractionEnabled = false
        lineChart.delegate = self
        lineChart.backgroundColor = .white
        lineChart.doubleTapToZoomEnabled = false
        lineChart.isUserInteractionEnabled = false
        lineChart.setScaleEnabled(false)
        lineChart.legend.enabled = false
        // yAxis
        let yAxis = lineChart.leftAxis
        yAxis.labelTextColor = UIColor(hex: "737678")
        yAxis.axisLineColor = UIColor(hex: "D3DFE8")
        yAxis.gridColor = UIColor(hex: "D3DFE8")
        yAxis.valueFormatter = LineChartLeftAxisFormatter(type: .heartRate)
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 250
        yAxis.granularity = 50
        
        // yAxis
        let yRightAxis = lineChart.rightAxis
        yRightAxis.labelTextColor = .clear
        yRightAxis.axisLineColor = .clear
        yRightAxis.gridColor = .clear
        
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = UIColor(hex: "737678")
        xAxis.axisLineColor = UIColor(hex: "D3DFE8")
        xAxis.gridColor = UIColor(hex: "D3DFE8")

        if timeType == .day {
            xAxis.valueFormatter = TimeValueFormatter(date: Date())
            xAxis.axisMinimum = Date().startOfDay.timeIntervalSince1970
            xAxis.axisMaximum = Date().endOfDay.timeIntervalSince1970
            xAxis.granularity = 3600 * 4
            lineChart.setVisibleXRange(minXRange: 24 * 3600, maxXRange: 24 * 3600)
            xAxis.setLabelCount(7, force: true)
        } else if timeType == .week {
            xAxis.valueFormatter = DayValueFormatter()
            xAxis.axisMinimum = Date().chartStartOfWeek!.timeIntervalSince1970
            xAxis.axisMaximum = Date().chartEndOfWeek!.timeIntervalSince1970
            xAxis.granularity = 3600 * 24
            lineChart.setVisibleXRange(minXRange: 6 * 24 * 3600, maxXRange: 6 * 24 * 3600)
            xAxis.setLabelCount(7, force: true)
        } else if timeType == .month {
            xAxis.valueFormatter = DayValueFormatter()
            xAxis.axisMinimum = Date().startOfMonth.timeIntervalSince1970
            xAxis.axisMaximum = Date().endOfMonth.timeIntervalSince1970
            xAxis.granularity = 3600 * 24 * 8
            xAxis.setLabelCount(8, force: true)
        } else {
            xAxis.valueFormatter = YearValueFormatter()
            xAxis.granularity = 1
            xAxis.axisMinimum = 1
            xAxis.axisMaximum = 13
            xAxis.setLabelCount(13, force: true)
        }
        xAxis.labelPosition = .bottom
        xAxis.avoidFirstLastClippingEnabled = false

        lineChart.clipsToBounds = false
        lineChart.xAxis.enabled = true
        lineChart.legend.textColor = .white
        lineChart.legend.verticalAlignment = .top
        return lineChart
    }
    
    /// Set chart animation
    /// - Parameter timeType: time filter type
    private func setAnimateLine(with timeType: TimeFilterType) {
        if kUIDevice.userInterfaceIdiom == .phone {
            // iphone below x cannot have chart animation
            if UIScreen.main.nativeBounds.height >= 2436 {
                switch timeType {
                case .day:
                    self.dayLineChartView.animate(yAxisDuration: 0.5)
                case .week:
                    self.weekLineChartView.animate(yAxisDuration: 0.5)
                case .month:
                    self.monthLineChartView.animate(yAxisDuration: 0.5)
                case .year:
                    self.yearLineChartView.animate(yAxisDuration: 0.5)
                }
            }
        }
    }
    
    /// Set data entry for week, month, year line chart
    /// - Parameters:
    ///   - dataEntry1: Max data entry
    ///   - dataEntry2: Min data entry
    /// - Returns: `LineChartData`
    private func setWMYLineChartData(with dataEntry1: [ChartDataEntry], and dataEntry2: [ChartDataEntry]) -> LineChartData {
        let set1 = LineChartDataSet(entries: dataEntry1, label: "")
        set1.colors = [UIColor(hex: "FFA422")]
        set1.fillColor = UIColor(hex: "FFA422", alpha: 0.3)
        set1.lineWidth = 3
        set1.drawCirclesEnabled = false
        set1.drawFilledEnabled = true
        
        let set2 = LineChartDataSet(entries: dataEntry2, label: "")
        set2.colors = [UIColor(hex: "47DEFF")]
        set2.fillColor = UIColor(hex: "47DEFF", alpha: 0.3)
        set2.lineWidth = 3
        set2.drawCirclesEnabled = false
        set2.drawFilledEnabled = true
        
        if dataEntry1.count == 1 {
            set1.drawCirclesEnabled = true
            set1.circleColors = [UIColor(hex: "FFA422")]
            set1.circleRadius = 2
        }
        
        if dataEntry2.count == 1 {
            set2.drawCirclesEnabled = true
            set2.circleColors = [UIColor(hex: "47DEFF")]
            set2.circleRadius = 2
        }
        
        set1.mode = (set1.mode == .cubicBezier) ? .linear : .horizontalBezier
        set2.mode = (set2.mode == .cubicBezier) ? .linear : .horizontalBezier
        let dataSet = LineChartData()
        dataSet.addDataSet(set1)
        dataSet.addDataSet(set2)
        dataSet.setDrawValues(false)
        return dataSet
    }
    
    /// Get NSMutableAttributedString text
    /// - Parameters:
    ///   - value: value string
    ///   - description: description string
    /// - Returns: a string with format `description value`
    private func getNSMutableAttributedString(for value: String, description: String) -> NSMutableAttributedString? {
        let attributeString = NSMutableAttributedString(string: description, attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!])
        attributeString.append(NSAttributedString(string: value, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.title()!]))
        return attributeString
    }
}
