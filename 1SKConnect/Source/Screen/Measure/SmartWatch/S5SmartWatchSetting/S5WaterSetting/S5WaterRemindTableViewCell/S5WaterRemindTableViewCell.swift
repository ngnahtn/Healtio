//
//  S5WaterRemindTableViewCell.swift
//  1SKConnect
//
//  Created by TrungDN on 09/02/2022.
//

import UIKit
import TrusangBluetooth

class S5WaterRemindTableViewCell: UITableViewCell {
    
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var model: ZHJTime? {
        didSet {
            self.setData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setData() {
        guard let model = model else {
            return
        }
        self.timeLabel.text = "\(model.hour):\(model.minute)"
    }
}
