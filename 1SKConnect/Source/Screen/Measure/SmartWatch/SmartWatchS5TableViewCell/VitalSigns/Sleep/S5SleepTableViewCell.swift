//
//  S5SleepTableViewCell.swift
//  1SKConnect
//
//  Created by admin on 09/12/2021.
//

import UIKit
import TrusangBluetooth

class S5SleepTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chartContentView: UIView!
    @IBOutlet weak var sleepLabel: UILabel!
    @IBOutlet weak var sleepChartView: UIView!

    // Date and Duration Label properties
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var deepDuration: UILabel!
    @IBOutlet weak var lightDurationLabel: UILabel!
    @IBOutlet weak var remDurationLabel: UILabel!
    @IBOutlet weak var asleepDurationLabel: UILabel!
    @IBOutlet var timeLabels: [UILabel]!
    @IBOutlet weak var chartWeekStackView: UIStackView!
    
    @IBOutlet var dashViews: [SKDashedLineHorizonatalView]!
    
    weak var delegate: ShowWeakDetailDelegate?

    var todaySleepData: SleepRecordModel? {
        didSet {
            guard let unwrappedData = self.todaySleepData else {
                return
            }
            if unwrappedData.sleeppDetail.isEmpty {
                self.dateLabel.text = ""
                self.sleepLabel.text = R.string.localizable.smart_watch_s5_sleep_input(R.string.localizable.smart_watch_s5_has_no_data())
            } else {
                self.dateLabel.text = Date().toString(.hmdmy)
            }
            self.configTimeData(unwrappedData)
            DispatchQueue.main.async {
                self.configChartData(unwrappedData)
            }
        }
    }
    
    var shadowLayer: CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setUpDefault()
        self.createShadow()
        self.chartWeekStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showWeekDetail(_:))))
    }
    
}

// MARK: - Selectors
extension S5SleepTableViewCell {
    @objc private func showWeekDetail(_ sender: UITapGestureRecognizer) {
        self.delegate?.onShowWeekData(self)
    }
}

// MARK: - Helpers
extension S5SleepTableViewCell {

    func setUpDefault() {
        self.dateLabel.text = Date().toString(.hmdmy)
        self.sleepLabel.text = R.string.localizable.smart_watch_s5_sleep_input(R.string.localizable.smart_watch_s5_has_no_data())
        for item in timeLabels {
            item.text = R.string.localizable.hourAndMinuteEmty()
        }
    }

    private func createShadow() {
        DispatchQueue.main.async {
            if self.shadowLayer == nil {
                let shadowPath = UIBezierPath(roundedRect: self.shadowView.bounds, cornerRadius: 4)
                self.shadowLayer = CAShapeLayer()
                self.shadowLayer?.shadowPath = shadowPath.cgPath
                self.shadowLayer?.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.11).cgColor
                self.shadowLayer?.shadowOpacity = 1
                self.shadowLayer?.shadowRadius = 5
                self.shadowLayer?.shadowOffset = CGSize(width: 0, height: 4)
                self.shadowView.layer.insertSublayer(self.shadowLayer!, at: 0)
            }
        }
    }

    private func configTimeData(_ unwrappedData: SleepRecordModel) {
        let startDate = unwrappedData.sleeppDetail[0].dateTime.toDate(.ymdhm)?.toString(.hm)
        let endDate = unwrappedData.sleeppDetail[unwrappedData.sleeppDetail.count - 1].dateTime.toDate(.ymdhm)?.toString(.hm)
        let totalDuration = unwrappedData.awakeDuration + unwrappedData.beginDuration + unwrappedData.lightDuration + unwrappedData.deepDuration + unwrappedData.remDuration
        self.sleepLabel.text = R.string.localizable.smart_watch_s5_sleep_input(totalDuration.hourAndMinuteStringValue)
        self.startTimeLabel.text = startDate
        self.endTimeLabel.text = endDate
        self.deepDuration.text = unwrappedData.deepDuration.hourAndMinuteStringValue
        self.lightDurationLabel.text = unwrappedData.lightDuration.hourAndMinuteStringValue
        self.remDurationLabel.text = unwrappedData.remDuration.hourAndMinuteStringValue
        self.asleepDurationLabel.text = unwrappedData.awakeDuration.hourAndMinuteStringValue
        for item in dashViews {
            DispatchQueue.main.async {
                item.setup(item.width)
            }
        }
    }

    private func configChartData(_ unwrappedData: SleepRecordModel) {
        var views = [UIView]()
        let prarentWidth = self.sleepChartView.frame.width
        for i in 0...unwrappedData.sleeppDetail.count - 1 {
            views.append(UIView())
            switch unwrappedData.sleeppDetail[i].type.value {
            case .awake:
                views[i].backgroundColor = UIColor(hex: "FEC63D")
            case .light:
                views[i].backgroundColor = UIColor(hex: "914FC5")
            case .deep:
                views[i].backgroundColor = UIColor(hex: "54399F")
            case .rem:
                views[i].backgroundColor = UIColor(hex: "4CD864")
            default:
                views[i].backgroundColor = .white
            }
            
            if i == 0 {
                self.sleepChartView.addSubview(views[0])
                    views[0].anchor(top: self.sleepChartView.topAnchor,
                                    left: self.sleepChartView.leftAnchor,
                                    bottom: self.sleepChartView.bottomAnchor,
                                    width: prarentWidth / Double(unwrappedData.sleeppDetail.count))
                
            } else {
                self.sleepChartView.addSubview(views[i])
                    views[i].anchor(top: self.sleepChartView.topAnchor,
                                    left: views[i-1].rightAnchor,
                                    bottom: self.sleepChartView.bottomAnchor,
                                    width: prarentWidth / Double(unwrappedData.sleeppDetail.count))
            }
        }
    }
}
