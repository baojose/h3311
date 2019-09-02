//
//  HLRoundedGradientButton.swift
//  Hula
//
//  Created by Juan Searle on 16/04/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit


class HLRoundedGradientButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        let gradient: CAGradientLayer = CAGradientLayer()
        let colorTop = UIColor(red: 35/255.0, green: 192/255.0, blue: 166.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 30.0/255.0, green: 161.0/255.0, blue: 162.0/255.0, alpha: 1.0).cgColor
        
        gradient.colors = [colorTop, colorBottom]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.2)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.8)
        gradient.frame = CGRect(x: 0, y: 0, width: rect.width, height:rect.height)
        gradient.cornerRadius = rect.height/2
        
        
        self.layer.insertSublayer(gradient, at: 0)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
        
    }
    
}
