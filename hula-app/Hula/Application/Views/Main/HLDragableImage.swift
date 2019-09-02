//
//  HLDragableImage.swift
//  Hula
//
//  Created by Juan Searle on 28/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLDragableImage: UIImageView {
    
    var dragStartPositionRelativeToCenter : CGPoint?
    var initialPoint: CGPoint?
    var item: Int = 0
    
    weak var delegate:DraggableProductDelegate?
    
    override init(image: UIImage!) {
        super.init(image: image)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        self.isUserInteractionEnabled = true   //< w00000t!!!1
        
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(nizer:))))

        initialPoint = self.center
    }
    
    func handlePan(nizer: UIPanGestureRecognizer!) {
        let locationInView = nizer.location(in: superview)
        if nizer.state == UIGestureRecognizerState.began {
            dragStartPositionRelativeToCenter = CGPoint(x: locationInView.x - center.x, y: locationInView.y - center.y)
            
            
            return
        }
        
        if nizer.state == UIGestureRecognizerState.ended || self.alpha == 0{
            dragStartPositionRelativeToCenter = nil
            
            UIView.animate(withDuration: 0.2) {
                self.center = self.initialPoint!
            }
            
            return
        }
        
        
        if  abs( self.center.x - initialPoint!.x ) > 15 {
            //print("lejos")
            UIView.animate(withDuration: 0.2) {
                self.center = self.initialPoint!
                self.alpha = 0
            }
            delegate?.productDropped(image: self, item: item)
            return
        }
        
        
        UIView.animate(withDuration: 0.1) {
            self.center = CGPoint(x: locationInView.x - self.dragStartPositionRelativeToCenter!.x,
                                  y: locationInView.y - self.dragStartPositionRelativeToCenter!.y)
        }
    }
 
 
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

protocol DraggableProductDelegate: class {
    func productDropped(image: HLDragableImage, item: Int)
}
