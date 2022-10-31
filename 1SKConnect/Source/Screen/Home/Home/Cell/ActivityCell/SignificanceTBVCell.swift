//
//  BloodPressureTBVCell.swift
//  1SKConnect
//
//  Created by admin on 24/11/2021.
//

import UIKit

class SignificanceTBVCell: UITableViewCell {

    @IBOutlet weak var bloodPressureLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconNextImageView: UIImageView!
    @IBOutlet weak var indexImageView: UIImageView!
    @IBOutlet weak var significanceLabel: UILabel!

    var measureDate = Double() {
        didSet {
            if measureDate == 0 {
                hourLabel.text = ""
                dateLabel.text = ""
                iconNextImageView.isHidden = true
            } else {
                let date = measureDate.toDate()
                hourLabel.text = date.toString(.hm)
                dateLabel.text = date.toString(.dmySlash)
                iconNextImageView.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.addShadow(width: 0, height: 4, color: .black, radius: 5, opacity: 0.11)
        self.selectionStyle = .none
    }

    func config(with bloodPressure: BloodPressureModel?, and index: Int) {
        switch index {
        case 0:
            self.significanceLabel.text = R.string.localizable.bloodpressure()
            self.indexImageView.image = R.image.ic_blood_pressure()
            guard let `bloodPressure` = bloodPressure else {
                self.measureDate = 0
                bloodPressureLabel.text = "--/-- mmHg"
                return
            }
            bloodPressureLabel.text = "\(bloodPressure.sys.value?.stringValue ?? "--")/\(bloodPressure.dia.value?.stringValue ?? "--") mmHg"
            self.measureDate = bloodPressure.date
        default:
            self.indexImageView.image = R.image.ic_pr()
                        self.significanceLabel.text = R.string.localizable.heartRate()
                        guard let `bloodPressure` = bloodPressure else {
                            self.measureDate = 0
                            bloodPressureLabel.text = "-- bpm"
                            return
                        }
                        bloodPressureLabel.text = "\(bloodPressure.pr.value?.stringValue ?? "--") bpm"
                        self.measureDate = bloodPressure.date
        }
    }

    func configS5BloodPressure(with data: BloodPressureRecordModel?) {
        self.significanceLabel.text = R.string.localizable.bloodpressure()
        self.indexImageView.image = R.image.ic_blood_pressure()
        guard let `data` = data else {
            self.measureDate = 0
            bloodPressureLabel.text = "--/-- mmHg"
            return
        }
        if !data.bloodPressureDetail.array.isEmpty {
            let sbp = data.bloodPressureDetail.last?.sbp ?? 0
            let dbp = data.bloodPressureDetail.last?.dbp ?? 0
//            let mac = dbp + 1/3 * (sbp - dbp)
            bloodPressureLabel.text = "\(sbp.stringValue )/\(dbp.stringValue) mmHg"
            self.measureDate = data.bloodPressureDetail.last?.timestamp ?? 0
        }
    }

    func configS5HR(with data: S5HeartRateRecordModel?) {
        self.indexImageView.image = R.image.ic_pr()
        self.significanceLabel.text = R.string.localizable.heartRate()
        guard let `data` = data else {
            self.measureDate = 0
            bloodPressureLabel.text = "-- bpm"
            return
        }
        if !data.hrDetail.array.isEmpty {
            bloodPressureLabel.text = "\(data.hrDetail.array.last?.heartRate.stringValue ?? "--") bpm"
            self.measureDate = data.hrDetail.array.last?.timestamp ?? 0
        }
    }
    
    func configS5SpO2(with data: S5SpO2RecordModel?) {
        self.indexImageView.image = R.image.ic_home_spo2()
        self.significanceLabel.text = R.string.localizable.spO2()
        guard let `data` = data else {
            self.measureDate = 0
            bloodPressureLabel.text = "-- %"
            return
        }
        if !data.spO2Detail.array.isEmpty {
            self.bloodPressureLabel.text = "\(data.spO2Detail.array.last?.bO.stringValue ?? "--") %"
            self.measureDate = data.spO2Detail.array.last?.timestamp ?? 0
        }
    }
    func configWaveForm(with waveform: WaveformListModel?, and index: Int) {
        switch index {
        case 1:
            self.indexImageView.image = R.image.ic_home_spo2()
            self.significanceLabel.text = R.string.localizable.spO2()
            guard let `waveform` = waveform else {
                self.measureDate = 0
                bloodPressureLabel.text = "-- %"
                return
            }
            if !waveform.waveforms.array.isEmpty {
                self.bloodPressureLabel.text = "\(waveform.waveforms.array.last?.spO2Value.value?.stringValue ?? "--") %"
                self.measureDate = waveform.endTime
            }

        default:
            self.indexImageView.image = R.image.ic_pr()
            self.significanceLabel.text = R.string.localizable.heartRate()
            guard let `waveform` = waveform else {
                self.measureDate = 0
                bloodPressureLabel.text = "-- bpm"
                return
            }

            if !waveform.waveforms.array.isEmpty {
                bloodPressureLabel.text = "\(waveform.waveforms.array.last?.prValue.value?.stringValue ?? "--") bpm"
                self.measureDate = waveform.endTime
            }
        }
    }
}
