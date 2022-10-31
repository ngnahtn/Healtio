//
//  SKStopWatchView.swift
//  1SKConnect
//
//  Created by TrungDN on 01/12/2021.
//

import UIKit

class SKStopWatchView: UIView {
    private var timer: Timer = Timer()
    private var count: Int = 0
    private var timerCounting: Bool = false

    private lazy var stopTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = R.color.title()
        label.text = "00:00:00"
        label.font = R.font.robotoRegular(size: 14)
        return label
    }()

    private lazy var stopWatchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.ic_stop_watch_time()
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initUI()
    }
}

// MARK: - Helpers
extension SKStopWatchView {
    private func initUI() {
        self.addSubview(stopWatchImageView)
        self.stopWatchImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(7)
            make.height.equalTo(7)
        }

        self.addSubview(self.stopTimeLabel)
        self.stopTimeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalTo(self.stopWatchImageView.snp.trailing).offset(2)
        }
    }

    func startTime() {
        self.timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
    }
 
    func startTime(at count: Int) {
        self.count = count + 1
        self.startTime()
    }

    func stopTime() {
        self.timer.invalidate()
        self.count = 0
        self.stopTimeLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
    }

    @objc private func timerCounter() {
        self.count += 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        self.stopTimeLabel.text = timeString
    }

    private func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }

    private func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += ":"
        timeString += String(format: "%02d", minutes)
        timeString += ":"
        timeString += String(format: "%02d", seconds)
        return timeString
    }
}
