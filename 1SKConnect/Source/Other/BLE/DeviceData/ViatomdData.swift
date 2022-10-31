//
//  ViatomdData.swift
//  1SKConnect
//
//  Created by tuyenvx on 02/02/2021.
//

import Foundation
import SwiftyJSON

// MARK: - ViatomCommand
struct ViatomCommand: BLECommand {
    var header: UInt8
    var command: Command
    var notCommand: UInt8
    var packetNumber: [UInt8]
    var dataSize: [UInt8]
    var data: [UInt8]
    var checkSum: UInt8

    var bytes: [UInt8] {
        var bytes = [header]
        bytes.append(command.getByte())
        bytes.append(notCommand)
        bytes.append(contentsOf: packetNumber)
        bytes.append(contentsOf: dataSize)
        bytes.append(contentsOf: data)
        bytes.append(checkSum)
        return bytes
    }

    init?(bytes: [UInt8]) {
        guard bytes.count >= 8, bytes.first == 170 else {
            return nil
        }
        header = bytes[0]
        let commandByte = bytes[1]
        guard let command = Command(rawValue: commandByte.hexString()) else {
            return nil
        }
        self.command = command
        notCommand = bytes[2]
        packetNumber = Array(bytes[3...4])
        dataSize = Array(bytes[5...6])
        data = Array(bytes[7...])
        checkSum = data.removeLast()
        if checkSum != bytes.calcCRC8(to: bytes.count - 2) {
            return nil
        }
    }

    init(command: Command, packetNumber: Int, data: [UInt8]) {
        header = 170 // "AA"
        self.command = command
        notCommand = ~command.getByte()
        self.packetNumber = Array(packetNumber.toUInt8()[0...1])
        dataSize = Array(data.count.toUInt8()[0...1])
        self.data = data
        var bytes = [header]
        bytes.append(command.getByte())
        bytes.append(notCommand)
        bytes.append(contentsOf: self.packetNumber)
        bytes.append(contentsOf: self.dataSize)
        bytes.append(contentsOf: data)
        let checkSum = bytes.calcCRC8(to: bytes.count - 1)
        self.checkSum = checkSum
    }
}

// MARK: - ViatomCommand - Command
extension ViatomCommand {
    enum Command: String {
        case fileStart = "03"
        case fileData = "04"
        case fileEnd = "05"
        case deviceInfo = "14"
        case ping = "15"
        case sync = "16"
        case realTimeData = "17"
        case factoryReset = "18"
        case waveformData = "1b"

        func getByte() -> UInt8 {
            return rawValue.hexaBytes.first ?? 0
        }
    }
}

// MARK: - ViatomResponse
struct ViatomResponse {
    var header: ViatomResponseHeader
    var data: [UInt8]
    var checkSum: UInt8?

    init(header: ViatomResponseHeader) {
        self.header = header
        data = []
    }

    init?(bytes: [UInt8]) {
        guard bytes.count >= 8,
            let header = ViatomResponseHeader(bytes: bytes) else {
            return nil
        }
        let data = Array(bytes[7...])
        var response = ViatomResponse(header: header)
        let result = response.addData(bytes: data)
        switch result {
        case (true, _):
            self = response
        case (false, _):
            return nil
        }
    }

    mutating func addData(bytes: [UInt8]) -> (Bool, Bool) { // completion isSuccess, isCompletedData
        if header.dataSize.intValue() - data.count >= bytes.count {
            data.append(contentsOf: bytes)
            return(true, false)
        } else if header.dataSize.intValue() - data.count == bytes.count - 1 {
            data.append(contentsOf: bytes)
            checkSum = data.removeLast()
            let isSuccess = checkSum == getCheckSum()
            return(isSuccess, true)
        } else {
            return(false, false)
        }
    }

    func getCheckSum() -> UInt8 {
        var bytes = header.getBytes()
        bytes.append(contentsOf: self.data)
        return bytes.calcCRC8(to: bytes.count - 1)
    }
}

// MARK: - ViatomResponseHeader - ViatomResponseHeader
extension ViatomResponse {
    struct ViatomResponseHeader {
        var header: UInt8
        var status: ViatomACKStatus
        var notStatus: UInt8
        var packetNumber: [UInt8]
        var dataSize: [UInt8]

        init?(bytes: [UInt8]) {
            header = bytes[0]
            let statusByte = bytes[1]
            guard let status = ViatomACKStatus(rawValue: statusByte.hexString()) else {
                return nil
            }
            self.status = status
            notStatus = bytes[2]
            guard header == 85, status.getByte() == ~notStatus else {
                return nil
            }
            packetNumber = Array(bytes[3...4])
            dataSize = Array(bytes[5...6])
        }

        func getBytes() -> [UInt8] {
            var bytes = [header]
            bytes.append(status.getByte())
            bytes.append(notStatus)
            bytes.append(contentsOf: packetNumber)
            bytes.append(contentsOf: dataSize)
            return bytes
        }
    }
}

// MARK: - ViatomResponse.ViatomResponseHeader - ViatomACKStatus
extension ViatomResponse.ViatomResponseHeader {
    enum ViatomACKStatus: String {
        case ok = "00"
        case bad = "01"

        func getByte() -> UInt8 {
            return rawValue.hexaBytes.first ?? 0
        }
    }
}

// MARK: - ViatomDeviceInfo
struct ViatomDeviceInfo: Codable {
    var region: String
    var model: String
    var hardwareVersion: String
    var softwareVersion: String
    var bootLoaderVersion: String
    var languageVersion: String?
    var curLanguage: String?
    var fileVer: String
    var spcVer: String?
    var sn: String
    var curTime: String
    var curBat: String
    var curbatState: String
    var curOxiThr: String
    var curMotor: String
    var curPedtar: String
    var curMode: String
    var fileList: [String]

    enum CodingKeys: String, CodingKey {
        case region = "Region"
        case model = "Model"
        case hardwareVersion = "HardwareVer"
        case softwareVersion = "SoftwareVer"
        case bootLoaderVersion = "BootloaderVer"
        case languageVersion = "LanguageVer"
        case curLanguage = "CurLanguage"
        case fileVer = "FileVer"
        case spcVer = "SPCPVer"
        case sn = "SN"
        case curTime = "CurTIME"
        case curBat = "CurBAT"
        case curbatState = "CurBatState"
        case curOxiThr = "CurOxiThr"
        case curMotor = "CurMotor"
        case curPedtar = "CurPedtar"
        case curMode = "CurMode"
        case fileList = "FileList"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        region = try values.decode(String.self, forKey: .region)
        model = try values.decode(String.self, forKey: .model)
        hardwareVersion = try values.decode(String.self, forKey: .hardwareVersion)
        softwareVersion = try values.decode(String.self, forKey: .softwareVersion)
        bootLoaderVersion = try values.decode(String.self, forKey: .bootLoaderVersion)
        languageVersion = try? values.decode(String.self, forKey: .languageVersion)
        curLanguage = try? values.decode(String.self, forKey: .curLanguage)
        fileVer = try values.decode(String.self, forKey: .fileVer)
        spcVer = try? values.decode(String.self, forKey: .spcVer)
        sn = try values.decode(String.self, forKey: .sn)
        curTime = try values.decode(String.self, forKey: .curTime)
        curBat = try values.decode(String.self, forKey: .curBat)
        curbatState = try values.decode(String.self, forKey: .curbatState)
        curOxiThr = try values.decode(String.self, forKey: .curOxiThr)
        curMotor = try values.decode(String.self, forKey: .curMotor)
        curPedtar = try values.decode(String.self, forKey: .curPedtar)
        curMode = try values.decode(String.self, forKey: .curMode)
        let fileListString = try values.decode(String.self, forKey: .fileList)
        fileList = fileListString.components(separatedBy: ",")
    }
}

// MARK: - ViatomRealTimeWaveform
struct ViatomRealTimeWaveform {
    var spO2: Int
    var pr: Int
    var battery: Int

    init(bytes: [UInt8]) {
        self.spO2 = Int(bytes[0])
        self.pr = Int(bytes[1])
        self.battery = Int(bytes[3])
    }

    init(_ json: JSON) {
        self.spO2 = json["spO2"].intValue
        self.pr = json["pr"].intValue
        self.battery = json["battery"].intValue
    }

    func toDictionary() -> [String: Any] {
        var json = [String: Any]()
        json["spO2"] = self.spO2
        json["pr"] = self.pr
        json["battery"] = self.battery
        return json
    }

    var spo2Attribute: NSAttributedString? {
        let attributeString = NSMutableAttributedString(string: String(self.spO2), attributes: [NSAttributedString.Key.font: R.font.robotoBold(size: 36)!, NSAttributedString.Key.foregroundColor: R.color.title()!])
        attributeString.append(NSAttributedString(string: "%", attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 20)!, NSAttributedString.Key.foregroundColor: R.color.title()!]))
        return attributeString
    }

    var prAttribute: NSAttributedString? {
        let attributeString = NSMutableAttributedString(string: String(self.pr), attributes: [NSAttributedString.Key.font: R.font.robotoBold(size: 36)!, NSAttributedString.Key.foregroundColor: R.color.title()!])
        attributeString.append(NSAttributedString(string: "bpm", attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 20)!, NSAttributedString.Key.foregroundColor: R.color.title()!]))
        return attributeString
    }
}
