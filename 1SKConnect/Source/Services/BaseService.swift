//
//  BaseService.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//

import Alamofire
import SwiftUI

struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!

    static var isConnectedToInternet: Bool {
        return self.sharedInstance.isReachable
    }
}

class BaseService {
    // Singleton
    static let shared = BaseService()
    private init() {
    }
    //
    private var headers: HTTPHeaders? {
        guard SKUserDefaults.shared.hasLogin, let tokenString = KeyChainManager.shared.accessToken else {
            return nil
        }
        return [
            "Authorization": "Bearer \(tokenString)"
        ]
    }

    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormat = DateFormatter()
        decoder.dateDecodingStrategy = .formatted(dateFormat)
        return decoder
    }

    // MARK: - REST
    func get<T: Codable>(url: ApiUrlProtocol,
                         param: [String: Any]?,
                         completion: @escaping ((Result<BaseModel<T>, APIError>) -> Void)) {
        let request = AF.request(url.fullURLString,
                                 method: .get,
                                 parameters: param,
                                 headers: headers)
        request.validate().responseDecodable(of: BaseModel<T>.self,
                                  decoder: jsonDecoder) { [weak self] (response: DataResponse<BaseModel<T>, AFError>) in
            guard let `self` = self else {
                return
            }
            completion(self.handleResponse(response))
        }
    }

    func post<T: Codable>(url: ApiUrlProtocol,
                          param: [String: Any]?,
                          encoding: ParameterEncoding = URLEncoding.default,
                          completion: @escaping ((Result<BaseModel<T>, APIError>) -> Void)) {
        let request = AF.request(url.fullURLString,
                                 method: .post,
                                 parameters: param,
                                 encoding: encoding,
                                 headers: headers)
        request.validate().responseDecodable(of: BaseModel<T>.self,
                                             decoder: jsonDecoder) { [weak self] (response: DataResponse<BaseModel<T>, AFError>) in
            guard let `self` = self else {
                return
            }
            completion(self.handleResponse(response))
        }
    }
    
    func post<T: Codable>(url: String,
                          param: [String: Any]?,
                          encoding: ParameterEncoding = URLEncoding.default,
                          completion: @escaping ((Result<BaseModel<T>, APIError>) -> Void)) {
        let request = AF.request(url,
                                 method: .post,
                                 parameters: param,
                                 encoding: encoding,
                                 headers: headers)
        request.validate().responseDecodable(of: BaseModel<T>.self,
                                             decoder: jsonDecoder) { [weak self] (response: DataResponse<BaseModel<T>, AFError>) in
            guard let `self` = self else {
                return
            }
            completion(self.handleResponse(response))
        }
    }

    func requestData(url: String, accessToken: String, method: HTTPMethod, params: Parameters!, completion: @escaping (_ success: Bool, _ message: String, _ result: [String: Any]) -> Void) {

        if Connectivity.isConnectedToInternet {
            let headers: HTTPHeaders = ["Content-Type": "application/json",
                                        "Authorization": "Bearer \(accessToken)"]

            AF.sessionConfiguration.timeoutIntervalForRequest = 120

            guard let path = URL(string: url) else {
                return
            }

            var encoding: Alamofire.ParameterEncoding = JSONEncoding.default
            if method == .get {
                encoding = URLEncoding.default
            } else {
                encoding = JSONEncoding.default
            }

            AF.request(path, method: method, parameters: params, encoding: encoding, headers: headers).validate(statusCode: 0 ..< 999).responseJSON { [weak self] AFdata in
                guard let `self` = self else { return }
                self.handleResponse(AFdata) { success, message, data in
                    dLogDebug("[API TOKEN]: \(accessToken)")
                    dLogDebug("[API URL]: \(url)")
                    dLogDebug("[API PARAMs]: \(String(describing: params))")
                    dLogDebug("[API RESPONSE]: \(data)")
                    completion(success, message, data)
                }
            }
        } else {
            dLogError("[NO INTERNET CONNECTION]")
            let data: [String: Any] = [:]
            completion(false, R.string.localizable.internet_error_not_connect(), data)
        }
    }
    
    func requestData(url: ApiUrlProtocol, method: HTTPMethod, params: Parameters!, completion: @escaping (_ success: Bool, _ message: String, _ result: [String: Any]) -> Void) {

        if Connectivity.isConnectedToInternet {
            let headers: HTTPHeaders = ["Content-Type": "application/json",
                                        "Authorization": "Bearer \(SKUserDefaults.shared.token)"]

            AF.sessionConfiguration.timeoutIntervalForRequest = 120

            guard let path = URL(string: url.fullURLString) else {
                return
            }

            var encoding: Alamofire.ParameterEncoding = JSONEncoding.default
            if method == .get {
                encoding = URLEncoding.default
            } else {
                encoding = JSONEncoding.default
            }

            AF.request(path, method: method, parameters: params, encoding: encoding, headers: headers).validate(statusCode: 0 ..< 999).responseJSON { [weak self] AFdata in
                guard let `self` = self else { return }
                self.handleResponse(AFdata) { success, message, data in
                    dLogDebug("[API TOKEN]: \(SKUserDefaults.shared.token)")
                    dLogDebug("[API URL]: \(url.fullURLString)")
                    dLogDebug("[API PARAMs]: \(String(describing: params))")
                    dLogDebug("[API RESPONSE]: \(data)")
                    completion(success, message, data)
                }
            }
        } else {
            dLogError("[NO INTERNET CONNECTION]")
            let data: [String: Any] = [:]
            completion(false, R.string.localizable.internet_error_not_connect(), data)
        }
    }

    func put<T: Codable>(url: ApiUrlProtocol,
                         param: [String: Any]?,
                         encoding: ParameterEncoding = JSONEncoding.prettyPrinted,
                         completion: @escaping ((Result<BaseModel<T>, APIError>) -> Void)) {
        let request = AF.request(url.fullURLString,
                                 method: .put,
                                 parameters: param,
                                 encoding: encoding,
                                 headers: headers)
        request.validate().responseDecodable(of: BaseModel<T>.self,
                                             queue: .main,
                                             decoder: jsonDecoder) { [weak self] (response: DataResponse<BaseModel<T>, AFError>) in
            guard let `self` = self else {
                return
            }
            completion(self.handleResponse(response))
        }
    }

    func delete<T: Codable>(url: ApiUrlProtocol,
                            param: [String: Any]?,
                            completion: @escaping ((Result<BaseModel<T>, APIError>) -> Void)) {
        let request = AF.request(url.fullURLString,
                                 method: .delete,
                                 parameters: param,
                                 headers: headers)
        request.validate().responseDecodable(of: BaseModel<T>.self,
                                             decoder: jsonDecoder) { [weak self] (response: DataResponse<BaseModel<T>, AFError>) in
            guard let `self` = self else {
                return
            }
            completion(self.handleResponse(response))
        }
    }

    func upload<T: Codable>(url: ApiUrlProtocol,
                            param: [String: String],
                            imageParam: [String: Data],
                            completion: @escaping (Result<T, APIError>) -> Void) {
        let request = AF.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in param {
                multipartFormData.append(value.data(using: .utf8)!, withName: key)
            }
            for (key, value) in imageParam {
                multipartFormData.append(value, withName: key, fileName: "\(key).jpeg", mimeType: "image/jpeg")
            }
        },
        to: url.fullURLString,
        usingThreshold: UInt64(),
        method: .post,
        headers: headers)
        request.validate().responseDecodable(of: T.self,
                                             decoder: jsonDecoder) { [weak self] (response: DataResponse<T, AFError>) in
            guard let `self` = self else {
                return
            }
            completion(self.handleResponse(response))
        }
    }

    func handleResponse(_ response: AFDataResponse<Any>, completion: @escaping (_ success: Bool, _ message: String, _ result: [String: Any]) -> Void) {
        switch response.result {
        case .success(let value):
            if let dict = value as? [String: Any] {
                completion(true, "", dict)
            } else {
                let data: [String: Any] = [:]
                completion(false, R.string.localizable.internet_error_data_error(), data)
            }
        case .failure(let error):
            print(error)
            let data: [String: Any] = [:]
            if error.localizedDescription.contains("timed out") {
                completion(false, R.string.localizable.internet_error_lost_connection(), data)
            } else {
                completion(false, error.localizedDescription, data)
            }
        }
    }

    func handleResponse<T: Codable>(_ response: DataResponse<T, AFError>) -> (Result<T, APIError>) {
        switch response.result {
        case .success(let value):
            return Result.success(value)
        case .failure(let error):
            if let data = response.data, let apiError = try? jsonDecoder.decode(APIError.self, from: data) {
                return Result.failure(apiError)
            } else {
                let code = response.response?.statusCode ?? -1
                if code == 403 || code == 401 {
                    handlerTokenExpire()
                }
                let message = error.errorDescription ?? "AFError"
                let apiError = APIError(message: message, statusCode: code)
                return Result.failure(apiError)
            }
        }
    }

    func handlerTokenExpire() {
        kNotificationCenter.post(name: .tokenExpire, object: nil)
    }

    func cancelAllRequest() {
        Alamofire.Session.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
}
