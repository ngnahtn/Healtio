//
//  ExerciseDetailTableViewCell.swift
//  1SKConnect
//
//  Created by admin on 20/12/2021.
//

import UIKit
import Charts
import MBCircularProgressBar

protocol ExcerciseDetailTBVCellProtocol: AnyObject {
    func onChangeTimeTypePressed(_ type: TimeChangeActionType)
}

class ExerciseDetailTableViewCell: UITableViewCell {
    
    // UI properties
    @IBOutlet weak var exerciseView: UIView!
    @IBOutlet weak var barChartContentView: UIView!
    @IBOutlet weak var barChartShadownView: UIView!
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var excerciseContentView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var stepTimeLabel: UILabel!
    @IBOutlet weak var sportTimeLabel: UILabel!
    
    @IBOutlet weak var stepImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var nextImageView: UIImageView!
    
    private lazy var excerciseChartView: BarChartView = self.createBarChartView()
    
    // delegate
    weak var delegate: ExcerciseDetailTBVCellProtocol?

    // listDAO properties
    private let profileListDAO = GenericDAO<ProfileListModel>()
    private let heartRateListDAO = GenericDAO<S5HeartRateListRecordModel>()

    // shadow properties
    var shadowLayer: CAShapeLayer?
    var barChartShadowLayer: CAShapeLayer?

    // calculation properties
    var model: StepRecordModel? {
        didSet {
            guard let unwrappedData = model else { return }
            self.configData(unwrappedData)
        }
    }

    var isMax: Bool = true {
        didSet {
            self.backImageView.isHidden = isMax
        }
    }

    var isMin: Bool = true {
        didSet {
            self.nextImageView.isHidden = isMin
        }
    }
    
    var sportDuration: Int = 0 {
        didSet {
            self.sportTimeLabel.text = Double(sportDuration).toHourMinuteString()
        }
    }
    
    var sportNumber: Int = 0 {
        didSet {
            self.historyLabel.isHidden = (sportNumber == 0) ? true : false
            self.historyLabel.text = (sportNumber != 0) ? (R.string.localizable.sm_excercise_history() + " (\(sportNumber))") : ""
        }
    }
    
    private var percent: Double = 0 {
        didSet {
            if percent.isInfinite {
                percent = 0
            }
            var percentString = percent.toString()
            if percentString.prefix(1) == "." {
                percentString = "0" + percentString
            }
            self.percentageLabel.text = "\(percentString)%"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpView()
        self.drawBarChart()
        self.setUpBarChartData([])
    }
// MARK: - SetUpView
    func setUpView() {
        self.selectionStyle = .none
        self.addTapGesture()
        DispatchQueue.main.async {
            // handle excerciseView shawdow
            if self.shadowLayer == nil {
                let shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, cornerRadius: 4)
                self.shadowLayer = CAShapeLayer()
                self.shadowLayer?.shadowPath = shadowPath.cgPath
                self.shadowLayer?.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.11).cgColor
                self.shadowLayer?.shadowOpacity = 1
                self.shadowLayer?.shadowRadius = 5
                self.shadowLayer?.shadowOffset = CGSize(width: 0, height: 4)
                self.shadowView.layer.insertSublayer(self.shadowLayer!, at: 0)
            }

            // handle barChartShadow shawdow
            if self.barChartShadowLayer == nil {
                let shadowPath = UIBezierPath(roundedRect: self.barChartShadownView.bounds, cornerRadius: 4)
                self.barChartShadowLayer = CAShapeLayer()
                self.barChartShadowLayer?.shadowPath = shadowPath.cgPath
                self.barChartShadowLayer?.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.11).cgColor
                self.barChartShadowLayer?.shadowOpacity = 1
                self.barChartShadowLayer?.shadowRadius = 5
                self.barChartShadowLayer?.shadowOffset = CGSize(width: 0, height: 4)
                self.barChartShadownView.layer.insertSublayer(self.barChartShadowLayer!, at: 0)
            }
        }
    }

    private func createBarChartView() -> BarChartView {
        let barChart = BarChartView()
        // handle barchart properties
        barChart.delegate = self
        barChart.backgroundColor = .white
        barChart.doubleTapToZoomEnabled = false
        barChart.isUserInteractionEnabled = true
        barChart.setScaleEnabled(false)
        barChart.legend.enabled = false
        barChart.clipsToBounds = false
        barChart.xAxis.enabled = true
        barChart.legend.textColor = .white
        barChart.legend.verticalAlignment = .top
        
        // yAxis properties
        let yAxis = barChart.leftAxis
        yAxis.labelTextColor = UIColor(hex: "737678")
        yAxis.axisLineColor = UIColor(hex: "D3DFE8")
        yAxis.gridColor = UIColor(hex: "D3DFE8")
        yAxis.axisMinimum = 0

        let yRightAxis = barChart.rightAxis
        yRightAxis.labelTextColor = .clear
        yRightAxis.axisLineColor = .clear
        yRightAxis.gridColor = .clear

        // xAxis properties
        let xAxis = barChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = UIColor(hex: "737678")
        xAxis.axisLineColor = UIColor(hex: "D3DFE8")
        xAxis.gridColor = UIColor(hex: "D3DFE8")
        xAxis.setLabelCount(7, force: true)
        xAxis.valueFormatter = TimeValueFormatter(date: Date())
        xAxis.axisMinimum = Date().startOfDay.timeIntervalSince1970
        xAxis.axisMaximum = Date().endOfDay.timeIntervalSince1970
        xAxis.labelPosition = .bottom
        xAxis.granularity = 3600 * 4
        barChart.setVisibleXRange(minXRange: 24 * 3600, maxXRange: 24 * 3600)
        xAxis.avoidFirstLastClippingEnabled = false

        return barChart
    }
    
    private func drawBarChart() {
        self.barChartContentView.addSubview(self.excerciseChartView)
        DispatchQueue.main.async {
            self.excerciseChartView.anchor(top: self.barChartContentView.topAnchor,
                                           left: self.barChartContentView.leftAnchor,
                                           bottom: self.barChartContentView.bottomAnchor,
                                           right: self.barChartContentView.rightAnchor,
                                           paddingTop: 8,
                                           paddingLeft: 8,
                                           paddingBottom: 8,
                                           paddingRight: 8
                                           )
        }
    }
    // MARK: - Action
    private func addTapGesture() {

        let timeTap1 = UITapGestureRecognizer(target: self, action: #selector(self.handleNextImageViewDidTap))
        self.nextImageView.addGestureRecognizer(timeTap1)

        let timeTap2 = UITapGestureRecognizer(target: self, action: #selector(self.handlePreviousImageViewDidTap))
        self.backImageView.addGestureRecognizer(timeTap2)
        
    }

    @objc func handleNextImageViewDidTap() {
        delegate?.onChangeTimeTypePressed(.next)
    }
 
    @objc func handlePreviousImageViewDidTap() {
        delegate?.onChangeTimeTypePressed(.previous)
    }
}
// MARK: - Helpers
extension ExerciseDetailTableViewCell {

    private func configData(_ data: StepRecordModel) {
        let step = data.totalStep > data.goal ? data.goal : data.totalStep
        guard let profile = self.profileListDAO.getFirstObject()?.currentProfile else { return }
        if data.duration != 0 {
            self.stepTimeLabel.text = Double(data.duration).toHourMinuteString()
        }
        
        self.progressView.value = CGFloat(step)
        self.progressView.maxValue = CGFloat(data.goal)
        self.progressView.layoutSubviews()
        
        let date = data.dateTime.toDate(.ymd) ?? Date()
        let dateStr = date.toString(.dayOfWeek)
        self.dateLabel.text = dateStr
        self.stepLabel.text = data.totalStep.formattedWithSeparator
        self.percent = (Double(data.totalStep) / Double(data.goal) * 100).roundTo(0)
      
        self.kcalLabel.text = data.totalCalories.roundTo(0).toString() + " kcal"
        self.distanceLabel.text = (data.totalDistance / 1000).toString() + " km"

        if let hrList = heartRateListDAO.getObject(with: profile.id) {
            if let record = hrList.hrList.array.first(where: { $0.dateTime.toDate(.ymd)?.isInSameDay(as: date) == true}) {
                self.heartRateLabel.text = (record.hrDetail.last?.heartRate.stringValue ?? "--") + " bpm"
            }
        }
        DispatchQueue.main.async {
            self.excerciseChartView.xAxis.valueFormatter = TimeValueFormatter(date: date)
            self.excerciseChartView.xAxis.axisMinimum = date.startOfDay.timeIntervalSince1970
            self.excerciseChartView.xAxis.axisMaximum = date.endOfDay.timeIntervalSince1970
            self.setUpBarChartData(data.stepDetail.array)
        }
    }
}
// MARK: - ChartViewDelegate
extension ExerciseDetailTableViewCell: ChartViewDelegate {
    private func setUpBarChartData(_ detail: [StepDetailModel]) {
        var chartDataValues: [BarChartDataEntry] = []
        for item in detail {
            let chartData = BarChartDataEntry(x: item.timestamp, y: Double(item.step))
            chartDataValues.append(chartData)
        }
            self.excerciseChartView.data = setUpBarChartData(with: chartDataValues)
    }
    
    private func setUpBarChartData(with dataEntry: [BarChartDataEntry]) -> BarChartData {
        var set: BarChartDataSet
        set = BarChartDataSet(entries: dataEntry, label: "")
        set.colors = [UIColor(hex: "00C2C5")]
        let dataSet = BarChartData(dataSet: set)
        dataSet.barWidth = 300
        dataSet.isHighlightEnabled = true
        self.excerciseChartView.animate(yAxisDuration: 1)
        self.excerciseChartView.setVisibleXRangeMaximum(7)
        dataSet.setDrawValues(false)
        return dataSet
    }
}
