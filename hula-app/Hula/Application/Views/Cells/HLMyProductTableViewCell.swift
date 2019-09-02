//
//  HLMyProductTableViewCell.swift
//  Hula
//
//  Created by Star on 3/17/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLMyProductTableViewCell: UITableViewCell {
    
    @IBOutlet weak var isMultipleTrades: UIImageView!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productDescription: UILabel!
    @IBOutlet var warningView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    var alreadyAnimated = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func animateAsNew(){
        if (!alreadyAnimated){
            self.cellContentView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
                self.cellContentView.transform = CGAffineTransform.identity
            }, completion: nil)
            alreadyAnimated = true
        }
    }
}
