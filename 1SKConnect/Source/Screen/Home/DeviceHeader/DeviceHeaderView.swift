//
//  DeviceHeaderView.swift
//  1SKConnect
//
//  Created by tuyenvx on 24/02/2021.
//

import UIKit

protocol DeviceHeaderViewDelegate: AnyObject {
    func onSelectDevice(at index: Int)
    func onAddDeviceDidSelected()
    func onLinkDeviceButtonDidTapped()
}

class DeviceHeaderView: UIView {
    private lazy var collectionView: UICollectionView = createCollectionView()
    private lazy var emptyDevicesView: UIView = createEmptyDevicesView()
    private lazy var addDeviceView: UIView = createAddDeviceView()
    private let leadingOffset: CGFloat = 16
    private let titleHeight = 36

    private var devices: [DeviceModel] = []
    weak var delegate: DeviceHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpDefaults()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpDefaults()
    }
    // MARK: - Setup
    private func setUpDefaults() {
        backgroundColor = .white
        let myDeviceLabel = UILabel()
        myDeviceLabel.text = L.myDevice.localized.localizedUppercase
        myDeviceLabel.font = R.font.robotoBold(size: 16)
        myDeviceLabel.textColor = R.color.title()
        addSubview(myDeviceLabel)
        myDeviceLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(leadingOffset)
            make.height.equalTo(titleHeight)
        }

        addSubview(addDeviceView)
        addDeviceView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(leadingOffset)
            make.width.greaterThanOrEqualTo(0)
            make.height.equalTo(28)
        }

        setupCollectionView()

        let breakView = UIView()
        breakView.backgroundColor = UIColor(hex: "E7ECF0")
        addSubview(breakView)
        breakView.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom).offset(6)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(6)
        }
    }

    private func createAddDeviceView() -> UIView {
        let addDeviceView = UIView()
        addDeviceView.backgroundColor = R.color.mainColor()
        addDeviceView.cornerRadius = 14

        let imageView = UIImageView(image: R.image.ic_add_white())
        addDeviceView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.width.height.equalTo(10)
        }

        let titleLabel = UILabel()
        titleLabel.text = L.addDevice.localized
        titleLabel.textColor = .white
        titleLabel.font = R.font.robotoRegular(size: 14)

        addDeviceView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imageView.snp.trailing).offset(3)
            make.trailing.equalToSuperview().inset(8)
        }

        let addDeviceButton = UIButton()
        addDeviceButton.addTarget(self, action: #selector(onButtonAddDeviceDidTapped), for: .touchUpInside)
        addDeviceView.addSubview(addDeviceButton)
        addDeviceButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        return addDeviceView
    }

    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 90)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset.left = leadingOffset
        collectionView.contentInset.right = leadingOffset
        return collectionView
    }

    private func createEmptyDevicesView() -> UIView {
        let emptyDevicesView = UIView()
        emptyDevicesView.backgroundColor = .white
        addSubview(emptyDevicesView)
        emptyDevicesView.snp.makeConstraints { (make) in
            make.edges.equalTo(collectionView)
        }
        let titleLabel = UILabel()
        titleLabel.text = L.youDoNotHaveAnyDevice.localized
        titleLabel.textColor = R.color.subTitle()
        titleLabel.font = R.font.robotoRegular(size: 14)
        titleLabel.textAlignment = .center
        emptyDevicesView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(leadingOffset)
            make.trailing.equalToSuperview().inset(leadingOffset)
        }
        let linkDeviceButton = UIButton()
        linkDeviceButton.addTarget(self, action: #selector(linkDeviceButtonDidTapped), for: .touchUpInside)
        linkDeviceButton.setTitle(L.linkDevice.localized, for: .normal)
        linkDeviceButton.titleLabel?.font = R.font.robotoRegular(size: 16)
        linkDeviceButton.setTitleColor(.white, for: .normal)
        linkDeviceButton.backgroundColor = R.color.mainColor()
        linkDeviceButton.cornerRadius = 20
        emptyDevicesView.addSubview(linkDeviceButton)
        linkDeviceButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.height.equalTo(40)
            make.width.equalTo(146)
        }
        return emptyDevicesView
    }

    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(titleHeight + 15)
            make.leading.trailing.equalToSuperview()
        }
        collectionView.registerNib(ofType: DeviceCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    // MARK: - Action
    func setDevices(_ devices: [DeviceModel]) {
        self.devices = devices
        emptyDevicesView.isHidden = !devices.isEmpty
        addDeviceView.isHidden = devices.isEmpty
        collectionView.reloadData()
    }

    @objc func linkDeviceButtonDidTapped() {
        delegate?.onLinkDeviceButtonDidTapped()
    }

    func reloadRow(at index: IndexPath) {
        collectionView.reloadItems(at: [index])
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    @objc func onButtonAddDeviceDidTapped() {
        delegate?.onAddDeviceDidSelected()
    }
}
// MARK: - UICollectionViewDataSource
extension DeviceHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeuCell(ofType: DeviceCollectionViewCell.self, for: indexPath)
        cell.config(with: devices[indexPath.row])
        return cell
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension DeviceHeaderView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.onSelectDevice(at: indexPath.row)
    }
}
