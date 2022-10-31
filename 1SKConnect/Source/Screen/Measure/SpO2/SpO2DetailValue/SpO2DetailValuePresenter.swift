//
//  
//  SpO2DetailValuePresenter.swift
//  1SKConnect
//
//  Created by TrungDN on 16/11/2021.
//
//

import UIKit

class SpO2DetailValuePresenter {

    weak var view: SpO2DetailValueViewProtocol?
    private var interactor: SpO2DetailValueInteractorInputProtocol
    private var router: SpO2DetailValueRouterProtocol
    var waveformList: WaveformListModel!

    init(interactor: SpO2DetailValueInteractorInputProtocol,
         router: SpO2DetailValueRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - SpO2DetailValuePresenterProtocol
extension SpO2DetailValuePresenter: SpO2DetailValuePresenterProtocol {
    func waveform(at index: Int) -> WaveformModel? {
        if index > self.waveformList.waveforms.array.count {
            return nil
        }
        return self.waveformList.waveforms.array[index]
    }

    func onViewDidLoad() {
        self.view?.setupData(with: self.waveformList)
    }
}

// MARK: - SpO2DetailValueInteractorOutput 
extension SpO2DetailValuePresenter: SpO2DetailValueInteractorOutputProtocol {

}
