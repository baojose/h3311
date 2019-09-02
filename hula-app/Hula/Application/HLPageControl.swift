//
//  HLPageControl.swift
//  Hula
//
//  Created by Juan Searle on 2/7/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLPageControl: UIPageControl {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let homeIcon: UIImage = UIImage(named: "house-sel-icon")!
    let homeSelIcon: UIImage = UIImage(named: "home-icon")!
    let pageCircle: UIImage = UIImage(named: "page-icon")!
    let pageSelCircle: UIImage = UIImage(named: "page-sel-icon")!
    
    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = false
    }
    
    func updateDots() {
        var i = 0
        for view in self.subviews {
            var imageView = self.imageView(forSubview: view)
            if imageView == nil {
                if i == 0 {
                    imageView = UIImageView(image: homeIcon)
                } else {
                    imageView = UIImageView(image: pageCircle)
                }
                imageView!.center = view.center
                view.addSubview(imageView!)
                view.clipsToBounds = false
            }
            if i == self.currentPage {
                if i != 0 {
                    imageView!.image = pageSelCircle
                } else {
                    imageView!.image = homeSelIcon
                }
            } else {
                if i == 0 {
                    imageView!.image = homeIcon
                } else {
                    imageView!.image = pageCircle
                }
            }
            i += 1
        }
    }
    
    fileprivate func imageView(forSubview view: UIView) -> UIImageView? {
        var dot: UIImageView?
        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }
        return dot
    }

}
import UIKit
