//
//  DeviceTableViewCell.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//

import UIKit
import TrusangBluetooth

protocol DeviceTableViewCellDelegate: AnyObject {
    func tableView(unlinkDeviceAt cell: DeviceTableViewCell)
}

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unLinkImageView: UIImageView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var macLabel: UILabel!

    @IBOutlet weak var nameImageViewLeadingConstraint: NSLayoutConstraint!
    
    weak var delegate: DeviceTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.unLinkImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleUnlinkDevice(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func handleUnlinkDevice(_ sender: UITapGestureRecognizer) {
        self.delegate?.tableView(unlinkDeviceAt: self)
    }

    func config(with device: DeviceModel?, isOtherDevice: Bool = false, isShowBottomLine: Bool = true) {
        guard let `device` = device else {
            return
        }
        switch device.type {
        case .scale:
            nameLabel.text = "Smart scale - 1SK - CF398"
        case .spO2:
            nameLabel.text = "SpO2 monitor - Vivatom - \(device.name)"
        case .biolightBloodPressure:
            nameLabel.text = "BioLight - WBP202 - \(device.mac.suffix(4).pairs.joined(separator: ":"))"
        case .smartWatchS5:
            nameLabel.text = device.name
        }

        var isConnect = BluetoothManager.shared.isConnect(with: device)
        if device.type == .smartWatchS5 {
            isConnect = ZHJBLEManagerProvider.shared.deviceState == .connected || ZHJBLEManagerProvider.shared.deviceState == .connecting
        } else {
            isConnect = BluetoothManager.shared.isConnect(with: device)
        }

        statusView.backgroundColor = isConnect ? .green : .lightGray
        statusView.isHidden = isOtherDevice
        unLinkImageView.superview?.isHidden = isOtherDevice
        nameImageViewLeadingConstraint.constant = isOtherDevice ? 16 : 33
        bottomLine.isHidden = !isShowBottomLine
        let mac = String(device.mac.suffix(12))
        macLabel.text = mac.pairs.joined(separator: ":")
    }
}
