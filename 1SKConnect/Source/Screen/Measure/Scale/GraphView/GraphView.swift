//
//  GraphView.swift
//  1SKConnect
//
//  Created by tuyenvx on 09/04/2021.
//

import Foundation
import UIKit

protocol GraphViewDelegate: AnyObject {
    func graphDidUpdateVisibleRange(range: (Double, Double))
}

class GraphView: UIView {

    // MARK: - Properties
    private var times: [Double] = []
    private var horizontalPoint: [Double] = []
    private var verticalPoint: [[Double]] = []
    lazy var lineChartView = VXGraphView()
    private var deviceType: DeviceType = .scale

    private lazy var yAxisView = UIView()
    private var type: TimeFilterType = .day
    private lazy var scrollView: UIScrollView = createScrollView()
    private lazy var emptyLabel = self.createEmptyLabel()
    private var graphVisibleWidth: CGFloat = Constant.Screen.width - 53

    /// number off y value
    private var yLabelCount = 4
    private var measurementType = MeasurementType.mass
    private var measurementData = MeasurementData.weightPoints

    private let yAxisWidth: CGFloat = 28
    private let yAxisHeight: CGFloat = 106 // 100 + yAxisInsetBottom
    private let yAxisOfsetFromTop: CGFloat = 5
    private let yAxisValueStartValueOffset: CGFloat = 22.75 // Offset from startvalue and origin
    private let yAxisInsetBottom: CGFloat = 6
    private var valueDetailsView: GraphValueDetailsView!
    private var startTime: Date!
    private var startPoint: CGPoint!
    private var isPangestureSwipeLeft: Bool?
    private var startRange: (Double, Double)!
    private let scrollViewLeadingInset: CGFloat = 10
    private let scrollViewTraillingInset: CGFloat = 0

    weak var delegate: GraphViewDelegate?

    var startValue: Double {
        switch self.deviceType {
        case .scale:
            guard let min = horizontalPoint.filter({ !$0.isNaN }).min(), let max = horizontalPoint.filter({ !$0.isNaN }).max() else {
                return 30
            }
            if max == min {
                return (min - 10) <= 0 ? min : min - 10
            }
            return (min - 5) <= 0 ? min : min - 5
        case .spO2:
            return 70
        case .biolightBloodPressure:
            return 50
        default:
            return 0
        }
    }

    var endValue: Double {
        switch self.deviceType {
        case .scale:
            guard let min = horizontalPoint.filter({ !$0.isNaN }).min(), let max = horizontalPoint.filter({ !$0.isNaN }).max() else {
                return 60
            }
            if max == min {
                return max + 10
            }
            return max + 5
        case .spO2:
            return 100
        case .biolightBloodPressure:
            return 200
        default:
            return 0
        }
    }

    var isEmpty: Bool {
        return self.times.isEmpty
    }

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaults()
    }

    // MARK: - Setup
    private func setupDefaults() {
        addSubview(scrollView)
        addSubview(yAxisView)
        let rightAsixView = UIView()
        rightAsixView.backgroundColor = .white
        addSubview(rightAsixView)
        yAxisView.backgroundColor = .white
        yAxisView.snp.makeConstraints { make in
            make.height.equalTo(yAxisHeight)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(yAxisWidth)
            make.bottom.equalTo(scrollView.snp.bottom).inset(25 - yAxisInsetBottom)
        }

        rightAsixView.snp.makeConstraints { make in
            make.height.equalTo(yAxisHeight)
            make.width.equalTo(16)
            make.trailing.equalToSuperview()
            make.bottom.equalTo(scrollView.snp.bottom).inset(25 - yAxisInsetBottom)
        }

        scrollView.snp.makeConstraints { make in
            make.height.equalTo(121)
            make.leading.equalTo(yAxisView.snp.trailing).inset(scrollViewLeadingInset)
            make.trailing.equalToSuperview().inset(16 - scrollViewTraillingInset)
            make.bottom.equalToSuperview()
        }

        scrollView.addSubview(lineChartView)
        lineChartView.delegate = self
        lineChartView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        addEmptyTextLayer()
    }

    private func addEmptyTextLayer() {
        self.addSubview(self.emptyLabel)
        self.emptyLabel.center(inView: self, xConstant: 10, yConstant: -10)
    }

    private func createEmptyLabel() -> UILabel {
        let emptyTextLayer = UILabel()
        emptyTextLayer.font = R.font.robotoRegular(size: 14)
        emptyTextLayer.textAlignment = .center
        emptyTextLayer.text = R.string.localizable.doNotHaveData()
        emptyTextLayer.textColor = R.color.subTitle()!
        return emptyTextLayer
    }

    private func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        scrollView.isScrollEnabled = false
        scrollView.panGestureRecognizer.addTarget(self, action: #selector(scrollViewPanGestureHandle(_:)))
        scrollView.contentInset = UIEdgeInsets(top: 0, left: scrollViewLeadingInset, bottom: 0, right: scrollViewTraillingInset)
        scrollView.decelerationRate = .normal
        return scrollView
    }

    private func createYAxis() {
        yAxisView.layer.addSublayer(createYAxisLineLayer())
        let weightMinUnit = (endValue - startValue) / Double(yLabelCount - 1)
        let yAxisRange = 95 - yAxisValueStartValueOffset - yAxisOfsetFromTop
        let yAxisMinValue = yAxisRange.doubleValue / (yLabelCount).doubleValue
        for index in 0 ... yLabelCount {
            let value = startValue + weightMinUnit * index.doubleValue
            var stringValue = ""

            if index == self.yLabelCount {
                stringValue = self.measurementType.description
            } else {
                stringValue = value.toString()
            }
            let textLayer = createYLabelLayer(value: stringValue,
                                              point: CGPoint(x: -3, y: yAxisHeight.doubleValue - index.doubleValue * yAxisMinValue - 7.5 - yAxisInsetBottom.doubleValue - yAxisValueStartValueOffset.doubleValue))
            textLayer.alignmentMode = index == self.yLabelCount ? .right : .left
            yAxisView.layer.addSublayer(textLayer)
        }
    }

    private func configLineChartView() {
        switch self.deviceType {
        case .scale:
            self.lineChartView.setPoints(self.horizontalPoint, measurementType: self.measurementType, measurementData: self.measurementData)
        case .spO2:
            self.lineChartView.setPoints(self.verticalPoint)
        case .biolightBloodPressure:
            self.lineChartView.setPoints(self.verticalPoint, deviceType: .biolightBloodPressure)
        default:
            return
        }
        self.lineChartView.setTimes(times)
        self.lineChartView.setType(type)
        self.lineChartView.notificationDataChanged()
    }

    // MARK: - Helper
    private func createYAxisLineLayer() -> CAShapeLayer {
        let yAxisLineLayer = CAShapeLayer()
        let bezierpath = UIBezierPath()
        bezierpath.move(to: CGPoint(x: yAxisWidth, y: yAxisHeight - yAxisInsetBottom))
        bezierpath.addLine(to: CGPoint(x: yAxisWidth, y: yAxisHeight - 95 - yAxisInsetBottom - yAxisOfsetFromTop))
        yAxisLineLayer.path = bezierpath.cgPath
        yAxisLineLayer.strokeColor = UIColor(hex: "D3DFE8").cgColor
        return yAxisLineLayer
    }

    private func createYLabelLayer(value: String, point: CGPoint) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(origin: point, size: CGSize(width: 30, height: 15))
        textLayer.font = R.font.robotoRegular(size: 12)
        textLayer.fontSize = 12
        textLayer.alignmentMode = .left
        textLayer.string = value != "NaN" ? value : ""
        textLayer.foregroundColor = R.color.subTitle()!.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }

    /// Add detail value for horizontal points
    /// - Parameters:
    ///   - point: touched point
    ///   - points: point value
    ///   - index: index selected
    ///   - dataType: `MeasurementType`
    private func addValueDetailsView(at point: CGPoint, points: [Double], index: Int, dataType: MeasurementType) {
        if self.valueDetailsView != nil {
            self.valueDetailsView.removeFromSuperview()
            self.valueDetailsView = nil
        }
        let title = L.average.localized

        var measurementType = ""
        if dataType == .mass {
            measurementType = "kg"
        } else {
            measurementType = "%"
        }

        let valueText = "\(points[index].toString()) \(measurementType)"
        let date = times[index].toDate()
        var timeString = ""
        switch type {
        case .day:
            timeString = "\(date.toString(.hour)) - \(date.nextHour.toString(.hour)), \(date.toString(.dmySlash))"
        case .week:
            timeString = "\(date.toString(.dmySlash))"
        case .month:
            timeString = "\(date.toString(.dmySlash))"
        case .year:
            timeString = "\(date.toString(.mySlash))"
        }
        valueDetailsView = GraphValueDetailsView(title: title, valueText: valueText, timeString: timeString)
        addSubview(valueDetailsView)
        let width = valueDetailsView.viewWidth
        var newPoint: CGPoint = point
        var positionX: CGFloat = width / 2
        if point.x < 16 + width / 2 {
            newPoint.x = 16
            positionX = point.x - newPoint.x
        } else if point.x + width / 2 > bounds.maxX - 16 {
            newPoint.x = bounds.maxX - width - 16
            positionX = point.x - newPoint.x
        } else {
            newPoint.x = point.x - width / 2
        }
        newPoint.y = point.y - 10
        valueDetailsView.addTritangle(at: positionX)
        valueDetailsView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(newPoint.x)
            make.bottom.equalTo(self.snp.top).offset(newPoint.y)
        }
    }

    /// Add value detail view
    /// - Parameters:
    ///   - point: touched point
    ///   - points: point values
    ///   - index: index
    private func addValueDetailsView(at point: CGPoint, points: [Double], index: Int) {
        if self.valueDetailsView != nil {
            self.valueDetailsView.removeFromSuperview()
            self.valueDetailsView = nil
        }
        var valueText = ""
        if points.count == 2 {
            valueText = "\(points[1].toString()) - \(points[0].toString())%"
        }
        self.valueDetailsView = GraphValueDetailsView(title: "", valueText: valueText, timeString: "")
        self.addSubview(valueDetailsView)
        let width = valueDetailsView.viewWidth
        var newPoint: CGPoint = point
        var positionX: CGFloat = width / 2
        if point.x < 16 + width / 2 {
            newPoint.x = 16
            positionX = point.x - newPoint.x
        } else if point.x + width / 2 > bounds.maxX - 16 {
            newPoint.x = bounds.maxX - width - 16
            positionX = point.x - newPoint.x
        } else {
            newPoint.x = point.x - width / 2
        }
        newPoint.y = point.y - 10
        valueDetailsView.addTritangle(at: positionX)
        valueDetailsView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(newPoint.x)
            make.bottom.equalTo(self.snp.top).offset(newPoint.y)
        }
    }

    /// Add detail value for horizontal points
    /// - Parameters:
    ///   - point: touched point
    ///   - points: point value
    ///   - index: index selected
    private func addBloodPressureValueDetailsView(at point: CGPoint, points: [Double], index: Int) {
        if self.valueDetailsView != nil {
            self.valueDetailsView.removeFromSuperview()
            self.valueDetailsView = nil
        }
        var title = ""
        var valueText = ""
        if self.type == .day {
            title = R.string.localizable.blood_pressure_value_sys_day("\(points[0].intValue)")
            valueText = R.string.localizable.blood_pressure_value_dia_day("\(points[2].intValue)")
        } else {
            title = R.string.localizable.blood_pressure_value_sys(points[0].intValue.stringValue, points[1].intValue.stringValue)
            valueText = R.string.localizable.blood_pressure_value_dia(points[2].intValue.stringValue, points[3].intValue.stringValue)
        }
        let date = times[index].toDate()
        var timeString = ""
        switch type {
        case .day:
            timeString = "\(date.toString(.hm)) - \(date.toString(.dmySlash))"
        case .week:
            timeString = "\(date.toString(.dmySlash))"
        case .month:
            timeString = "\(date.toString(.dmySlash))"
        case .year:
            timeString = "\(date.toString(.mySlash))"
        }
        valueDetailsView = GraphValueDetailsView(title: title, valueText: valueText, timeString: timeString)
        addSubview(valueDetailsView)
        let width = valueDetailsView.viewWidth
        var newPoint: CGPoint = point
        var positionX: CGFloat = width / 2
        if point.x < 16 + width / 2 {
            newPoint.x = 16
            positionX = point.x - newPoint.x
        } else if point.x + width / 2 > bounds.maxX - 16 {
            newPoint.x = bounds.maxX - width - 16
            positionX = point.x - newPoint.x
        } else {
            newPoint.x = point.x - width / 2
        }
        newPoint.y = point.y - 10
        valueDetailsView.addTritangle(at: positionX)
        valueDetailsView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(newPoint.x)
            make.bottom.equalTo(self.snp.top).offset(newPoint.y)
        }
    }

    private func removeValueDetailsView() {
        valueDetailsView?.removeFromSuperview()
        valueDetailsView = nil
        lineChartView.removeSelectedLayer()
    }

    // MARK: - Action
    @objc func scrollViewPanGestureHandle(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .possible:
            break
        case .began:
            startTime = Date()
            startPoint = gesture.location(in: scrollView)
            startRange = getVisbleRange()
            isPangestureSwipeLeft = nil
        case .changed:
            if scrollView.contentOffset.x <= -scrollView.contentInset.left || scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.bounds.size.width + scrollViewLeadingInset - scrollViewTraillingInset {
                self.startTime = nil
                self.startPoint = nil
            }
        case .ended:
            guard let `startTime` = startTime, let `startPoint` = startPoint else {
                return
            }
            let endTime = Date()
            let currentPoint = gesture.location(in: scrollView)
            let duration = endTime.timeIntervalSince(startTime)
            let distance = abs(startPoint.x - currentPoint.x)
            if duration < 0.15, distance < 35 {
                let isSwipeLeft = startPoint.x < currentPoint.x
                scrollView.setContentOffset(scrollView.contentOffset, animated: false)
                if isSwipeLeft {
                    scrollViewDidSwipeLeft()
                } else {
                    scrollViewDidSwipeRight()
                }
            }
            self.startTime = nil
            self.startPoint = nil
        case .cancelled:
            break
        case .failed:
            break
        @unknown default:
            break
        }
    }

    private func scrollViewDidSwipeLeft() {
        let minXValue = startRange.0
        let maxXValue = startRange.1
        let max = Date().timeIntervalSince1970
        if minXValue <= max && max <= maxXValue {
            return
        }
        let date = type.getNextStartRangeValue(of: minXValue.toDate())
        scrollToXValue(date.timeIntervalSince1970)
    }

    private func scrollViewDidSwipeRight() {
        let minXValue = startRange.0
        let maxXValue = startRange.1
        guard let min = times.min() else {
            return
        }
        if minXValue <= min && min <= maxXValue {
            return
        }
        let date = type.getPriviousStartRangeValue(of: ((minXValue + maxXValue) / 2).toDate())
        scrollToXValue(date.timeIntervalSince1970)
    }

    func scrollToXValue(_ xValue: Double, animated: Bool = true) {
        let position = lineChartView.calculateXProsition(for: xValue) - scrollViewLeadingInset
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: position, y: 0), animated: animated)
        }
        let rect = CGRect(x: position, y: 0, width: scrollView.width, height: scrollView.height)
        let minTime = lineChartView.calculateXValue(from: Double(rect.minX + scrollViewLeadingInset))
        let maxTime = lineChartView.calculateXValue(from: Double(rect.maxX - scrollViewTraillingInset))
        delegate?.graphDidUpdateVisibleRange(range: (minTime, maxTime))
    }

    func getVisbleRange() -> (Double, Double) {
        if lineChartView.isEmpty {
            return (0, 0)
        }
        let visibleRect = scrollView.convert(scrollView.bounds, to: lineChartView)
        let minTime = lineChartView.calculateXValue(from: Double(visibleRect.minX + scrollViewLeadingInset))
        let maxTime = lineChartView.calculateXValue(from: Double(visibleRect.maxX - scrollViewTraillingInset))
        return (minTime, maxTime)
    }

    func reset() {
        self.horizontalPoint = []
        self.verticalPoint = []
        removeValueDetailsView()
        yAxisView.layer.sublayers?.forEach({ $0.removeFromSuperlayer()})
    }

}
// MARK: - UIScrollViewDelegate
extension GraphView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let range = getVisbleRange()
        let date = range.0.toDate()
        let startRangeDate = type.getStartRangeValue(of: date)
        if date.timeIntervalSince(startRangeDate) < (range.1 - range.0) / 15 && date.timeIntervalSince(startRangeDate) != 0 {
            scrollToXValue(startRangeDate.timeIntervalSince1970)
        } else {
            delegate?.graphDidUpdateVisibleRange(range: getVisbleRange())
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            delegate?.graphDidUpdateVisibleRange(range: getVisbleRange())
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.removeValueDetailsView()
    }
}
// MARK: - VXGraphViewDelegate
extension GraphView: VXGraphViewDelegate {
    func didTapAtPoint(_ point: CGPoint, points: [Double], index: Int?, deviceType: DeviceType) {
        if let `index` = index {
            let selfPoint = scrollView.convert(point, to: self) // tapGesture.location(in: self)
            self.addBloodPressureValueDetailsView(at: selfPoint, points: points, index: index)
        } else {
            self.removeValueDetailsView()
        }
    }

    func didTapAtPoint(_ point: CGPoint, points: [Double], index: Int?) {
        if let `index` = index {
            let selfPoint = scrollView.convert(point, to: self) // tapGesture.location(in: self)
            self.addValueDetailsView(at: selfPoint, points: points, index: index)
        } else {
            self.removeValueDetailsView()
        }
    }

    func didTapAtPoint(_ point: CGPoint, points: [Double], index: Int?, measurementType: MeasurementType) {
        if let `index` = index {
            let selfPoint = scrollView.convert(point, to: self) // tapGesture.location(in: self)
            self.addValueDetailsView(at: selfPoint, points: points, index: index, dataType: measurementType)
        } else {
            self.removeValueDetailsView()
        }
    }
}

// MARK: - VXGraphViewDelegate
extension GraphView {
    /// Set points for horizontal line chart
    /// - Parameters:
    ///   - points: value point
    ///   - measurementType: measurement type
    ///   - measurementData: measurement data
    ///   - times: times scale
    ///   - type: time type
    func setPoints(_ points: [Double], measurementType: MeasurementType, measurementData: MeasurementData, times: [Double], type: TimeFilterType = .day) {
        reset()
        self.deviceType = .scale
        self.horizontalPoint = points
        self.measurementType = measurementType
        self.measurementData = measurementData
        self.times = times
        self.emptyLabel.isHidden = !self.isEmpty
        self.type = type
        configLineChartView()
//        yLabelCount = Int(endWeight - startWeight) % 3 == 0 ? 4 : 3
        createYAxis()
        if let lastDate = times.last?.toDate() {
            let xValue = type.getStartRangeValue(of: lastDate).timeIntervalSince1970
            DispatchQueue.main.async {
                self.scrollToXValue(xValue, animated: false)
            }
        }
    }

    func setEmptyPoints(_ points: [Double], times: [Double], type: TimeFilterType = .day, deviceType: DeviceType) {
        reset()
        self.deviceType = deviceType
        self.horizontalPoint = points
        switch self.deviceType {
        case .scale:
            self.measurementType = .mass
        case .spO2:
            self.measurementType = .percentage
        case .biolightBloodPressure:
            self.measurementType = .none
        default:
            return
        }
        self.times = times
        self.emptyLabel.isHidden = !self.isEmpty
        self.type = type
        configLineChartView()
//        yLabelCount = Int(endWeight - startWeight) % 3 == 0 ? 4 : 3
        createYAxis()
        if let lastDate = times.last?.toDate() {
            let xValue = type.getStartRangeValue(of: lastDate).timeIntervalSince1970
            DispatchQueue.main.async {
                self.scrollToXValue(xValue, animated: false)
            }
        }
    }

    /// Set point for spo2 vertical line chart
    /// - Parameters:
    ///   - points: vertical line points
    ///   - times: time scale
    ///   - type: time type
    func setPoints(_ points: [[Double]], times: [Double], type: TimeFilterType = .day) {
        self.reset()
        self.deviceType = .spO2
        self.measurementType = .percentage
        self.verticalPoint = points
        self.times = times
        self.emptyLabel.isHidden = !self.isEmpty
        self.type = type
        self.configLineChartView()
        self.createYAxis()

        if let lastDate = times.last?.toDate() {
            let xValue = type.getStartRangeValue(of: lastDate).timeIntervalSince1970
            DispatchQueue.main.async {
                self.scrollToXValue(xValue, animated: false)
            }
        }
    }

    /// Set point for biolight vertical line chart
    /// - Parameters:
    ///   - points: vertical line points
    ///   - times: time scale
    ///   - type: time type
    ///   - deviceType:device type
    func setPoints(_ points: [[Double]], times: [Double], type: TimeFilterType = .day, deviceType: DeviceType = .biolightBloodPressure) {
        self.reset()
        self.deviceType = deviceType
        self.measurementType = .none
        self.verticalPoint = points
        self.times = times
        self.emptyLabel.isHidden = !self.isEmpty
        self.type = type
        self.configLineChartView()
        self.createYAxis()

        if let lastDate = times.last?.toDate() {
            let xValue = type.getStartRangeValue(of: lastDate).timeIntervalSince1970
            DispatchQueue.main.async {
                self.scrollToXValue(xValue, animated: false)
            }
        }
    }
}
