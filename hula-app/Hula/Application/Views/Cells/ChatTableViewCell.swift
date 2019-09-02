//
//  ChatTableViewCell.swift
//  Hula
//
//  Created by Juan Searle FC on 25/08/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var messageText: UITextView!
    @IBOutlet weak var mainHolder: UIView!
    @IBOutlet weak var rightUserImage: UIImageView!
    @IBOutlet weak var leftUserImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        CommonUtils.sharedInstance.circleImageView(rightUserImage)
        CommonUtils.sharedInstance.circleImageView(leftUserImage)
        mainHolder.layer.cornerRadius = 20.0
        mainHolder.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
