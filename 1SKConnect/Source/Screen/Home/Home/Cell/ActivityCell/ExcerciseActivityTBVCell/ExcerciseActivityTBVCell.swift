//
//  ExcerciseActivityTBVCell.swift
//  1SKConnect
//
//  Created by admin on 28/12/2021.
//

import UIKit
import TrusangBluetooth

class ExcerciseActivityTBVCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var excerciseImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconNextImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.addShadow(width: 0, height: 4, color: .black, radius: 5, opacity: 0.11)
        self.selectionStyle = .none
    }
    
    func config(with sportData: S5SportRecordModel?) {
        guard let `sportData` = sportData else {
            distanceLabel.text = "-- km"
            dateLabel.text = ""
            self.timeLabel.text = "--:--:--"
            self.speedLabel.text = "-- km/h"
            iconNextImageView.isHidden = true
            return
        }
        self.iconNextImageView.isHidden = false
        if sportData.type == .walk {
            self.typeLabel.text = R.string.localizable.s5_sport_type_walk()
            self.excerciseImageView.image = R.image.ic_s5_walk()
        } else if sportData.type == .run {
            self.typeLabel.text = R.string.localizable.s5_sport_type_run()
            self.excerciseImageView.image = R.image.ic_s5_run()
        } else if sportData.type == .ride {
            self.typeLabel.text = R.string.localizable.s5_sport_type_bike()
            self.excerciseImageView.image = R.image.ic_s5_bike()
        } else if sportData.type == .climb {
            self.excerciseImageView.image = R.image.ic_s5_climb()
            self.typeLabel.text = R.string.localizable.s5_sport_type_climb()
        }

        let distance = (Double(sportData.distance) / 1000)
        if distance == 0 {
            distanceLabel.text = "-- km"
        } else {
            distanceLabel.text = distance.toString() + " km"
        }
        
        dateLabel.text = sportData.dateTime.toDate(.ymdhm)?.toString(.hmdmy) ?? ""
        
        let duration = sportData.duration
        if duration == 0 {
            self.timeLabel.text = "--:--"
        } else {
            self.timeLabel.text = Double(duration).toHourMinuteSecondString()
        }

        let speed = Double(sportData.distance) / Double(sportData.duration) * 3.6
        var speedString = ""
        if speed == 0 || speed.isNaN {
            speedString = "--"
        } else {
            speedString = speed.toString()
        }

        self.speedLabel.text = speedString + " km/h"
    }
}
