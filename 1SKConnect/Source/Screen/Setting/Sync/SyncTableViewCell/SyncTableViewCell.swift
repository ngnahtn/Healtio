//
//  SyncTableViewCell.swift
//  1SKConnect
//
//  Created by Be More on 13/07/2021.
//

import UIKit

class SyncTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
    @IBOutlet weak var linkIcon: UIImageView!
    @IBOutlet weak var syncButton: UIButton!

    var model: ProfileModel? {
        didSet {
            self.setData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - Helpers
extension SyncTableViewCell {
    private func setData() {
        guard let model = self.model else {
            return
        }
        avatarImageView.setImage(model.image, placeHolder: R.image.ic_default_avatar())
        nameLabel.text = model.name
        if let linkedAccount = model.linkAccount {
            relationLabel.text = R.string.localizable.sync_linked_account("")
            self.linkIcon.isHidden = false
            self.syncButton.isHidden = true
            if linkedAccount.isGoogleAccount {
                self.linkIcon.image = R.image.ic_google()
            } else {
                self.linkIcon.image = R.image.ic_facebook()
            }
        } else {
            self.relationLabel.text = R.string.localizable.sync_not_link()
            self.linkIcon.isHidden = true
            self.syncButton.isHidden = false
        }
    }
}
