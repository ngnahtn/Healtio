//
//  DeviceCollectionViewCell.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//

import UIKit
import TrusangBluetooth

class DeviceCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layoutIfNeeded()
        let shadowView = deviceImageView.superview?.superview
        shadowView?.layer.cornerRadius = 20
        shadowView?.layer.masksToBounds = false
        shadowView?.addShadow(width: 0, height: 6, color: .black, radius: 12, opacity: 0.11)
    }
    
    

    func config(with device: DeviceModel) {
        switch device.type {
        case .scale:
            nameLabel.text = "1SK - CF398 - \(device.mac.suffix(4).pairs.joined(separator: ":"))"
        case .spO2:
            nameLabel.text = "Vivatom - \(device.name) - \(device.mac.suffix(4).pairs.joined(separator: ":"))"
        case .biolightBloodPressure:
            nameLabel.text = "BioLight - WBP202 - \(device.mac.suffix(4).pairs.joined(separator: ":"))"
        case .smartWatchS5:
            nameLabel.text = device.name
        }
        deviceImageView.setImage(device.image, placeHolder: R.image.scales())
        var isConnect = BluetoothManager.shared.isConnect(with: device)
        
        if !BluetoothManager.shared.checkBluetoothStatusAvailble() {
            isConnect = false
        } else {
            if device.type == .smartWatchS5 {
                isConnect = ZHJBLEManagerProvider.shared.deviceState == .connected || ZHJBLEManagerProvider.shared.deviceState == .connecting
            } else {
                isConnect = BluetoothManager.shared.isConnect(with: device)
            }
        }
        
        statusView.backgroundColor = isConnect ? R.color.active() : R.color.disable()
    }
}
