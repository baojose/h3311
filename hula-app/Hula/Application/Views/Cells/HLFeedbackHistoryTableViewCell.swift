//
//  HLFeedbackHistoryTableViewCell.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLFeedbackHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var feedbackCommentLabel: UILabel!
    @IBOutlet weak var feedbackPercentage: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CommonUtils.sharedInstance.circleImageView(userImage)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
