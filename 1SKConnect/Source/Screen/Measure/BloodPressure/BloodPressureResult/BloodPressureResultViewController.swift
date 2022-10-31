//
//  
//  BloodPressureResultViewController.swift
//  1SKConnect
//
//  Created by admin on 19/11/2021.
//
//

import UIKit

class BloodPressureResultViewController: BaseViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bloodPressureLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var errorTopView: UIView!
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var bpGraphView: BloodPressureGraphView!

    @IBOutlet weak var constraint_height_TopView: NSLayoutConstraint!
    @IBOutlet weak var constraint_height_ErrorImageView: NSLayoutConstraint!
    @IBOutlet weak var constraint_height_StateLabel: NSLayoutConstraint!
    var measureDate = Date() {
        didSet {
            let hour = self.measureDate.toString(.hm)
            let day = self.measureDate.toString(.dmySlash)
            self.dateLabel.text = "\(hour),  \(day)"
        }
    }
    var isErrorTopViewHide: Bool = false {
        didSet {
            errorTopView.isHidden = isErrorTopViewHide
            if errorTopView.isHidden == true {
                self.constraint_height_TopView.constant = 0
                self.constraint_height_ErrorImageView.constant = 0
            } else {
                self.stateLabel.isHidden = true
                self.bpGraphView.isDataNil = true
            }
            self.errorImageView.layoutIfNeeded()
            self.errorTopView.layoutIfNeeded()
        }
    }
    var presenter: BloodPressureResultPresenterProtocol!

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

    @IBAction func onCloseButtonTap(_ sender: UIButton) {
        presenter.sendBackToBloodPressureVC(from: self)
    }
}

// MARK: - BloodPressureResultViewProtocol
extension BloodPressureResultViewController: BloodPressureResultViewProtocol {

    func showData(with data: BloodPressureModel?, with errorText: String) {
        self.errorLabel.text = errorText
        if data != nil {
            guard let unwrappedData = data else {return}
            self.isErrorTopViewHide = true
            self.bloodPressureLabel.text = "\(unwrappedData.sys.value ?? 0)/\(unwrappedData.dia.value ?? 0)/\(unwrappedData.map.value ?? 0)"
            self.heartRateLabel.text = "\(unwrappedData.pr.value ?? 0)"
            self.stateLabel.text = unwrappedData.state.title
            self.stateLabel.textColor = unwrappedData.state.color
            self.bpGraphView.view_Circle.backgroundColor = unwrappedData.state.color
            let date = unwrappedData.date.toDate()
            self.measureDate = date
            DispatchQueue.main.async {
                self.bpGraphView.setContraintForPointView(xValue: CGFloat(unwrappedData.dia.value ?? 0), yValue: CGFloat(unwrappedData.sys.value ?? 0))
            }
        } else {
            self.isErrorTopViewHide = false
            self.measureDate = Date()
        }
    }
}
