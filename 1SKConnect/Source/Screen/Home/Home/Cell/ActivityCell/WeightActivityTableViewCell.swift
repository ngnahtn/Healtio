//
//  WeightActivityTableViewCell.swift
//  1SKConnect
//
//  Created by tuyenvx on 07/04/2021.
//

import UIKit

class WeightActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconNextImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.addShadow(width: 0, height: 4, color: .black, radius: 5, opacity: 0.11)
        self.selectionStyle = .none
    }

    func config(with bodyFat: BodyFat?) {
        guard let `bodyFat` = bodyFat else {
            weightLabel.text = "--.-- kg"
            hourLabel.text = ""
            dateLabel.text = ""
            iconNextImageView.isHidden = true
            return
        }
        iconNextImageView.isHidden = false
        let weight = bodyFat.weight.value ?? 0
        weightLabel.text = "\(weight.toString()) kg"
        let time = bodyFat.createAt.toDate(.hmsdMy)
        hourLabel.text = time?.toString(.hm)
        dateLabel.text = time?.toString(.dmySlash)
    }
}
