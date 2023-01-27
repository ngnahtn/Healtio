//
//  DescriptionTableViewCell.swift
//  1SKConnect
//
//  Created by admin on 23/01/2023.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descripLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func config(with data: VitalSignsDescriptionModel) {
        self.titleLabel.text = data.title
        self.descripLabel.text = data.des
    }
    
    func configHrDescription(with data: VitalSignsDescriptionModel, and valueString: String) {
        self.descripLabel.text = data.des
        self.titleLabel.attributedText = self.getNSMutableAttributedString(for: valueString, description: data.title)
    }
    
    private func getNSMutableAttributedString(for value: String, description: String) -> NSMutableAttributedString? {
        let attributeString = NSMutableAttributedString(string: description, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 16)!, NSAttributedString.Key.foregroundColor: R.color.title()!])
        attributeString.append(NSAttributedString(string: value, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 16)!, NSAttributedString.Key.foregroundColor: R.color.mainColor()!]))
        attributeString.append(NSAttributedString(string: " bpm", attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!]))
        return attributeString
    }
}
