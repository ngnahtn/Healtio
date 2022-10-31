//
//  BiolightDeviceTableViewCell.swift
//  1SKConnect
//
//  Created by admin on 24/11/2021.
//

import UIKit

class BiolightDeviceTableViewCell: UITableViewCell, DeviceActivityTableViewCellProtocol {
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconNextImageView: UIImageView!
    weak var delegate: DeviceActivityTableViewCellDelegate?
    @IBOutlet weak var sysAndDiaLabel: UILabel!
    @IBOutlet weak var hrLabel: UILabel!
    @IBOutlet weak var measurementUnitLabel: UILabel!
    var isDataNil = false {
        didSet {
            if isDataNil {
                self.measureDate = 0
                hrLabel.text = "--"
            }
        }
    }

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
        deviceImageView.superview?.addShadow(width: 0, height: 2, color: .black, radius: 6, opacity: 0.25)
        self.selectionStyle = .none
    }

    func config(with bloodpressure: BloodPressureModel?) {
        self.measurementUnitLabel.text = "mmHg"
        guard let `bloodpressure` = bloodpressure else {
            self.isDataNil = true
            sysAndDiaLabel.text = "--/--"
            return
        }
        deviceImageView.setImage(R.image.al_WBP(), placeHolder: R.image.al_WBP())
        iconNextImageView.isHidden = bloodpressure.sys.value == nil
        nameLabel.text = "BioLight - WBP202 - \(bloodpressure.biolight?.mac.suffix(4).pairs.joined(separator: ":") ?? "")"
        sysAndDiaLabel.text = "\(bloodpressure.sys.value?.stringValue ??  "--")/\(bloodpressure.dia.value?.stringValue ?? "--")"
        hrLabel.text = bloodpressure.pr.value?.stringValue ?? "--"
        self.measureDate = bloodpressure.date
    }

    func configWaveForm(with waveform: WaveformListModel?) {
        self.measurementUnitLabel.text = "%"
        guard let `waveform` = waveform else {
            self.isDataNil = true
            sysAndDiaLabel.text = "--"
            return
        }
        deviceImageView.setImage(R.image.o22291(), placeHolder: R.image.o22291())
        iconNextImageView.isHidden = waveform.waveforms.array.isEmpty
        nameLabel.text = "Vivatom - \(waveform.device?.name ?? "") - \(waveform.device?.mac.suffix(4).pairs.joined(separator: ":") ?? "")"
        if !waveform.waveforms.array.isEmpty {
            self.sysAndDiaLabel.text = waveform.waveforms.array.last?.spO2Value.value?.stringValue
            self.measureDate = waveform.endTime
            hrLabel.text = waveform.waveforms.array.last?.prValue.value?.stringValue ?? "--"
        } else {
            self.isDataNil = true
            sysAndDiaLabel.text = "--"
        }
    }

    func configDefaultValue(with index: Int) {
        self.nameLabel.text = ""
        self.isDataNil = true
        switch index {
        case 1:
            self.deviceImageView.image = R.image.ic_blood_pressure()
            sysAndDiaLabel.text = "--/--"
            self.measurementUnitLabel.text = "mmHg"
        case 2:
            self.deviceImageView.image = R.image.ic_home_spo2()
            sysAndDiaLabel.text = "--"
            self.measurementUnitLabel.text = "%"
        default:
            break
        }
    }

    @IBAction func buttonDeviceDidTapped(_ sender: Any) {
        delegate?.onButtonDeviceDidTapped(self)
    }
}
