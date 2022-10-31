//
//  SKTimeFilterView.swift
//  1SKConnect
//
//  Created by admin on 16/12/2021.
//

import UIKit

class SKTimeFilterView: UIView {
    var currentType: TimeFilterType = .day
    var defaultType: TimeFilterType = .day {
        didSet {
            self.setUpDefault(self.defaultType)
        }
    }
    @IBOutlet var timeTypeButtons: [UIButton]!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet var typeLabels: [UILabel]!
    var currentLabel = UILabel() {
        didSet {
            self.currentLabel.textColor = .white
            for item in typeLabels where item != currentLabel {
                item.textColor = R.color.subTitle()
            }
        }
    }
    var currentButtonPressed = UIButton() {
        didSet {
            switch currentButtonPressed {
            case dayButton:
                self.currentType = .day
                self.currentLabel = dayLabel
            case weekButton:
                self.currentType = .week
                self.currentLabel = weekLabel
            case monthButton:
                self.currentType = .month
                self.currentLabel = monthLabel
            default:
                self.currentType = .year
                self.currentLabel = yearLabel
            }
            delegate?.filterTypeDidSelected(self.currentType)
        }
    }
    
    weak var delegate: TimeFilterViewDelegate?
    
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
        guard let view = self.loadViewFromNib(nibName: "SKTimeFilterView") else {return}
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func setUpDefault(_ timeType: TimeFilterType) {
        var defaultButton = UIButton()
        if timeType == .day {
            defaultButton = self.dayButton
            self.currentLabel = self.dayLabel
        } else {
            defaultButton = self.weekButton
            self.currentLabel = self.weekLabel
        }
        defaultButton.isUserInteractionEnabled = false
        defaultButton.backgroundColor = R.color.subTitle()
        for item in self.timeTypeButtons where item != defaultButton {
            DispatchQueue.main.async {
                item.isUserInteractionEnabled = true
                item.titleLabel?.textColor = R.color.subTitle()
                item.backgroundColor = .clear
            }
        }
    }

// MARK: - Actions
    @IBAction func handleTimeButtonPressed(_ sender: UIButton) {
        self.currentButtonPressed = sender
        for item in self.timeTypeButtons {
            item.isUserInteractionEnabled = (item == sender) ? false : true
            UIView.animate(withDuration: Constant.Number.animationTime) {
                item.backgroundColor = (item == sender) ? R.color.subTitle() : .clear
            }
        }
    }
}
