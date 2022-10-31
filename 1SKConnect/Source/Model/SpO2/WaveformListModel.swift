//
//  WaveformListModel.swift
//  1SKConnect
//
//  Created by TrungDN on 22/11/2021.
//

import RealmSwift
import Charts

class WaveformListModel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var device: DeviceModel?
    let waveforms = List<WaveformModel>()
    @objc dynamic var endTime: Double = 0
    @objc dynamic var startTime: Double = 0

    /// SpO2 status.
    var spO2Status: SpO2Status {
        return SpO2Status(value: self.waveforms.array.last?.spO2Value.value ?? 0)
    }

    /// min spO2 value.
    var minSpO2AttributedString: NSMutableAttributedString? {
        let valueString = self.waveforms.array.map { $0.spO2Value.value! }.min()?.stringValue
        if let valueString = valueString {
            return self.getNSMutableAttributedString(for: valueString, description: R.string.localizable.spO2_detail_value_min())
        }
        return nil
    }

    /// average spO2 value.
    var averageSpO2AttributedString: NSMutableAttributedString? {
        let valueString = (self.waveforms.array.map { $0.spO2Value.value! }.reduce(0, +) / self.waveforms.array.count).stringValue
        return self.getNSMutableAttributedString(for: valueString, description: R.string.localizable.spO2_detail_value_average())
    }

    /// average heart rate value.
    var averagePrAttributedString: NSMutableAttributedString? {
        let valueString = (self.waveforms.array.map { $0.prValue.value! }.reduce(0, +) / self.waveforms.array.count).stringValue
        return self.getNSMutableAttributedString(for: valueString, description: R.string.localizable.spO2_detail_value_average_pr())
    }

    /// Total time measure.
    var timeMeasure: String {
        let timeString = self.startTime.toDate().time(to: self.endTime.toDate())
        return R.string.localizable.spO2_detail_value_time_measure(timeString)
    }

    /// From date to date
    var date: String {
        return R.string.localizable.spO2_detail_value_from_to(self.startTime.toDate().toString(.hmsdMySlash), self.endTime.toDate().toString(.hmsdMySlash))
    }

    /// Total danger time.
    var totalDangerTime: NSMutableAttributedString? {
        let valueString = self.waveforms.array.filter { $0.spO2Value.value! < 90 }.count.toTimeSting()
        return self.getNSMutableAttributedString(for: valueString, description: "SpO2 < 90%")
    }

    /// SpO2 chart values.
    var spO2ChartData: [ChartDataEntry] {
        var chartDataValues: [ChartDataEntry] = []
        for i in 0 ..< self.waveforms.count {
            let chartData = ChartDataEntry(x: Double(i), y: Double(self.waveforms[i].spO2Value.value!))
            chartDataValues.append(chartData)
        }
        return chartDataValues
    }

    /// SpO2 chart values.
    var prChartData: [ChartDataEntry] {
        var chartDataValues: [ChartDataEntry] = []
        for i in 0 ..< self.waveforms.count {
            let chartData = ChartDataEntry(x: Double(i), y: Double(self.waveforms[i].prValue.value!))
            chartDataValues.append(chartData)
        }
        return chartDataValues
    }

    init(device: DeviceModel, waveforms: [WaveformModel], startTime: Double) {
        super.init()
        self.id = UUID().uuidString
        self.startTime = startTime
        self.endTime = Date().timeIntervalSince1970
        self.device = device
        self.waveforms.append(objectsIn: waveforms)
    }

    init(device: DeviceModel, waveforms: [WaveformModel], startTime: Double, endTime: Double) {
        super.init()
        self.id = UUID().uuidString
        self.startTime = startTime
        self.endTime = endTime
        self.device = device
        self.waveforms.append(objectsIn: waveforms)
    }

    init(waveforms: WaveformModel, startTime: Double) {
        super.init()
        self.id = UUID().uuidString
        self.endTime = Date().timeIntervalSince1970
        self.startTime = startTime
        self.device = waveforms.spO2
        self.waveforms.append(waveforms)
    }

    init(profile: ProfileModel, startTime: Double) {
        self.device = nil
        self.id = UUID().uuidString
        self.startTime = startTime
        self.endTime = Date().timeIntervalSince1970
        self.waveforms.append(objectsIn: [])
    }

    init(profileID: String, device: DeviceModel, waveforms: [WaveformModel], startTime: Double) {
        super.init()
        self.id = UUID().uuidString
        self.endTime = Date().timeIntervalSince1970
        self.startTime = startTime
        self.device = device
        self.waveforms.append(objectsIn: waveforms)
    }

    override init() {
        super.init()
    }
    
    init(spO2: DeviceModel) {
        super.init()
        self.device = spO2
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    /// Get NSMutableAttributedString text
    /// - Parameters:
    ///   - value: value string
    ///   - description: description string
    /// - Returns: a string with format `description value`
    private func getNSMutableAttributedString(for value: String, description: String) -> NSMutableAttributedString? {
        let attributeString = NSMutableAttributedString(string: "\(description): ", attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 16)!, NSAttributedString.Key.foregroundColor: R.color.title()!])
        attributeString.append(NSAttributedString(string: value, attributes: [NSAttributedString.Key.font: R.font.robotoMedium(size: 16)!, NSAttributedString.Key.foregroundColor: R.color.title()!]))
        return attributeString
    }
}
