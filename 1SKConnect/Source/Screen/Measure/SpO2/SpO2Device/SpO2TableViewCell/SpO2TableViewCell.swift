//
//  SpO2TableViewCell.swift
//  1SKConnect
//
//  Created by Be More on 16/09/2021.
//

import UIKit

class SpO2TableViewCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var spO2ValueLabel: UILabel!
    @IBOutlet weak var prValueLabel: UILabel!

    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var shadowLayer: CAShapeLayer?
    var model: WaveformListModel? {
        didSet {
            self.setupData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
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
    }
}

extension SpO2TableViewCell {
    /// Set table view data/
    func setupData() {
        guard let model = self.model else { return }
        if !model.waveforms.array.isEmpty {
            self.spO2ValueLabel.text = model.waveforms.array.last?.spO2Value.value?.stringValue
            self.prValueLabel.text = model.waveforms.array.last?.prValue.value?.stringValue
            self.statusLabel.text = model.spO2Status.title
            self.statusLabel.textColor = model.spO2Status.color

            let startDate = model.startTime.toDate()
            let endDate = model.endTime.toDate()
            if startDate.isSameDay(with: endDate) {
                self.timeLabel.text = "\(startDate.toString(.hm)) - \(endDate.toString(.hm))"
                self.dateLabel.text = endDate.toString(.dmyColon)
            } else {
                self.timeLabel.text = startDate.toString(.hmdmy)
                self.dateLabel.text = endDate.toString(.hmdmy)
            }
        }

    }
}
