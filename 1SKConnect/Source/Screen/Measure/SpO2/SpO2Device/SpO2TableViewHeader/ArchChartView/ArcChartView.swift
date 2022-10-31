//
//  ArcChartView.swift
//  1SKConnect
//
//  Created by Be More on 1/10/2021.
//

import UIKit

public enum ValueType {
    case spO2
    case pR
}

@IBDesignable
open class ArcChartView: UIView {

    private var indicatorLayer: CAShapeLayer?

    private lazy var arcLayer: ArtChartLayer = {
        let _gauge = ArtChartLayer()
        _gauge.drawsAsynchronously = true
        _gauge.disableSpringAnimation = true
        return _gauge
    }()

    private var valueType = ValueType.spO2

    @IBInspectable open var enableSpring: Bool {
        get {
            return arcLayer.disableSpringAnimation
        } set {
            arcLayer.disableSpringAnimation = newValue
        }
    }

    /// Save range color.
    @IBInspectable open var saveColor: UIColor = UIColor.green {
        didSet {
            if self.valueType == .spO2 {
                arcLayer.fillColor = saveColor.cgColor
            }
            setNeedsDisplay()
        }
    }

    /// Warning range color.
    @IBInspectable open var warningColor: UIColor = UIColor.orange {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Danger range color.
    @IBInspectable open var dangerColor: UIColor = UIColor.red {
        didSet {
            if valueType == .spO2 {
                arcLayer.fillColor = dangerColor.cgColor
            }
            setNeedsDisplay()
        }
    }

    /// Arc min value.
    @IBInspectable open var minValue: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Arc max value.
    @IBInspectable open var maxValue: CGFloat = 25 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// Start value
    @IBInspectable open var startingValue: CGFloat = 0 {
        didSet {
            if startingValue > maxValue {
                startingValue = maxValue
            }
            if startingValue < minValue {
                startingValue = minValue
            }
            setNeedsDisplay()
        }
    }

    /// Arc line width
    @IBInspectable open var lineWidth: CGFloat = 12 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    /// Create ArcChartView with value type
    /// - Parameter valueType: can be spo2 and smart scale
    init(valueType: ValueType) {
        super.init(frame: .zero)
        self.valueType = valueType
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Draw arc function
    /// - Parameter rect: draw in rect
    open override func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2
        let startAngle: CGFloat = 0.75 * CGFloat(Double.pi)
        let endAngle: CGFloat = 0.25 * CGFloat(Double.pi)
        let context = UIGraphicsGetCurrentContext()!
        let outlinePath = UIBezierPath(arcCenter: center, radius: radius - (lineWidth / 2), startAngle: startAngle, endAngle: endAngle, clockwise: true)
        outlinePath.lineWidth = lineWidth
        outlinePath.lineCapStyle = .round
        if self.valueType == .spO2 {
            saveColor.setStroke()
        } else {
            dangerColor.setStroke()
        }

        outlinePath.stroke()
        context.saveGState()
        if valueType == .spO2 {
            saveColor.setFill()
        } else {
            dangerColor.setFill()
        }

        var outlinePath2 = UIBezierPath()
        if self.valueType == .spO2 {
            outlinePath2 = UIBezierPath(arcCenter: center, radius: radius - (lineWidth / 2), startAngle: startAngle, endAngle: 2 * CGFloat(Double.pi), clockwise: true)
            outlinePath2.lineWidth = lineWidth
        } else {
            let startAngle: CGFloat = (25 * (27 / 22) * CGFloat(Double.pi)) / 180 + 0.75 * CGFloat(Double.pi)
            let endAngle: CGFloat = (120 * (27 / 22) * CGFloat(Double.pi)) / 180 + 0.75 * CGFloat(Double.pi)
            outlinePath2 = UIBezierPath(arcCenter: center, radius: radius - (lineWidth / 2), startAngle: startAngle, endAngle: endAngle, clockwise: true)
            outlinePath2.lineWidth = lineWidth + 0.5
        }
        outlinePath2.lineCapStyle = .round
        self.warningColor.setStroke()
        outlinePath2.stroke()
        context.saveGState()
        self.warningColor.setFill()

        var outlinePath3 = UIBezierPath()
        if self.valueType == .spO2 {
            outlinePath3 = UIBezierPath(arcCenter: center, radius: radius - (lineWidth / 2), startAngle: startAngle, endAngle: 7 * CGFloat(Double.pi) / 4, clockwise: true)
            outlinePath3.lineWidth = lineWidth
        } else {
            let startAngle: CGFloat = (25 * (27 / 22) * CGFloat(Double.pi)) / 180 + 0.75 * CGFloat(Double.pi)
            let endAngle: CGFloat = (60 * (27 / 22) * CGFloat(Double.pi)) / 180 + 0.75 * CGFloat(Double.pi)
            outlinePath3 = UIBezierPath(arcCenter: center, radius: radius - (lineWidth / 2), startAngle: startAngle, endAngle: endAngle, clockwise: true)
            outlinePath3.lineWidth = lineWidth + 0.5
        }
        outlinePath3.lineCapStyle = .round
        if self.valueType == .spO2 {
            dangerColor.setStroke()
        } else {
            saveColor.setStroke()
        }
        outlinePath3.stroke()
        context.saveGState()
        if self.valueType == .spO2 {
            dangerColor.setFill()
        } else {
            saveColor.setFill()
        }
        context.translateBy(x: rect.width / 2, y: rect.height / 2)
        context.restoreGState()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        arcLayer.fillColor = saveColor.cgColor
        layer.addSublayer(arcLayer)
        let anchorPoint = CGPoint(x: 0.5, y: 1.0)
        let newPoint = CGPoint(x: arcLayer.bounds.size.width * anchorPoint.x, y: arcLayer.bounds.size.height * anchorPoint.y)
        let oldPoint = CGPoint(x: arcLayer.bounds.size.width * arcLayer.anchorPoint.x, y: arcLayer.bounds.size.height * arcLayer.anchorPoint.y)
        var position = arcLayer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        position.y -= oldPoint.y
        position.y += newPoint.y
        arcLayer.position = position
        arcLayer.anchorPoint = anchorPoint
        rotateGauge(newValue: startingValue)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        // draw gauge.
        let viewWidth = frame.width
        let halfViewWidth = viewWidth / 2
        let viewHeight = frame.height
        let gaugeYPos: CGFloat = self.lineWidth / 2
        let gaugeHeight: CGFloat = viewHeight / 2 - self.lineWidth / 2
        let gaugeWidth: CGFloat = gaugeHeight * 0.16
        let gaugeFrame = CGRect(x: halfViewWidth - (gaugeWidth / 2), y: gaugeYPos, width: gaugeWidth, height: gaugeHeight).integral
        arcLayer.bounds.size = gaugeFrame.size
        arcLayer.position.x = gaugeFrame.origin.x + (gaugeFrame.width / 2)
        arcLayer.position.y = gaugeFrame.origin.y + gaugeFrame.height

        // draw indicator.
        if self.indicatorLayer == nil {
            indicatorLayer = CAShapeLayer()
            let radius: CGFloat = 8
            let gaugePath = UIBezierPath()
            indicatorLayer?.strokeColor = UIColor.white.cgColor
            indicatorLayer?.lineWidth = 6
            indicatorLayer?.fillColor = UIColor.clear.cgColor
            indicatorLayer?.shadowColor = UIColor(red: 0.254, green: 0.254, blue: 0.254, alpha: 0.3).cgColor
            indicatorLayer?.shadowOpacity = 1.0
            indicatorLayer?.shadowRadius = 3
            gaugePath.addArc(withCenter: CGPoint(x: gaugeWidth / 2, y: 0), radius: radius, startAngle: CGFloat(Double.pi), endAngle: 3 * CGFloat(Double.pi), clockwise: true)
            indicatorLayer?.path = gaugePath.cgPath
            arcLayer.addSublayer(indicatorLayer!)
        }
    }

    func rotateGauge(newValue: CGFloat) {
        var value = newValue
        if value > maxValue {
            value = maxValue
        }
        if value < minValue {
            value = minValue
        }
        let fractalSpeed = (value - minValue) / (maxValue - minValue)
        let newAngle = 0.75 * CGFloat(Double.pi) * (2 * fractalSpeed - 1)
        arcLayer.transform = CATransform3DMakeRotation(newAngle, 0, 0, 1)
    }
}
