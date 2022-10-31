//
//  
//  MainHomeViewController.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//
//

import UIKit

class MainHomeViewController: BaseViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var profileCollectionView: UICollectionView!
    @IBOutlet weak var transparentView: UIView! // view has gesture to hide profile collection
    @IBOutlet weak var homeContainerView: UIView!
    @IBOutlet weak var profileCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var smartWatchImageView: UIImageView!
    @IBOutlet weak var syncImageView: UIImageView!
    
    var shadowLayer: CAShapeLayer?
    private var stopReload = false

    var presenter: MainHomePresenterProtocol!

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        presenter.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch self.presenter.childType {
        case.smartWatchS5:
            self.stopReload = false
            self.rotateView(targetView: self.syncImageView)
        default:
            return
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIView.setAnimationsEnabled(false)
        self.syncImageView.layer.removeAllAnimations() // remove layer based animations e.g. aview.layer.opacity
        UIView.setAnimationsEnabled(true)
    }

    // MARK: - Setup
    private func setupDefaults() {
        kNotificationCenter.addObserver(self, selector: #selector(finishSaveData), name: .finishSaveData, object: nil)
        kNotificationCenter.addObserver(self, selector: #selector(reloadSaveData), name: .reloadData, object: nil)
        self.topView.addShadow(width: 0, height: 4, color: .black, radius: 4, opacity: 0.1)
        setupCollectionView()
    }
    
    deinit {
        kNotificationCenter.removeObserver(self, name: .finishSaveData, object: nil)
        kNotificationCenter.removeObserver(self, name: .reloadData, object: nil)
    }

    @objc private func finishSaveData() {
        self.stopReload = true
        self.syncImageView.isHidden = true
    }

    @objc private func reloadSaveData() {
        self.syncImageView.isHidden = false
        self.stopReload = false
        self.rotateView(targetView: self.syncImageView)
    }
    
    func showShadow() {
        //        profileCollectionView.superview?.layer.shadowOpacity = 0.4
    }

    private func removeShadow() {
        //        profileCollectionView.superview?.layer.shadowOpacity = 0
    }

    private func setupCollectionView() {
        profileCollectionView.registerNib(ofType: AddProfileCollectionViewCell.self)
        profileCollectionView.registerNib(ofType: ProfileCollectionViewCell.self)
        profileCollectionView.dataSource = self
        profileCollectionView.delegate = self
        profileCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        profileCollectionView.backgroundColor = .white
    }

    private func addChildViewController(with type: MainHomePresenter.ChildViewType) {
        var childVC: UIViewController
        switch type {
        case .home:
            childVC = HomeRouter.setupModule()
        case .tracking:
            childVC = TrackingRouter.setupModule()
        case .scale(let scale):
            childVC = ScaleRouter.setupModule(with: scale)
        case .spO2(let spO2):
            childVC = SpO2Router.setupModule(with: spO2)
        case .bo(let bo):
            childVC = BloodPressureRouter.setupModule(with: bo)
        case .smartWatchS5(let smartWatch):
            childVC = SmartWatchS5Router.setupModule(with: smartWatch)
        }
        addChild(childVC)
        homeContainerView.addSubview(childVC.view)
        childVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        childVC.didMove(toParent: self)
    }

    // MARK: - Action
    @IBAction func buttonAvatarDidTapped(_ sender: Any) {
        presenter.onButtonAvatarDidTapped()
    }

    @IBAction func backgroundDidTapped(_ sender: Any) {
        presenter.onBackgroundDidTapped()
    }

    @IBAction func buttonHomeDidTapped(_ sender: Any) {
        presenter.onButtonHomeDidTapped()
    }

    @IBAction func buttonCreateProfileDidTapped(_ sender: Any) {
        presenter.onAddProfileCellDidSelected()
    }
}

// MARK: - MainHomeViewProtocol
extension MainHomeViewController: MainHomeViewProtocol {
    func reloadData(with currentProfile: ProfileModel?) {
        avatarImageView.setImage(currentProfile?.image, placeHolder: R.image.ic_default_avatar())
        profileCollectionView.reloadData()
        //        createProfileButton.isHidden = currentProfile != nil
        avatarImageView.superview?.isHidden = currentProfile == nil
    }

    func setProfileCollectionViewHidden(_ isHidden: Bool) {
        profileCollectionViewHeightConstraint.constant = isHidden ? 0 : 115
        if isHidden {
            removeShadow()
        } else {
            showShadow()
        }
        transparentView.isHidden = isHidden
        UIView.animate(withDuration: Constant.Number.animationTime) {
            self.chevronImageView.image = isHidden ? R.image.ic_down() : R.image.ic_up()
            self.view.layoutIfNeeded()
        }
    }

    func updateView(with type: MainHomePresenter.ChildViewType) {
        switch type {
        case .home:
            navigationTitleLabel.text = ""
            logoImageView.isHidden = false
            //            createProfileButton.isHidden = true
            homeButton.isHidden = true
            self.smartWatchImageView.isHidden = true
            self.syncImageView.isHidden = true
        case .tracking:
            navigationTitleLabel.text = L.tracking.localized
            logoImageView.isHidden = true
            //            createProfileButton.isHidden = true
            homeButton.isHidden = true
            self.smartWatchImageView.isHidden = true
            self.syncImageView.isHidden = true
        case .scale(let scale):
            navigationTitleLabel.text = "1SK - CF398 - \(scale.mac.suffix(4).pairs.joined(separator: ":"))"
            logoImageView.isHidden = true
            //            createProfileButton.isHidden = true
            homeButton.isHidden = false
            self.smartWatchImageView.isHidden = true
            self.syncImageView.isHidden = true
        case .spO2(let spO2):
            navigationTitleLabel.text = "Vivatom - \(spO2.name) - \(spO2.mac.suffix(4).pairs.joined(separator: ":"))"
            logoImageView.isHidden = true
            homeButton.isHidden = false
            self.smartWatchImageView.isHidden = true
            self.syncImageView.isHidden = true
        case .bo(let bo):
            navigationTitleLabel.text = "BioLight - WBP202 - \(bo.mac.suffix(4).pairs.joined(separator: ":"))"
            logoImageView.isHidden = true
            self.smartWatchImageView.isHidden = true
            self.syncImageView.isHidden = true
            homeButton.isHidden = false
        case .smartWatchS5(let smartWatch):
            logoImageView.isHidden = true
            navigationTitleLabel.text = smartWatch.name
            homeButton.isHidden = false
            self.smartWatchImageView.isHidden = false
            self.syncImageView.isHidden = false
        }
        addChildViewController(with: type)
    }
}

// MARK: - UICollectionViewDataSource
extension MainHomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfRow(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeuCell(ofType: ProfileCollectionViewCell.self, for: indexPath)
        let profileModel = presenter.itemForRow(at: indexPath)
        cell.config(with: profileModel, isCurrentProfile: presenter.isCurrentProfile(profileModel))
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        presenter.onProfileDidSelected(at: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 67, height: 115)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
}

// MARK: - Helpers
extension MainHomeViewController {
    private func rotateView(targetView: UIView, duration: Double = 1) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear) {
            targetView.transform = targetView.transform.rotated(by: CGFloat(Double.pi))
        } completion: { [weak self] _ in
            guard let `self` = self else { return }
            if !self.stopReload {
                self.rotateView(targetView: targetView, duration: duration)
            }
        }
    }
}
