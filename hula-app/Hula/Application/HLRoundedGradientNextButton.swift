//
//  HLRoundedGradientNextButton.swift
//  Hula
//
//  Created by Juan Searle on 05/08/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLRoundedGradientNextButton: UIButton {

    let arrowLayer:CALayer = CALayer()
    let positionAnimation = CABasicAnimation(keyPath: "position")
    let arrow_width:CGFloat = 10
    let arrow_height:CGFloat = 16
    let padding:CGFloat = 12
    var animated = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    //override func draw(_ rect: CGRect) {
    //        // Drawing code
    
    //}
    
    
    public func setup(){
        let rect = self.bounds
        //let color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4).cgColor
        //self.layer.cornerRadius = rect.height/2
        //self.layer.backgroundColor = color
        
        
        
        let gradient: CAGradientLayer = CAGradientLayer()
        let colorTop = UIColor(red: 35/255.0, green: 192/255.0, blue: 166.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 30.0/255.0, green: 161.0/255.0, blue: 162.0/255.0, alpha: 1.0).cgColor
        
        gradient.colors = [colorTop, colorBottom]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.7)
        gradient.frame = CGRect(x: 0, y: 0, width: rect.width, height:rect.height)
        gradient.cornerRadius = rect.height/2
        
        
        self.layer.insertSublayer(gradient, at: 0)
        //self.layer.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3).cgColor
        self.layer.cornerRadius = rect.height/2
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.lightGray, for: .highlighted)
        
        
        
        //print("setting up arrow")
        let arrowImage = UIImage(named: "icon_forward_white")?.cgImage
        arrowLayer.frame = CGRect(x: rect.origin.x + rect.width - arrow_width - padding, y:rect.origin.y+padding, width: arrow_width, height:arrow_height)
        arrowLayer.contents = arrowImage
        self.layer.insertSublayer(arrowLayer, at: 1)
        //self.layer.addSublayer(arrowLayer)
        //print("arrow inserted")
        
        
        positionAnimation.fromValue = [arrowLayer.frame.origin.x-padding/2, rect.height/2]
        positionAnimation.toValue = [arrowLayer.frame.origin.x+padding/2, rect.height/2]
        positionAnimation.duration = 0.5
        positionAnimation.autoreverses = true
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        positionAnimation.repeatCount = 1000
        
        
        //self.alpha = 0.5
    }
    
    public func startAnimation(){
        self.alpha = 1
        if (!animated){
            self.layer.removeAnimation(forKey: "position")
            arrowLayer.add(positionAnimation, forKey: "position")
            animated = true
            self.layer.speed = 1.0
            let pausedTime : CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
            self.layer.timeOffset = pausedTime
        }
    }
    public func stopAnimation(){
        //print("Stopping animation")
        self.alpha = 0.5
        if (animated){
            self.layer.removeAnimation(forKey: "position")
            self.layer.removeAllAnimations()
            animated = false
            let pausedTime : CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
            self.layer.speed = 0.0
            self.layer.timeOffset = pausedTime
        }
    }
}
