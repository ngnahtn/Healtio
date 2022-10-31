//
//  WaveformModel.swift
//  1SKConnect
//
//  Created by Elcom Corp on 11/11/2021.
//

import RealmSwift
import VTO2Lib

class WaveformModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var spO2: DeviceModel?
    @objc dynamic var timeCreated: Double = 0
    let prValue = RealmOptional<Int>()
    let spO2Value = RealmOptional<Int>()

    init(waveforms data: ViatomRealTimeWaveform, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.timeCreated = Date().timeIntervalSince1970
        self.prValue.value = data.pr
        self.spO2Value.value = data.spO2
        self.spO2 = device
    }

    init(waveforms data: VTO2WaveObject, of device: DeviceModel, timeCreated: Double) {
        self.id = UUID().uuidString
        self.timeCreated = timeCreated
        self.spO2 = device
        self.prValue.value = Int(data.hr) 
        self.spO2Value.value = Int(data.spo2)
    }

    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
