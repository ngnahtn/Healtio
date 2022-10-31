//
//  
//  ScaleResultDetailPresenter.swift
//  1SKConnect
//
//  Created by Elcom Corp on 02/11/2021.
//
//

import UIKit

class ScaleResultDetailPresenter {

    weak var view: ScaleResultDetailViewProtocol?
    private var interactor: ScaleResultDetailInteractorInputProtocol
    private var router: ScaleResultDetailRouterProtocol
    var weightDetail: DetailsItemProtocol!
    var bodyFat: BodyFat!

    init(interactor: ScaleResultDetailInteractorInputProtocol,
         router: ScaleResultDetailRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

}

// MARK: - ScaleResultDetailPresenterProtocol
extension ScaleResultDetailPresenter: ScaleResultDetailPresenterProtocol {
    func onDismiss() {
        self.router.onDismiss()
    }

    var bodyFatData: BodyFat {
        return self.bodyFat
    }

    var descriptionData: DetailsItemProtocol {
        return self.weightDetail
    }

    var title: String {
        return self.weightDetail.navigationTitle
    }

    var description: String {
        return self.weightDetail.description
    }

    var valueAttribute: NSAttributedString? {
        let attributeString = NSMutableAttributedString(string: R.string.localizable.scale_result_detail_value(), attributes: [NSAttributedString.Key.font: R.font.robotoRegular(size: 16)!, NSAttributedString.Key.foregroundColor: R.color.subTitle()!])

        var valueString = "\(self.weightDetail.value.toString())"
        if !String.isNilOrEmpty(weightDetail.unit) {
            valueString = "\(self.weightDetail.value.toString()) (\(self.weightDetail.unit))"
        }
        if valueString == "0" {
            return nil
        }
        attributeString.append(NSAttributedString(string: valueString, attributes: [NSAttributedString.Key.font: R.font.robotoBold(size: 16)!, NSAttributedString.Key.foregroundColor: R.color.mainColor()!]))
        return attributeString
    }

    func onViewDidLoad() {
        self.view?.onViewDidLoad()
    }
}

// MARK: - ScaleResultDetailInteractorOutput 
extension ScaleResultDetailPresenter: ScaleResultDetailInteractorOutputProtocol {

}
