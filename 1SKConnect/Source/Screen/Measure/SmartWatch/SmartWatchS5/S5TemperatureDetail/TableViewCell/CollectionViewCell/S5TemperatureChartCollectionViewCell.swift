//
//  S5TemperatureChartCollectionViewCell.swift
//  1SKConnect
//
//  Created by TrungDN on 28/12/2021.
//

import UIKit

import Charts

protocol S5TemperatureChartCollectionViewCellDelegate: AnyObject {
    func onSelectNext(_ cell: UICollectionViewCell)
    func onSelectPrevious(_ cell: UICollectionViewCell)
}

class S5TemperatureChartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var icPreviousImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var icNextImageView: UIImageView!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var mainempLabel: UILabel!
    @IBOutlet weak var viewContent: UIView!
    
    weak var delegate: S5TemperatureChartCollectionViewCellDelegate?
    
    private lazy var dayLineChartView = self.createLineChartView(with: .temperature, timeType: .day)
    private lazy var weekLineChartView = self.createLineChartView(with: .temperature, timeType: .week)
    private lazy var monthLineChartView = self.createLineChartView(with: .temperature, timeType: .month)
    private lazy var yearLineChartView = self.createLineChartView(with: .temperature, timeType: .year)
    
    var dayModel: S5TemperatureRecordModel? {
        didSet {
            self.setDayData()
        }
    }
    
    var weakModel: [S5TemperatureRecordModel]? {
        didSet {
            self.setWeekData()
        }
    }
    
    var monthModel: [S5TemperatureRecordModel]? {
        didSet {
            self.setMonthData()
        }
    }

    var yearModel: [[S5TemperatureRecordModel]]? {
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
            self.setUpDayChartsData(data: [])
            
            self.weekLineChartView.anchor(top: self.chartContentView.topAnchor,
                                      left: self.chartContentView.leftAnchor,
                                      bottom: self.chartContentView.bottomAnchor,
                                      right: self.chartContentView.rightAnchor,
                                      paddingTop: 0,
                                      paddingLeft: 0,
                                      paddingBottom: 0,
                                      paddingRight: 0)
            self.setUpWeakChartsData(data: [])

            self.monthLineChartView.anchor(top: self.chartContentView.topAnchor,
                                           left: self.chartContentView.leftAnchor,
                                           bottom: self.chartContentView.bottomAnchor,
                                           right: self.chartContentView.rightAnchor,
                                           paddingTop: 0,
                                           paddingLeft: 0,
                                           paddingBottom: 0,
                                           paddingRight: 0)
            self.setUpMonthChartsData(data: [])

            self.yearLineChartView.anchor(top: self.chartContentView.topAnchor,
                                           left: self.chartContentView.leftAnchor,
                                           bottom: self.chartContentView.bottomAnchor,
                                           right: self.chartContentView.rightAnchor,
                                           paddingTop: 0,
                                           paddingLeft: 0,
                                           paddingBottom: 0,
                                           paddingRight: 0)
            self.setUpYearChartsData(data: [])
        }
    }
    
    @objc private func handleNext() {
        self.delegate?.onSelectNext(self)
    }
    
    @objc private func handlePrevious() {
        self.delegate?.onSelectPrevious(self)
    }
    
    private func setDayData() {
        guard let model = self.dayModel else {
            self.setUpDayChartsData(data: [])
            self.maxTempLabel.attributedText = self.getNSMutableAttributedString(for: "-- °C", description: R.string.localizable.smart_watch_s5_max_temp())
            self.mainempLabel.attributedText = self.getNSMutableAttributedString(for: "-- °C", description: R.string.localizable.smart_watch_s5_min_temp())
            return
        }
        let date = model.dateTime.toDate(.ymd) ?? Date()
        let dateStr = date.toString(.dayOfWeek)
        self.dateLabel.text = dateStr

        if !model.tempDetail.isEmpty {
            self.maxTempLabel.attributedText = self.getNSMutableAttributedString(for: "\(Double(model.max) / 100) °C", description: R.string.localizable.smart_watch_s5_max_temp())
            self.mainempLabel.attributedText = self.getNSMutableAttributedString(for: "\(Double(model.min) / 100) °C", description: R.string.localizable.smart_watch_s5_min_temp())
            DispatchQueue.main.async {
                self.dayLineChartView.xAxis.valueFormatter = TimeValueFormatter(date: model.dateTime.toDate(.ymd)!)
                self.dayLineChartView.xAxis.axisMinimum = model.dateTime.toDate(.ymd)!.startOfDay.timeIntervalSince1970
                self.dayLineChartView.xAxis.axisMaximum = model.dateTime.toDate(.ymd)!.endOfDay.timeIntervalSince1970
                self.setUpDayChartsData(data: model.vitalSigns)
            }
        } else {
            self.maxTempLabel.attributedText = self.getNSMutableAttributedString(for: "-- °C", description: R.string.localizable.smart_watch_s5_max_temp())
            self.mainempLabel.attributedText = self.getNSMutableAttributedString(for: "-- °C", description: R.string.localizable.smart_watch_s5_min_temp())
            DispatchQueue.main.async {
                self.setUpDayChartsData(data: [])
            }
        }
    }

    private func setWeekData() {
        guard let data = self.weakModel else { return }
        if !data.isEmpty {
            let startOfWeek = data[0].dateTime.toDate(.ymd)!.startOfWeek.toString(.dayMonth)
            let endOfWeek = data[0].dateTime.toDate(.ymd)!.endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
            
            DispatchQueue.main.async {
                self.maxTempLabel.attributedText = self.getNSMutableAttributedString(for: "\(Double(data.map { $0.max }.max()!) / 100) °C", description: R.string.localizable.smart_watch_s5_max_temp())
                
                self.mainempLabel.attributedText = self.getNSMutableAttributedString(for: "\(Double(data.map { $0.min }.min()!) / 100) °C", description: R.string.localizable.smart_watch_s5_min_temp())
                
                self.weekLineChartView.xAxis.axisMinimum = data[0].dateTime.toDate(.ymd)!.chartStartOfWeek!.timeIntervalSince1970
                self.weekLineChartView.xAxis.axisMaximum = data[0].dateTime.toDate(.ymd)!.chartEndOfWeek!.timeIntervalSince1970
                self.setUpWeakChartsData(data: data)
            }
        } else {
            let startOfWeek = Date().startOfWeek.toString(.dayMonth)
            let endOfWeek = Date().endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
        }
    }
    
    private func setMonthData() {
        guard let data = self.monthModel else { return }
        if !data.isEmpty {
            let startOfWeek = data[0].dateTime.toDate(.ymd)!.startOfWeek.toString(.dayMonth)
            let endOfWeek = data[0].dateTime.toDate(.ymd)!.endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
            
            DispatchQueue.main.async {
                self.maxTempLabel.attributedText = self.getNSMutableAttributedString(for: "\(Double(data.map { $0.max }.max()!) / 100) °C", description: R.string.localizable.smart_watch_s5_max_temp())
                
                self.mainempLabel.attributedText = self.getNSMutableAttributedString(for: "\(Double(data.map { $0.min }.min()!) / 100) °C", description: R.string.localizable.smart_watch_s5_min_temp())
                
                self.monthLineChartView.xAxis.axisMinimum = data[0].dateTime.toDate(.ymd)!.startOfMonth.timeIntervalSince1970
                self.monthLineChartView.xAxis.axisMaximum = data[0].dateTime.toDate(.ymd)!.endOfMonth.timeIntervalSince1970
                self.monthLineChartView.setVisibleXRange(minXRange: Double(data[0].dateTime.toDate(.ymd)!.numberOfDaysInMonth) * 24 * 3600, maxXRange: Double(data[0].dateTime.toDate(.ymd)!.numberOfDaysInMonth) * 24 * 3600)
                self.setUpMonthChartsData(data: data)
            }
        } else {
            let startOfWeek = Date().startOfWeek.toString(.dayMonth)
            let endOfWeek = Date().endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
        }
    }
    
    private func setYearData() {
        guard let data = self.yearModel else { return }
        if !data.isEmpty {
            let startOfMonth = data[0][0].dateTime.toDate(.ymd)!.startOfYear.toString(.dayMonth)
            let endOfMonth = data[0][0].dateTime.toDate(.ymd)!.endOfYear.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
            
            let maxHr = data.map { bp in
                return bp.map { bpData in
                    return bpData.max
                }.max()!
            }.max()!
            let minHr = data.map { bp in
                return bp.map { bpData in
                    return bpData.min
                }.min()!
            }.min()!
            
            self.maxTempLabel.attributedText = self.getNSMutableAttributedString(for: "\(Double(maxHr) / 100) °C", description: R.string.localizable.smart_watch_s5_max_temp())
            self.mainempLabel.attributedText = self.getNSMutableAttributedString(for: "\(Double(minHr) / 100) °C", description: R.string.localizable.smart_watch_s5_min_temp())
            DispatchQueue.main.async {
                self.setUpYearChartsData(data: data)
            }
        } else {
            let startOfMonth = Date().startOfYear.toString(.dayMonth)
            let endOfMonth = Date().endOfYear.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
        }
    }
    
    /// Get NSMutableAttributedString text
    /// - Parameters:
    ///   - value: value string
    ///   - description: description string
    /// - Returns: a string with format `description value`
    private func getNSMutableAttributedString(for value: String, description: String) -> NSMutableAttributedString? {
        let attributeString = NSMutableAttributedString(string: description, attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!])
        attributeString.append(NSAttributedString(string: "\n" + value, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.title()!]))
        return attributeString
    }
}

extension S5TemperatureChartCollectionViewCell {
    private func createLineChartView(with lineChartType: CellType, timeType: TimeFilterType) -> LineChartView {
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
        yAxis.valueFormatter = LineChartLeftAxisFormatter(type: lineChartType)
        
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
        
        if lineChartType == .heartRate || lineChartType == .spO2 {
            yAxis.axisMinimum = 0
            yAxis.axisMaximum = 250
            yAxis.granularity = 50
        } else if lineChartType == .temperature {
            yAxis.axisMinimum = 30
            yAxis.axisMaximum = 60
            yAxis.granularity = 10
        }

        lineChart.clipsToBounds = false
        lineChart.xAxis.enabled = true
        lineChart.legend.textColor = .white
        lineChart.legend.verticalAlignment = .top
        return lineChart
    }

}

// MARK: - ChartViewDelegate
extension S5TemperatureChartCollectionViewCell: ChartViewDelegate {
    private func setUpDayChartsData(data: [VitalSign]) {
        if data.isEmpty {
            self.dayLineChartView.data = setupLineChartData(with: [], for: .heartRate)
        } else {
            var chartDataValues: [ChartDataEntry] = []
            for data in data {
                let chartData = ChartDataEntry(x: data.timestamp, y: data.value)
                chartDataValues.append(chartData)
            }
            self.dayLineChartView.data = setupLineChartData(with: chartDataValues, for: .heartRate)
        }
        self.dayLineChartView.setVisibleXRangeMaximum(7)
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height >= 2436 {
                self.dayLineChartView.animate(yAxisDuration: 0.5)
            }
        }
    }
    
    func setUpWeakChartsData(data: [S5TemperatureRecordModel]) {
        if data.isEmpty {
            self.weekLineChartView.data = setupLineChartData(with: [], for: .heartRate)
        } else {
            var chartDataValues: [ChartDataEntry] = []
            for data in data {
                let chartData = ChartDataEntry(x: data.timestamp, y: Double(data.avg / 100))
                chartDataValues.append(chartData)
            }
            self.weekLineChartView.data = setupLineChartData(with: chartDataValues, for: .heartRate)
        }
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height >= 2436 {
                self.weekLineChartView.animate(yAxisDuration: 0.5)
            }
        }
    }

    func setUpMonthChartsData(data: [S5TemperatureRecordModel]) {
        if data.isEmpty {
            self.monthLineChartView.data = setupLineChartData(with: [], for: .heartRate)
        } else {
            var chartDataValues: [ChartDataEntry] = []
            for data in data {
                let chartData = ChartDataEntry(x: data.timestamp, y: Double(data.avg / 100))
                chartDataValues.append(chartData)
            }
            self.monthLineChartView.data = setupLineChartData(with: chartDataValues, for: .heartRate)
        }
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height >= 2436 {
                self.monthLineChartView.animate(yAxisDuration: 0.5)
            }
        }
    }
    
    func setUpYearChartsData(data: [[S5TemperatureRecordModel]]) {
        if data.isEmpty {
            self.yearLineChartView.data = setupLineChartData(with: [], for: .heartRate)
        } else {
            var chartDataValues: [ChartDataEntry] = []
            for i in 0 ..< data.count {
                let chartData = ChartDataEntry(x: Double(data[i][0].timestamp.toDate().month), y: Double((data[i].map { $0.avg }.reduce(0, +) / data[i].count) / 100))
                chartDataValues.append(chartData)
            }
            self.yearLineChartView.data = setupLineChartData(with: chartDataValues, for: .spO2)
            if UIDevice().userInterfaceIdiom == .phone {
                if UIScreen.main.nativeBounds.height >= 2436 {
                    self.yearLineChartView.animate(yAxisDuration: 0.5)
                }
            }
        }
    }

    private func setupLineChartData(with dataEntry: [ChartDataEntry], for lineChartType: CellType) -> LineChartData {
        var set: LineChartDataSet

        set = LineChartDataSet(entries: dataEntry, label: "")
        set.colors = [UIColor(hex: "FF2A44")]
        set.lineWidth = 3
        set.drawCirclesEnabled = false
        set.drawFilledEnabled = true
        set.fillColor = UIColor(hex: "FF2A44", alpha: 0.3)
        set.circleColors = [UIColor(hex: "FF2A44")]
        set.circleRadius = 2
        
        if dataEntry.count == 1 {
            set.drawCirclesEnabled = true
            set.circleColors = [UIColor(hex: "FF2A44")]
            set.circleRadius = 2
        }

        set.mode = (set.mode == .cubicBezier) ? .linear : .horizontalBezier
        let dataSet = LineChartData(dataSet: set)
        dataSet.setDrawValues(false)
        return dataSet
        
    }
}
