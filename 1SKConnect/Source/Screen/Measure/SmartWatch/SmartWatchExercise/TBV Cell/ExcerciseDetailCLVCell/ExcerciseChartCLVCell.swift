//
//  ExcerciseChartCLVCell.swift
//  1SKConnect
//
//  Created by admin on 27/12/2021.
//

import UIKit
import Charts

protocol ExcerciseChartCLVCellDelegate: AnyObject {
    func onSelectNext(_ cell: UICollectionViewCell)
    func onSelectPrevious(_ cell: UICollectionViewCell)
}

class ExcerciseChartCLVCell: UICollectionViewCell {
    // UI properties
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var icPreviousImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var icNextImageView: UIImageView!

    @IBOutlet weak var totalStepLabel: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var avgStepLabel: UILabel!
    @IBOutlet weak var avgKcalLabel: UILabel!
    @IBOutlet weak var excerciseTimeLabel: UILabel!
    @IBOutlet weak var practiceTimeLabel: UILabel!
    
    private lazy var weakStepBarChartView: BarChartView = self.createGoalStepBarChartView(with: .week)
    private lazy var monthStepBarChartView: BarChartView = self.createGoalStepBarChartView(with: .month)
    private lazy var yearStepBarChartView: BarChartView = self.createGoalStepBarChartView(with: .year)

    // calculation properties
    weak var delegate: ExcerciseChartCLVCellDelegate?
    var timeType: TimeFilterType = .week {
        didSet {
            self.weakStepBarChartView.isHidden = (self.timeType == .week) ? false : true
            self.monthStepBarChartView.isHidden = (self.timeType == .month) ? false : true
            self.yearStepBarChartView.isHidden = (self.timeType == .year) ? false : true
        }
    }
    var sportRecords: [S5SportRecordModel]?
    var models: [StepRecordModel]? {
        didSet {
            self.setWeakData()
        }
    }
    
    var monthModels: [StepRecordModel]? {
        didSet {
            self.setMonthData()
        }
    }
    
    var yearModels: [[StepRecordModel]]? {
        didSet {
            self.setYearData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.createChart()
        self.addTapGesture()
    }

    // MARK: - Setup
    private func createChart() {
        [self.weakStepBarChartView, self.monthStepBarChartView, self.yearStepBarChartView].forEach { self.chartContentView.addSubview($0) }
        DispatchQueue.main.async {
            self.weakStepBarChartView.anchor(top: self.chartContentView.topAnchor,
                                      left: self.chartContentView.leftAnchor,
                                      bottom: self.chartContentView.bottomAnchor,
                                      right: self.chartContentView.rightAnchor,
                                      paddingTop: 0,
                                      paddingLeft: 0,
                                      paddingBottom: 0,
                                      paddingRight: 0)
            self.setUpChartsData([], timeType: .week)

            self.monthStepBarChartView.anchor(top: self.chartContentView.topAnchor,
                                      left: self.chartContentView.leftAnchor,
                                      bottom: self.chartContentView.bottomAnchor,
                                      right: self.chartContentView.rightAnchor,
                                      paddingTop: 0,
                                      paddingLeft: 0,
                                      paddingBottom: 0,
                                      paddingRight: 0)
            self.setUpChartsData([], timeType: .month)

            self.yearStepBarChartView.anchor(top: self.chartContentView.topAnchor,
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

    private func createGoalStepBarChartView(with timeType: TimeFilterType) -> BarChartView {
        // barChart setUp
        let barChart = BarChartView()
        barChart.delegate = self
        barChart.backgroundColor = .white
        barChart.doubleTapToZoomEnabled = false
        barChart.isUserInteractionEnabled = false
        barChart.setScaleEnabled(false)
        barChart.legend.enabled = false
        barChart.xAxis.enabled = true
        barChart.leftAxis.enabled = false
        barChart.rightAxis.enabled = false
        barChart.leftAxis.axisMinimum = 0
        barChart.legend.textColor = .clear
        barChart.legend.verticalAlignment = .top
        barChart.clipsToBounds = false
        
        // xAxis setUp
        let xAxis = barChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = UIColor(hex: "737678")
        xAxis.axisLineColor = UIColor(hex: "D3DFE8")
        xAxis.gridColor = UIColor.clear
        xAxis.labelPosition = .bottom
        if timeType == .week {
            xAxis.setLabelCount(8, force: true)
            xAxis.valueFormatter = WMYValueFormatter(date: Date().chartStartOfWeek!, type: .week)
            xAxis.axisMinimum = Date().chartStartOfWeek!.timeIntervalSince1970 - 3600 * 24
            xAxis.axisMaximum = Date().chartEndOfWeek!.timeIntervalSince1970
            xAxis.granularity = 3600 * 24
            barChart.setVisibleXRange(minXRange: 8 * 24 * 3600, maxXRange: 8 * 24 * 3600)
        } else if timeType == .month {
            let numberOfTotal = Date().numberOfDaysInMonth
            xAxis.valueFormatter = WMYValueFormatter(date: Date().startOfMonth, type: .month)
            xAxis.axisMinimum = Date().startOfMonth.startOfDay.timeIntervalSince1970 - 3600 * 24
            xAxis.axisMaximum = Date().endOfMonth.startOfDay.timeIntervalSince1970
            xAxis.granularity = 3600 * 24
            xAxis.setLabelCount(8, force: true)
            barChart.setVisibleXRange(minXRange: (Double(numberOfTotal) + 1) * 24 * 3600, maxXRange: (Double(numberOfTotal) + 1) * 24 * 3600)
            
        } else {
            xAxis.valueFormatter = YearValueFormatter()
            xAxis.axisMinimum = 0
            xAxis.axisMaximum = 12
            xAxis.granularity = 1
            xAxis.setLabelCount(13, force: true)
            barChart.setVisibleXRange(minXRange: 13, maxXRange: 13)
        }
        xAxis.avoidFirstLastClippingEnabled = false
        return barChart
       }
}
// MARK: - HandleChartData
extension ExcerciseChartCLVCell {

    // handleWeakData
    private func setWeakData() {
        guard let data = self.models else { return }
        if !data.isEmpty {
            let date = data[0].dateTime.toDate(.ymd)!.startOfDay
            let startOfWeek = date.chartStartOfWeek!.toString(.dayMonth)
            let endOfWeek = date.chartEndOfWeek!.toString(.dayMonth)
            self.dateLabel.text = startOfWeek + " - " + endOfWeek
            
            let totalStep = data.map { $0.totalStep }.reduce(0, +).stringValue
            let totalDistance = (data.map { $0.totalDistance}.reduce(0, +) / 1000).toString()
            let avgStep = (data.map { $0.totalStep }.reduce(0, +) / data.count).stringValue
            let avgKcal = (data.map { $0.totalCalories }.reduce(0, +) / Double(data.count)).toString()
            let excerciseDuration = (data.map { $0.duration }.reduce(0, +) / 60) / data.count
            var sportDuration = 0
            if let records = self.sportRecords?.filter({$0.dateTime.toDate(.ymdhm)?.isInSameWeek(as: date) == true }) {
                if !records.isEmpty {
                    let uniquePosts = self.checkDuplicate(in: records)
                    sportDuration = (uniquePosts.map { $0.duration }.reduce(0, +) / 60) / uniquePosts.count
                }
            }
            self.handleShowData(with: totalStep, and: totalDistance, and: avgStep, and: avgKcal)
            self.handleShowHourData(with: excerciseDuration, and: sportDuration)
  
            DispatchQueue.main.async {
                let xRange: Double = 8 * 24 * 3600
                self.weakStepBarChartView.xAxis.valueFormatter = WMYValueFormatter(date: date.chartStartOfWeek!, type: .week)
                
                self.weakStepBarChartView.xAxis.axisMinimum = date.chartStartOfWeek!.timeIntervalSince1970 - 3600 * 24
                self.weakStepBarChartView.xAxis.axisMaximum = date.chartEndOfWeek!.timeIntervalSince1970
                self.weakStepBarChartView.xAxis.granularity = 3600 * 24
                self.weakStepBarChartView.xAxis.setLabelCount(8, force: true)
                self.weakStepBarChartView.setVisibleXRange(minXRange: xRange, maxXRange: xRange)
                self.setUpChartsData(data, timeType: .week)
            }
        } else {
            let startOfWeek = Date().startOfWeek.toString(.dayMonth)
            let endOfWeek = Date().endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfWeek + " - " + endOfWeek
        }
    }
  
    // handleMonthData
    private func setMonthData() {
        guard let data = self.monthModels else { return }
        if !data.isEmpty {
            let dayOfMonth = data[0].dateTime.toDate(.ymd)!
            let startOfMonth = dayOfMonth.startOfMonth.toString(.dayMonth)
            let endOfMonth = dayOfMonth.endOfMonth.toString(.dayMonth)
            let numberOfTotal = dayOfMonth.numberOfDaysInMonth
            dateLabel.text = startOfMonth + " - " + endOfMonth
            
            let totalStep = data.map { $0.totalStep }.reduce(0, +).stringValue
            let totalDistance = (data.map { $0.totalDistance}.reduce(0, +) / 1000).toString()
            let avgStep = (data.map { $0.totalStep }.reduce(0, +) / data.count).stringValue
            let avgKcal = (data.map { $0.totalCalories }.reduce(0, +) / Double(data.count)).toString()
            let excerciseDuration = (data.map { $0.duration }.reduce(0, +) / 60) / data.count
            var sportDuration = 0
            if let records = self.sportRecords?.filter({$0.dateTime.toDate(.ymdhm)?.isInSameMonth(as: dayOfMonth) == true }) {
                if !records.isEmpty {
                    let uniquePosts = self.checkDuplicate(in: records)
                    sportDuration = (uniquePosts.map { $0.duration }.reduce(0, +) / 60) / uniquePosts.count
                }
            }
            
            self.handleShowData(with: totalStep, and: totalDistance, and: avgStep, and: avgKcal)
            self.handleShowHourData(with: excerciseDuration, and: sportDuration)

            DispatchQueue.main.async {
                let xRange: Double = (Double(numberOfTotal) + 1) * 24 * 3600
                self.monthStepBarChartView.xAxis.valueFormatter = WMYValueFormatter(date: dayOfMonth, type: .month)
                self.monthStepBarChartView.xAxis.axisMinimum = dayOfMonth.startOfMonth.startOfDay.timeIntervalSince1970 - 3600 * 24
                self.monthStepBarChartView.xAxis.axisMaximum = dayOfMonth.endOfMonth.startOfDay.timeIntervalSince1970
                self.monthStepBarChartView.xAxis.granularity = 3600 * 24
                self.monthStepBarChartView.xAxis.setLabelCount(8, force: true)
                self.monthStepBarChartView.setVisibleXRange(minXRange: xRange, maxXRange: xRange)
                self.setUpChartsData(data, timeType: .month)
            }
        } else {
            let startOfMonth = Date().startOfWeek.toString(.dayMonth)
            let endOfMonth = Date().endOfWeek.toString(.dayMonth)
            dateLabel.text = startOfMonth + " - " + endOfMonth
        }
    }
    
    // handleYearData
    private func setYearData() {
        guard let data = self.yearModels else { return }
        if !data.isEmpty {
            let date = data[0][0].dateTime.toDate(.ymd)!
            let startOfYear = data[0][0].dateTime.toDate(.ymd)!.startOfYear.toString(.dayMonth)
            let endOfYear = data[0][0].dateTime.toDate(.ymd)!.endOfYear.toString(.dayMonth)
            dateLabel.text = startOfYear + " - " + endOfYear

            let totalStep = data[0].map { $0.totalStep }.reduce(0, +).stringValue
            let totalDistance = (data[0].map { $0.totalDistance}.reduce(0, +) / 1000).toString()
            let avgStep = (data[0].map { $0.totalStep }.reduce(0, +) / data[0].count).stringValue
            let avgKcal = (data[0].map { $0.totalCalories }.reduce(0, +) / Double(data[0].count)).toString()
            let excerciseDuration = (data[0].map { $0.duration }.reduce(0, +) / 60) / data[0].count
            var sportDuration = 0
            if let records = self.sportRecords?.filter({$0.dateTime.toDate(.ymdhm)?.isInSameYear(as: date) == true }) {
                if !records.isEmpty {
                    let uniquePosts = self.checkDuplicate(in: records)
                    sportDuration = (uniquePosts.map { $0.duration }.reduce(0, +) / 60) / uniquePosts.count
                }
            }

            self.handleShowData(with: totalStep, and: totalDistance, and: avgStep, and: avgKcal)
            self.handleShowHourData(with: excerciseDuration, and: sportDuration)

            DispatchQueue.main.async {
                self.yearStepBarChartView.xAxis.valueFormatter = YearValueFormatter()
                self.yearStepBarChartView.xAxis.axisMinimum = 0
                self.yearStepBarChartView.xAxis.axisMaximum = 12
                self.yearStepBarChartView.xAxis.granularity = 1
                self.yearStepBarChartView.xAxis.setLabelCount(13, force: true)
                self.yearStepBarChartView.setVisibleXRange(minXRange: 13, maxXRange: 13)
                self.setUpYearChartsData(data: data)
            }
        } else {
            let startOfYear = Date().startOfYear.toString(.dayMonth)
            let endOfYear = Date().endOfYear.toString(.dayMonth)
            dateLabel.text = startOfYear + " - " + endOfYear
        }
    }
}
// MARK: - Actions
extension ExcerciseChartCLVCell {
    @objc private func handleNext() {
        self.delegate?.onSelectNext(self)
    }
    
    @objc private func handlePrevious() {
        self.delegate?.onSelectPrevious(self)
    }
}

// MARK: - Helpers
extension ExcerciseChartCLVCell {
    
    /// check duplicate in Records
    /// - Parameter records: [S5SportRecordModel]]
    /// - Returns: [S5SportRecordModel]]
    private func checkDuplicate(in records: [S5SportRecordModel]) -> [S5SportRecordModel] {
        var uniquePosts = [S5SportRecordModel]()
        for post in records {
            if !uniquePosts.contains(where: {$0.dateTime == post.dateTime }) {
                uniquePosts.append(post)
            }
        }
        print(uniquePosts.count)
        return uniquePosts
    }

    private func addTapGesture() {
        self.icNextImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleNext)))
        self.icPreviousImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handlePrevious)))
    }

    private func getNSMutableAttributedString(for value: String, description: String) -> NSMutableAttributedString? {
    
            let attributeString = NSMutableAttributedString(string: description, attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!])
            attributeString.append(NSAttributedString(string: value, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.title()!]))
            return attributeString
    
    }
    
    /// ShowDescripData
    /// - Parameters:
    ///   - totalStep: total of Step in record
    ///   - totalDistance: total of Distance in record
    ///   - avgStep: avg of Step
    ///   - avgKcal: avg of Kcal
    private func handleShowData(with totalStep: String, and totalDistance: String, and avgStep: String, and avgKcal: String) {

        self.totalStepLabel.attributedText = getNSMutableAttributedString(for: " " + totalStep, description: R.string.localizable.sm_excercise_total_step())

        self.totalDistance.attributedText = getNSMutableAttributedString(for: " " + totalDistance + " km", description: R.string.localizable.sm_excercise_total_distance())

        self.avgStepLabel.attributedText = getNSMutableAttributedString(for: " " + avgStep, description: R.string.localizable.sm_excercise_average_step())

        self.avgKcalLabel.attributedText = getNSMutableAttributedString(for: " " + avgKcal, description: R.string.localizable.sm_excercise_average_kcal())
    }
    
    /// showHourData
    /// - Parameters:
    ///   - excerciseDuration: total duration of excercise
    ///   - sportDuration: total duration of sport
    private func handleShowHourData(with excerciseDuration: Int, and sportDuration: Int) {

        self.practiceTimeLabel.attributedText = getNSMutableAttributedString(for: "\n" + sportDuration.hourAndMinuteStringValue, description: R.string.localizable.sm_practice_avg_day())

        self.excerciseTimeLabel.attributedText = getNSMutableAttributedString(for: "\n" + excerciseDuration.hourAndMinuteStringValue, description: R.string.localizable.sm_excercise_avg_day())
    }
}

// MARK: - ChartViewDelegate
extension ExcerciseChartCLVCell: ChartViewDelegate {
    // handle Data for BarChart
    private func setUpChartsData(_ steps: [StepRecordModel], timeType: TimeFilterType) {
        if steps.isEmpty {
            if timeType == .week {
                self.weakStepBarChartView.data = setUpStepBarChartData(with: [], and: 3600 * 24 / 1.5)
            } else {
                self.monthStepBarChartView.data = setUpStepBarChartData(with: [], and: 3600 * 24 / 1.5)
            }
            
        } else {
            var stepDataValue: [BarChartDataEntry] = []
            for data in steps {
                let max = data.goal
                var goal: Double = Double(max) - Double(data.totalStep)
                if goal < 0 {
                    goal = 0
                }
                let chartData = BarChartDataEntry(x: data.timestamp, yValues: [Double(data.totalStep), goal])
                stepDataValue.append(chartData)
            }
            if timeType == .week {
                self.weakStepBarChartView.data = setUpStepBarChartData(with: stepDataValue, and: 3600 * 24 / 1.5)
            } else {
                self.monthStepBarChartView.data = setUpStepBarChartData(with: stepDataValue, and: 3600 * 24 / 1.5)
            }
        }
    }
 
    private func setUpYearChartsData(data: [[StepRecordModel]]) {
        if !data.isEmpty {
            var dataCharts: [BarChartDataEntry] = []
            for i in 0 ..< data.count {
                let max: Double = Double(data[i].map { $0.goal }.reduce(0, +))
                var goal: Double = max - Double(data[i].map { $0.totalStep }.reduce(0, +))
                if goal < 0 {
                    goal = 0
                }
                let chartData = BarChartDataEntry(x: Double(data[i][0].timestamp.toDate().month), yValues: [Double(data[i].map { $0.totalStep }.reduce(0, +)), goal])
                dataCharts.append(chartData)
            }
            self.yearStepBarChartView.data = setUpStepBarChartData(with: dataCharts, and: 0.5)
        } else {
            self.yearStepBarChartView.data = setUpStepBarChartData(with: [], and: 0.5)
        }
    }
    
    private func setUpStepBarChartData(with dataEntry: [BarChartDataEntry], and barWidth: Double) -> BarChartData {
        var set: BarChartDataSet
        set = BarChartDataSet(entries: dataEntry, label: "")
        let dataSet = BarChartData(dataSet: set)
        set.colors = [UIColor(hex: "4B7E7F"), UIColor(hex: "00C2C5")]
        dataSet.barWidth = barWidth
        dataSet.isHighlightEnabled = true
        dataSet.setDrawValues(false)
        self.weakStepBarChartView.animate(yAxisDuration: 1)
        return dataSet
    }
}
