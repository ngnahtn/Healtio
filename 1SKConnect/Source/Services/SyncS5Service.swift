//
//  SyncS5Service.swift
//  1SKConnect
//
//  Created by TrungDN on 14/03/2022.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol SyncS5ServiceProtocol: AnyObject {
    func sync(with model: BodyFatSyncModel, completion: @escaping ((_ data: BaseResponseModel?, _ status: Bool, _ message: String) -> Void))
}

class SyncS5Service: SyncS5ServiceProtocol {
    func sync(with model: BodyFatSyncModel, completion: @escaping ((BaseResponseModel?, Bool, String) -> Void)) {
    }
}
