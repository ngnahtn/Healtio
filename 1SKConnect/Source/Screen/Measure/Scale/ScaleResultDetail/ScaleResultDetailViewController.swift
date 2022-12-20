//
//  
//  ScaleResultDetailViewController.swift
//  1SKConnect
//
//  Created by Elcom Corp on 02/11/2021.
//
//

import UIKit

class ScaleResultDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var lineChart: ScaleResultRulerChart!
    @IBOutlet weak var bodyStandarView: ScaleResultCollectionChart!

    var presenter: ScaleResultDetailPresenterProtocol!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInit()
        self.presenter.onViewDidLoad()
    }

    // MARK: - Setup
    private func setupInit() {
    }

    // MARK: - Action
    @IBAction func handleBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - ScaleResultDetailViewProtocol
extension ScaleResultDetailViewController: ScaleResultDetailViewProtocol {
    func onViewDidLoad() {
        self.titleLabel.text = self.presenter.title
        self.descriptionLabel.text = self.presenter.description

        if let valueAttribute = self.presenter.valueAttribute {
            self.valueLabel.attributedText = valueAttribute
        } else {
            self.valueLabel.isHidden = true
        }

        if self.presenter.descriptionData is LBW || self.presenter.descriptionData is BodyType || self.presenter.descriptionData is BodyStandard {
            self.lineChart.isHidden = true
        }

        if self.presenter.descriptionData is BodyType {
            self.bodyStandarView.isHidden = false
            self.valueLabel.isHidden = true
        }
        self.bodyStandarView.setUpView(bodyFat: self.presenter.bodyFatData)
        self.lineChart.setUpView(with: self.presenter.descriptionData, bodyFat: self.presenter.bodyFatData)
    }
}
