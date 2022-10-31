//
//  SKSwitch.swift
//  1SKConnect
//
//  Created by tuyenvx on 05/05/2021.
//

import Foundation
import UIKit

class SKSwitch: UIControl {
    public var padding: CGFloat = 1 {
        didSet {
            self.layoutSubviews()
        }
    }

    public var onTintColor = UIColor(red: 144/255, green: 202/255, blue: 119/255, alpha: 1) {
        didSet {
            self.setupUI()
        }
    }

    public var offTintColor = UIColor.lightGray {
        didSet {
            self.setupUI()
        }
    }

    public var layerCornerRadius: CGFloat = 0.5 {
        didSet {
            self.layoutSubviews()
        }
    }

    public var thumbTintOnColor = UIColor.white {
        didSet {
            self.thumbView.backgroundColor = self.thumbTintOnColor
        }
    }

    public var thumbTintOffColor = UIColor.white {
        didSet {
            self.thumbView.backgroundColor = self.thumbTintOffColor
        }
    }

    public var thumbCornerRadius: CGFloat = 0.5 {
        didSet {
            self.layoutSubviews()
        }
    }

    public var thumbSize = CGSize.zero {
        didSet {
            self.layoutSubviews()
        }
    }

    public var isOn = true

    public var animationDuration: Double = 0.5

    fileprivate var thumbView = UIView(frame: CGRect.zero)

    fileprivate var onPoint = CGPoint.zero

    fileprivate var offPoint = CGPoint.zero

    fileprivate var isAnimating = false
    let shadowLayer = CAShapeLayer()

    private func clear() {
       for view in self.subviews {
          view.removeFromSuperview()
       }
    }

    func setupUI() {
        self.clear()
        self.clipsToBounds = false
        self.thumbView.backgroundColor = self.thumbTintOnColor
        self.thumbView.isUserInteractionEnabled = false
        self.addSubview(self.thumbView)
    }

    public override func layoutSubviews() {

        self.shadowLayer.path = UIBezierPath(roundedRect: self.thumbView.bounds, cornerRadius: 11).cgPath
        self.shadowLayer.fillColor = UIColor.clear.cgColor
        self.shadowLayer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.shadowLayer.shadowPath = self.shadowLayer.path
        self.shadowLayer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.shadowLayer.shadowOpacity = 1
        self.shadowLayer.shadowRadius = 4
        self.thumbView.layer.insertSublayer(self.shadowLayer, at: 0)

        super.layoutSubviews()
        if !self.isAnimating {
            self.layer.cornerRadius = self.bounds.size.height * self.layerCornerRadius
            self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
            self.shadowLayer.fillColor = self.isOn ? self.thumbTintOnColor.cgColor : self.thumbTintOffColor.cgColor
            // thumb managment

            let thumbSize = self.thumbSize != CGSize.zero ? self.thumbSize : CGSize(width: self.bounds.size.height - 2,
                                                                                    height: self.bounds.height - 2)
            let yPostition = (self.bounds.size.height - thumbSize.height) / 2

            self.onPoint = CGPoint(x: self.bounds.size.width - thumbSize.width - self.padding, y: yPostition)
            self.offPoint = CGPoint(x: self.padding, y: yPostition)

            self.thumbView.frame = CGRect(origin: self.isOn ? self.onPoint : self.offPoint, size: thumbSize)

            self.thumbView.layer.cornerRadius = thumbSize.height * self.thumbCornerRadius

        }

    }

    func animate(_ needSentAction: Bool = true) {
        self.isOn = !self.isOn

        if needSentAction {
            self.sendActions(for: UIControl.Event.valueChanged)
        }

        self.isAnimating = true
        UIView.animate(withDuration: self.animationDuration, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5, options: [UIView.AnimationOptions.curveEaseOut,
                                                             UIView.AnimationOptions.beginFromCurrentState], animations: {
                                                                self.thumbView.frame.origin.x = self.isOn ? self.onPoint.x + 1 : -1
                                                                self.backgroundColor = self.isOn ? self.onTintColor : self.offTintColor
                                                                self.shadowLayer.fillColor = self.isOn ? self.thumbTintOnColor.cgColor : self.thumbTintOffColor.cgColor
                                                             }, completion: { _ in
                                                                self.isAnimating = false
                                                             })
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        self.animate()
        return true
    }
}
