//
//  
//  ScaleResultDetailConstract.swift
//  1SKConnect
//
//  Created by Elcom Corp on 02/11/2021.
//
//

import UIKit

// MARK: - View
protocol ScaleResultDetailViewProtocol: AnyObject {
    func onViewDidLoad()
}

// MARK: - Presenter
protocol ScaleResultDetailPresenterProtocol {
    var title: String { get }
    var description: String { get }
    var valueAttribute: NSAttributedString? { get }
    var descriptionData: DetailsItemProtocol { get }
    var bodyFatData: BodyFat { get }

    func onViewDidLoad()
    func onDismiss()
}

// MARK: - Interactor Input
protocol ScaleResultDetailInteractorInputProtocol {

}

// MARK: - Interactor Output
protocol ScaleResultDetailInteractorOutputProtocol: AnyObject {
}

// MARK: - Router
protocol ScaleResultDetailRouterProtocol {
    func onDismiss()
}
