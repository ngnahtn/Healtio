//
//  SKDashedLineHorizonatalView.swift
//  1SKConnect
//
//  Created by admin on 13/12/2021.
//

import UIKit

class SKDashedLineHorizonatalView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        DispatchQueue.main.async {
            self.setup(self.width)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        DispatchQueue.main.async {
            self.setup(self.width)
        }

    }

    func setup(_ width: CGFloat) {
        self.layer.sublayers?.removeAll()
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(hex: "737678").cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [2, 2]
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: width, y: 0)])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
    
    func removeSubLayer() {
        self.layer.sublayers?.removeAll()
    }
}
