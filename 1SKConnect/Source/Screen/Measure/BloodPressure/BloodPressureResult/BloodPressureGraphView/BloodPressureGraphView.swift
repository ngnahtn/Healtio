//
//  GraphsView.swift
//  ProjectForTesting
//
//  Created by admin on 17/11/2021.
//

import UIKit

class BloodPressureGraphView: UIView {
    @IBOutlet weak var pointTrailingContrant: NSLayoutConstraint!
    @IBOutlet weak var pointTopContrant: NSLayoutConstraint!

    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var ograngeView: UIView!
    @IBOutlet weak var pinkView: UIView!
    @IBOutlet weak var pointView: UIView!
    @IBOutlet weak var view_Circle: UIView!
    @IBOutlet var views: [UIView]!
    var isDataNil = false {
        didSet {
            if isDataNil == true {
                self.pointView.isHidden = true
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
// MARK: - SetupView
    func setUpView() {
        guard let view = self.loadViewFromNib(nibName: "BloodPressureGraphView") else {return}
        view.frame = self.bounds
        self.addSubview(view)
        for item in views {
            item.layer.maskedCorners = [.layerMaxXMinYCorner]
        }
        self.pointView.addShadow(width: 0, height: 2, color: .black, radius: 15, opacity: 0.56)
    }

    // MARK: - Helpers
    /// Set x and y anchor for pointView
    /// - Parameters:
    ///   - xValue: value of X 
    ///   - yValue: value of Y
    func setContraintForPointView(xValue: CGFloat, yValue: CGFloat) {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0

        self.pointTopContrant.isActive = false
        self.pointTrailingContrant.isActive = false

        switch xValue {
        case 0...40:
            self.pointTrailingContrant = self.pointView.trailingAnchor.constraint(equalTo: self.blueView.leadingAnchor, constant: CGFloat(10))
        case 41...60:
            x = xValue - 40
            width = blueView.frame.width
            self.pointTrailingContrant = self.pointView.trailingAnchor.constraint(equalTo: self.blueView.leadingAnchor, constant: (10 + (width/20)*x))
        case 61...80:
            x = xValue - 60
            width = greenView.frame.width - blueView.frame.width
            self.pointTrailingContrant = self.pointView.trailingAnchor.constraint(equalTo: self.blueView.trailingAnchor, constant: (10 + (width/20)*x))
        case 81...90:
            x = xValue - 80
            width = yellowView.frame.width - greenView.frame.width
            self.pointTrailingContrant = self.pointView.trailingAnchor.constraint(equalTo: self.greenView.trailingAnchor, constant: (10 + (width/10)*x))
        case 91...100:
            x = xValue - 90
            width = ograngeView.frame.width - yellowView.frame.width
            self.pointTrailingContrant = self.pointView.trailingAnchor.constraint(equalTo: self.yellowView.trailingAnchor, constant: (10 + (width/10)*x))
        case 101...120:
            x = xValue - 100
            width = pinkView.frame.width - ograngeView.frame.width
            self.pointTrailingContrant = self.pointView.trailingAnchor.constraint(equalTo: self.ograngeView.trailingAnchor, constant: (10 + (width/20)*x))
        default:
            self.pointTrailingContrant = self.pointView.trailingAnchor.constraint(equalTo: self.pinkView.trailingAnchor, constant: (10))
        }

        switch yValue {
        case 0...40:
            self.pointTopContrant = self.pointView.topAnchor.constraint(equalTo: self.blueView.bottomAnchor, constant: (-10))
        case 40...90:
            y = yValue - 40
            height = blueView.frame.height
            self.pointTopContrant = self.pointView.topAnchor.constraint(equalTo: self.blueView.bottomAnchor, constant: (-10 - (height/50)*y))
        case 91...120:
            y = yValue - 90
            height = greenView.frame.height - blueView.frame.height
            self.pointTopContrant = self.pointView.topAnchor.constraint(equalTo: self.blueView.topAnchor, constant: (-10 - (height/30)*y))
        case 121...140:
            y = yValue - 120
            height = yellowView.frame.height - greenView.frame.height
            self.pointTopContrant = self.pointView.topAnchor.constraint(equalTo: self.greenView.topAnchor, constant: (-10 - (height/20)*y))
        case 141...160:
            y = yValue - 140
            height = ograngeView.frame.height - yellowView.frame.height
            self.pointTopContrant = self.pointView.topAnchor.constraint(equalTo: self.yellowView.topAnchor, constant: (-10 - (height/20)*y))
        case 161...180:
            y = yValue - 160
            height = pinkView.frame.height - ograngeView.frame.height
            self.pointTopContrant = self.pointView.topAnchor.constraint(equalTo: self.ograngeView.topAnchor, constant: (-10 - (height/20)*y))
        default:
            self.pointTopContrant = self.pointView.topAnchor.constraint(equalTo: self.pinkView.topAnchor, constant: (-10))
        }
        self.pointTopContrant.isActive = true
        self.pointTrailingContrant.isActive = true
        self.pointView.layoutIfNeeded()
    }

}
