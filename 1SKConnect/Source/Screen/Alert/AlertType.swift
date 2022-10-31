//
//  AlertType.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//

import Foundation

enum AlertType {
    case turnOnBluetooth
    case unLinkDevice(_ device: DeviceModel)
    case deleteProfile
    case unlinkAccount

    var bottomViewHeight: CGFloat {
        switch self {
        case .turnOnBluetooth:
            return 230
        case .unLinkDevice, .unlinkAccount:
            return 240
        case .deleteProfile:
            return 212
        }
    }

    var image: UIImage? {
        switch self {
        case .turnOnBluetooth:
            return R.image.ic_phone_ble()
        case .unLinkDevice, .unlinkAccount:
            return R.image.ic_unlink()
        case .deleteProfile:
            return R.image.ic_delete_2()
        }
    }

    var cancelButtonTitle: String {
        switch self {
        case .turnOnBluetooth:
            return L.close.localized
        case .unLinkDevice, .deleteProfile:
            return L.no.localized
        case .unlinkAccount:
            return R.string.localizable.alert_cancel()
        }
    }

    var okButtonTitle: String {
        switch self {
        case .turnOnBluetooth:
            return L.update.localized
        case .unLinkDevice:
            return L.unlinkDeviceConfirm.localized
        case .deleteProfile:
            return L.deleteProfileConfirm.localized
        case .unlinkAccount:
            return R.string.localizable.agree()
        }
    }

    var content: String {
        switch self {
        case .turnOnBluetooth:
            return L.turnOnBluetoothMessage.localized
        case .unLinkDevice:
            return L.unlinkDeviceConfirmMessage.localized
        case .deleteProfile:
            return L.deleteProfileConfirmMessage.localized
        case .unlinkAccount:
            return R.string.localizable.alert_message_unlink()
        }
    }
}
