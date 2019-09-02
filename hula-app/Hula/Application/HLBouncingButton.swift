//
//  HLBouncingButton.swift
//  Hula
//
//  Created by Juan Searle on 20/04/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLBouncingButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95,y: 0.95);
            self.alpha = 1

            

        })
        super.touchesBegan(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1,y: 1);
            self.alpha = 1.0


        })
        super.touchesEnded(touches, with: event)
    }

}


