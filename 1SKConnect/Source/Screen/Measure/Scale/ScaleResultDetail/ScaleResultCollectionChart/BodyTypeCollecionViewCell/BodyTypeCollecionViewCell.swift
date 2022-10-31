//
//  BodyTypeCollecionViewCell.swift
//  1SKConnect
//
//  Created by Elcom Corp on 05/11/2021.
//

import UIKit
import SwiftUI

class BodyTypeCollecionViewCell: UICollectionViewCell {
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var valueLabel: UILabel!

    var dataSource: BodyTypeModel? {
        didSet {
            self.setData()
        }
    }

    override var isSelected: Bool {
        didSet {
            self.setSelected(isSelected: self.isSelected)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

// MARK: Helpers
extension BodyTypeCollecionViewCell {
    func setData() {
        guard let model = self.dataSource else {
            return
        }
        self.valueLabel.text = model.title
        self.setSelected(isSelected: model.isSelected)
    }

    func setSelected(isSelected: Bool) {
        self.viewContent.backgroundColor = isSelected ? UIColor(hex: "#00C2C5") : UIColor(hex: "#F0F0F0")
        self.valueLabel.font = isSelected ? R.font.robotoMedium(size: 14) : R.font.robotoRegular(size: 14)
        self.valueLabel.textColor = isSelected ? .white : R.color.title()
    }
}
