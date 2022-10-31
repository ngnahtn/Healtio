//
//  BiolightData.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/02/2021.
//

import Foundation

struct BiolightData {
    var header: UInt8
    var length: Int
    var dataBlock: DataBlock?
    var checkSum: UInt8

    init?(data: [UInt8]) {
        var `data` = data
        guard data.count >= 3 else {
            return nil
        }
        let header = data.removeFirst()
        let checkSum = data.removeLast()
        // check checkSum
        guard data.checkSum(to: data.count - 1) == checkSum else {
            return nil
        }
        let length = Int(data.removeFirst())
        let dataBlock = data
        self = BiolightData(header: header, length: length, dataBlock: dataBlock, checkSum: checkSum)
    }

    init(header: UInt8, dataBlock: [UInt8]) {
        self.header = header
        self.length = dataBlock.count + 1
        self.dataBlock = DataBlock(data: dataBlock)
        var array: [UInt8] = [UInt8(length)]
        array.append(contentsOf: dataBlock)
        let checkSum = array.checkSum(to: length - 1)
        self.checkSum = checkSum
    }

    init(header: UInt8, dataBlock: DataBlock) {
        self.header = header
        self.length = dataBlock.getBytes().count + 1
        self.dataBlock = dataBlock
        var array: [UInt8] = [UInt8(length)]
        array.append(contentsOf: dataBlock.getBytes())
        let checkSum = array.checkSum(to: length - 1)
        self.checkSum = checkSum
    }

    init(header: UInt8, length: Int, dataBlock: [UInt8], checkSum: UInt8) {
        self.header = header
        self.length = length
        self.dataBlock = DataBlock(data: dataBlock)
        self.checkSum = checkSum
    }

    func getBytes() -> [UInt8] {
        var bytes: [UInt8] = [header]
        bytes.append(UInt8(length))
        bytes.append(contentsOf: dataBlock?.getBytes() ?? [])
        bytes.append(checkSum)
        return bytes
    }
}
// MARK: - BioLightData - DataBlock
extension BiolightData {
    struct DataBlock {
        var id: UInt8
        var dataSegment: [UInt8]

        init(id: UInt8, dataSegment: [UInt8]) {
            self.id = id
            self.dataSegment = dataSegment
        }

        init?(data: [UInt8]) {
            var `data` = data
            guard !data.isEmpty else {
                return nil
            }
            self.id = data.removeFirst()
            self.dataSegment = data
        }

        func getBytes() -> [UInt8] {
            var bytes = [id]
            bytes.append(contentsOf: dataSegment)
            return bytes
        }
    }
}
// MARK: - BioDevice
enum BioDevice: String {
    case wt1 = "01"
    case wt2 = "02"
    case wt3 = "03"
    case pulseOxymetter = "1E"
    case wbp100 = "32"
    case wbp101 = "35"
    case wbp201 = "34"
    case wbp202 = "33"
    case wbp203 = "36"
    case wbp204 = "37"
    case wbp301 = "38"
    case wbp302 = "39"
    case wbp303 = "3A"
    case wbp304 = "3B"
    case wf100 = "46"
    case wf200 = "47"
}
// MARK: - BioCommand
struct BioCommand: BLECommand {
    var command: Command

    var bytes: [UInt8] {
        var startCommandString = "78"
        startCommandString.append(command.rawValue) // command
        startCommandString.append("00") // Ble connection time
        startCommandString.append("00") // Ble connection time 2 digit higer
        startCommandString.append("00") // Ignore
        startCommandString.append("7e") // Remark
        let dataBlock = BiolightData.DataBlock(data: startCommandString.hexaBytes)
        let bioData = BiolightData(header: UInt8(170), dataBlock: dataBlock?.getBytes() ?? [])
        return bioData.getBytes()
    }

    init(command: Command) {
        self.command = command
    }
}
// MARK: - BioCommand - Command
extension BioCommand {
    enum Command: String {
        case start = "00"
        case continueMeasurement = "01"
        case staticPresure = "02"
        case abandon = "08"
    }
}
