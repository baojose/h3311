//
//  HulaTip.swift
//  Hula
//
//  Created by Juan Searle FC on 23/08/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import EasyTipView

class HulaTip: NSObject {
    
    var delay: Float = 0.0
    var view: UIView!
    var text: String!
    
    class var sharedInstance: HulaTip {
        struct Static {
            static let instance: HulaTip = HulaTip()
        }
        return Static.instance
    }
    override init() {
        super.init()
        self.delay = 0.0
        self.view = UIView()
        self.text = ""
    }
    
    init(delay : Float, view : UIView, text: String) {
        self.delay = delay
        self.view = view
        self.text = text
    }
    
}
