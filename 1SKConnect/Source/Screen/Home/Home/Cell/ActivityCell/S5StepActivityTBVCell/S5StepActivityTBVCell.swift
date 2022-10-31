//
//  S5StepActivityTBVCell.swift
//  1SKConnect
//
//  Created by admin on 11/01/2022.
//

import UIKit

class S5StepActivityTBVCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var excerciseImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconNextImageView: UIImageView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!

    var stepRecord: StepRecordModel? {
        didSet {
            guard let record = stepRecord else { return }
            self.config(with: record)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.addShadow(width: 0, height: 4, color: .black, radius: 5, opacity: 0.11)
        self.selectionStyle = .none
    }
    
    func config(with data: StepRecordModel) {
        self.iconNextImageView.isHidden = false
        let date = data.dateTime.toDate(.ymd) ?? Date()
        let dateStr = date.toString(.dmySlash)
        self.dateLabel.text = dateStr
        self.stepLabel.text = data.totalStep.formattedWithSeparator
        self.kcalLabel.text = data.totalCalories.roundTo(0).toString() + " kcal"
        self.distanceLabel.text = (data.totalDistance / 1000).toString() + " km"
        if data.duration != 0 {
            self.timeLabel.text = Double(data.duration).toHourMinuteSecondString()
        }
    }
}
