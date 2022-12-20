//
//  ScaleDataHandler.swift
//  1SKConnect
//
//  Created by tuyenvx on 16/04/2021.
//

import CoreBluetooth

class SKScaleBLEDataHandler: ScaleBLEDataHandler {
    var scale: DeviceModel
    var profile: ProfileModel?
    weak var delegate: ScaleBLEDataHandlerDelegate?

    init(profile: ProfileModel?, scale: DeviceModel) {
        self.profile = profile
        self.scale = scale
    }

    func handlerData(_ data: [UInt8], of characteristic: CBCharacteristic, error: Error?) {
        guard let scaleData = SKScaleData(bytes: data) else {
            return
        }
        let weight = Double(scaleData.weight)
        switch scaleData.dataType {
        case .transmittingData:
            delegate?.updateWeight(weight)
        case .lockData:
            delegate?.updateWeight(weight)
            guard let bodyfat = caculateBodyFatData(from: CGFloat(scaleData.weight),
                                                    encryptionImpedance: scaleData.encryptionImpedance, impedance: Int(scaleData.impedance)) else {
                return
            }
            print(data)
            print(scaleData.impedance)
            print(scaleData.encryptionImpedance)

            delegate?.finishData(bodyfat)
        case .overloaded:
            delegate?.scaleDidOverload()
        default:
            break
        }
    }

    private func caculateBodyFatData(from weight: CGFloat, encryptionImpedance: Int, impedance: Int) -> BodyFat? {
        guard let currentProfile = profile,
              let height = currentProfile.height.value,
              let birthday = currentProfile.birthday?.toDate(.ymd),
              let gender = currentProfile.gender.value else {
            return nil
        }
        let hTBodyfat = HTBodyfat_NewSDK()
        let sex = gender == .male ? THTSexType.male : .female
        let age = Date().year - birthday.year

        let errorType = hTBodyfat.getBodyfatWithweightKg(weight, heightCm: CGFloat(height), sex: sex, age: age, impedance: encryptionImpedance)
        let bodyfat = BodyFat(bodyFat: hTBodyfat, hasError: errorType != .none, impedance: encryptionImpedance)
        
        let something = BodyFat(bodyFat: hTBodyfat,
                                hasError: errorType != .none,
                                impedance: encryptionImpedance,
                                encryptedImpedance: impedance,
                                weight: Double(weight),
                                height: height,
                                age: age,
                                sex: sex)
        
        something.profileID = currentProfile.id
        something.scale = scale
        return something
    }
}
