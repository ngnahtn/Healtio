//
//  VXGraphView.swift
//  1SKConnect
//
//  Created by tuyenvx on 12/05/2021.
//

import UIKit
import SnapKit

protocol VXGraphViewDelegate: AnyObject {
    /// Tap at horizontal point.
    func didTapAtPoint(_ point: CGPoint, points: [Double], index: Int?, measurementType: MeasurementType)

    /// Tap at vertical point.
    func didTapAtPoint(_ point: CGPoint, points: [Double], index: Int?)

    /// Tap at vertical point with device type
    func didTapAtPoint(_ point: CGPoint, points: [Double], index: Int?, deviceType: DeviceType)
}

class VXGraphView: UIView {
    private var type: TimeFilterType = .day
    private var horizontalPoints: [Double] = []
    private var verticalPoints: [[Double]] = []
    private var times: [Double] = []
    private var measurementType = MeasurementType.mass
    private var measurementData = MeasurementData.weightPoints

    private var deviceType: DeviceType = .scale
    //
    private var graphVisibleWidth: CGFloat = Constant.Screen.width - 53
    private var xLabelSpace: Double = 21_600
    private var xVisibleRange: Double = 0
    private var xRatio: Double = 1
    //
    private let graphVisibleHeight: CGFloat = 96
    private var yRatio: Double = 1
    private var yVisibleRange: Double = 0
    private let yAxisOfsetFromTop: CGFloat = 5
    private let yAxisValueStartValueOffset: CGFloat = 22.75 // Offset from startvalue and origin
    private var yLabelCount = 4
    //
    private var graphLeadingOffset: CGFloat = 6
    private var graphTraillingOffset: CGFloat = 9
    //
    private var widthConstraint: Constraint!
    private var selectedLayer: CAShapeLayer?

    var isEmpty: Bool {
        return self.times.isEmpty
    }

    weak var delegate: VXGraphViewDelegate?

    // MARK: - Init
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
        snp.makeConstraints { make in
            make.height.equalTo(121)
            widthConstraint = make.width.equalTo(0).offset(graphVisibleWidth).constraint
        }
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundDidTapped(_:))))
    }

    private func addXAxisLayer() {
        let xAxisLayer = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: -graphVisibleWidth, y: graphVisibleHeight))
        let lastX = calculateXProsition(for: endTime)
        linePath.addLine(to: CGPoint(x: lastX + graphVisibleWidth, y: graphVisibleHeight))
        xAxisLayer.lineWidth = 1
        xAxisLayer.strokeColor = UIColor(hex: "D3DFE8").cgColor
        xAxisLayer.path = linePath.cgPath
        layer.addSublayer(xAxisLayer)
    }

    private func addGraphViewBackgroundLineLayer() {
        addXLabelLayer()
        let lineLayer = CAShapeLayer()
        //
        let lastX = calculateXProsition(for: endTime)
        let weightMinUnit = (endValue - startValue) / Double(yLabelCount)
        for index in 0 ... yLabelCount {
            let yValue = startValue + weightMinUnit * index.doubleValue
            let horizontalLineLayer = CAShapeLayer()
            let bezierPath = UIBezierPath()
            let yPosition = calculateYProsition(for: yValue)

            bezierPath.move(to: CGPoint(x: -graphVisibleWidth, y: yPosition))
            bezierPath.addLine(to: CGPoint(x: lastX + graphVisibleWidth, y: yPosition))
            horizontalLineLayer.path = bezierPath.cgPath
            horizontalLineLayer.lineWidth = 0.7
            horizontalLineLayer.strokeColor = UIColor(hex: "E7ECF0").cgColor
            lineLayer.addSublayer(horizontalLineLayer)
        }
        layer.addSublayer(lineLayer)
    }

    private func addXLabelLayer() {
        let lineLayer = CAShapeLayer()
        let xLabelLayer = CAShapeLayer()
        var startMarginTime = startTime - 10 * xLabelSpace
        var endMarginTime = endTime + 10 * xLabelSpace
        if type == .year {
            startMarginTime = startTime.toDate().previousYear.timeIntervalSince1970
            endMarginTime = endTime.toDate().nextYear.endOfYear.timeIntervalSince1970
        }
        var xLabelValue = startMarginTime
        while xLabelValue <= endMarginTime {
            let textLayer = createTextLayer(xValue: xLabelValue)
            xLabelLayer.addSublayer(textLayer)
            let verticalLineLayer = CAShapeLayer()
            let bezierPath = UIBezierPath()
            let xPosition = calculateXProsition(for: xLabelValue)
            bezierPath.move(to: CGPoint(x: xPosition, y: 0))
            bezierPath.addLine(to: CGPoint(x: xPosition, y: graphVisibleHeight))
            verticalLineLayer.path = bezierPath.cgPath
            verticalLineLayer.lineWidth = 0.7
            verticalLineLayer.strokeColor = UIColor(hex: "E7ECF0").cgColor
            lineLayer.addSublayer(verticalLineLayer)
            switch type {
            case .day, .week, .month:
                xLabelValue += xLabelSpace
            case .year:
                let date = xLabelValue.toDate()
                let nextMonth = date.nextMonth
                xLabelValue = nextMonth.timeIntervalSince1970
            }
        }

        layer.addSublayer(xLabelLayer)
        if !self.isEmpty {
            layer.addSublayer(lineLayer)
        }
    }

    /// Add graph line layer
    /// - Parameter dataType: `MeasurementData`
    private func addLineLayer(dataType: MeasurementData) {
        // configure line with dataType
        let lineLayer = CAShapeLayer()
        lineLayer.lineWidth = 1
        lineLayer.shadowColor = UIColor(red: 3 / 255.0, green: 189 / 255.0, blue: 192 / 255.0, alpha: 1).cgColor
        lineLayer.shadowOffset = CGSize(width: 0, height: 1)
        lineLayer.shadowRadius = 4
        lineLayer.shadowOpacity = 0.5
        lineLayer.masksToBounds = false
        switch dataType {
        case .weightPoints:
            lineLayer.strokeColor = R.color.weightColor()!.cgColor
        case .musclePoints:
            lineLayer.strokeColor = R.color.weightOfMuscleColor()!.cgColor
        case .bonePoints:
            lineLayer.strokeColor = R.color.weightOfBoneColor()!.cgColor
        case .idealWeightPoint:
            lineLayer.strokeColor = R.color.idealWeightColor()!.cgColor
        case .waterPoints:
            lineLayer.strokeColor = R.color.ratioOfWaterColor()!.cgColor
        case .proteinPoints:
            lineLayer.strokeColor = R.color.ratioOfProteinColor()!.cgColor
        case .fatPoints:
            lineLayer.strokeColor = R.color.ratioOfFatColor()!.cgColor
        case .subcutaneousFatPoints:
            lineLayer.strokeColor = R.color.ratioOfSubcutaneousFatColor()!.cgColor
        }

        // create actual line
        self.createScaleLine(with: horizontalPoints,
                             lineShape: lineLayer,
                             dataType: dataType)
    }

    /// Create horizontal line layer
    /// - Parameters:
    ///   - points: horizontal line values
    ///   - lineShape: add values to line
    ///   - dataType: `MeasurementData`
    func createScaleLine(with points: [Double],
                         lineShape: CAShapeLayer,
                         dataType: MeasurementData) {
        let pointShape = CAShapeLayer()
        pointShape.backgroundColor = UIColor.clear.cgColor
        let linePath = UIBezierPath()
        for index in 0 ... points.count - 1 {
            // Add line
            let point = calculatePosition(for: (times[index], points[index]))
            if index != 0 {
//                if times[index] - times[index - 1] <= xVisibleRange {
                linePath.addLine(to: point)
//                }
                linePath.move(to: point)
            } else {
                linePath.move(to: point)
            }
            var pointLayer = CAShapeLayer()
            if !point.y.isNaN {
                pointLayer = createValuePointLayer(at: point, with: dataType)
                pointShape.addSublayer(pointLayer)
            } else {
                pointLayer = createValuePointLayer(at: CGPoint(x: point.x, y: -100), with: dataType)
                pointShape.addSublayer(pointLayer)
            }
        }
        lineShape.path = linePath.cgPath
        layer.addSublayer(lineShape)
        layer.addSublayer(pointShape)
    }

    /// Create spO2 line
    /// - Parameter points: with point
    func createSpO2Line(with points: [[Double]]) {
        // configure line with dataType
        let lineLayer = CAShapeLayer()
        lineLayer.lineWidth = 1
        lineLayer.shadowColor = UIColor(red: 3 / 255.0, green: 189 / 255.0, blue: 192 / 255.0, alpha: 1).cgColor
        lineLayer.shadowOffset = CGSize(width: 0, height: 1)
        lineLayer.shadowRadius = 4
        lineLayer.shadowOpacity = 0.5
        lineLayer.masksToBounds = false
        lineLayer.strokeColor = R.color.mainColor()!.cgColor

        let pointShape = CAShapeLayer()
        pointShape.backgroundColor = UIColor.clear.cgColor
        let linePath = UIBezierPath()
        for i in 0 ..< points.count {
            for j in 0 ..< points[i].count {
                let point = calculatePosition(for: (times[i], points[i][j]))
                if j != 0 {
                    linePath.addLine(to: point)
                    linePath.move(to: point)
                } else {
                    linePath.move(to: point)
                }
                var pointLayer = CAShapeLayer()
                if !point.y.isNaN {
                    pointLayer = createValuePointLayer(at: point, with: .idealWeightPoint)
                    pointShape.addSublayer(pointLayer)
                } else {
                    pointLayer = createValuePointLayer(at: CGPoint(x: point.x, y: -100), with: .idealWeightPoint)
                    pointShape.addSublayer(pointLayer)
                }
            }
        }
        lineLayer.path = linePath.cgPath
        layer.addSublayer(lineLayer)
        layer.addSublayer(pointShape)
    }

    /// Create biolight line
    /// - Parameter points: with point
    func createBiolightLine(with points: [[Double]]) {
        // sys line layer
        let sysLineLayer = CAShapeLayer()
        sysLineLayer.lineWidth = 1
        sysLineLayer.shadowColor = UIColor(red: 0.188, green: 0.494, blue: 0.957, alpha: 0.62).cgColor
        sysLineLayer.shadowOffset = CGSize(width: 0, height: 1)
        sysLineLayer.shadowRadius = 3
        sysLineLayer.shadowOpacity = 1
        sysLineLayer.masksToBounds = false
        sysLineLayer.strokeColor =  UIColor(hex: "307EF4").cgColor

        // dia line layer
        let diaLineLayer = CAShapeLayer()
        diaLineLayer.lineWidth = 1
        diaLineLayer.shadowColor = UIColor(red: 0.953, green: 0.412, blue: 0.412, alpha: 0.62).cgColor
        diaLineLayer.shadowOffset = CGSize(width: 0, height: 1)
        diaLineLayer.shadowRadius = 3
        diaLineLayer.shadowOpacity = 1
        diaLineLayer.masksToBounds = false
        diaLineLayer.strokeColor = UIColor(hex: "F36969").cgColor

        let pointShape = CAShapeLayer()
        pointShape.backgroundColor = UIColor.clear.cgColor
        let sysLinePath = UIBezierPath()
        let diaLinePath = UIBezierPath()
        if self.type == .day {
            for i in 0 ..< points.count {
                let sysPoint = calculatePosition(for: (times[i], points[i][0]))
                let diaPoint = calculatePosition(for: (times[i], points[i][2]))
                if i != 0 {
                    sysLinePath.addLine(to: sysPoint)
                    sysLinePath.move(to: sysPoint)

                    diaLinePath.addLine(to: diaPoint)
                    diaLinePath.move(to: diaPoint)
                } else {
                    sysLinePath.move(to: sysPoint)
                    diaLinePath.move(to: diaPoint)
                }
                let sysPointLayer = createValuePointLayer(at: sysPoint, with: UIColor(hex: "307EF4"))
                let diaPointLayer = createValuePointLayer(at: diaPoint, with: UIColor(hex: "F36969"))
                pointShape.addSublayer(sysPointLayer)
                pointShape.addSublayer(diaPointLayer)
            }
        } else {
            for i in 0 ..< points.count {
                for j in 0 ..< points[i].count {
                    let point = calculatePosition(for: (times[i], points[i][j]))

                    // draw line
                    if j == 0 {
                        sysLinePath.move(to: point)
                    } else if j == 1 {
                        sysLinePath.addLine(to: point)
                        sysLinePath.move(to: point)
                    }
                    if j == 2 {
                        diaLinePath.move(to: point)
                    } else if j == 3 {
                        diaLinePath.addLine(to: point)
                        diaLinePath.move(to: point)
                    }

                    var pointLayer = CAShapeLayer()
                    if !point.y.isNaN {
                        if j == 0 || j == 1 {
                            pointLayer = createValuePointLayer(at: point, with: UIColor(hex: "307EF4"))
                        } else {
                            pointLayer = createValuePointLayer(at: point, with: UIColor(hex: "F36969"))
                        }
                        pointShape.addSublayer(pointLayer)
                    } else {
                        pointLayer = createValuePointLayer(at: CGPoint(x: point.x, y: -100), with: .idealWeightPoint)
                        pointShape.addSublayer(pointLayer)
                    }
                }
            }
        }

        sysLineLayer.path = sysLinePath.cgPath
        diaLineLayer.path = diaLinePath.cgPath
        layer.addSublayer(sysLineLayer)
        layer.addSublayer(diaLineLayer)
        layer.addSublayer(pointShape)
    }

    // MARK: - Action
    @objc func backgroundDidTapped(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: self)
        guard let valuePointLayer = layer.sublayers?.last, let pointLayers = valuePointLayer.sublayers else {
            return
        }
        if selectedLayer == nil {
            if self.deviceType == .scale {
                for (index, pointLayer) in pointLayers.enumerated() {
                    if pointLayer.frame.contains(touchPoint) {
                        self.removeSelectedLayer()
                        let valuePoint = calculatePosition(for: (times[index], horizontalPoints[index]))
                        let lineSelectedLayer = createSelectedLineLayer(at: valuePoint)
                        let pointSelectedLayer = createSelectedValuePointLayer(at: valuePoint, dataType: self.measurementData)
                        selectedLayer = CAShapeLayer()
                        selectedLayer?.addSublayer(lineSelectedLayer)
                        selectedLayer?.addSublayer(pointSelectedLayer)
                        valuePointLayer.addSublayer(selectedLayer!)
                        delegate?.didTapAtPoint(valuePoint, points: horizontalPoints, index: index, measurementType: self.measurementType)
                        break
                    }
                }
            } else if self.deviceType == .spO2 {
                for (index, pointLayer) in pointLayers.enumerated() {
                    if pointLayer.frame.contains(touchPoint) {
                        self.removeSelectedLayer()
                        var tempIndex = 0
                        if index % 2 != 0 {
                            tempIndex = (index - 1) / 2
                        } else {
                            tempIndex = index / 2
                        }
                        for j in 0 ..< self.verticalPoints[tempIndex].count {
                            let valuePoint = calculatePosition(for: (self.times[tempIndex], self.verticalPoints[tempIndex][j]))
                            let lineSelectedLayer = createSelectedLineLayer(at: valuePoint)
                            let pointSelectedLayer = createSelectedValuePointLayer(at: valuePoint, dataType: .idealWeightPoint)
                            if self.selectedLayer == nil {
                                selectedLayer = CAShapeLayer()
                            }
                            if j == 1 {
                                selectedLayer?.addSublayer(lineSelectedLayer)
                            }
                            selectedLayer?.addSublayer(pointSelectedLayer)
                            valuePointLayer.addSublayer(selectedLayer!)
                            delegate?.didTapAtPoint(calculatePosition(for: (self.times[tempIndex], self.verticalPoints[tempIndex][0])), points: self.verticalPoints[tempIndex], index: tempIndex)
                        }
                        break
                    }
                }
            } else if self.deviceType == .biolightBloodPressure {
                for (index, pointLayer) in pointLayers.enumerated() {
                    if pointLayer.frame.contains(touchPoint) {
                        self.removeSelectedLayer()
                        var tempIndex = 0
                        if self.type == .day {
                            if index % 2 != 0 {
                                tempIndex = (index - (index % 2)) / 2
                            } else {
                                tempIndex = index / 2
                            }
                        } else {
                            if index % 4 != 0 {
                                tempIndex = (index - (index % 4)) / 4
                            } else {
                                tempIndex = index / 4
                            }
                        }
                        for j in 0 ..< self.verticalPoints[tempIndex].count {
                            let valuePoint = calculatePosition(for: (self.times[tempIndex], self.verticalPoints[tempIndex][j]))
                            let lineSelectedLayer = createSelectedLineLayer(at: valuePoint)
                            var pointSelectedLayer = CAShapeLayer()
                            if j == 1 || j == 0 {
                                pointSelectedLayer = createSelectedValuePointLayer(at: valuePoint, color: UIColor(hex: "307EF4"))
                            } else {
                                pointSelectedLayer = createSelectedValuePointLayer(at: valuePoint, color: UIColor(hex: "F36969"))
                            }
                            if self.selectedLayer == nil {
                                selectedLayer = CAShapeLayer()
                            }
                            if j == 3 {
                                selectedLayer?.addSublayer(lineSelectedLayer)
                            }
                            selectedLayer?.addSublayer(pointSelectedLayer)
                            valuePointLayer.addSublayer(selectedLayer!)
                            delegate?.didTapAtPoint(calculatePosition(for: (self.times[tempIndex], self.verticalPoints[tempIndex][0])), points: self.verticalPoints[tempIndex], index: tempIndex, deviceType: .biolightBloodPressure)
                        }
                        break
                    }
                }
            }
        } else {
            self.removeSelectedLayer()
            delegate?.didTapAtPoint(touchPoint, points: [], index: nil, measurementType: self.measurementType)
        }

    }

    /// set points for horizontal charts
    /// - Parameters:
    ///   - points: horizontal points
    ///   - measurementType: `MeasurementType`
    ///   - measurementData: `MeasurementData`
    func setPoints(_ points: [Double], measurementType: MeasurementType, measurementData: MeasurementData) {
        self.deviceType = .scale
        self.horizontalPoints = points
        self.measurementType = measurementType
        self.measurementData = measurementData
        yVisibleRange = endValue - startValue
        yRatio = Double(graphVisibleHeight - yAxisOfsetFromTop - yAxisValueStartValueOffset) / yVisibleRange
    }

    /// Set point for spo2 line chart
    /// - Parameter points: vertical points
    func setPoints(_ points: [[Double]]) {
        self.verticalPoints = points
        self.deviceType = .spO2
        self.measurementType = .percentage
        yVisibleRange = endValue - startValue
        yRatio = Double(graphVisibleHeight - yAxisOfsetFromTop - yAxisValueStartValueOffset) / yVisibleRange
    }

    /// Set point for boilight line chart
    /// - Parameter points: vertical points
    func setPoints(_ points: [[Double]], deviceType: DeviceType = .biolightBloodPressure) {
        self.verticalPoints = points
        self.deviceType = deviceType
        self.measurementType = .none
        yVisibleRange = endValue - startValue
        yRatio = Double(graphVisibleHeight - yAxisOfsetFromTop - yAxisValueStartValueOffset) / yVisibleRange
    }

    func setTimes(_ times: [Double]) {
        self.times = times
    }

    func setType(_ type: TimeFilterType) {
        self.type = type
        switch type {
        case .day:
            xVisibleRange = 86_400
            xLabelSpace = 21_600
        case .week:
            xVisibleRange = 604_800
            xLabelSpace = 86_400
        case .month:
            xVisibleRange = startTime.toDate().endOfMonth.timeIntervalSince1970 - startTime.toDate().startOfMonth.timeIntervalSince1970 + 1
            xLabelSpace = 259_200
        case .year:
            xVisibleRange = 31_536_000
            xLabelSpace = 2_678_400
        }
        xRatio = Double(graphVisibleWidth) / xVisibleRange
    }

    func notificationDataChanged() {
        reset()
        snp.updateConstraints { update in
            widthConstraint.update(offset: (endTime - startTime) * xRatio)
        }
        addXAxisLayer()
        addGraphViewBackgroundLineLayer()
        guard !isEmpty else {
            return
        }

        switch self.deviceType {
        case .scale:
            self.addLineLayer(dataType: self.measurementData)
        case .spO2:
            self.createSpO2Line(with: self.verticalPoints)
        case .biolightBloodPressure:
            self.createBiolightLine(with: self.verticalPoints)
        default:
            return
        }
        setNeedsLayout()
    }

    func calculateXValue(from xPosition: Double) -> Double {
        let xValue = startTime + xPosition / xRatio
        return xValue
    }

    func calculateXProsition(for xValue: Double) -> CGFloat {
        let xPosition = (xValue - startTime) * xRatio
        return CGFloat(xPosition)
    }

    func calculateYProsition(for yValue: Double) -> CGFloat {
        let yPosition = (endValue - yValue) * yRatio + yAxisOfsetFromTop.doubleValue + 14
        return CGFloat(yPosition)
    }

    func calculatePosition(for point: (Double, Double)) -> CGPoint {
        let xPosition = calculateXProsition(for: point.0)
        let yPosition = calculateYProsition(for: point.1)
        return CGPoint(x: xPosition, y: yPosition)
    }

    func removeSelectedLayer() {
        selectedLayer?.removeFromSuperlayer()
        selectedLayer = nil
    }

    private func reset() {
        layer.sublayers?.forEach({ $0.removeFromSuperlayer()})
    }
}
// MARK: - Computed propety
extension VXGraphView {
    var startTime: Double {
        guard let firstTime = times.first else {
            return type.getStartRangeValue(of: Date()).timeIntervalSince1970
        }
        return type.getStartRangeValue(of: firstTime.toDate()).timeIntervalSince1970
    }

    var endTime: Double {
        return type.getEndRangeValue(of: Date()).timeIntervalSince1970
    }

    var startValue: Double {
        switch self.deviceType {
        case .scale:
            guard let min = horizontalPoints.min(), let max = horizontalPoints.max() else {
                return 40
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
            guard let min = horizontalPoints.min(), let max = horizontalPoints.max() else {
                return 100
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
}

// MARK: - Helper
extension VXGraphView {
    private func cgColor(for dataType: MeasurementData) -> CGColor {
        switch dataType {
        case .weightPoints:
            return R.color.weightColor()!.cgColor
        case .musclePoints:
            return R.color.weightOfMuscleColor()!.cgColor
        case .bonePoints:
             return R.color.weightOfBoneColor()!.cgColor
        case .idealWeightPoint:
            return R.color.idealWeightColor()!.cgColor
        case .waterPoints:
            return R.color.ratioOfWaterColor()!.cgColor
        case .proteinPoints:
            return R.color.ratioOfProteinColor()!.cgColor
        case .fatPoints:
            return R.color.ratioOfFatColor()!.cgColor
        case .subcutaneousFatPoints:
            return R.color.ratioOfSubcutaneousFatColor()!.cgColor
        }
    }

    private func createTextLayer(xValue: Double) -> CATextLayer {
        let textLayer = CATextLayer()
        if self.type == .month {
            textLayer.frame = CGRect(x: calculateXProsition(for: xValue) - 13, y: 101, width: 20, height: 14)
        } else {
            textLayer.frame = CGRect(x: calculateXProsition(for: xValue) - 10, y: 101, width: 20, height: 14)
        }
        textLayer.font = R.font.robotoRegular(size: 13)
        textLayer.fontSize = 12
        textLayer.alignmentMode = .center
        textLayer.string = xLabelTitleForValue(xValue)
        textLayer.foregroundColor = R.color.subTitle()!.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }

    private func xLabelTitleForValue(_ value: Double) -> String {
        let date = Date(timeIntervalSince1970: value)
        switch type {
        case .day:
            return date.toString(.hour)
        case .week:
            let weekDay = WeekDay(rawValue: date.weekDay) ?? .mon
            return weekDay.name
        case .month:
            return String(date.day)
        case .year:
            return String(date.month)
        }
    }

    private func createValuePointLayer(at point: CGPoint, with dataType: MeasurementData) -> CAShapeLayer {
        let pointLayer = CAShapeLayer()
        pointLayer.frame = CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20)
        let bezierPath = UIBezierPath(roundedRect: pointLayer.bounds.insetBy(dx: 8, dy: 8), cornerRadius: 2)
        pointLayer.path = bezierPath.cgPath
        pointLayer.fillColor = self.cgColor(for: dataType)
        return pointLayer
    }

    private func createValuePointLayer(at point: CGPoint, with color: UIColor) -> CAShapeLayer {
        let pointLayer = CAShapeLayer()
        pointLayer.frame = CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20)
        let bezierPath = UIBezierPath(roundedRect: pointLayer.bounds.insetBy(dx: 8, dy: 8), cornerRadius: 2)
        pointLayer.path = bezierPath.cgPath
        pointLayer.fillColor = color.cgColor
        return pointLayer
    }

    private func createSelectedValuePointLayer(at point: CGPoint, dataType: MeasurementData) -> CAShapeLayer {
        let pointLayer = CAShapeLayer()
        pointLayer.frame = CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)
        let path1 = UIBezierPath(roundedRect: pointLayer.bounds, cornerRadius: 5)
        let path2 = UIBezierPath(roundedRect: pointLayer.bounds.insetBy(dx: 1, dy: 1), cornerRadius: 4)
        let path3 = UIBezierPath(roundedRect: pointLayer.bounds.insetBy(dx: 3, dy: 3), cornerRadius: 2)
        let bezierPath = UIBezierPath()
        bezierPath.append(path1)
        bezierPath.append(path2)
        bezierPath.append(path3)
        pointLayer.path = bezierPath.cgPath
        pointLayer.fillColor = self.cgColor(for: dataType)
        pointLayer.backgroundColor = UIColor.white.cgColor
        pointLayer.cornerRadius = 5
        pointLayer.masksToBounds = true
        pointLayer.fillRule = .evenOdd
        return pointLayer
    }

    private func createSelectedValuePointLayer(at point: CGPoint, color: UIColor) -> CAShapeLayer {
        let pointLayer = CAShapeLayer()
        pointLayer.frame = CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)
        let path1 = UIBezierPath(roundedRect: pointLayer.bounds, cornerRadius: 5)
        let path2 = UIBezierPath(roundedRect: pointLayer.bounds.insetBy(dx: 1, dy: 1), cornerRadius: 4)
        let path3 = UIBezierPath(roundedRect: pointLayer.bounds.insetBy(dx: 3, dy: 3), cornerRadius: 2)
        let bezierPath = UIBezierPath()
        bezierPath.append(path1)
        bezierPath.append(path2)
        bezierPath.append(path3)
        pointLayer.path = bezierPath.cgPath
        pointLayer.fillColor = color.cgColor
        pointLayer.backgroundColor = UIColor.white.cgColor
        pointLayer.cornerRadius = 5
        pointLayer.masksToBounds = true
        pointLayer.fillRule = .evenOdd
        return pointLayer
    }

    private func createSelectedLineLayer(at point: CGPoint) -> CAShapeLayer {
        let selectedLineLayer = CAShapeLayer()
        let bezierpath = UIBezierPath()
        bezierpath.move(to: point)
        let endPoint = CGPoint(x: point.x, y: graphVisibleHeight)
        bezierpath.addLine(to: endPoint)
        selectedLineLayer.path = bezierpath.cgPath
        selectedLineLayer.strokeColor = UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1).cgColor
        selectedLineLayer.lineWidth = 1
        selectedLineLayer.lineDashPattern = [3.5, 2.5]
        return selectedLineLayer
    }

    private func createSelectedLineLayer(at point: CGPoint, with color: UIColor) -> CAShapeLayer {
        let selectedLineLayer = CAShapeLayer()
        let bezierpath = UIBezierPath()
        bezierpath.move(to: point)
        let endPoint = CGPoint(x: point.x, y: graphVisibleHeight)
        bezierpath.addLine(to: endPoint)
        selectedLineLayer.path = bezierpath.cgPath
        selectedLineLayer.strokeColor = color.cgColor
        selectedLineLayer.lineWidth = 1
        selectedLineLayer.lineDashPattern = [3.5, 2.5]
        return selectedLineLayer
    }
}
