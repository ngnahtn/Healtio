//
//  
//  S5NotificationSettingInteractorInput.swift
//  1SKConnect
//
//  Created by Be More on 25/01/2022.
//
//

import UIKit
import TrusangBluetooth

struct S5AppNoticeSettig {
    var title: String
    var status: Bool
}

class S5NotificationSettingInteractorInput {
    weak var output: S5NotificationSettingInteractorOutputProtocol?
    let noticeProcessor = ZHJMessageNoticeProcessor()
}

// MARK: - S5NotificationSettingInteractorInputProtocol
extension S5NotificationSettingInteractorInput: S5NotificationSettingInteractorInputProtocol {

    // handle read s5AppNoticeState
    func readNotice() {
        self.noticeProcessor.readMessageNotice { [weak self] (results) in
            guard let self = self else { return }
            self.output?.onReadNoticeFinished(notice: results)
        }
    }
}
