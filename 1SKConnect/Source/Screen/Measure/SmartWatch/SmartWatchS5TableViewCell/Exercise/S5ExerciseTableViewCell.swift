//
//  S5ExerciseTableViewCell.swift
//  1SKConnect
//
//  Created by TrungDN on 07/12/2021.
//

import UIKit
import MBCircularProgressBar

protocol S5ExerciseTableViewCellDelegate: AnyObject {
    func menu(isOpen: Bool)
    func onChartDetailDidPressed(_ celltype: CellType)
}

class S5ExerciseTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var chartDetailView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stepTimeLabel: UILabel!
    @IBOutlet weak var exerciseTimeLabel: UILabel!
    
    @IBOutlet weak var progressView: MBCircularProgressBarView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var menuView: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!
    var isOpen = true
    weak var delegate: S5ExerciseTableViewCellDelegate?
    
    var shadowLayer: CAShapeLayer?
    
    var model: S5Exercise? {
        didSet {
            self.setData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.dateLabel.text = Date().toString(.hmdmy)
        DispatchQueue.main.async {
            if self.shadowLayer == nil {
                let shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, cornerRadius: 4)
                self.shadowLayer = CAShapeLayer()
                self.shadowLayer?.shadowPath = shadowPath.cgPath
                self.shadowLayer?.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.11).cgColor
                self.shadowLayer?.shadowOpacity = 1
                self.shadowLayer?.shadowRadius = 5
                self.shadowLayer?.shadowOffset = CGSize(width: 0, height: 4)
                self.shadowView.layer.insertSublayer(self.shadowLayer!, at: 0)
            }
        }
        [menuView, menuImageView].forEach { $0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowMenu))) }
        [chartDetailView, dateLabel].forEach { $0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageViewDidTap))) }
    }

    @objc func handleImageViewDidTap() {
        delegate?.onChartDetailDidPressed(.exercise)
    }
}

// MARK: - Helpers
extension S5ExerciseTableViewCell {
    private func setData() {
        guard let model = self.model else { return }
        if model.duration != 0 {
            self.stepTimeLabel.text = Double(model.duration).toHourMinuteString()
        }
        if model.sportDuration != 0 {
            self.exerciseTimeLabel.text = Double(model.sportDuration).toHourMinuteString()
        }
        let step = model.step > model.stepGoal ? model.stepGoal : model.step
        
        self.progressView.value = CGFloat(step)
        self.progressView.maxValue = CGFloat(model.stepGoal)
        self.progressView.layoutSubviews()

        self.stepLabel.text = model.step.formattedWithSeparator

        var percent = Double(model.step) / Double(model.stepGoal) * 100
        
        if percent.isInfinite || percent.isNaN {
            percent = 0
        }

        var percentString = percent.roundTo(0).toString()
        if percentString.prefix(1) == "." {
            percentString = "0" + percentString
        }
        self.percentageLabel.text = "\(percentString)%"
        self.kcalLabel.text = model.kcal.roundTo(0).toString() + " kcal"
        self.distanceLabel.text = model.distance.toString() + " km"
        self.heartRateLabel.text = model.heartRate.stringValue + " bmp"
    }
    
    private func secondsToHoursMinutes(_ seconds: Int) -> (Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60)
    }

    @objc private func handleShowMenu() {
        self.isOpen = !isOpen
        self.menuView.text = isOpen ? R.string.localizable.smart_watch_s5_collapse() : R.string.localizable.smart_watch_s5_expand()
        self.menuImageView.image = isOpen ? R.image.ic_drop_up() : R.image.ic_drop_down()
        self.delegate?.menu(isOpen: isOpen)
    }
}
