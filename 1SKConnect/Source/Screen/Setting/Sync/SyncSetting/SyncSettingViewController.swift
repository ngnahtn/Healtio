//
//  SyncSettingViewController.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import UIKit
import RealmSwift
import GoogleSignIn
import FBSDKLoginKit

class SyncSettingViewController: BaseViewController {

    // MARK: - Properties
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var syncSwich: SKSwitch!
    @IBOutlet weak var syncIconImageView: UIImageView!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var linkIconImageView: UIImageView!
    @IBOutlet weak var linkAccountIconImageView: UIImageView!
    @IBOutlet weak var syncLabel: UILabel!
    @IBOutlet weak var linkDescriptionLabel: UILabel!
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var facebookSignInButton: UIButton!
    @IBOutlet weak var lastDateLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var facebookButtonWidthAnchor: NSLayoutConstraint!
    var presenter: SyncSettingPresenter!
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.closeButton.isHidden = self.navigationController != nil
        navigationItem.title = L.syncData.localized
        self.setupDefaults()
        self.presenter.onViewDidLoad()
    }

    @IBAction func googleSignIn(_ sender: Any) {
//        let config = GIDConfiguration(clientID: Constant.Client.googleCilentID)
//        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] (user,error) in
//            guard error == nil else { return dLogError(error!.localizedDescription) }
//            guard
//                let authentication = user?.authentication,
//                let idToken = authentication.idToken
//            else { return }
//            self?.showHud()
//            dLogDebug("[TOKEN Google: \(idToken)]")
//            ConfigService.share.signInWithGoogle(with: idToken) { [weak self] result in
//                guard let `self` = self else { return }
//                self.hideHud()
//                switch result {
//                case .success(let tokenModel):
//                    SKUserDefaults.shared.token = tokenModel.data?.accessToken ?? ""
//                    self.getUserInfo(with: tokenModel.data, isGoogleAccount: true)
//                case .failure:
//                    self.presenter.saveLinkedAccount(with: nil, isGoogleAccount: true)
//                }
//            }
//        }
    }

    @IBAction func handleClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func facebookSignIn(_ sender: Any) {
        let fbLoginManager = LoginManager()
        if  AccessToken.current != nil {
            fbLoginManager.logOut()
        }
        fbLoginManager.logIn(permissions: Constant.Client.facebookPermission, from: self) { result, _ in
            guard let token = result?.token?.tokenString else { return }
            self.showHud()
            dLogDebug("[TOKEN Facebook: \(token)]")
            ConfigService.share.signInWithFacebook(with: token) { [weak self] result in
                guard let `self` = self else { return }
                self.hideHud()
                switch result {
                case .success(let tokenModel):
                    self.getUserInfo(with: tokenModel.data, isGoogleAccount: false)
                case .failure:
                    self.presenter.saveLinkedAccount(with: nil, isGoogleAccount: false)
                }
            }
        }
    }
}

// MARK: - Selector
extension SyncSettingViewController {
    @objc private func onFindDeviceSwitchValueChange(_ sender: SKSwitch) {
        if sender.isOn {
            self.presenter.didSwitchSync()
        } else {
            self.presenter.didSwitchOffSync()
        }
        self.syncIconImageView.isHidden = !sender.isOn
    }

    @objc private func handleTapLink(_ sender: UITapGestureRecognizer) {
        self.presenter.didTapButtonLink()
    }

    @objc private func handleSync(_ sender: UITapGestureRecognizer) {
        self.presenter.didTapSync()
    }
}

// MARK: - Helpers
extension SyncSettingViewController {
    private func setupDefaults() {
        self.setUpSwitch()
        self.setUpSyncDate()
        self.setUpGesture()
        self.setUpGoogleSignIn()
    }

    private func setUpUnderlineText(didLinkAccout: Bool) {
        if didLinkAccout {
            self.linkLabel.isHidden = false
            self.linkIconImageView.isHidden = false
            self.linkAccountIconImageView.isHidden = false
            self.facebookSignInButton.isHidden = true
            self.googleSignInButton.isHidden = true

            if let linkAccount = self.presenter.profile?.linkAccount {
                if !linkAccount.isGoogleAccount {
                    self.linkAccountIconImageView.image = R.image.ic_facebook()
                } else {
                    self.linkAccountIconImageView.image = R.image.ic_google()
                }
            }

            self.linkDescriptionLabel.isHidden = false
            guard let linkAccount = self.presenter.profile?.linkAccount else {
                return
            }
            if linkAccount.isGoogleAccount {
                self.linkDescriptionLabel.text = R.string.localizable.sync_linked_account(linkAccount.email ?? "")
            } else {
                self.linkDescriptionLabel.text = R.string.localizable.sync_facebook()
            }
        } else {
            self.linkLabel.isHidden = true
            self.linkIconImageView.isHidden = true
            self.linkAccountIconImageView.isHidden = true
            self.facebookSignInButton.isHidden = false
            if let profile = self.presenter.profile {
                if profile.relation.value == .yourSelf {
                    self.facebookSignInButton.isHidden = false
                    self.facebookButtonWidthAnchor.constant = 25
                } else {
                    self.facebookSignInButton.isHidden = true
                    self.facebookButtonWidthAnchor.constant = 0
                }
            }
            self.googleSignInButton.isHidden = false
            self.linkDescriptionLabel.isHidden = true
            if self.syncSwich.isOn {
                self.syncIconImageView.isHidden = true
                self.syncSwich.animate(false)
            }
            self.lastDateLabel.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    private func setUpSwitch() {
        syncSwich.tintColor = UIColor(hex: "E7ECF0")
        syncSwich.onTintColor = UIColor(hex: "AEEBEC")
        syncSwich.offTintColor = R.color.background()!
        syncSwich.thumbTintOnColor = R.color.mainColor()!
        syncSwich.thumbTintOffColor = .white
        syncSwich.thumbSize = CGSize(width: 22, height: 22)
        self.syncSwich.isOn = self.presenter.profile?.enableAutomaticSync ?? false
        self.syncIconImageView.isHidden = !self.syncSwich.isOn
    }

    private func setUpSyncDate() {
        self.lastDateLabel.isHidden = String.isNilOrEmpty(self.presenter.profile?.lastSyncDate)
        self.lastDateLabel.text = self.presenter.profile?.lastSyncDate
    }

    private func setUpGesture() {
        self.linkLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapLink(_:))))
        self.linkIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapLink(_:))))
        self.linkAccountIconImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapLink(_:))))
        self.syncSwich.addTarget(self, action: #selector(onFindDeviceSwitchValueChange(_:)), for: .valueChanged)
    }

    private func setUpGoogleSignIn() {
    }
}

// MARK: - SyncSettingViewProtocol
extension SyncSettingViewController: SyncSettingViewProtocol {
    func onLastDateChange(with date: String) {
        self.setUpSyncDate()
    }
    func presentDownloadView() {
        self.presenter.presentDownloadView()
    }

    func handleUpdateView(didLinkAccount: Bool) {
        self.setUpUnderlineText(didLinkAccout: didLinkAccount)
    }

    func setProfileData(with user: ProfileModel) {
        userAvatarImageView.setImage(user.image, placeHolder: R.image.ic_default_avatar())
        self.userNameLabel.text = user.name
    }

    // Change switch if user have not linked account yet.
    func changeSwitchState() {
        self.syncSwich.animate()
    }
    
    private func getUserInfo(with token: TokenModel?, isGoogleAccount: Bool) {
        guard let token = token else {
            self.presenter.saveLinkedAccount(with: nil, isGoogleAccount: true)
            return
        }
        ConfigService.share.getUserInfo(with: token.accessToken ?? "") { data, success, _ in
            if success {
                self.presenter.saveLinkedAccount(with: data?.data, isGoogleAccount: isGoogleAccount)
            } else {
                self.presenter.saveLinkedAccount(with: nil, isGoogleAccount: isGoogleAccount)
            }
        }
    }
}

// MARK: - DownloadDataViewControllerDelegate
extension SyncSettingViewController: DownloadDataViewControllerDelegate {
    func handleDownloadData(needDownload: Bool) {
        if needDownload {
            self.presenter.getSyncData()
        }
    }
}
