//
//  Header.swift
//  1SKConnect
//
//  Created by admin on 08/11/2021.
//

import Foundation
import UIKit
import SwiftUI

protocol BloodPresureTableViewHeaderDelegate: AnyObject {
    func handleMeasureButtonDidTap()
    func handleSyncButtonDidTap()
}

class BloodPresureHeader: UIView {
    private lazy var connectButton: UIButton = createButtonConnect()
    private lazy var bpImageView: UIImageView = createBpImageView()
    private lazy var measureButton: UIButton = createButtonMeasure()
    private lazy var graphView: SKGraphView = createGraphView()
    private lazy var weightView: UIView = createWeightView()
    private lazy var progressView: UIView = createProgressView()
    private lazy var measuringLabel: UILabel = createMeasuringLabel()
    lazy var syncLabel: UILabel = createSyncLabel()
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.color = R.color.mainColor()
        indicator.isHidden = true
        return indicator
    }()
    private var percentLayer = CAShapeLayer()
    private var strokeLayer = CAShapeLayer()
    weak var weightViewWidthConstraint: NSLayoutConstraint!
    weak var delegate: BloodPresureTableViewHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupDefaults()
    }
    // MARK: - Setup
    private func setupDefaults() {
        kNotificationCenter.addObserver(self, selector: #selector(onProfileChange), name: .changeProfile, object: nil)
        self.weightView.isHidden = true
        addSubview(connectButton)
        connectButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(28)
            make.width.equalTo(115)
        }
        addSubview(self.indicator)
        indicator.snp.makeConstraints { (make) in
            make.centerY.equalTo(connectButton)
            make.leading.equalTo(connectButton.snp.trailing).offset(10)
        }
        addSubview(bpImageView)
        bpImageView.snp.makeConstraints { (make) in
            make.top.equalTo(connectButton.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.height.equalTo(171)
            make.width.equalTo(133)
        }
        addSubview(self.weightView)
        weightView.snp.makeConstraints { (make) in
            make.top.equalTo(bpImageView.snp.top)
            make.centerX.equalToSuperview()
            make.height.equalTo(174)
            make.width.equalTo(174)
        }
        weightView.addSubview(self.progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().inset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(144)
            make.width.equalTo(144)
        }
        progressView.addSubview(self.measuringLabel)
        measuringLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        addSubview(measureButton)
        measureButton.snp.makeConstraints { (make) in
            make.top.equalTo(bpImageView.snp.bottom).offset(17)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(162)
        }
        let breakView = UIView()
        breakView.backgroundColor = UIColor(hex: "E7ECF0")
        addSubview(breakView)
        breakView.snp.makeConstraints { (make) in
            make.top.equalTo(measureButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(6)
        }
        let titleLabel = UILabel()
        titleLabel.text = L.measuringHistory.localized
        titleLabel.textColor = R.color.title()
        titleLabel.font = R.font.robotoBold(size: 16)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(breakView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        let syncButton = createSyncButton()
        addSubview(syncButton)
        syncButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(breakView).offset(16)
            make.width.height.equalTo(0)
        }
        addSubview(syncLabel)
        syncLabel.snp.makeConstraints { (make) in
            make.top.equalTo(syncButton)
            make.trailing.equalTo(syncButton.snp.leading).offset(-6)
        }
        addSubview(graphView)
        graphView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    private func createMeasuringLabel() -> UILabel {
        let label = UILabel()
        label.text = "0"
        label.font = R.font.robotoMedium(size: 42)
        label.textColor = UIColor(hex: "232930")
        return label
    }
    private func createWeightView() -> UIView {
        let aview = UIView()
        aview.backgroundColor = UIColor(hex: "F8F8F8")
        aview.layer.cornerRadius = 174/2
        aview.clipsToBounds = true
        return aview
    }
    private func createProgressView() -> UIView {
        let aview = UIView()
        aview.layer.cornerRadius = 144/2
        aview.backgroundColor = .white
        return aview
    }
    private func createGraphView() -> SKGraphView {
        let graphView = SKGraphView(frame: .zero)
        graphView.setFilterTypes(TimeFilterType.allCases)
        graphView.needShowMeasurementCollectionView = false
        return graphView
    }
    private func createSyncButton() -> UIButton {
        let button = UIButton()
        button.setImage(R.image.ic_sync(), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(syncButtonDidTapped), for: .touchUpInside)
        return button
    }
    private func createSyncLabel() -> UILabel {
        let syncDateTitleLabel = UILabel()
        syncDateTitleLabel.font = R.font.robotoRegular(size: 12)
        syncDateTitleLabel.textColor = R.color.subTitle()
        syncDateTitleLabel.textAlignment = .right
        syncDateTitleLabel.numberOfLines = 0
        return syncDateTitleLabel
    }
    private func createButtonMeasure() -> UIButton {
        let button = UIButton()
        button.setTitle(L.measurement.localized, for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(hex: "00C2C5")
        button.titleLabel?.font = R.font.robotoRegular(size: 16)
        button.cornerRadius = 18
        button.addTarget(self, action: #selector(buttonMeasureDidTapped( _:)), for: .touchUpInside)
        return button
    }
    private func createBpImageView() -> UIImageView {
        let image = UIImage(named: "AL_WBP")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    private func createButtonConnect() -> UIButton {
        let connectButton = UIButton()
        connectButton.backgroundColor = UIColor(hex: "C5C5C5")
        connectButton.layer.cornerRadius = 10
        connectButton.clipsToBounds = true
        connectButton.setTitle("  \(L.disconnect.localized)", for: .normal)
        connectButton.titleLabel?.font = R.font.robotoRegular(size: 14)
        connectButton.titleLabel?.textColor = .white
        connectButton.setImage(R.image.ic_bluetooth(), for: .normal)
        connectButton.isUserInteractionEnabled = false
        return connectButton
    }
    // MARK: - Action
    @objc private func onProfileChange() {
        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if currentProfile.linkAccount != nil && !String.isNilOrEmpty(currentProfile.lastSyncDate) {
            self.syncLabel.isHidden = false
            self.syncLabel.text = currentProfile.lastSyncDate
            var dateSync = ""
            if currentProfile.lastSyncDate.contains("Đồng bộ lần cuối ") {
                dateSync = "Đồng bộ lần cuối:\n\(currentProfile.lastSyncDate.replacingOccurrences(of: "Đồng bộ lần cuối ", with: ""))"
                self.syncLabel.text = dateSync
            }
        } else {
            self.syncLabel.isHidden = true
        }
    }
    @objc func buttonMeasureDidTapped(_ sender: UIButton) {
        delegate?.handleMeasureButtonDidTap()
    }
    @objc func syncButtonDidTapped() {
        delegate?.handleSyncButtonDidTap()
    }

    func getValueWhenMeasuring(with value: Int) {
        self.measuringLabel.text = "\(value)"
    }

    func updateMeasurementState(_ state: BloodPressureMeasurementState) {

        if state == .none {
            self.measureButton.setTitle(R.string.localizable.measurement(), for: .normal)
            percentLayer.removeAnimation(forKey: "SKProgressAnimation")
            self.bpImageView.isHidden = false
            self.weightView.isHidden = true
        } else {
            if self.bpImageView.isHidden == false {
                self.bpImageView.isHidden = true
                self.weightView.isHidden = false
            }
            self.measureButton.setTitle(R.string.localizable.stop_measurement(), for: .normal)
            self.startAnimation()
        }
    }

    func updateConnectState(_ state: Bool) {
        percentLayer.removeAnimation(forKey: "SKProgressAnimation")
        if state {
            connectButton.setTitle("  \(R.string.localizable.connected())", for: .normal)
            connectButton.backgroundColor = R.color.mainColor()
            measureButton.backgroundColor = R.color.mainColor()
            measureButton.setTitle(L.measurement.localized, for: .normal)
        } else {
            connectButton.setTitle("  \(R.string.localizable.disconnected())", for: .normal)
            measureButton.backgroundColor = UIColor(hex: "C5C5C5")
            connectButton.backgroundColor = UIColor(hex: "C5C5C5")
            measureButton.setTitle(L.linkDevice.localized, for: .normal)
        }
        measureButton.isUserInteractionEnabled = state
    }

    func setIndicatorHidden(_ isHidden: Bool) {
        indicator.isHidden = isHidden
        if isHidden {
            indicator.stopAnimating()
        } else {
            indicator.startAnimating()
        }
    }

    func setTimeFilterDelegate(_ delegate: TimeFilterViewDelegate) {
        graphView.setTimeFilterDelegate(delegate)
    }
}

// MARK: - HandleCircleProgress
extension BloodPresureHeader {
    private func drawPercent(percent: CGFloat) {
        percentLayer.removeFromSuperlayer()
        self.strokeLayer.removeFromSuperlayer()
        let progressViewWidth: CGFloat = 144
        let pi = CGFloat.pi
        let path = UIBezierPath(arcCenter: CGPoint(x: progressViewWidth/2, y: progressViewWidth/2),
                                radius: progressViewWidth / 2,
                                startAngle: -pi / 2.0,
                                endAngle: -pi / 2.0 + percent * 2 * pi,
                                clockwise: true)
        percentLayer.path = path.cgPath
        percentLayer.fillColor = UIColor.clear.cgColor
        percentLayer.strokeColor = R.color.mainColor()?.cgColor
        percentLayer.lineCap = .round
        percentLayer.lineWidth = 14
        strokeLayer.path = path.cgPath
        strokeLayer.fillColor = UIColor.clear.cgColor
        strokeLayer.lineWidth = 14
        strokeLayer.strokeColor = UIColor(hex: "DEECEC").cgColor
        progressView.layer.addSublayer(strokeLayer)
        progressView.layer.addSublayer(percentLayer)
    }

    private func startAnimation() {
        CATransaction.begin()
        drawPercent(percent: 1)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 5
        animation.repeatCount = .infinity
        percentLayer.add(animation, forKey: "SKProgressAnimation")
        CATransaction.commit()
    }
}

// MARK: - Helpers
extension BloodPresureHeader {
    /// Set graph data
    /// - Parameters:
    ///   - data: blood pressure data
    ///   - type: time filter type
    func setData(_ data: [[[BloodPressureModel]]], timeType: TimeFilterType, deviceType: DeviceType) {
        self.graphView.setData(data, timeType: timeType, deviceType: deviceType)
    }

    func setPoints(_ data: WeightMeasurementModel, times: [Double], type: TimeFilterType) {
        graphView.setPoints(data, times: times, type: type)
    }
}
