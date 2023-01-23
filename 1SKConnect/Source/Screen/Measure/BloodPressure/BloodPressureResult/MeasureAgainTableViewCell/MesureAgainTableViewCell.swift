//
//  MesureAgainTableViewCell.swift
//  1SKConnect
//
//  Created by admin on 24/01/2023.
//

import UIKit

protocol MesureAgainTableViewCellDelegate: AnyObject {
    func doAgainButtonDidTap()
}
class MesureAgainTableViewCell: UITableViewCell {

    weak var delegate: MesureAgainTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    @IBAction func doAgainButtonDidTap(_ sender: UIButton) {
        self.delegate?.doAgainButtonDidTap()
    }
    
}
