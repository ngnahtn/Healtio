//
//  SyntheticCategoriesTableViewCell.swift
//  1SKConnect
//
//  Created by Be More on 10/12/2021.
//

import UIKit

class SyntheticCategoriesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    
    var model: SyntheticCategories? {
        didSet {
            self.setData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension SyntheticCategoriesTableViewCell {
    private func setData() {
        guard let model = self.model else { return }
        self.titleLabel.text = model.title
        self.iconImageView.image = model.image
        self.bottomLineView.isHidden = model.type == .sleep
        switch model.type {
        case .step:
            self.detailLabel.attributedText = self.getNSMutableAttributedString(for: model.value, description: " " + R.string.localizable.smart_watch_s5_step_per_day())
        case .calo:
            self.detailLabel.attributedText = self.getNSMutableAttributedString(for: model.value, description: " " + R.string.localizable.kcalPerDay())
        case .hr:
            self.detailLabel.attributedText = self.getNSMutableAttributedString(for: model.value, description: " bpm")
        case .spO2:
            self.detailLabel.attributedText = self.getNSMutableAttributedString(for: model.value, description: " %")
        case .bp:
            self.detailLabel.attributedText = self.getNSMutableAttributedString(for: model.value, description: " mmHg")
        case .temp:
            self.detailLabel.attributedText = self.getNSMutableAttributedString(for: model.value, description: " ºC")
        case .sleep:
            self.detailLabel.attributedText = self.getSleepNSMutableAttributedString(for: model.value)
        case .run:
            if String.isNilOrEmpty(model.value) || model.value == "-" {
                self.titleLabel.text = R.string.localizable.smart_watch_s5_run_times(model.title)
                let value = String.isNilOrEmpty(model.value) ? "-" : model.value
                self.detailLabel.attributedText = self.getNSMutableAttributedString(for: value, description: " km")
            } else {
                let delimiter = "-"
                let newstr = model.value
                let token = newstr.components(separatedBy: delimiter)
                self.titleLabel.text = R.string.localizable.smart_watch_s5_run_times(token[0])
                self.detailLabel.attributedText = self.getNSMutableAttributedString(for: token[1], description: " km")
            }
        }
    }
    
    /// Get NSMutableAttributedString text
    /// - Parameters:
    ///   - value: value string
    ///   - description: description string
    /// - Returns: a string with format `description value`
    private func getNSMutableAttributedString(for value: String, description: String) -> NSMutableAttributedString? {
        let attributeString = NSMutableAttributedString(string: value, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.title()!])
        attributeString.append(NSAttributedString(string: description, attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!]))
        return attributeString
    }

    /// Get SleepNSMutableAttributedString text
    /// - Parameters:
    ///   - value: value string
    ///   - description: description string
    /// - Returns: a string with format `description value`
    private func getSleepNSMutableAttributedString(for value: String) -> NSMutableAttributedString? {
        if let intVaue = Int(value) {
        let attributeString = NSMutableAttributedString(string: intVaue.hourValue.stringValue, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.title()!])
        attributeString.append(NSAttributedString(string: " " + R.string.localizable.hour(), attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!]))
        attributeString.append(NSAttributedString(string: " " + intVaue.minuteValue.checkMinuteValueToString(), attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.title()!]))
        attributeString.append(NSAttributedString(string: " " + R.string.localizable.minute() + " " + R.string.localizable.smart_watch_s5_avg_per_day(), attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!]))
            return attributeString
        } else {
            let attributeString = NSMutableAttributedString(string: "--", attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.title()!])
            attributeString.append(NSAttributedString(string: " " + R.string.localizable.hour(), attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!]))
            attributeString.append(NSAttributedString(string: " " + "--", attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.title()!]))
            attributeString.append(NSAttributedString(string: " " + R.string.localizable.minute(), attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 14)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!]))
                return attributeString
        }
    }
}
