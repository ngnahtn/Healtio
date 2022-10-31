//
//  GraphWeightDetailsView.swift
//  1SKConnect
//
//  Created by tuyenvx on 14/05/2021.
//

import UIKit

class GraphValueDetailsView: UIView {
    private lazy var titleLabel = createLabel(with: 14)
    private lazy var valueLabel = createLabel(with: 14)
    private lazy var timeLabel = createLabel(with: 12)
    private let topOffset = 3
    private let leadingOffset: CGFloat = 6
    var viewHeight: CGFloat = 55
    var viewWidth: CGFloat = 73

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    convenience init(title: String, valueText: String, timeString: String) {
        self.init(frame: .zero)
        setupDefaults()
        titleLabel.text = title
        valueLabel.text = valueText
        timeLabel.text = timeString
        snp.makeConstraints { make in
            make.height.equalTo(viewHeight)
            if let maxWidth = [titleLabel, valueLabel, timeLabel].map({ calcalateLabelWidth(of: $0)}).max() {
                viewWidth = max(maxWidth + 2 * leadingOffset, 73)
                make.width.equalTo(viewWidth)
            } else {
                viewWidth = 73
                make.width.equalTo(viewWidth)
            }
        }
        let shadowLayer = CAShapeLayer()
        let bezierPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: viewWidth, height: viewHeight)), cornerRadius: 4)
        shadowLayer.path = bezierPath.cgPath
        shadowLayer.shadowPath = bezierPath.cgPath
        shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
        shadowLayer.shadowRadius = 5
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOpacity = 0.25
        shadowLayer.masksToBounds = false
        shadowLayer.fillColor = UIColor.white.cgColor
        layer.insertSublayer(shadowLayer, at: 0)
    }

    private func setupDefaults() {
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(topOffset)
            make.leading.equalToSuperview().offset(leadingOffset)
            make.height.equalTo(15)
            make.centerX.equalToSuperview()
        }

        self.addSubview(valueLabel)
        self.valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(topOffset)
            make.leading.equalTo(titleLabel.snp.leading)
            make.height.equalTo(15)
            make.centerX.equalToSuperview()
        }

        self.addSubview(timeLabel)
        self.timeLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(topOffset)
            make.leading.equalTo(valueLabel.snp.leading)
            make.height.equalTo(13).priority(.low)
            make.bottom.equalToSuperview().offset(4).priority(250)
        }
    }

    private func createLabel(with fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = R.font.robotoRegular(size: fontSize)
        label.textColor = R.color.subTitle()
        label.textAlignment = .left
        return label
    }

    private func calcalateLabelWidth(of label: UILabel) -> CGFloat {
        return label.systemLayoutSizeFitting(CGSize(width: .infinity, height: CGFloat(15)),
                                             withHorizontalFittingPriority: .fittingSizeLevel,
                                             verticalFittingPriority: .required).width
    }

    func addTritangle(at xPosition: CGFloat) {
        var xValue = xPosition
        if xValue < 6 {
            xValue = 6
        } else if xValue > viewWidth - 6 {
            xValue = viewWidth - 6
        }
        let shapeLayer = CAShapeLayer()
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: xValue - 3, y: viewHeight))
        bezierPath.addLine(to: CGPoint(x: xPosition, y: viewHeight + 3))
        bezierPath.addLine(to: CGPoint(x: xValue + 3, y: viewHeight))
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        layer.addSublayer(shapeLayer)
    }
}
