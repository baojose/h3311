//
//  HLProductCollectionViewCell.swift
//  Hula
//
//  Created by Juan Searle on 01/07/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    var been_added = false
    var been_removed = false
    var side = "left"
    var type = "select"

    
    func is_added() {
        if (!been_added){
            /*
            let center = image.center
            image.center.y = -100
            if ((side == "left") && (type == "select")) || ((side != "left") && (type != "select")){
                image.center.x = -1000
            }
            if ((side == "right") && (type == "select")) || ((side != "right") && (type != "select")) {
                image.center.x = 1000
            }
            image.alpha = 0.1
            UIView.animate(withDuration: 0.5, animations: {
                self.image.center = center
                self.image.alpha = 1
            })
 */
            self.alpha = 0
            UIView.animate(withDuration: 0.6, animations: {
                self.alpha = 1
            })
        }
        been_added = true
    }
    
    func is_removed() {
        if (!been_removed){
            /*
            let center = image.center
            image.center.y = -100
            image.alpha = 0.1
            UIView.animate(withDuration: 0.5, animations: {
                self.image.center = center
                self.image.alpha = 1
            })
 */
        }
        been_removed = true
    }
}
