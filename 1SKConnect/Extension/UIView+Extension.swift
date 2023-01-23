//
//  UIView+Extension.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import UIKit

// MARK: - Border
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = true
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    var width: CGFloat {
        return bounds.width
    }

    var height: CGFloat {
        return bounds.height
    }

    func roundCorners(cornes: CACornerMask, radius: CGFloat) {
        layer.cornerRadius = radius
        layer.maskedCorners = cornes
    }

    func roundCorner(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }

    func makeRound() {
        let cornerRadius = min(width, height) / 2
        self.cornerRadius = cornerRadius
    }
}
// MARK: - SKShadow
extension UIView {
    func addSKShadow(shadowColor: UIColor, offset: CGSize, radius: CGFloat, opacity: Float = 1) {
        layoutIfNeeded()
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        let cornerRadius = layer.cornerRadius
        let roundedRect = CGRect(x: 0, y: height / 2, width: width, height: height / 2)
        let shadowPath = UIBezierPath(roundedRect: roundedRect,
                                      byRoundingCorners: [.allCorners],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        layer.shadowPath = shadowPath
    }

    func addShadow(offSet: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offSet
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func addShadow(width: CGFloat, height: CGFloat, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: width, height: height)
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func addShadowPath(rect: CGRect, cornerRadius: CGFloat, width: CGFloat, height: CGFloat, color: UIColor, radius: CGFloat, opacity: Float) {
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
        shadowLayer.shadowOffset = CGSize(width: width, height: height)
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowRadius = radius
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shouldRasterize = true
        shadowLayer.rasterizationScale = UIScreen.main.scale
        shadowLayer.fillColor = UIColor.white.cgColor
        layer.insertSublayer(shadowLayer, at: 0)
    }
}
// MARK: - Nib
// swiftlint:disable force_cast
extension UIView {
    static func nibName() -> String {
        return String(describing: self)
    }

    static func loadFromNib() -> Self {
        return UINib(nibName: String(describing: self), bundle: nil)
            .instantiate(withOwner: nil, options: nil)[0] as! Self
    }
}

// MARK: - Programatically constraints
extension UIView {

    func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    /// Add constraints programatically.
    ///
    /// - Parameters:
    ///   - top:            constraint to top anchor
    ///   - left:           constraint to left anchor
    ///   - bottom:         constraint to bottom anchor
    ///   - right:          constraint to right anchor
    ///   - paddingTop:     top padding
    ///   - paddingLeft:    left padding
    ///   - paddingBottom:  bottom padding
    ///   - paddingRight:   right padding
    ///   - width:          set width
    ///   - height:         set height
    /// - Returns: Void
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {

        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    /// Center to superview
    ///
    /// - Parameters:
    ///   - view:      center to view
    ///   - yConstant: set y constraint
    /// - Returns: Void
    func center(inView view: UIView, xConstant: CGFloat? = 0, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: xConstant!).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }

    /// Center X to superview
    ///
    /// - Parameters:
    ///   - view:       superview
    ///   - topAnchor:  constraint to top anchor
    ///   - paddingTop: add padding top
    /// - Returns: Void
    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }

    /// Center Y to superview
    ///
    /// - Parameters:
    ///   - view:        superview
    ///   - leftAnchor:  constraint to left anchor
    ///   - paddingLeft: add padding left
    ///   - constant:    constant set to center y anchor
    /// - Returns: Void
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat? = nil, constant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false

        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant!).isActive = true

        if let leftAnchor = leftAnchor, let padding = paddingLeft {
            self.leftAnchor.constraint(equalTo: leftAnchor, constant: padding).isActive = true
        }
    }

    /// Set view dimensions
    ///
    /// - Parameters:
    ///     - width:  set width anchor
    ///     - height: set height anchor
    /// - Returns: Void
    func setDimensions(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    /// Set constaint full to superview
    ///
    /// - Parameters:
    ///   - view: superview
    /// - Returns: Void
    func addConstraintsToFillView(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        anchor(top: view.topAnchor, left: view.leftAnchor,
               bottom: view.bottomAnchor, right: view.rightAnchor)
    }

    /// Constraints by visual format.
    ///
    /// - Parameters:
    ///   - format: format
    ///   - views:  constraint in view
    /// - Returns: Void
    func addVisualFormatConstraint(format: String, views: UIView...) {
        var viewDictionaries = [String: UIView]()
        for (key, view) in views.enumerated() {
            let key = "v\(key)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDictionaries[key] = view
        }
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionaries))
    }

    /// fill superview
    /// - Returns: Void
    func fillSuperView() {
        self.superview?.addVisualFormatConstraint(format: "H:|[v0]|", views: self)
        self.superview?.addVisualFormatConstraint(format: "V:|[v0]|", views: self)
    }

}

extension UIView {
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}
