//
//  
//  SpO2DetailValueViewController.swift
//  1SKConnect
//
//  Created by TrungDN on 16/11/2021.
//
//

import UIKit
import Charts

class SpO2DetailValueViewController: BaseViewController {
    var presenter: SpO2DetailValuePresenterProtocol!
    @IBOutlet weak var timeMeasureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var spO2Label: UILabel!
    @IBOutlet weak var averageSpO2Label: UILabel!
    @IBOutlet weak var minSpO2Label: UILabel!

    @IBOutlet weak var averagePRLabel: UILabel!

    // Chart views
    let spO2MarkerView = SpO2MarkerView()
    let prMarkerView = SpO2MarkerView()
    @IBOutlet weak var lineChartContentView: UIView!
    private lazy var spO2LineChartView: LineChartView = self.createLineChartView(with: .spO2)
    private lazy var prLineChartView: LineChartView = self.createLineChartView(with: .pr)

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }

    // MARK: - Setup
    private func setupInit() {
        self.navigationItem.title = R.string.localizable.spO2_detail_value_title()

        // Add spO2 line chart
        self.lineChartContentView.addSubview(self.spO2LineChartView)
        DispatchQueue.main.async {
            let lineChartHeight = self.lineChartContentView.frame.height / 2
            self.spO2LineChartView.anchor(top: self.lineChartContentView.topAnchor, left: self.lineChartContentView.leftAnchor, right: self.lineChartContentView.rightAnchor, height: lineChartHeight)
        }

        // Add pr line chart
        self.lineChartContentView.addSubview(self.prLineChartView)
        DispatchQueue.main.async {
            let lineChartHeight = self.lineChartContentView.frame.height / 2
            self.prLineChartView.anchor(top: self.spO2LineChartView.bottomAnchor, left: self.lineChartContentView.leftAnchor, right: self.lineChartContentView.rightAnchor, height: lineChartHeight)
        }
        self.setupMarker()
    }

    func setupMarker() {
        self.spO2MarkerView.chartView = self.spO2LineChartView
        self.spO2LineChartView.marker = self.spO2MarkerView

        self.prMarkerView.chartView = self.prLineChartView
        self.prLineChartView.marker = self.prMarkerView
    }

    // MARK: - Action

}

// MARK: - SpO2DetailValueViewProtocol
extension SpO2DetailValueViewController: SpO2DetailValueViewProtocol {
    func setupData(with waveform: WaveformListModel) {
        self.timeMeasureLabel.text = waveform.timeMeasure
        self.dateLabel.text = waveform.date

        self.spO2Label.attributedText = waveform.totalDangerTime
        self.minSpO2Label.attributedText = waveform.minSpO2AttributedString
        self.averageSpO2Label.attributedText = waveform.averageSpO2AttributedString
        self.averagePRLabel.attributedText = waveform.averagePrAttributedString

        // set spo2 chart datas
        self.spO2LineChartView.data = self.setupLineChartData(with: waveform, for: .spO2)

        // set pr chart datas
        self.prLineChartView.data = self.setupLineChartData(with: waveform, for: .pr)
    }
}

// MARK: - Helpers
extension SpO2DetailValueViewController {
    /// Create line chart
    /// - Parameter lineChartType: chart value type
    /// - Returns: LineChartView
    private func createLineChartView(with lineChartType: ChartValueType) -> LineChartView {
        let lineChart = LineChartView()
        lineChart.delegate = self
        lineChart.rightAxis.enabled = false
        lineChart.backgroundColor = UIColor(red: 43/255, green: 168/255, blue: 244/255, alpha: 1)
        let yAxis = lineChart.leftAxis
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.gridColor = .white

        switch lineChartType {
        case .spO2:
            yAxis.axisMinimum = 70
            yAxis.axisMaximum = 100
        case .pr:
            yAxis.axisMinimum = 30
            yAxis.axisMaximum = 150
        }

        yAxis.valueFormatter = LineChartLeftAxisFormatter(type: lineChartType)
        lineChart.clipsToBounds = false
        lineChart.xAxis.enabled = false
        lineChart.animate(xAxisDuration: 1)
        lineChart.legend.textColor = .white
        lineChart.legend.verticalAlignment = .top
        return lineChart
    }

    /// Setup line chart data
    /// - Parameters:
    ///   - waveform: WaveformListModel
    ///   - lineChartType: ChartValueType
    /// - Returns: LineChartData
    private func setupLineChartData(with waveform: WaveformListModel, for lineChartType: ChartValueType) -> LineChartData {
        var set: LineChartDataSet
        switch lineChartType {
        case .spO2:
            set = LineChartDataSet(entries: waveform.spO2ChartData, label: "SpO2(%)")
        case .pr:
            set = LineChartDataSet(entries: waveform.prChartData, label: "Pulse_Rate(/min)")
        }
        set.drawCirclesEnabled = false
        set.setColor(.green)
        set.highlightLineDashLengths = [2]
        set.highlightColor = .white

        let dataSet = LineChartData(dataSet: set)
        dataSet.setDrawValues(false)
        return dataSet
    }
}

// MARK: - ChartViewDelegate
extension SpO2DetailValueViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let dataSet = chartView.data?.dataSets[highlight.dataSetIndex] else { return }
              let entryIndex = dataSet.entryIndex(entry: entry)
        let waveform = self.presenter.waveform(at: entryIndex)
        if let waveform = waveform {
            self.prLineChartView.highlightValue(highlight)
            self.spO2MarkerView.valueLabel.text = "\(waveform.spO2Value.value!)%"
            self.spO2MarkerView.timeLabel.text = waveform.timeCreated.toDate().toString(.hms)

            self.spO2LineChartView.highlightValue(highlight)
            self.prMarkerView.valueLabel.text = "\(waveform.prValue.value!)/min"
            self.prMarkerView.timeLabel.text = waveform.timeCreated.toDate().toString(.hms)
        }
    }
}
