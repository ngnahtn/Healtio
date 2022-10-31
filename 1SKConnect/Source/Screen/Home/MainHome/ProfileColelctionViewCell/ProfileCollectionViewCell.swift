//
//  ProfileCollectionViewCell.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func config(with profile: ProfileModel?, isCurrentProfile: Bool) {
        guard let `profile` = profile else {
            return
        }
        avatarImageView.setImage(profile.image, placeHolder: R.image.ic_default_avatar())
        nameLabel.text = profile.name
        nameLabel.textColor = isCurrentProfile ? R.color.mainColor() : .black
    }
}
