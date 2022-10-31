//
//  ConfigService.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol ConfigServiceProtocol: AnyObject {
    func getNotificationNumber(of deviceToken: String, completion: @escaping ((Result<BaseModel<NotificationNumberModel>, APIError>) -> Void))
    func getListNotification(of userID: String,
                             page: Int,
                             limit: Int,
                             completion: @escaping ((Result<BaseModel<[NotificationModel]>, APIError>) -> Void))
    func updateNotificationStatus(of notificationId: String, completion: @escaping ((Result<BaseModel<NotificationModel>, APIError>) -> Void))
    func saveDeviceToken(_ token: String, completion: @escaping ((Result<BaseModel<EmptyModel>, APIError>) -> Void))

    func getUserInfo(with token: String, completion: @escaping ((UserLoginBaseModel?, Bool, String) -> Void))
    
    // MARK: - sync protocol
    func sync(with model: BodyFatSyncModel, accessToken: String, completion: @escaping ((_ data: SyncBaseModel?, _ status: Bool, _ message: String) -> Void))
    func sync(with userId: String, accessToken: String, page: Int, limit: Int, completion: @escaping ((_ data: SyncBaseModel?, _ status: Bool, _ message: String) -> Void))
    func syncDelete(with scaleids: [String], with bpids: [String], accessToken: String, completion: @escaping ((_ data: IntResponse?, _ status: Bool, _ message: String) -> Void))
    
    // MARK: - blood pressure sync protocol
    func createBpSync(with model: BloodPressureSyncModel, accessToken: String, completion: @escaping ((_ data: BloodPressureSyncBaseModel?, _ status: Bool, _ message: String) -> Void))
    func getBpSync(with userId: String, accessToken: String, page: Int, limit: Int, completion: @escaping ((_ data: BloodPressureSyncBaseModel?, _ status: Bool, _ message: String) -> Void))
}

class ConfigService: ConfigServiceProtocol {

    private let service = BaseService.shared
    static let share = ConfigService()
    
    func getUserInfo(with token: String, completion: @escaping ((UserLoginBaseModel?, Bool, String) -> Void)) {
        service.requestData(url: "https://id-dev.1sk.vn/api/customer/me", accessToken: token, method: .get, params: [:]) { success, message, result in
            let data = UserLoginBaseModel(JSON(result))
            completion(data, success, message)
        }
    }

    func getNotificationNumber(of deviceToken: String, completion: @escaping ((Result<BaseModel<NotificationNumberModel>, APIError>) -> Void)) {
        let param = [
            SKKey.deviceToken: deviceToken,
            SKKey.deviceType: "IOS"
        ]
        service.get(url: ConfigServiceAPI.notifyNumber, param: param, completion: completion)
    }

    func getListNotification(of userID: String,
                             page: Int,
                             limit: Int,
                             completion: @escaping ((Result<BaseModel<[NotificationModel]>, APIError>) -> Void)) {
        let param: [String: Any] = [
//            SKKey.userID: userID,
            SKKey.page: page,
            SKKey.limit: limit
        ]
        service.get(url: ConfigServiceAPI.notify, param: param, completion: completion)
    }

    func updateNotificationStatus(of notificationId: String, completion: @escaping ((Result<BaseModel<NotificationModel>, APIError>) -> Void)) {
        let param = [
            SKKey.notifyID: notificationId
        ]
        service.post(url: ConfigServiceAPI.updateNotifyStatus, param: param, encoding: JSONEncoding.prettyPrinted, completion: completion)
    }

    func saveDeviceToken(_ token: String, completion: @escaping ((Result<BaseModel<EmptyModel>, APIError>) -> Void)) {
        let param = [
            SKKey.deviceToken: token,
            SKKey.deviceType: "IOS"
        ]
        service.post(url: ConfigServiceAPI.saveDeviceToken, param: param, encoding: JSONEncoding.prettyPrinted, completion: completion)
    }
}

// MARK: - Login
extension ConfigService {
    func signInWithGoogle(with token: String, completion: @escaping ((Result<BaseModel<TokenModel>, APIError>) -> Void)) {
        let params = [
            SKKey.token: token
        ]

        service.post(url: "https://id-dev.1sk.vn/api/customer/google/callback", param: params, encoding: JSONEncoding.prettyPrinted, completion: completion)
    }

    func signInWithFacebook(with token: String, completion: @escaping ((Result<BaseModel<TokenModel>, APIError>) -> Void)) {
        let params = [
            SKKey.token: token
        ]
        service.post(url: "https://id-dev.1sk.vn/api/customer/fb/callback", param: params, encoding: JSONEncoding.prettyPrinted, completion: completion)
    }
}

// MARK: - Sync
extension ConfigService {
    func sync(with userId: String, accessToken: String, page: Int, limit: Int, completion: @escaping ((_ data: SyncBaseModel?, _ status: Bool, _ message: String) -> Void)) {
        let currentDate = Date()
        let params: [String: Any] = [
            SKKey.userId: userId,
            SKKey.page: page,
            SKKey.limit: limit,
            SKKey.fromDate: currentDate.scaleMonths.toString(.ymdhms),
            SKKey.toDate: currentDate.toString(.ymdhms)
        ]
        service.requestData(url: ConfigServiceAPI.syncData,
                            method: .get,
                            params: params) { success, message, data in
            let syncBaseModel = SyncBaseModel(JSON(data))
            completion(syncBaseModel, success, message)
        }
    }

    func sync(with model: BodyFatSyncModel, accessToken: String, completion: @escaping ((_ data: SyncBaseModel?, _ status: Bool, _ message: String) -> Void)) {
        service.requestData(url: ConfigServiceAPI.syncData,
                            method: .post,
                            params: model.toDictionary()) { success, message, data in
            let data = SyncBaseModel(JSON(data))
            completion(data, success, message)
        }
    }

    func syncDelete(with scaleids: [String], with bpids: [String], accessToken: String, completion: @escaping ((_ data: IntResponse?, _ status: Bool, _ message: String) -> Void)) {
        
        let params: [String: Any] = [
            SKKey.smartScale: scaleids,
            SKKey.spO2: [],
            SKKey.bloodpressure: bpids
        ]
        service.requestData(url: ConfigServiceAPI.syncDelete,
                            method: .delete,
                            params: params) { success, message, data in
            let data = IntResponse(JSON(data))
            completion(data, success, message)
        }
    }
}

// MARK: BloodPressure Sync
extension ConfigService {

    func getBpSync(with userId: String, accessToken: String, page: Int, limit: Int, completion: @escaping ((BloodPressureSyncBaseModel?, Bool, String) -> Void)) {
        let currentDate = Date()
        let params: [String: Any] = [
            SKKey.userId: userId,
            SKKey.page: page,
            SKKey.limit: limit,
            SKKey.fromDate: currentDate.spO2Months.toString(.ymdhms),
            SKKey.toDate: currentDate.toString(.ymdhms)
        ]
        service.requestData(url: ConfigServiceAPI.bloodPressureSyncData,
                            method: .get,
                            params: params) { success, message, data in
            let syncBaseModel = BloodPressureSyncBaseModel(JSON(data))
            completion(syncBaseModel, success, message)
        }
    }

    func createBpSync(with model: BloodPressureSyncModel, accessToken: String, completion: @escaping ((BloodPressureSyncBaseModel?, Bool, String) -> Void)) {
        service.requestData(url: ConfigServiceAPI.bloodPressureSyncData,
                            method: .post,
                            params: model.toDictionary()) { success, message, data in
            let data = BloodPressureSyncBaseModel(JSON(data))
            completion(data, success, message)
        }
    }
}
