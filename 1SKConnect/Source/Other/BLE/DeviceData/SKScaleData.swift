//
//  SKScaleData.swift
//  1SKConnect
//
//  Created by TrungDN on 22/03/2021.
//

import Foundation

// MARK: - SKScaleData
struct SKScaleData: CustomStringConvertible {
    var deviceType: String // CF: BodyFat, CE: Bathroom, CB: Baby, CA: Kitchen
    var impedance: Float
    var weight: Float
    var encryptionImpedance: Int
    var currentUnit: WeightUnit
    var dataType: DataType

    init?(bytes: [UInt8]) {
        guard bytes.count == 11,
              SKScaleData.calculateChecksum(from: bytes) == bytes[10] else {
            return nil
        }
        self.deviceType = bytes[0].hexString()
        self.impedance = Float(Array(bytes[1...2]).intValue(isLittleEndian: true)) / 10
        let unitHex = bytes[8].hexString()
        self.currentUnit = WeightUnit(rawValue: unitHex) ?? .kg
        switch currentUnit {
        case .g:
            self.weight = Float(Array(bytes[3...4]).intValue(isLittleEndian: true)) / 1000
        default:
            self.weight = Float(Array(bytes[3...4]).intValue(isLittleEndian: true)) / 100
        }
        self.encryptionImpedance = Array(bytes[5...7]).intValue(isLittleEndian: true)
        let dataTypeHex = bytes[9].hexString()
        self.dataType = DataType(rawValue: dataTypeHex) ?? .transmittingData
    }

    static func calculateChecksum(from bytes: [UInt8]) -> UInt8 {
        var checksum: UInt8 = 0
        for (index, byte) in bytes.enumerated() where index != 10 {
            checksum = checksum ^ byte
        }
        return checksum
    }

    func getBodyFatData(with height: Float, age: Int, gender: Int) -> HTBodyfat_NewSDK? {
        let bodyFat = HTBodyfat_NewSDK()

        let errorType = bodyFat.getBodyfatWithweightKg(CGFloat((weight)),
                                                       heightCm: CGFloat(height),
                                                       sex: gender == 0 ? .male : .female,
                                                       age: age,
                                                       impedance: encryptionImpedance)
        guard errorType == .none else {
            return nil
        }
        bodyFat.thtBoneKg = (bodyFat.thtBoneKg * 100 + 5) / 100
        bodyFat.thtMuscleKg = (bodyFat.thtMuscleKg * 100 + 5) / 100
        return bodyFat
    }

    func weightOfCurrentUnit() -> Float {
        switch currentUnit {
        case .kg: // kg
            return weight
        case .lb: // LB
            let lbWeight = weight * 2.2046
            var value = Int(lbWeight * 10)
            if (value % 2)  != 0 {
                value += 1
            }
            return Float(value) / 10
        case .st: // ST
            return weight * 0.1574
        case .chinessJin: // Chiness Jin
            return weight * 2
        case .g: // g
            return weight * 1000
        }
    }

    var description: String {
        return
            """
            -------
            DeviceType: \(deviceType),
            weigth: \(weight.toString()),
            dataType: \(dataType)
            """
    }
}
// MARK: - SKScaleData - DataType
extension SKScaleData {
    // swiftlint:disable identifier_name
    enum DataType: String {
        case lockData = "00"
        case transmittingData = "01"
        case overloaded = "02"
        case shutDown = "35"
        case dontCalculateBodyAge = "36"
        case userGroup_0 = "20"
        case userGroup_1 = "21"
        case userGroup_2 = "22"
        case userGroup_3 = "23"
        case userGroup_4 = "24"
        case userGroup_5 = "25"
        case userGroup_6 = "26"
        case userGroup_7 = "27"
        case userGroup_8 = "28"
        case userGroup_9 = "29"

    }
}
// MARK: - SKScaleComand
struct SKScaleCommand: BLECommand {
    private var command: Command
    private var unit: WeightUnit
    private var userGroup: String

    init(command: Command, unit: WeightUnit, userGroup: String = "00") {
        self.command = command
        self.unit = unit
        self.userGroup = userGroup
    }

    var bytes: [UInt8] {
        var hexString = "FD" // Header
        hexString.append(command.rawValue)// 34: Calib, 35: shutdown, 36: low enegy, 37: valid group, 38: infant weighing mode
        hexString.append(unit.rawValue)// 00: kg, 01: LB, 02: ST, 03: Chinese Jin
        hexString.append(userGroup)// 00: group 0 .... 09: group 9
        hexString.append("000000000000")
        var command = hexString.hexaBytes
        command.append(command.xorChecksum(to: 9))
        return command
    }
}
// MARK: - SKScaleCommand - Command
extension SKScaleCommand {
    enum Command: String {
        case calib = "34"
        case shutdown = "35"
        case lowEnegy = "36"
        case validGroup = "37"
        case infantWeightMode = "38"
        case none = "00"
    }
}
// MARK: - WeightUnit
enum WeightUnit: String {
    case kg = "00"
    case lb = "01"
    case st = "02"
    case chinessJin = "03"
    case g = "04"

    init?(with stringValue: String) {
        switch stringValue {
        case "0":
            self = .kg
        case "1":
            self = .lb
        case "2":
            self = .st
        case "3":
            self = .chinessJin
        case "4":
            self = .g
        default:
            return nil
        }
    }

    var name: String {
        switch self {
        case .kg:
            return "kg"
        case .lb:
            return "lb"
        case .st:
            return "st"
        case .chinessJin:
            return "斤"
        case .g:
            return "g"
        }
    }
}
