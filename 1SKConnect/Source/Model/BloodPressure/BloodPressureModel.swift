//
//  BloodPressureModel.swift
//  1SKConnect
//
//  Created by admin on 12/11/2021.
//

import Foundation
import RealmSwift

struct BiolightMeasurementModel {
    var sys: Int
    var dia: Int
    var map: Int
    var pr: Int
}

struct VitalSignsDescriptionModel {
    var title: String
    var des: String
}

class BloodPressureModel: Object {
    let sys = RealmOptional<Int>()
    let dia = RealmOptional<Int>()
    let map = RealmOptional<Int>()
    let pr = RealmOptional<Int>()
    @objc dynamic var date: Double = 0

    var createAt: String {
        return Date(timeIntervalSince1970: self.date).toString(.ymdhms)
    }

    @objc dynamic var syncId: String = ""
    var isSync: Bool {
        if String.isNilOrEmpty(syncId) {
            return false
        } else {
            return true
        }
    }

    @objc dynamic var id: String = ""
    @objc dynamic var biolight: DeviceModel?

    var deviceMac: String? {
        return biolight?.mac
    }

    var deviceName: String? {
        return biolight?.name
    }

    /// Blood pressure state
    var state: BloodPressureState {
        return BloodPressureState(sys: self.sys.value!, dia: self.dia.value!)
    }

    init(_ bp: BloodPressure) {
        self.id = UUID().uuidString
        self.syncId = bp.id ?? ""
        self.biolight = DeviceModel(name: bp.deviceName ?? "", mac: bp.mac ?? "", deviceType: .biolightBloodPressure, image: R.image.al_WBP())
        self.date = bp.ts ?? Date().timeIntervalSince1970
        self.sys.value = bp.sys ?? 0
        self.dia.value = bp.dia ?? 0
        self.map.value = bp.map ?? 0
        self.pr.value = bp.pr ?? 0
    }

    init(with biolightMeasurementModel: BiolightMeasurementModel, of device: DeviceModel) {
        self.id = UUID().uuidString
        self.sys.value = biolightMeasurementModel.sys
        self.dia.value = biolightMeasurementModel.dia
        self.map.value = biolightMeasurementModel.map
        self.pr.value = biolightMeasurementModel.pr
        self.date = Date().timeIntervalSince1970
        self.biolight = device
    }

    init(biolight: DeviceModel) {
        super.init()
        self.biolight = biolight
    }

    override init() {
        super.init()
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
