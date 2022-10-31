//
//  WeightDetailsCollectionViewCell.swift
//  SK365
//
//  Created by tuyenvx on 6/12/20.
//  Copyright © 2020 Elcom. All rights reserved.
//

import UIKit

class WeightDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var itemTypeLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var statusView: UIView!
    @IBOutlet private weak var statusLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func config(with item: DetailsItemProtocol) {
        itemTypeLabel.text = item.title
        switch item {
        case is BodyType:
            let bodyType = BodyType(rawValue: Int(item.value))
            valueLabel.text = bodyType?.stringValue
        default:
            valueLabel.text = item.value.toString()
        }
        statusView.backgroundColor = item.color
        statusLabel.text = item.status
    }
}
