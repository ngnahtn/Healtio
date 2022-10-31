//
//  ScaleActivityTableViewCell.swift
//  1SKConnect
//
//  Created by tuyenvx on 07/04/2021.
//

import UIKit

class ScaleActivityTableViewCell: UITableViewCell, DeviceActivityTableViewCellProtocol {

    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconNextImageView: UIImageView!
    weak var delegate: DeviceActivityTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.addShadow(width: 0, height: 4, color: .black, radius: 5, opacity: 0.11)
        deviceImageView.superview?.addShadow(width: 0, height: 2, color: .black, radius: 6, opacity: 0.25)
    }

    func config(with bodyFat: BodyFat?) {
        guard let `bodyFat` = bodyFat else {
            deviceImageView.image = R.image.scales()
            weightLabel.text = "--.-- kg"
            hourLabel.text = ""
            dateLabel.text = ""
            nameLabel.text = ""
            iconNextImageView.isHidden = true
            return
        }
        deviceImageView.setImage(bodyFat.deviceImage, placeHolder: R.image.scales())
        iconNextImageView.isHidden = bodyFat.weight.value == nil
        nameLabel.text = "1SK - CF398 - \(bodyFat.deviceMac?.suffix(4).pairs.joined(separator: ":") ?? "")"
        let weightString = bodyFat.weight.value?.toString() ?? "--.--"
        weightLabel.text = "\(weightString) kg"
        let time = bodyFat.createAt.toDate(.hmsdMy)
        hourLabel.text = time?.toString(.hm) ?? ""
        dateLabel.text = time?.toString(.dmySlash) ?? ""

    }

    @IBAction func buttonDeviceDidTapped(_ sender: Any) {
        delegate?.onButtonDeviceDidTapped(self)
    }
}
