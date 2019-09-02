//
//  HLTradesCollectionViewCell.swift
//  Hula
//
//  Created by Juan Searle on 29/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLTradesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var tradeNumber: UILabel!
    @IBOutlet weak var emptyRoomLabel: UILabel!
    @IBOutlet weak var middleArrows: UIImageView!
    @IBOutlet weak var optionsDotsImage: UIImageView!
    @IBOutlet weak var left_side: UIView!
    @IBOutlet weak var right_side: UIView!
    @IBOutlet weak var myTurnView: UIView!
    @IBOutlet weak var otherTurnView: UIView!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var dealClosedLbl: UILabel!
    
    @IBOutlet weak var chatCountLabel: UILabel!
    
    var dbDelegate: HLDashboardViewController?
    var tradeId: String = ""
    var userId: String = ""
    var tradeStatus: String = "current"
    
    var isEmptyRoom = true;
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes?) {
        self.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let s = dbDelegate?.view.frame.width {
            self.frame.size.width = s
        }
        CommonUtils.sharedInstance.circleImageView(userImage)
        CommonUtils.sharedInstance.circleImageView(myImage)
        boxView.frame = CGRect(x: 8, y: 7, width: self.frame.width - 39, height: 59)
        left_side.frame = CGRect(x: 0, y: 0, width: boxView.frame.width/2, height: 59)
        right_side.frame = CGRect(x: boxView.frame.width/2, y: 0, width: boxView.frame.width/2, height: 59)
        boxView.layer.borderWidth = 1
        boxView.layer.cornerRadius = 4.0
        boxView.layer.borderColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha: 1.0).cgColor
        chatCountLabel.layer.cornerRadius = 7.5
        chatCountLabel.clipsToBounds = true
        //boxView.clipsToBounds = true
        if (!isEmptyRoom){
            boxView.layer.shadowColor = UIColor.black.cgColor
            boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
            boxView.layer.shadowOpacity = 0.2
            boxView.layer.shadowRadius = 3
            optionsDotsImage.alpha = 1.0
        } else {
            boxView.layer.shadowColor = UIColor(red:1, green:1, blue:1, alpha: 0).cgColor
            boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
            boxView.layer.shadowOpacity = 0
            boxView.layer.shadowRadius = 0
            optionsDotsImage.alpha = 0.2
        }
        //print(self.frame)
        
        // test for commit
        self.transform = CGAffineTransform(scaleX: 1,y: 1);
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.tradeId != ""){
             UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1.1,y: 1.1);
             }, completion: { (ok) in
                 UIView.animate(withDuration: 0.4, animations: {
                    self.transform = CGAffineTransform(scaleX: 1,y: 1);
                 })
             })
            super.touchesBegan(touches, with: event)
        }
    }
    

    
    @IBAction func tradeOptionsAction(_ sender: Any) {
        if (self.tradeId != "" && self.tradeStatus == "current"){
            if dbDelegate != nil {
                let alert = UIAlertController(title: NSLocalizedString("Trading options", comment: ""),
                                              message: nil,
                                              preferredStyle: .actionSheet)
                
                let reportAction = UIAlertAction(title: NSLocalizedString("Report this user", comment: ""), style: .default, handler: { action -> Void in
                    
                    self.reportUser()
                    
                })
                alert.addAction(reportAction)
                
                
                let removeAction = UIAlertAction(title: NSLocalizedString("Cancel this trade", comment: ""), style: .destructive, handler: { action -> Void in
                    self.closeTrade()
                })
                alert.addAction(removeAction)
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                dbDelegate?.present(alert, animated: true)
            }
        }
    }
    
    func closeTrade(){
        if (self.tradeId != ""){
            // call parent closeTrade(id)
            dbDelegate?.closeTrade(self.tradeId)
            self.tradeId = ""
        }
    }
    func reportUser(){
        if (self.userId != ""){
            dbDelegate?.reportUser(self.userId)
        }
    }
}
