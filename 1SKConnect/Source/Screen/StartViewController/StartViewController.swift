//
//  
//  StartViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//
//

import UIKit

class StartViewController: UIViewController {

    var presenter: StartPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.onViewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.onViewDidAppear()
    }

}

// MARK: StartViewController - StartViewProtocol -
extension StartViewController: StartViewProtocol {
}
