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
    
    private func getNSMutableAttributedString(for value: String, description: String) -> NSMutableAttributedString? {
        let attributeString = NSMutableAttributedString(string: value, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 16)!, NSAttributedString.Key.foregroundColor: R.color.mainColor()!])
        attributeString.append(NSAttributedString(string: description, attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!]))
        return attributeString
    }
}
