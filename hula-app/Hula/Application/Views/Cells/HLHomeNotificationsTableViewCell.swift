//
//  HLHomeNotificationsTableViewCell.swift
//  Hula
//
//  Created by Jose Bao on 4/7/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLHomeNotificationsTableViewCell: UITableViewCell {
    
    //MARK: Properties

    @IBOutlet weak var forwardIcon: UIImageView!
    @IBOutlet weak var rotationIcon: UIImageView!
    @IBOutlet weak var NotificationsText: UILabel!
    @IBOutlet var NotificationImageView: UIImageView!
    @IBOutlet var NotificationsDate: UILabel!
    @IBOutlet weak var unreadIcon: UIImageView!
    @IBOutlet weak var newTradeActionView: UIView!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rejectBtn.layer.cornerRadius = 13
        acceptBtn.layer.cornerRadius = 13
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
