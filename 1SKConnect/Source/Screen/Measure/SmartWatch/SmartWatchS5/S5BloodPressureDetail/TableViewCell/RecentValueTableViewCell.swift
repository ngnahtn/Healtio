//
//  RecentValueTableViewCell.swift
//  1SKConnect
//
//  Created by admin on 25/01/2023.
//

import UIKit

class RecentValueTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func fetchData(with record: BloodPressureDetailModel?) {
        guard let data = record else {
            self.valueLabel.attributedText = self.getNSMutableAttributedString(for: "--/-- ", description: "mmHg")
            self.stateLabel.text = "--"
            return
        }
        
        self.valueLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.sbp)/\(data.dbp) ", description: "mmHg")
        self.stateLabel.text = data.state.title
    }
    
    func fetchSpO2Data(with record: S5SpO2DetailModel?) {
        guard let data = record else {
            self.valueLabel.attributedText = self.getNSMutableAttributedString(for: "-- %", description: "")
            self.stateLabel.text = "--"
            return
        }
        
        self.valueLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.bO) %", description: "")
        self.stateLabel.text = data.state.status
    }
    
    func fetchHrData(with detail: S5HeartRateDetailModel?) {
        guard let data = detail else {
            self.valueLabel.attributedText = self.getNSMutableAttributedString(for: "-- ", description: "bpm")
            self.stateLabel.text = "--"
            return
        }
        self.valueLabel.attributedText = self.getNSMutableAttributedString(for: "\(data.heartRate) ", description: "bpm")
        self.stateLabel.text = data.state.status
    }
    
    private func getNSMutableAttributedString(for value: String, description: String) -> NSMutableAttributedString? {
        let attributeString = NSMutableAttributedString(string: value, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 16)!, NSAttributedString.Key.foregroundColor: R.color.mainColor()!])
        attributeString.append(NSAttributedString(string: description, attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!]))
        return attributeString
    }
}

