//
//  S5BloodPressureChartCollectionViewCell.swift
//  1SKConnect
//
//  Created by TrungDN on 27/12/2021.
//

import UIKit
import Charts

protocol S5BloodPressureChartCollectionViewCellDelegate: AnyObject {
    func onSelectNext(_ cell: UICollectionViewCell)
    func onSelectPrevious(_ cell: UICollectionViewCell)
}

class S5BloodPressureChartCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var icPreviousImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var icNextImageView: UIImageView!
    @IBOutlet weak var maxBpLabel: UILabel!
    @IBOutlet weak var minBpLabel: UILabel!
    @IBOutlet weak var viewContent: UIView!
    weak var delegate: S5BloodPressureChartCollectionViewCellDelegate?
    
    private lazy var dayLineChartView = self.createLineChartView(with: .bloodPressure, timeType: .day)
    private lazy var weekLineChartView = self.createLineChartView(with: .bloodPressure, timeType: .week)
    private lazy var monthLineChartView = self.createLineChartView(with: .bloodPressure, timeType: .month)
    private lazy var yearLineChartView = self.createLineChartView(with: .bloodPressure, timeType: .year)
    
    var dayModel: BloodPressureRecordModel? {
        didSet {
            self.setDayData()
        }
    }
    
    var weakModel: [BloodPressureRecordModel]? {
        didSet {
            self.setWeekData()
        }
    }
    
    var monthModel: [BloodPressureRecordModel]? {
        didSet {
            self.setMonthData()
        }
    }

    var yearModel: [[BloodPressureRecordModel]]? {
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

// MARK: - Helpers
extension S5BloodPressureChartCollectionViewCell {
    @objc private func handleNext() {
        self.delegate?.onSelectNext(self)
    }
    
    @objc private func handlePrevious() {
        self.delegate?.onSelectPrevious(self)
    }
    
    private func setDayData() {
        guard let model = self.dayModel else {
            self.setUpDayChartsData(sys: [], dia: [])
            return
        }
        let date = model.dateTime.toDate(.ymd) ?? Date()
        let dateStr = date.toString(.dayOfWeek)
        self.dateLabel.text = dateStr
        if !model.bloodPressureDetail.isEmpty {
            self.maxBpLabel.attributedText = self.getNSMutableAttributedString(for: "\(model.max.sbp)/\(model.max.dbp) mmHg", description: R.string.localizable.smart_watch_s5_max_bp())
            
            self.minBpLabel.attributedText = self.getNSMutableAttributedString(for: "\(model.min.sbp)/\(model.min.dbp) mmHg", description: R.string.localizable.smart_watch_s5_min_bp())
            
            DispatchQueue.main.async {
                self.dayLineChartView.xAxis.valueFormatter = TimeValueFormatter(date: model.dateTime.toDate(.ymd)!)
                self.dayLineChartView.xAxis.axisMinimum = model.dateTime.toDate(.ymd)!.startOfDay.timeIntervalSince1970
                self.dayLineChartView.xAxis.axisMaximum = model.dateTime.toDate(.ymd)!.endOfDay.timeIntervalSince1970
                self.setUpDayChartsData(sys: model.sysSigns, dia: model.diaSigns)
            }
        } else {
            self.maxBpLabel.attributedText = self.getNSMutableAttributedString(for: "--/-- mmHg", description: R.string.localizable.smart_watch_s5_max_bp())
            
            self.minBpLabel.attributedText = self.getNSMutableAttributedString(for: "--/-- mmHg", description: R.string.localizable.smart_watch_s5_min_bp())
            
            DispatchQueue.main.async {
                self.setUpDayChartsData(sys: [], dia: [])
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
                self.maxBpLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.map { $0.max.sbp }.max()!)/\(data.map { $0.max.dbp }.max()!) mmHg", description: R.string.localizable.smart_watch_s5_max_bp())
                
                self.minBpLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.map { $0.min.sbp }.min()!)/\(data.map { $0.min.dbp }.min()!) mmHg", description: R.string.localizable.smart_watch_s5_min_bp())
                
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
            let startOfMonth = data[0].dateTime.toDate(.ymd)!.startOfMonth.toString(.dayMonth)
            let endOfMonth = data[0].dateTime.toDate(.ymd)!.endOfMonth.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
            DispatchQueue.main.async {
                self.maxBpLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.map { $0.max.sbp }.max()!)/\(data.map { $0.max.dbp }.max()!) mmHg", description: R.string.localizable.smart_watch_s5_max_bp())
                
                self.minBpLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.map { $0.min.sbp }.min()!)/\(data.map { $0.min.dbp }.min()!) mmHg", description: R.string.localizable.smart_watch_s5_min_bp())
                
                self.monthLineChartView.xAxis.axisMinimum = data[0].dateTime.toDate(.ymd)!.startOfMonth.timeIntervalSince1970
                self.monthLineChartView.xAxis.axisMaximum = data[0].dateTime.toDate(.ymd)!.endOfMonth.timeIntervalSince1970
                self.monthLineChartView.setVisibleXRange(minXRange: Double(data[0].dateTime.toDate(.ymd)!.numberOfDaysInMonth) * 24 * 3600, maxXRange: Double(data[0].dateTime.toDate(.ymd)!.numberOfDaysInMonth) * 24 * 3600)
                self.setUpMonthChartsData(data: data)
            }
        } else {
            let startOfMonth = Date().startOfWeek.toString(.dayMonth)
            let endOfMonth = Date().endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
        }
    }
    
    private func setYearData() {
        guard let data = self.yearModel else { return }
        if !data.isEmpty {
            let startOfMonth = data[0][0].dateTime.toDate(.ymd)!.startOfYear.toString(.dayMonth)
            let endOfMonth = data[0][0].dateTime.toDate(.ymd)!.endOfYear.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
            
            let maxSbp = data.map { bp in
                return bp.map { bpData in
                    return bpData.max.sbp
                }.max()!
            }.max()!
            
            let minSbp = data.map { bp in
                return bp.map { bpData in
                    return bpData.min.sbp
                }.min()!
            }.min()!
            
            let maxDbp = data.map { bp in
                return bp.map { bpData in
                    return bpData.max.dbp
                }.max()!
            }.max()!
            
            let minDbp = data.map { bp in
                return bp.map { bpData in
                    return bpData.min.dbp
                }.min()!
            }.min()!
            
            self.maxBpLabel.attributedText = self.getNSMutableAttributedString(for: "\(maxSbp)/\(maxDbp) mmHg", description: R.string.localizable.smart_watch_s5_max_bp())
            self.minBpLabel.attributedText = self.getNSMutableAttributedString(for: "\(minSbp)/\(minDbp) mmHg", description: R.string.localizable.smart_watch_s5_min_bp())
            DispatchQueue.main.async {
                self.setUpYearChartsData(data: data)
            }
        } else {
            let startOfMonth = Date().startOfYear.toString(.dayMonth)
            let endOfMonth = Date().endOfYear.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
        }
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
            self.setUpDayChartsData(sys: [], dia: [])
            
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
    
    private func createLineChartView(with lineChartType: CellType, timeType: TimeFilterType) -> LineChartView {
        let lineChart = LineChartView()
        lineChart.isUserInteractionEnabled = false
        lineChart.delegate = self
        lineChart.backgroundColor = .white
        lineChart.doubleTapToZoomEnabled = false
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
        
        if lineChartType == .heartRate || lineChartType == .bloodPressure {
            yAxis.axisMinimum = 0
            yAxis.axisMaximum = 250
            yAxis.granularity = 50
        } else if lineChartType == .temperature {
            yAxis.axisMinimum = 20
            yAxis.axisMaximum = 60
            yAxis.granularity = 10
        }
        lineChart.clipsToBounds = false
        lineChart.xAxis.enabled = true
        lineChart.legend.textColor = .white
        lineChart.legend.verticalAlignment = .top
        return lineChart
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

// MARK: - ChartViewDelegate
extension S5BloodPressureChartCollectionViewCell: ChartViewDelegate {
    private func setUpDayChartsData(sys: [VitalSign], dia: [VitalSign]) {
        if sys.isEmpty {
            self.dayLineChartView.data = setupDayLineChartData(with: [], dataEntry2: [])
        } else {
            var sysDataValue: [ChartDataEntry] = []
            for data in sys {
                let chartData = ChartDataEntry(x: data.timestamp, y: data.value)
                sysDataValue.append(chartData)
            }
            
            var diaDataValue: [ChartDataEntry] = []
            for data in dia {
                let chartData = ChartDataEntry(x: data.timestamp, y: data.value)
                diaDataValue.append(chartData)
            }
            self.dayLineChartView.data = setupDayLineChartData(with: diaDataValue, dataEntry2: sysDataValue)
        }
        self.dayLineChartView.setVisibleXRangeMaximum(7)
    }
    
    private func setupDayLineChartData(with dataEntry1: [ChartDataEntry], dataEntry2: [ChartDataEntry]) -> LineChartData {
        var set1: LineChartDataSet
        set1 = LineChartDataSet(entries: dataEntry1, label: "")
        set1.colors = [UIColor(hex: "FF2A44")]
        set1.lineWidth = 1.2
        set1.drawCirclesEnabled = false
        set1.drawFilledEnabled = false
        set1.circleColors = [UIColor(hex: "FF2A44")]
        set1.circleRadius = 2
        
        set1.mode = (set1.mode == .cubicBezier) ? .linear : .horizontalBezier
        
        var set2: LineChartDataSet
        set2 = LineChartDataSet(entries: dataEntry2, label: "")
        set2.colors = [UIColor(hex: "#307EF4")]
        set2.lineWidth = 1.2
        set2.drawCirclesEnabled = false
        set2.drawFilledEnabled = false
        set2.circleColors = [UIColor(hex: "#307EF4")]
        set2.circleRadius = 2
        
        set2.mode = (set2.mode == .cubicBezier) ? .linear : .horizontalBezier
        
        if dataEntry1.count == 1 {
            set1.drawCirclesEnabled = true
        }

        if dataEntry2.count == 1 {
            set2.drawCirclesEnabled = true
        }
        let dataSet = LineChartData()
        dataSet.addDataSet(set1)
        dataSet.addDataSet(set2)
        dataSet.setDrawValues(false)
        return dataSet
    }
    
    private func setUpWeakChartsData(data: [BloodPressureRecordModel]) {
        if !data.isEmpty {
            var dataCharts: [[ChartDataEntry]] = []
            for bpData in data {
                let dataSbpChart: [ChartDataEntry] = [ChartDataEntry(x: bpData.timestamp, y: Double(bpData.max.sbp)),
                                                      ChartDataEntry(x: bpData.timestamp, y: Double(bpData.min.sbp))]
                let dataDbpChart: [ChartDataEntry] = [ChartDataEntry(x: bpData.timestamp, y: Double(bpData.max.dbp)),
                                                      ChartDataEntry(x: bpData.timestamp, y: Double(bpData.min.dbp))]
                dataCharts.append(dataSbpChart)
                dataCharts.append(dataDbpChart)
            }
            self.weekLineChartView.data = self.setupWeakLineChartData(entries: dataCharts)
        } else {
            self.weekLineChartView.data = self.setupWeakLineChartData(entries: [])
        }
    }
    
    private func setupWeakLineChartData(entries: [[ChartDataEntry]]) -> LineChartData {
        let dataSet = LineChartData()
        for i in  0 ..< entries.count {
            let set = LineChartDataSet(entries: entries[i], label: "")
            set.lineWidth = 1.2
            if i % 2 == 0 {
                set.colors = [UIColor(hex: "#307EF4")]
                set.circleColors = [UIColor(hex: "#307EF4")]
            } else {
                set.colors = [UIColor(hex: "FF2A44")]
                set.circleColors = [UIColor(hex: "FF2A44")]
            }
            set.drawCirclesEnabled = true
            set.drawFilledEnabled = false
            
            set.circleRadius = 2
            dataSet.addDataSet(set)
        }
        dataSet.setDrawValues(false)
        return dataSet
    }
    
    private func setUpMonthChartsData(data: [BloodPressureRecordModel]) {
        if !data.isEmpty {
            var dataCharts: [[ChartDataEntry]] = []
            for bpData in data {
                let dataSbpChart: [ChartDataEntry] = [ChartDataEntry(x: bpData.timestamp, y: Double(bpData.max.sbp)),
                                                      ChartDataEntry(x: bpData.timestamp, y: Double(bpData.min.sbp))]
                let dataDbpChart: [ChartDataEntry] = [ChartDataEntry(x: bpData.timestamp, y: Double(bpData.max.dbp)),
                                                      ChartDataEntry(x: bpData.timestamp, y: Double(bpData.min.dbp))]
                dataCharts.append(dataSbpChart)
                dataCharts.append(dataDbpChart)
            }
            self.monthLineChartView.data = self.setupWeakLineChartData(entries: dataCharts)
        } else {
            self.monthLineChartView.data = self.setupWeakLineChartData(entries: [])
        }
    }
    
    private func setUpYearChartsData(data: [[BloodPressureRecordModel]]) {
        if !data.isEmpty {
            var dataCharts: [[ChartDataEntry]] = []
            for i in 0 ..< data.count {
                let dataSbpChart: [ChartDataEntry] = [ChartDataEntry(x: Double(Int(data[i][0].timestamp.toDate().month)), y: Double(data[i].map { $0.max.sbp }.max()!)),
                                                      ChartDataEntry(x: Double(Int(data[i][0].timestamp.toDate().month)), y: Double(data[i].map { $0.min.sbp }.min()!))]
                let dataDbpChart: [ChartDataEntry] = [ChartDataEntry(x: Double(Int(data[i][0].timestamp.toDate().month)), y: Double(data[i].map { $0.max.dbp }.max()!)),
                                                      ChartDataEntry(x: Double(Int(data[i][0].timestamp.toDate().month)), y: Double(data[i].map { $0.min.dbp }.min()!))]
                dataCharts.append(dataSbpChart)
                dataCharts.append(dataDbpChart)
            }
            self.yearLineChartView.data = self.setupWeakLineChartData(entries: dataCharts)
        } else {
            self.yearLineChartView.data = self.setupWeakLineChartData(entries: [])
        }
    }
}
