//
//  BloodPressureTableViewCell.swift
//  1SKConnect
//
//  Created by TrungDN on 09/12/2021.
//

import UIKit
import Charts
import SwiftUI

class S5BloodPressureTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bloodPressureLabel: UILabel!
    @IBOutlet weak var chartImageView: UIImageView!
    @IBOutlet weak var weakChartStackView: UIStackView!
    
    weak var delegate: ShowWeakDetailDelegate?
    
    let lineChartHeight: CGFloat = 150
    private lazy var lineChartView = self.createLineChartView(with: .bloodPressure)
    var shadowLayer: CAShapeLayer?
    
    var model: BloodPressureRecordModel? {
        didSet {
            self.setData()
        }
    }

    override func awakeFromNib() {
        self.selectionStyle = .none
        self.dateLabel.text = Date().toString(.hmdmy)
        super.awakeFromNib()
        self.createShadow()
        self.createChart()
        self.weakChartStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showWeekDetail(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - Selectors
extension S5BloodPressureTableViewCell {
    @objc private func showWeekDetail(_ sender: UITapGestureRecognizer) {
        self.delegate?.onShowWeekData(self)
    }
}

extension S5BloodPressureTableViewCell {
    private func setData() {
        guard let model = self.model else {
            self.setUpChartsData(sys: [], dia: [])
            return
        }
        let currentValue  = "\(model.bloodPressureDetail.last?.sbp.stringValue ?? "--")/\(model.bloodPressureDetail.last?.dbp.stringValue ?? "--")"
        self.bloodPressureLabel.text = R.string.localizable.smart_watch_s5_blood_pressure_input(currentValue)
        DispatchQueue.main.async {
            self.setUpChartsData(sys: model.sysSigns, dia: model.diaSigns)
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
            self.setUpChartsData(sys: [], dia: [])
        }
    }
    
    private func createLineChartView(with lineChartType: CellType) -> LineChartView {
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
        xAxis.setLabelCount(7, force: true)
        xAxis.valueFormatter = TimeValueFormatter(date: Date())
        xAxis.axisMinimum = Date().startOfDay.timeIntervalSince1970
        xAxis.axisMaximum = Date().endOfDay.timeIntervalSince1970
        xAxis.labelPosition = .bottom
        xAxis.granularity = 3600 * 4
        lineChart.setVisibleXRange(minXRange: 24 * 3600, maxXRange: 24 * 3600)
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
}

// MARK: - ChartViewDelegate
extension S5BloodPressureTableViewCell: ChartViewDelegate {
    private func setUpChartsData(sys: [VitalSign], dia: [VitalSign]) {
        if sys.isEmpty {
            self.lineChartView.data = setupLineChartData(with: [], dataEntry2: [])
            self.lineChartView.setVisibleXRangeMaximum(7)
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
            self.lineChartView.data = setupLineChartData(with: diaDataValue, dataEntry2: sysDataValue)
        }
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height >= 2436 {
                self.lineChartView.animate(xAxisDuration: 0.5)
            }
        }
        self.lineChartView.setVisibleXRangeMaximum(7)
    }
    
    private func setupLineChartData(with dataEntry1: [ChartDataEntry], dataEntry2: [ChartDataEntry]) -> LineChartData {
        var set1: LineChartDataSet
        set1 = LineChartDataSet(entries: dataEntry1, label: "")
        set1.colors = [UIColor(hex: "FF2A44")]
        set1.lineWidth = 1.2
        set1.drawFilledEnabled = false
        set1.circleColors = [UIColor(hex: "FF2A44")]
        set1.circleRadius = 2
        
        if dataEntry1.count == 1 {
            set1.drawCirclesEnabled = true
        } else {
            set1.drawCirclesEnabled = false
        }
        set1.mode = (set1.mode == .cubicBezier) ? .linear : .horizontalBezier
        
        var set2: LineChartDataSet
        set2 = LineChartDataSet(entries: dataEntry2, label: "")
        set2.colors = [UIColor(hex: "#307EF4")]
        set2.lineWidth = 1.2
        set2.drawFilledEnabled = false
        set2.circleColors = [UIColor(hex: "#307EF4")]
        set2.circleRadius = 2
        if dataEntry2.count == 1 {
            set2.drawCirclesEnabled = true
        } else {
            set2.drawCirclesEnabled = false
        }
        
        set2.mode = (set2.mode == .cubicBezier) ? .linear : .horizontalBezier
        let dataSet = LineChartData()
        dataSet.addDataSet(set1)
        dataSet.addDataSet(set2)
        dataSet.setDrawValues(false)
        return dataSet
    }
}
