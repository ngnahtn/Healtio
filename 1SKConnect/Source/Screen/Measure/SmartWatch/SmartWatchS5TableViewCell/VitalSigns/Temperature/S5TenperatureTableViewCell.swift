//
//  S5TenperatureTableViewCell.swift
//  1SKConnect
//
//  Created by TrungDN on 09/12/2021.
//

import UIKit
import Charts

class S5TenperatureTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var chartImageView: UIImageView!
    @IBOutlet weak var weakChartStackView: UIStackView!
    
    weak var delegate: ShowWeakDetailDelegate?
    
    var model: S5TemperatureRecordModel? {
        didSet {
            self.setData()
        }
    }
    
    let lineChartHeight: CGFloat = 150
    private lazy var lineChartView = self.createLineChartView(with: .temperature)
    var shadowLayer: CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        super.awakeFromNib()
        self.selectionStyle = .none
        self.dateLabel.text = Date().toString(.hmdmy)
        self.createShadow()
        self.createChart()
        self.weakChartStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showWeekDetail(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

// MARK: - Selectors
extension S5TenperatureTableViewCell {
    @objc private func showWeekDetail(_ sender: UITapGestureRecognizer) {
        self.delegate?.onShowWeekData(self)
    }
}

// MARK: - Helpers
extension S5TenperatureTableViewCell {
    private func setData() {
        guard let model = self.model else {
            self.setUpChartsData(data: [])
            return
        }
        let currentValue = Double(model.tempDetail.last?.wristTemp ?? 0)
        if currentValue != 0 {
            self.temperatureLabel.text = R.string.localizable.smart_watch_s5_temperature_input(currentValue.toString())
        }
        DispatchQueue.main.async {
            self.setUpChartsData(data: model.vitalSigns)
        }
    }
    
    private func createShadow() {
        DispatchQueue.main.async {
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
        }
    }
    
    private func createChart() {
        self.chartContentView.addSubview(self.lineChartView)
        DispatchQueue.main.async {
            self.lineChartView.anchor(top: self.chartContentView.topAnchor,
                                      left: self.chartContentView.leftAnchor,
                                      bottom: self.chartContentView.bottomAnchor,
                                      right: self.chartContentView.rightAnchor,
                                      paddingTop: 48,
                                      paddingLeft: 16,
                                      paddingBottom: 20,
                                      paddingRight: 16)
            self.setUpChartsData(data: [])
        }
    }
    
    private func createLineChartView(with lineChartType: CellType) -> LineChartView {
        let lineChart = LineChartView()
        lineChart.isUserInteractionEnabled = false
        lineChart.delegate = self
        lineChart.backgroundColor = .white
        lineChart.isUserInteractionEnabled = false
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
        xAxis.setLabelCount(7, force: true)
        xAxis.valueFormatter = TimeValueFormatter(date: Date())
        xAxis.axisMinimum = Date().startOfDay.timeIntervalSince1970
        xAxis.axisMaximum = Date().endOfDay.timeIntervalSince1970
        xAxis.labelPosition = .bottom
        xAxis.granularity = 3600 * 4
        lineChart.setVisibleXRange(minXRange: 24 * 3600, maxXRange: 24 * 3600)
        xAxis.avoidFirstLastClippingEnabled = false
        
        if lineChartType == .heartRate || lineChartType == .spO2 {
            yAxis.axisMinimum = -50
            yAxis.axisMaximum = 150
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
extension S5TenperatureTableViewCell: ChartViewDelegate {
    private func setUpChartsData(data: [VitalSign]) {
        if data.isEmpty {
            self.lineChartView.data = setupLineChartData(with: [], for: .temperature)
            self.lineChartView.setVisibleXRangeMaximum(7)
        } else {
            var chartDataValues: [ChartDataEntry] = []
            for data in data {
                let chartData = ChartDataEntry(x: data.timestamp, y: data.value)
                chartDataValues.append(chartData)
            }
            self.lineChartView.data = setupLineChartData(with: chartDataValues, for: .temperature)
        }
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height >= 2436 {
                self.lineChartView.animate(xAxisDuration: 0.5)
            }
        }
        self.lineChartView.setVisibleXRangeMaximum(7)
    }
    
    private func setupLineChartData(with dataEntry: [ChartDataEntry], for lineChartType: CellType) -> LineChartData {
        var set: LineChartDataSet
        switch lineChartType {
        case .spO2:
            set = LineChartDataSet(entries: dataEntry, label: "")
            set.colors = [UIColor(hex: "71D875")]
            set.fillColor = UIColor(hex: "71D875", alpha: 0.3)
            set.lineWidth = 3
            set.drawCirclesEnabled = false
            set.drawFilledEnabled = true
        case .heartRate:
            set = LineChartDataSet(entries: dataEntry, label: "")
            set.colors = [UIColor(hex: "FFA422")]
            set.fillColor = UIColor(hex: "FFA422", alpha: 0.3)
            set.lineWidth = 3
            set.drawCirclesEnabled = false
            set.drawFilledEnabled = true
        case .temperature:
            set = LineChartDataSet(entries: dataEntry, label: "")
            set.colors = [UIColor(hex: "FF2A44")]
            set.lineWidth = 3
            set.drawFilledEnabled = true
            set.fillColor = UIColor(hex: "FF2A44", alpha: 0.3)
            set.circleColors = [UIColor(hex: "FF2A44")]
            set.circleRadius = 2
            
            if dataEntry.count == 1 {
                set.drawCirclesEnabled = true
            } else {
                set.drawCirclesEnabled = false
            }
        default:
            return LineChartData()
        }
        
        set.mode = (set.mode == .cubicBezier) ? .linear : .horizontalBezier
        let dataSet = LineChartData(dataSet: set)
        dataSet.setDrawValues(false)
        return dataSet
    }
}
