//
//  S5SmartWatchDeviceTBVCell.swift
//  1SKConnect
//
//  Created by admin on 29/12/2021.
//

import UIKit

class S5SmartWatchDeviceTBVCell: UITableViewCell, DeviceActivityTableViewCellProtocol {
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconNextImageView: UIImageView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var kcalLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var stepRecord: StepRecordModel? {
        didSet {
            guard let record = stepRecord else { return }
            self.config(with: record)
        }
    }

    weak var delegate: DeviceActivityTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.addShadow(width: 0, height: 4, color: .black, radius: 5, opacity: 0.11)
        deviceImageView.superview?.addShadow(width: 0, height: 2, color: .black, radius: 6, opacity: 0.25)
        self.selectionStyle = .none
    }
    
    func config(with data: StepRecordModel) {
        self.nameLabel.text = data.device?.name
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

    @IBAction func buttonDeviceDidTapped(_ sender: Any) {
        delegate?.onButtonDeviceDidTapped(self)
    }
}
