//
//  ScaleTableViewHeader.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//

import UIKit

protocol ScaleTableViewHeaderDelegate: AnyObject {
    func onButtonConnectDidTapped()
    func onButtonMeasureDidTapped()
    func onButtonSyncDidTapped()
    func updateBodyFatData(fromDate: Date?, toDate: Date)
}

class ScaleTableViewHeader: UIView {
    private lazy var connectButton: UIButton = createButtonConnect()
    private var connectViewTitleLabel: UILabel = UILabel()
    private lazy var measureButton: UIButton = createButtonMeasure()
    private lazy var scaleImageView: UIImageView = createScaleImageView()
    private lazy var graphView: SKGraphView = createGraphView()
    lazy var syncLabel: UILabel = createSyncLabel()
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.color = R.color.mainColor()
        indicator.isHidden = true
        return indicator
    }()

    weak var delegate: ScaleTableViewHeaderDelegate?

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
        backgroundColor = .white
        let connectView = createConnectView()
        addSubview(connectView)
        connectView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(0)
        }

        addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.centerY.equalTo(connectView)
            make.leading.equalTo(connectView.snp.trailing).offset(10)
        }

        addSubview(scaleImageView)
        scaleImageView.snp.makeConstraints { (make) in
            make.top.equalTo(connectView.snp.bottom).offset(7)
            make.width.height.equalTo(175)
            make.centerX.equalToSuperview()
        }

        addSubview(measureButton)
        measureButton.snp.makeConstraints { (make) in
            make.top.equalTo(scaleImageView.snp.bottom).offset(15)
            make.height.equalTo(40)
            make.width.equalTo(162)
            make.centerX.equalToSuperview()
        }

        let breakView = UIView()
        breakView.backgroundColor = UIColor(hex: "E7ECF0")
        addSubview(breakView)
        breakView.snp.makeConstraints { (make) in
            make.top.equalTo(measureButton.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(6)
        }

        let titleLabel = UILabel()
        titleLabel.text = L.measuringHistory.localized
        titleLabel.textColor = R.color.title()
        titleLabel.font = R.font.robotoBold(size: 16)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(breakView.snp.bottom).offset(20)
            make.leading.equalTo(connectView)
        }

        addSubview(graphView)
        graphView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
        
        addSubview(syncLabel)
        syncLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(16)
        }
    }

    @objc private func handleSync() {
        self.delegate?.onButtonSyncDidTapped()
    }

    private func createConnectView() -> UIView {
        let view = UIView()
        view.cornerRadius = 16
        view.backgroundColor = R.color.mainColor()
        let bleIconImageView = UIImageView(image: R.image.ic_bluetooth())
        bleIconImageView.contentMode = .scaleAspectFit
        view.addSubview(bleIconImageView)
        bleIconImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }

        connectViewTitleLabel.text = L.connect.localized
        connectViewTitleLabel.textColor = .white
        connectViewTitleLabel.font = R.font.robotoRegular(size: 14)
        view.addSubview(connectViewTitleLabel)
        connectViewTitleLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(bleIconImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }

        view.addSubview(connectButton)
        connectButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return view
    }

    private func createScaleImageView() -> UIImageView {
        let scaleImageView = UIImageView()
        scaleImageView.contentMode = .scaleAspectFit
        return scaleImageView
    }

    private func createButtonConnect() -> UIButton {
        let connectButton = UIButton()
        connectButton.addTarget(self, action: #selector(connectButtonDidTapped), for: .touchUpInside)
        return connectButton
    }

    private func createButtonMeasure() -> UIButton {
        let button = UIButton()
        button.setTitle(L.measurement.localized, for: .normal)
        button.backgroundColor = R.color.mainColor()
        button.cornerRadius = 20
        button.addTarget(self, action: #selector(buttonMeasureDidTapped), for: .touchUpInside)
        return button
    }

    private func createGraphView() -> SKGraphView {
        let graphView = SKGraphView(frame: .zero)
        graphView.delegate = self
        graphView.setFilterTypes(TimeFilterType.allCases)
        return graphView
    }
    
    private func createSyncLabel() -> UILabel {
        let syncDateTitleLabel = UILabel()
        syncDateTitleLabel.font = R.font.robotoRegular(size: 12)
        syncDateTitleLabel.textColor = R.color.subTitle()
        syncDateTitleLabel.textAlignment = .right
        syncDateTitleLabel.numberOfLines = 0
        return syncDateTitleLabel
    }

    // MARK: - Action
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
    
    @objc func connectButtonDidTapped() {
        delegate?.onButtonConnectDidTapped()
    }

    @objc func buttonMeasureDidTapped() {
        delegate?.onButtonMeasureDidTapped()
    }

    func setMesuareButtonEnable(_ isEnable: Bool) {
        measureButton.isEnabled = isEnable
        measureButton.backgroundColor = isEnable ? R.color.blue() : .lightGray
    }

    func setConnectButtonState(_ isConnect: Bool) {
        connectViewTitleLabel.text = isConnect ? L.disconnect.localized : L.connect.localized
        connectButton.superview?.backgroundColor = isConnect ? .lightGray : R.color.mainColor()
    }

    func setScaleImage(_ image: UIImage?) {
        scaleImageView.image = image
    }

    func setIndicatorHidden(_ isHidden: Bool) {
        indicator.isHidden = isHidden
        if isHidden {
            indicator.stopAnimating()
        } else {
            indicator.startAnimating()
        }
    }

    func setPoints(_ data: WeightMeasurementModel, times: [Double], type: TimeFilterType) {
        graphView.setPoints(data, times: times, type: type)
    }

    func setData(_ data: [[[BodyFat]]], timeType: TimeFilterType, deviceType: DeviceType) {
        self.graphView.setData(data, timeType: timeType, deviceType: deviceType)
    }

    func setTimeFilterDelegate(_ delegate: TimeFilterViewDelegate) {
        graphView.setTimeFilterDelegate(delegate)
    }

    func setTypes(_ types: [TimeFilterType]) {
        graphView.setFilterTypes(types)
    }

    func update(with isUnLinkDevice: Bool) {
        connectButton.superview?.isHidden = isUnLinkDevice
        measureButton.setTitle(isUnLinkDevice ? L.linkDevice.localized : L.measurement.localized, for: .normal)
    }
}

extension ScaleTableViewHeader: SKGraphViewDelegate {
    func updateBodyFatData(fromDate: Date?, toDate: Date) {
        self.delegate?.updateBodyFatData(fromDate: fromDate, toDate: toDate)
    }
}
