//
//  
//  StartInteractorInput.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//
//

import UIKit

class StartInteractorInput {
    weak var output: StartInteractorOutputProtocol?
    var configService: ConfigServiceProtocol?
}

// MARK: - StartInteractorInput - StartInteractorInputProtocol -
extension StartInteractorInput: StartInteractorInputProtocol {
    func getNumberNotification(_ token: String) {
        configService?.getListNotification(of: "", page: 1, limit: 1, completion: { [weak self] result in
            self?.output?.onGetNumberNotificationFinished(with: result.getTotal() ?? 0)
        })
    }
}
