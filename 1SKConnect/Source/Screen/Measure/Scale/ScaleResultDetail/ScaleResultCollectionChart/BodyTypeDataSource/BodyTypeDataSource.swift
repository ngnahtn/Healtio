//
//  BodyTypeDataSource.swift
//  1SKConnect
//
//  Created by Elcom Corp on 05/11/2021.
//

import Foundation

struct BodyTypeDataSource {
    static let shared = BodyTypeDataSource()
    
    var dataSource: [BodyTypeModel] = [BodyTypeModel(title: R.string.localizable.lFatMuscle(), bodyType: .lFatMuscle),
                                       BodyTypeModel(title: R.string.localizable.obesFat(), bodyType: .obesFat),
                                       BodyTypeModel(title: R.string.localizable.muscleFat(), bodyType: .muscleFat),
                                       BodyTypeModel(title: R.string.localizable.lackofexercise(), bodyType: .lackofexercise),
                                       BodyTypeModel(title: R.string.localizable.standard(), bodyType: .standard),
                                       BodyTypeModel(title: R.string.localizable.muscular(), bodyType: .muscular),
                                       BodyTypeModel(title: R.string.localizable.thin(), bodyType: .thin),
                                       BodyTypeModel(title: R.string.localizable.standardMuscle(), bodyType: .standardMuscle),
                                       BodyTypeModel(title: R.string.localizable.lThinMuscle(), bodyType: .lThinMuscle)]
}
