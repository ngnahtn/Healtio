//
//  BaseDevice.swift
//  1SKConnect
//
//  Created by Be More on 21/11/2021.
//

import Foundation
import CoreBluetooth

class BaseDevice {
    var name: String = ""
    var mac: String = ""
    var type: DeviceType = .scale
    var imageData: Data?

    var image: UIImage? {
        guard let `imageData` = imageData else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
