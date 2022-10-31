//
//  SportTableViewCell.swift
//  1SKConnect
//
//  Created by admin on 14/12/2021.
//

import UIKit

class SportTableViewCell: UITableViewCell {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    
    // indicators label
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var shadowLayer: CAShapeLayer?
    
    var recordModel: S5SportRecordModel? {
        didSet {
            self.configCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        drawShadow()
    }
    
    private func drawShadow() {
        DispatchQueue.main.async {
            if self.shadowLayer == nil {
                let shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, cornerRadius: 4)
                self.shadowLayer = CAShapeLayer()
                self.shadowLayer?.shadowPath = shadowPath.cgPath
                self.shadowLayer?.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.11).cgColor
                self.shadowLayer?.shadowOpacity = 0.5
                self.shadowLayer?.shadowRadius = 5
                self.shadowLayer?.shadowOffset = CGSize(width: 0, height: 4)
                self.shadowView.layer.insertSublayer(self.shadowLayer!, at: 0)
            }
        }
    }
    
    func configCell() {
        guard let record = recordModel else { return }
        self.timeLabel.text = (record.duration / 60).stringValue + " " + R.string.localizable.minute()
        self.stepLabel.text = record.step.stringValue + " " + R.string.localizable.smart_watch_s5_step()
        self.distanceLabel.text = (Double(record.distance) / 1000).toString() + " km"
        self.kcalLabel.text = record.calories.stringValue + " kcal"
        let startTime = record.dateTime.toDate(.ymdhm) ?? Date()
        let endTimestamp = startTime.timeIntervalSince1970 + Double(record.duration)
        self.dateLabel.text = startTime.toString(.hm) + " - " + endTimestamp.toDate().toString(.hm)
    
        self.stepLabel.isHidden = (record.type == .climb || record.type == .ride) ? true : false
        self.distanceLabel.isHidden = (record.type == .climb || record.type == .ride) ? true : false

        if record.type == .run {
            self.typeLabel.text = R.string.localizable.s5_sport_type_run()
            self.typeImageView.image = R.image.ic_s5_run()
        }
        if record.type == .walk {
            self.typeLabel.text = R.string.localizable.s5_sport_type_walk()
            self.typeImageView.image = R.image.ic_s5_walk()
        }
        if record.type == .ride {
            self.typeLabel.text = R.string.localizable.s5_sport_type_bike()
            self.typeImageView.image = R.image.ic_s5_bike()
        }
        if record.type == .climb {
            self.typeImageView.image = R.image.ic_s5_climb()
            self.typeLabel.text = R.string.localizable.s5_sport_type_climb()
        }
    }
}
