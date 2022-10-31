//
//  
//  WeightMeasuringViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 06/04/2021.
//
//

import UIKit

class WeightMeasuringViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scaleImageView: UIImageView!
    @IBOutlet weak var guildView: UIView!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightUnitLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weightView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var measuringLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var weightDetailsView: WeightDetailsView!
    @IBOutlet weak var seperatorLine: UIView!

    @IBOutlet weak var weightViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var weightViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var weightDetailViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var kilogamLabelCenterYConstraint: NSLayoutConstraint!
    private var percentLayer = CAShapeLayer()
    private var transitionFrame: CGRect = CGRect()

    var presenter: WeightMeasuringPresenterProtocol!
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.onViewDidDisappear()
    }
    // MARK: - Setup
    private func setupDefaults() {
        self.navigationController?.delegate = self
        update(with: .waiting)
    }
    // MARK: - Action

    @IBAction func buttonCloseDidTapped(_ sender: Any) {
        presenter.onButtonCloseDidTapped()
    }

    private func drawPercent(percent: CGFloat) {
        percentLayer.removeFromSuperlayer()
        let progressViewWidth = weightViewWidthConstraint.constant * 237 / 257
        let pi = CGFloat.pi
        let path = UIBezierPath(arcCenter: CGPoint(x: progressViewWidth / 2, y: progressViewWidth / 2),
                                radius: progressViewWidth / 2,
                                startAngle: -pi / 2.0,
                                endAngle: -pi / 2.0 + percent * 2 * pi,
                                clockwise: true)
        percentLayer.path = path.cgPath
        percentLayer.fillColor = UIColor.clear.cgColor
        percentLayer.strokeColor = R.color.mainColor()?.cgColor
        percentLayer.lineWidth = progressViewWidth / 2
        progressView.layer.addSublayer(percentLayer)
    }

    private func startAnimation() {
        CATransaction.begin()
        drawPercent(percent: 1)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 5
        animation.repeatCount = .infinity
        percentLayer.add(animation, forKey: "SKProgressAnimation")
        CATransaction.commit()
    }
}

// MARK: - WeightMeasuringViewProtocol
extension WeightMeasuringViewController: WeightMeasuringViewProtocol {
    func update(with weight: Double) {
        if kilogamLabelCenterYConstraint.constant == 0 {
            kilogamLabelCenterYConstraint.constant = 13
        }
        weightLabel.text = weight.toString()

    }

    func setScaleImage(_ image: UIImage?) {
        scaleImageView.image = image
    }

    func update(with state: WeightMeasuringPresenter.State) {
        if state == .measuring {
            startAnimation()
        } else if state == .finish {
            percentLayer.removeAnimation(forKey: "SKProgressAnimation")
        }
        let isFinish = state == .finish
        titleLabel.text = isFinish ? L.measuringResult.localized : L.weightMeasuring.localized
        guildView.isHidden = state != .waiting
        timeLabel.isHidden = state != .finish
        statusLabel.superview?.isHidden = !isFinish
        seperatorLine.isHidden = !isFinish
        weightDetailsView.isHidden = !isFinish
        weightDetailViewHeightConstraint.constant = weightDetailsView.getHeight()
        measuringLabel.isHidden = state != .measuring
        weightViewTopConstraint.constant = isFinish ? 35 : 100
        weightViewWidthConstraint.constant = isFinish ? 206 : 257
        weightView.cornerRadius = isFinish ? 103 : 128.5
        let progressViewWidth = weightViewWidthConstraint.constant * 237 / 257
        progressView.cornerRadius = progressViewWidth / 2
        progressView.alpha = 0
        weightLabel.superview?.superview?.cornerRadius = (weightViewWidthConstraint.constant * 196 / 257) / 2
        UIView.animate(withDuration: Constant.Number.animationTime) {
            self.view.layoutIfNeeded()
            self.progressView.alpha = 1
            self.progressView.backgroundColor = isFinish ? R.color.mainColor() : UIColor(hex: "DEECEC")
            self.weightLabel.font = R.font.robotoMedium(size: isFinish ? 49 : 64)
            self.weightUnitLabel.font = UIFont(name: "Helvetica", size: isFinish ? 20 : 24)
        }
    }

    func update(with bodyfat: BodyFat) {
        weightDetailsView.items = bodyfat.items
        weightDetailsView.delegate = self
        weightDetailsView.reloadData(completion: { [weak self] in
            self?.weightDetailViewHeightConstraint.constant = self?.weightDetailsView.getHeight() ?? 0
        })
        timeLabel.text = bodyfat.createAt.toDate(.hmsdMy)?.toString(.hmdmy)
        let weight = bodyfat.weight.value ?? 0
        weightLabel.text = weight.toString()
        if let bmi = bodyfat.bmiEnum {
            statusLabel.text = bmi.status
            statusLabel.superview?.backgroundColor = bmi.color
        }
    }

}

// MARK: - WeightDetailsViewDelegate
extension WeightMeasuringViewController: WeightDetailsViewDelegate {
    func didSelect(cell inRect: CGRect, item: DetailsItemProtocol) {
        self.transitionFrame = inRect
        self.presenter.onGoToScaleResultDetail(with: item)
    }
}

// MARK: - UINavigationControllerDelegate
extension WeightMeasuringViewController: UINavigationControllerDelegate {
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
