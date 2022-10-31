//
//  ProfileTableViewCell.swift
//  1SKConnect
//
//  Created by tuyenvx on 31/03/2021.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var relationLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func config(with profile: ProfileModel?) {
        guard let `profile` = profile else {
            return
        }
        avatarImageView.setImage(profile.image, placeHolder: R.image.ic_default_avatar())
        nameLabel.text = profile.name
        relationLabel.text = profile.relation.value?.getName()
    }
}
