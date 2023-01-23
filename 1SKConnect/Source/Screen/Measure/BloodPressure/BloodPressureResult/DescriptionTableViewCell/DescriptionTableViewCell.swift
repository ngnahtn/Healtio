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
}
