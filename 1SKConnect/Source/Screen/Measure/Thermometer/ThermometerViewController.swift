//
//  
//  ThermometerViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 29/01/2021.
//
//

import UIKit
import CoreBluetooth

class ThermometerViewController: UIViewController {

    var presenter: ThermometerPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.onViewDidLoad()
    }

    @IBAction func scan(_ sender: Any) {
        presenter.onButtonScanDidTapped()
    }
}

// MARK: ThermometerViewController - ThermometerViewProtocol -
extension ThermometerViewController: ThermometerViewProtocol {
    
}
