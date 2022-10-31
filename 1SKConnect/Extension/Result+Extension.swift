//
//  Result+Extension.swift
//  1SKConnect
//
//  Created by tuyenvx on 01/04/2021.
//

import Foundation
extension Result where Success: Codable {
    func unwrapSuccessModel<T>() -> Result<T, Failure> where Success == BaseModel<T>, Failure == APIError {
        return flatMap { (baseModel) -> Result<T, Failure> in
            if let data = baseModel.data {
                return .success(data)
            } else {
                let apiError = APIError(message: "Can not unwrap optional \(T.self)", statusCode: -1)
                return .failure(apiError)
            }
        }
    }

    func optionalSuccessModel<T>() -> Result<T?, Failure> where Success == BaseModel<T>, Failure == APIError {
        return map({ $0.data })
    }

    func getTotal<T>() -> Int? where Success == BaseModel<T> {
        switch self {
        case .success(let baseModel):
            return nil 
//            return baseModel.total
        case .failure:
            return nil
        }
    }
}
