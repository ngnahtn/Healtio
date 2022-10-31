//
//  NotificationTableViewCell.swift
//  1SK
//
//  Created by tuyenvx on 25/02/2021.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabelLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.superview?.isSkeletonable = true
        iconImageView.isSkeletonable = true
        titleLabel.isSkeletonable = true
        contentLabel.isSkeletonable = true
        timeLabel.isSkeletonable = true
        dateLabel.isSkeletonable = true
        titleLabel.lineBreakStrategy = []
        contentLabel.lineBreakStrategy = []
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clear()
    }

    func config(with notification: NotificationModel?, hasRead: Bool) {
        guard let `notification` = notification else {
            titleLabel.superview?.showAnimatedGradientSkeleton()
            return
        }
        iconImageView.setImageWith(imageUrl: notification.image)
        let isUnread = !hasRead//notification.notifyUserStatus == 0
        statusView.isHidden = !isUnread
        titleLabelLeadingConstraint.constant = isUnread ? 3 : -10
        titleLabel.text = notification.title
        contentLabel.text = notification.content
        timeLabel.text = Date(timeIntervalSince1970: TimeInterval(notification.timeSendNotify)).toString(.hmdmy)
        contentLabel.superview?.hideSkeleton()
    }

    func updateStatus(with status: Int) {
        statusView.isHidden = status == 1
    }

    private func clear() {
        iconImageView.image = nil
        statusView.isHidden = true
        titleLabel.text = ""
        contentLabel.text = ""
        timeLabel.text = ""
        titleLabelLeadingConstraint.constant = -10
    }

}
