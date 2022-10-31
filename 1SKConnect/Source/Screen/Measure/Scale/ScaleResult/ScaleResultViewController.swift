//
//  
//  ScaleResultViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 22/03/2021.
//
//

import UIKit

class ScaleResultViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var weightDetailsView: WeightDetailsView!
    @IBOutlet weak var weightDetailViewHeightConstraint: NSLayoutConstraint!
    var presenter: ScaleResultPresenterProtocol!
    var transitionFrame: CGRect!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup
    private func setupDefaults() {
        navigationItem.title = "Kết quả đo"
        self.navigationController?.delegate = self
        setLeftBarButton(style: .close) { [weak self] (_) in
            self?.presenter.onCloseButtonDidTapped()
        }
        weightDetailsView.delegate = self
    }
    // MARK: - Action
    @IBAction func buttonCloseDidTapped(_ sender: Any) {
        presenter.onCloseButtonDidTapped()
    }
}

// MARK: ScaleResultViewController - ScaleResultViewProtocol -
extension ScaleResultViewController: ScaleResultViewProtocol {
    func reloadData(with bodyFat: BodyFat) {
        weightDetailsView.items = bodyFat.items

        weightDetailsView.reloadData(completion: { [weak self] in
            self?.weightDetailViewHeightConstraint.constant = self?.weightDetailsView.getHeight() ?? 0
        })

        timeLabel.text = bodyFat.createAt.toDate(.hmsdMy)?.toString(.hmdmy)
        let weight = bodyFat.weight.value ?? 0
        weightLabel.text = weight.toString()
        if let bmi = bodyFat.bmiEnum {
            statusLabel.text = bmi.status
            statusLabel.superview?.backgroundColor = bmi.color
        }
    }
}

// MARK: - WeightDetailsViewDelegate
extension ScaleResultViewController: WeightDetailsViewDelegate {
    func didSelect(cell inRect: CGRect, item: DetailsItemProtocol) {
        print("didSelect: \(inRect)")
        self.transitionFrame = inRect
        self.presenter.onGoToScaleResultDetail(with: item)
    }
}

// MARK: - UINavigationControllerDelegate
extension ScaleResultViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            let animator = SKPresentAnimator(startFrame: self.transitionFrame)
            return animator
        case .pop:
            let animator = SKDismissAnimator(toFrame: self.transitionFrame)
            return animator
        default:
            return nil
        }
    }
}
