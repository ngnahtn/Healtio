//
//  MeasurementCollectionViewCell.swift
//  1SKConnect
//
//  Created by Be More on 23/08/2021.
//

import UIKit

class MeasurementCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var measureLabel: UILabel!

    var model: WeightMeasurementValue? {
        didSet {
            self.setUpdata()
        }
    }

    override var isSelected: Bool {
        didSet {
            self.isSelected ? self.setSelected() : self.setUnselected()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

// MARK: - Heplers
extension MeasurementCollectionViewCell {

    private func setUpdata() {
        guard let model = self.model else {
            return
        }
        self.measureLabel.text = model.title
    }

    private func setSelected() {
        guard self.model != nil else {
            self.viewContent.backgroundColor = R.color.idealWeightColor()
            self.measureLabel.font = R.font.robotoMedium(size: 12)
            measureLabel.textColor = .white
            viewContent.layer.borderWidth = 0
            return
        }
        self.measureLabel.font = R.font.robotoMedium(size: 12)
        measureLabel.textColor = .white
        viewContent.layer.borderWidth = 0
        self.viewContent.backgroundColor = R.color.idealWeightColor()
    }

    private func setUnselected() {
        viewContent.layer.borderWidth = 1
        viewContent.layer.borderColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1).cgColor
        measureLabel.font = R.font.robotoRegular(size: 12)
        measureLabel.textColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1)
        self.viewContent.backgroundColor = .white
    }

}
