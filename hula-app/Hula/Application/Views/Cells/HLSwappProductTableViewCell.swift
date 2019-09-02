//
//  HLSwappProductTableViewCell.swift
//  Hula
//
//  Created by Juan Searle on 25/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSwappProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage: HLDragableImage!
    @IBOutlet weak var productName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
