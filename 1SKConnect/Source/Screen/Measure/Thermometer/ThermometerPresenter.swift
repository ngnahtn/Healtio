//
//  
//  ThermometerPresenter.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//
//

import UIKit
import CoreBluetooth

class ThermometerPresenter {
    private var bluetoothManager = BluetoothConnection()
    private var temperatureUUID = CBUUID(string: "0xFFE1")

    weak var view: ThermometerViewProtocol?
    private var interactor: ThermometerInteractorInputProtocol
    private var router: ThermometerRouterProtocol

    init(interactor: ThermometerInteractorInputProtocol,
         router: ThermometerRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - extending ThermometerPresenter: ThermometerPresenterProtocol -
extension ThermometerPresenter: ThermometerPresenterProtocol {
    func onViewDidLoad() {
        bluetoothManager.delegate = self
        bluetoothManager.servicesUUID = [CBUUID(string: "0xFFE0")]
    }

    func onButtonScanDidTapped() {
        if bluetoothManager.checkBluetoothStatusAvailble() {
            bluetoothManager.scanForDevice()
        }
    }
}

// MARK: - ThermometerPresenter: ThermometerInteractorOutput -
extension ThermometerPresenter: ThermometerInteractorOutputProtocol {

}
// MARK: - BlueTooth
extension ThermometerPresenter: BluetoothConnectionDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

    }

    func centralManagerDidUpdateState(_ centraManager: CBCentralManager) {

    }

    func showTurnOnBluetoothAlert() {

    }

    func isSearchingPeripheral(_ peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) -> Bool {
        print(peripheral.name ?? "")
        return peripheral.name?.contains("BLT_") ?? false
    }

    func didConnect(to peripheral: CBPeripheral) {
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let temperatureCharacteristic = service.characteristics?.first(where: { $0.uuid ==  temperatureUUID}) {
            peripheral.setNotifyValue(true, for: temperatureCharacteristic)
        }
    }

    func handleUpdateData(bytes: [UInt8], of characteristic: CBCharacteristic) {
        guard let bioData = BiolightData(data: bytes) else {
            return
        }
        if let dataBlock = bioData.dataBlock, dataBlock.id.hexString() == "11", dataBlock.dataSegment.count >= 3 {
            let lowerTemperature = bytes[1]
            let higherTemperature = bytes[2]
            let temperature = Double(Int(higherTemperature) * 256 + Int(lowerTemperature)) * 0.01
            print(temperature)
        }
    }
}
