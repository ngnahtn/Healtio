//
//  SpO2TableViewHeader.swift
//  1SKConnect
//
//  Created by Be More on 31/08/2021.
//

import UIKit

protocol SpO2TableViewHeaderDelegate: AnyObject {
    func onButtonMeasureDidTapped(stop: Bool)
    func onButtonSyncDidTapped()
}

class SpO2TableViewHeader: UIView {
    private var isConnected = false
    private var connectViewTitleLabel: UILabel = UILabel()
    private lazy var connectButton: UIButton = createButtonConnect()

    private lazy var batteryLevelLabel: UILabel = createBatteryLevelLabel()
    private lazy var batteryView: SKBatteryView = createBatteryView()

    private lazy var stopWatchView: SKStopWatchView = createStopWatchView()

    private lazy var spO2ArcView = self.createSpO2MeasurementView()
    private lazy var spO2ValueLabel: UILabel = self.createSpO2ValueLabel()

    private lazy var pRArcView = self.createPRMeasurementView()
    private lazy var pRValueLabel: UILabel = self.createPRValueLabel()

    private lazy var measureButton: UIButton = createButtonMeasure()
    private lazy var measureView: UIView = createMeasureView()
    private lazy var graphView: SKGraphView = createGraphView()

    private let profileListDAO = GenericDAO<ProfileListModel>()
    var device: DeviceModel!

    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.color = R.color.mainColor()
        indicator.isHidden = true
        return indicator
    }()

    private lazy var lastDateLabel: UILabel = {
        let syncDateTitleLabel = UILabel()
        syncDateTitleLabel.font = R.font.robotoRegular(size: 12)
        syncDateTitleLabel.textColor = R.color.subTitle()
        syncDateTitleLabel.textAlignment = .right
        syncDateTitleLabel.numberOfLines = 0
        syncDateTitleLabel.isHidden = true
        return syncDateTitleLabel
    }()

    private lazy var syncImageView: UIImageView = {
        let syncImageView = UIImageView()
        syncImageView.image = R.image.ic_sync()
        syncImageView.isUserInteractionEnabled = true
        syncImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSync)))
        return syncImageView
    }()

    weak var delegate: SpO2TableViewHeaderDelegate?

    // MARK: - Initializers
    init(frame: CGRect, isConnected: Bool) {
        super.init(frame: frame)
        self.isConnected = isConnected
        self.setupDefaults()
    }

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
        self.addSubview(connectView)
        connectView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(32)
        }

        addSubview(self.batteryView)
        self.batteryView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(connectView)
            make.height.equalTo(13)
            make.width.equalTo(30)
        }

        self.addSubview(self.batteryLevelLabel)
        self.batteryLevelLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.batteryView.snp.leading).offset(-6)
            make.centerY.equalTo(connectView)
        }

        self.addSubview(self.stopWatchView)
        self.stopWatchView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(connectView)
        }

        self.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerY.equalTo(connectView)
            make.leading.equalTo(connectView.snp.trailing).offset(10)
        }

        addSubview(measureView)
        measureView.snp.makeConstraints { make in
            make.top.equalTo(connectView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }

        self.addSubview(measureButton)
        measureButton.snp.makeConstraints { make in
            make.top.equalTo(measureView.snp.bottom).offset(15)
            make.height.equalTo(40)
            make.width.equalTo(162)
            make.centerX.equalToSuperview()
        }

        let breakView = UIView()
        breakView.backgroundColor = UIColor(hex: "E7ECF0")
        self.addSubview(breakView)
        breakView.snp.makeConstraints { make in
            make.top.equalTo(measureButton.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(6)
        }

        let titleLabel = UILabel()
        titleLabel.text = L.measuringHistory.localized
        titleLabel.textColor = R.color.title()
        titleLabel.font = R.font.robotoBold(size: 16)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(breakView.snp.bottom).offset(20)
            make.leading.equalTo(connectView)
        }

        self.addSubview(syncImageView)
        syncImageView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(22)
            make.height.equalTo(22)
            make.trailing.equalToSuperview().inset(16)
        }

        self.addSubview(lastDateLabel)
        lastDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.syncImageView)
            make.trailing.equalTo(self.syncImageView.snp.leading).inset(-10)
        }

        self.addSubview(graphView)
        graphView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    @objc private func onProfileChange() {
        self.setSpO2State()
        let profileListDAO = GenericDAO<ProfileListModel>()
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else {
            return
        }
        if currentProfile.linkAccount != nil && !String.isNilOrEmpty(currentProfile.lastSyncDate) {
            self.lastDateLabel.isHidden = false
            self.lastDateLabel.text = currentProfile.lastSyncDate
            var dateSync = ""
            if currentProfile.lastSyncDate.contains("Đồng bộ lần cuối ") {
                dateSync = "Đồng bộ lần cuối:\n\(currentProfile.lastSyncDate.replacingOccurrences(of: "Đồng bộ lần cuối ", with: ""))"
                self.lastDateLabel.text = dateSync
            }
        } else {
            self.lastDateLabel.isHidden = true
        }
    }

    @objc private func handleSync() {
        self.delegate?.onButtonSyncDidTapped()
    }

    private func createConnectView() -> UIView {
        let view = UIView()
        view.cornerRadius = 16
        view.backgroundColor = self.isConnected ? R.color.mainColor() : UIColor(hex: "#BDBDBD")
        let bleIconImageView = UIImageView(image: R.image.ic_bluetooth())
        bleIconImageView.contentMode = .scaleAspectFit
        view.addSubview(bleIconImageView)
        bleIconImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }

        connectViewTitleLabel.text = self.isConnected ? R.string.localizable.connected() : R.string.localizable.disconnected()
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

    private func createMeasureView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white

        view.addSubview(spO2ArcView)
        spO2ArcView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.width - 16 * 2 - 20) / 2)
            make.height.equalTo((UIScreen.main.bounds.width - 16 * 2 - 20) / 2)
        }

        view.addSubview(pRArcView)
        pRArcView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.equalTo((UIScreen.main.bounds.width - 16 * 2 - 20) / 2)
            make.height.equalTo((UIScreen.main.bounds.width - 16 * 2 - 20) / 2)
        }

        let spO2Label = self.createSpO2Label()
        view.addSubview(spO2Label)
        spO2Label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalTo(spO2ArcView)
            make.bottom.equalTo(spO2ArcView.snp.top).offset(-16)
        }

        let PRLabel = self.createPRLabel()
        view.addSubview(PRLabel)
        PRLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalTo(pRArcView)
            make.bottom.equalTo(pRArcView.snp.top).offset(-16)
        }

        let spO2MinLabel = self.createBoundaryValueLabel(with: 70)
        let spO2MaxLabel = self.createBoundaryValueLabel(with: 100)
        let PRMinLabel = self.createBoundaryValueLabel(with: 30)
        let PRMaxLabel = self.createBoundaryValueLabel(with: 250)

        view.addSubview(spO2MinLabel)
        spO2MinLabel.snp.makeConstraints { make in
            make.top.equalTo(spO2ArcView.snp.bottom).offset(-10 )
            make.leading.equalTo(spO2ArcView.snp.leading).offset(16)
            make.bottom.equalToSuperview()
        }

        view.addSubview(spO2MaxLabel)
        spO2MaxLabel.snp.makeConstraints { make in
            make.centerY.equalTo(spO2MinLabel)
            make.trailing.equalTo(spO2ArcView.snp.trailing).offset(-16)
        }

        view.addSubview(PRMinLabel)
        PRMinLabel.snp.makeConstraints { make in
            make.centerY.equalTo(spO2MinLabel)
            make.leading.equalTo(pRArcView.snp.leading).offset(16)
        }

        view.addSubview(PRMaxLabel)
        PRMaxLabel.snp.makeConstraints { make in
            make.centerY.equalTo(spO2MinLabel)
            make.trailing.equalTo(pRArcView.snp.trailing).offset(-16)
        }
        return view
    }

    private func createSpO2Label() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = R.font.robotoBold(size: 18)
        label.textColor = R.color.title()
        label.text = R.string.localizable.spO2()
        return label
    }

    private func createSpO2ValueLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = R.font.robotoBold(size: 36)
        label.textColor = R.color.title()
        label.text = "--"
        return label
    }

    private func createPRLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = R.font.robotoBold(size: 18)
        label.textColor = R.color.title()
        label.text = R.string.localizable.pR()
        return label
    }

    private func createPRValueLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = R.font.robotoBold(size: 36)
        label.textColor = R.color.title()
        label.text = "--"
        return label
    }

    private func createSpO2MeasurementView() -> ArcChartView {
        let view = ArcChartView(valueType: .spO2)
        view.clipsToBounds = false
        view.addSubview(self.spO2ValueLabel)
        self.spO2ValueLabel.center(inView: view)
        view.backgroundColor = .white
        view.minValue = 70
        view.maxValue = 100
        return view
    }

    private func createPRMeasurementView() -> ArcChartView {
        let view = ArcChartView(valueType: .pR)
        view.addSubview(self.pRValueLabel)
        self.pRValueLabel.center(inView: view)
        view.backgroundColor = .white
        view.minValue = 30
        view.maxValue = 250
        return view
    }

    private func createBoundaryValueLabel(with value: Int) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = R.font.robotoMedium(size: 16)
        label.textColor = R.color.subTitle()
        label.text = String(value)
        return label
    }

    private func createButtonConnect() -> UIButton {
        let connectButton = UIButton()
        connectButton.isEnabled = false
        return connectButton
    }

    private func createBatteryView() -> SKBatteryView {
        let view = SKBatteryView()
        view.batteryViewBorderColor = R.color.subTitle()!
        view.batteryViewBorderWidth = 1
        view.batteryViewCornerRadius = 1
        view.highLevelColor = R.color.subTitle()!
        view.terminalLengthRatio = 0.15
        view.terminalWidthRatio = 0.4
        view.level = 50
        view.direction = .maxXEdge
        view.isHidden = true
        return view
    }

    private func createStopWatchView() -> SKStopWatchView {
        let view = SKStopWatchView()
        view.isHidden = true
        return view
    }

    private func createBatteryLevelLabel() -> UILabel {
        let label = UILabel()
        label.isHidden = true
        label.font = R.font.robotoRegular(size: 12)
        label.textColor = .black
        return label
    }

    private func createButtonMeasure() -> UIButton {
        let button = UIButton()
        button.setTitle(L.measurement.localized, for: .normal)
        button.backgroundColor = self.isConnected ? R.color.mainColor() : UIColor(hex: "#C8C9CA")
        button.isEnabled = self.isConnected
        button.cornerRadius = 20
        button.addTarget(self, action: #selector(buttonMeasureDidTapped), for: .touchUpInside)
        return button
    }

    private func createGraphView() -> SKGraphView {
        let graphView = SKGraphView(frame: .zero)
        graphView.needShowMeasurementCollectionView = false
        graphView.setFilterTypes(TimeFilterType.allCases)
        return graphView
    }

    // start measual.
    @objc func buttonMeasureDidTapped() {
        if measureButton.titleLabel?.text == R.string.localizable.stop_measurement() {
            self.stopStopWatch()
            delegate?.onButtonMeasureDidTapped(stop: true)
        } else {
            self.startStopWatch()
            measureButton.setTitle(R.string.localizable.stop_measurement(), for: .normal)
            delegate?.onButtonMeasureDidTapped(stop: false)
        }
    }

    func setMesuareButtonEnable(_ isEnable: Bool) {
        measureButton.isEnabled = isEnable
        measureButton.backgroundColor = isEnable ? R.color.blue() : .lightGray
    }

    func setConnectButtonState(_ isConnect: Bool) {
        self.isConnected = isConnect
        connectViewTitleLabel.text = isConnect ? R.string.localizable.connected() : R.string.localizable.disconnected()
        if SpO2DataHandler.shared.spO2Status == .measuring {
            measureButton.setTitle(R.string.localizable.stop_measurement(), for: .normal)
        } else {
            measureButton.setTitle(L.measurement.localized, for: .normal)
        }
        connectButton.superview?.backgroundColor = isConnect ? R.color.mainColor() : UIColor(hex: "#BDBDBD")
        measureButton.backgroundColor = isConnect ? R.color.mainColor() : UIColor(hex: "#C8C9CA")
        measureButton.isEnabled = isConnect
        if measureButton.titleLabel?.text != L.measurement.localized {
            measureButton.setTitle(L.measurement.localized, for: .normal)
        }
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

    func setTimeFilterDelegate(_ delegate: TimeFilterViewDelegate) {
        graphView.setTimeFilterDelegate(delegate)
    }

    func setTypes(_ types: [TimeFilterType]) {
        graphView.setFilterTypes(types)
    }
}

// MARK: - Helpers
extension SpO2TableViewHeader {
    /// Update battery level
    /// - Parameter level: battery level
    private func updateBateryState(at level: Int) {
        self.batteryLevelLabel.text = "\(level)%"
        self.batteryView.level = level
    }
    
    /// update initial level of battery
    /// - Parameter level: battery level
    func updateInitialBattery(at level: Int) {
        self.batteryLevelLabel.isHidden = false
        self.batteryView.isHidden = false
        self.batteryLevelLabel.text = "\(level)%"
        self.batteryView.level = level
    }

    /// Update measuring data
    /// - Parameter waveform: waveform data
    func updateData(with waveform: ViatomRealTimeWaveform) {
        guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else { return }
        if currentProfile == SpO2DataHandler.shared.measuringProfile && self.device.mac == SpO2DataHandler.shared.measuringDeviceMac {
            self.spO2ArcView.rotateGauge(newValue: CGFloat(waveform.spO2))
            self.pRArcView.rotateGauge(newValue: CGFloat(waveform.pr))
            self.spO2ValueLabel.attributedText = waveform.spo2Attribute
            self.pRValueLabel.attributedText = waveform.prAttribute
            self.updateBateryState(at: waveform.battery)
        } else {
            self.setStopMeasuring()
        }
    }

    /// Set graph data
    /// - Parameters:
    ///   - data: waveform data
    ///   - type: time filter type
    func setData(_ data: [[[WaveformModel]]], timeType: TimeFilterType, deviceType: DeviceType) {
        self.graphView.setData(data, timeType: timeType, deviceType: deviceType)
    }

    /// set spO2 state
    private func setSpO2State() {
        if SpO2DataHandler.shared.spO2Status == .measuring {
            guard let currentProfile = profileListDAO.getFirstObject()?.currentProfile else { return }
            if currentProfile == SpO2DataHandler.shared.measuringProfile && self.device.mac == SpO2DataHandler.shared.measuringDeviceMac {
                let startTime = Date().timeIntervalSince1970 - SpO2DataHandler.shared.startTime
                self.startStopWatch(at: Int(startTime))
                measureButton.setTitle(R.string.localizable.stop_measurement(), for: .normal)
            } else {
                self.stopStopWatch()
                measureButton.setTitle(L.measurement.localized, for: .normal)
            }
        } else {
            self.stopStopWatch()
            measureButton.setTitle(L.measurement.localized, for: .normal)
        }
    }

    /// Stop spO2 measuring
    func setStopMeasuring() {
        self.measureButton.setTitle(L.measurement.localized, for: .normal)
        self.spO2ArcView.rotateGauge(newValue: 70)
        self.pRArcView.rotateGauge(newValue: 30)
        self.spO2ValueLabel.text = "--"
        self.pRValueLabel.text = "--"
    }

    private func startStopWatch(at time: Int) {
        self.stopWatchView.isHidden = false
        self.stopWatchView.startTime(at: time)
    }

    private func startStopWatch() {
        self.stopWatchView.isHidden = false
        self.stopWatchView.startTime()
    }

    private func stopStopWatch() {
        self.stopWatchView.isHidden = true
        self.stopWatchView.stopTime()
    }
}
