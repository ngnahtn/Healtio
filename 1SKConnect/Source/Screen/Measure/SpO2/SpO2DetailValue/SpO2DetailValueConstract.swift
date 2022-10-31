//
//  
//  SpO2DetailValueConstract.swift
//  1SKConnect
//
//  Created by TrungDN on 16/11/2021.
//
//

import UIKit

// MARK: - View
protocol SpO2DetailValueViewProtocol: AnyObject {
    func setupData(with waveform: WaveformListModel)
}

// MARK: - Presenter
protocol SpO2DetailValuePresenterProtocol {
    func onViewDidLoad()

    func waveform(at index: Int) -> WaveformModel?
}

// MARK: - Interactor Input
protocol SpO2DetailValueInteractorInputProtocol {

}

// MARK: - Interactor Output
protocol SpO2DetailValueInteractorOutputProtocol: AnyObject {
    
}

// MARK: - Router
protocol SpO2DetailValueRouterProtocol {

}
