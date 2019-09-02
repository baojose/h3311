//
//  HLSpinnerUIView.swift
//  Hula
//
//  Created by Juan Searle on 29/7/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSpinnerUIView: UIView {
    
    var spinning: Bool = false
    var spinner:UIView!
    
    
    func show(inView: UIView) {
        spinner = UIView();
        spinner.frame = CGRect(x: 0, y: 0, width: 75.0, height: 75.0)
        spinner.center = inView.center
        
        let img = UIImage(named: "spinner_arrows")
        let image = UIImageView(image: img)
        
        let image_h = UIImageView(image:UIImage(named: "spinner_H"))
        spinner.addSubview(image_h)
        spinner.addSubview(image)
        
        self.addSubview(spinner)
        
        spinning = true
        rotate(targetView: image, duration: 0.5)
    }
    
    func hide(){
        UIView.animate(withDuration: 0.1, animations: {
            self.spinner.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { success in
        
            for subUIView in self.subviews as [UIView] {
                subUIView.removeFromSuperview()
            }
            self.spinning = false
            self.removeFromSuperview()
        })
    }
    
    private func rotate(targetView: UIView, duration: Double = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat( Double.pi + 0.001 ))
        }) { finished in
            if (self.spinning){
                self.rotate(targetView: targetView, duration: duration)
            }
        }
    }
}
