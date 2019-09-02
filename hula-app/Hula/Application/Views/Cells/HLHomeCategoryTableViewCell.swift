//
//  HLHomeProductTableViewCell.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLHomeCategoryTableViewCell: UITableViewCell {

    @IBOutlet var categoryImage: UIImageView!
    @IBOutlet var categoryName: UILabel!
    @IBOutlet var categoryProductNum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
