//
//  CommonUtils.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import EasyTipView
import Kingfisher
import AVKit

class CommonUtils: NSObject, EasyTipViewDelegate, UIGestureRecognizerDelegate {
    
    var currentTipArr: [HulaTip] = []
    var currentTip:Int = -1
    var lastTip:EasyTipView = EasyTipView(text: "");
    var startingViewController: UIViewController!
    var bgViewToRemove : UIView!
    var tutorialToComplete : String = ""
    
    class var sharedInstance: CommonUtils {
        struct Static {
            static let instance: CommonUtils = CommonUtils()
        }
        return Static.instance
    }
    // Common Utils Functions
    func attributedStringWithTextSpacing(_ str: String, _ textSpacing: CGFloat) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: str.uppercased())
        attributedString.addAttribute(NSKernAttributeName, value: textSpacing, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    func circleImageView(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2.0;
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.contentMode = UIViewContentMode.scaleAspectFill
    }
    func setRoundedRectBorderImageView(_ imageView: UIImageView, _ width: CGFloat, _ borderColor: UIColor, _ radius: CGFloat){
        let borderLayer: CALayer! = CALayer()
        let borderFrame: CGRect! = CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.frame = borderFrame
        borderLayer.cornerRadius = radius
        borderLayer.borderWidth = width
        borderLayer.borderColor = borderColor.cgColor
        imageView.layer.addSublayer(borderLayer)
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
    }
    func setRoundedRectBorderButton(_ button: UIButton, _ width: CGFloat, _ borderColor: UIColor, _ radius: CGFloat){
        button.clipsToBounds = true
        button.layer.cornerRadius = radius
        button.layer.borderColor = borderColor.cgColor
        button.layer.borderWidth = width
    }
    func cropImage(_ image: UIImage!, _ newSize: CGSize!) -> UIImage{
        let ratio: Double!
        let delta: Double!
        let offset: CGPoint!
        
        let hRatio: Double! = Double(newSize.width / image.size.width)
        let vRatio: Double! = Double(newSize.height / image.size.height)
        
        if hRatio > vRatio {
            ratio = hRatio
            delta = Double(CGFloat(ratio) * image.size.height - newSize.height)
            offset = CGPoint(x: 0.0, y: delta / 2)
        }else{
            ratio = vRatio
            delta = Double(CGFloat(ratio) * image.size.width - newSize.width)
            offset = CGPoint(x: delta / 2, y: 0.0)
        }
        let cropArea: CGRect = CGRect(x: -offset.x, y: -offset.y, width: CGFloat(ratio) * image.size.width, height: CGFloat(ratio) * image.size.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        UIRectClip(cropArea)
        image.draw(in: cropArea)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage!
    }
    func heightString(width: CGFloat, font: UIFont, string: String) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = string.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }


    
    func getDistanceFrom(lat:CGFloat, lon:CGFloat) -> String{
        let coordinate₀ = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        
        return getDistanceFrom(loc:coordinate₀)
    }
    func getDistanceFrom(loc:CLLocation) -> String{
        let coordinate₀ = loc
        
        if loc.coordinate.latitude == 0 && loc.coordinate.longitude == 0 {
            return "-"
        }
        if HulaUser.sharedInstance.location.coordinate.latitude == 0 && HulaUser.sharedInstance.location.coordinate.longitude == 0 {
            return "-"
        }
        if let userLocation = HulaUser.sharedInstance.location {
            let distanceInMeters = coordinate₀.distance(from: userLocation) // result is in meters
            
            var distance = round( distanceInMeters / 1609 );
            var dist_unit = NSLocalizedString("miles", comment: "");
            if (!inUSA(HulaUser.sharedInstance.location)){
                distance = round( distanceInMeters / 1000 );
                dist_unit = NSLocalizedString("kilometers", comment: "");
            }
            if (distance<1){
                distance = round( distance*10 ) / 10;
            } else {
                if (distance>1000){
                    //distance = distance
                    //return "Too far"
                    return "\(Int(distance)) " + dist_unit
                }
            }
            return "\(distance) " + dist_unit
        } else {
            return "-"
        }
    }
    func inUSA(_ loc:CLLocation) -> Bool{
        if (loc.coordinate.longitude < -50) && (loc.coordinate.longitude > -170){
            return true
        }
        return false;
    }
    func getCGDistanceFrom(loc:CLLocation) -> CGFloat{
        if let userLocation = HulaUser.sharedInstance.location {
            let distanceInMeters:CGFloat = CGFloat(loc.distance(from: userLocation)) // result is in meters
            return distanceInMeters  / 1609.0
        } else {
            return CGFloat(0.0)
        }
    }
    
    
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) " + NSLocalizedString("years ago", comment: "")
        } else if (components.year! >= 1){
            if (numericDates){
                return NSLocalizedString("1 year ago", comment: "")
            } else {
                return NSLocalizedString("Last year", comment: "")
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) " + NSLocalizedString("months ago", comment: "")
        } else if (components.month! >= 1){
            if (numericDates){
                return NSLocalizedString("1 month ago", comment: "")
            } else {
                return NSLocalizedString("Last month", comment: "")
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) " + NSLocalizedString("weeks ago", comment: "")
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return NSLocalizedString("1 week ago", comment: "")
            } else {
                return NSLocalizedString("Last week", comment: "")
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) " + NSLocalizedString("days ago", comment: "")
        } else if (components.day! >= 1){
            if (numericDates){
                return NSLocalizedString("1 day ago", comment: "")
            } else {
                return NSLocalizedString("Yesterday", comment: "")
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) " + NSLocalizedString("hours ago", comment: "")
        } else if (components.hour! >= 1){
            if (numericDates){
                return NSLocalizedString("1 hour ago", comment: "")
            } else {
                return NSLocalizedString("An hour ago", comment: "")
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) " + NSLocalizedString("minutes ago", comment: "")
        } else if (components.minute! >= 1){
            if (numericDates){
                return NSLocalizedString("1 minute ago", comment: "")
            } else {
                return NSLocalizedString("A minute ago", comment: "")
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago" + NSLocalizedString("seconds ago", comment: "")
        } else {
            return NSLocalizedString("Just now", comment: "")
        }
        
    }
    
    func isoDateToNSDate(date:String) -> NSDate{
        //print(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
        let dateObj = dateFormatter.date(from: date)
        if (dateObj != nil){
            return dateObj! as NSDate
        } else {
            return NSDate()
        }
    }
    func userImageURL(userId: String) -> String{
        return HulaConstants.apiURL + "users/\(userId)/image"
    }
    func productImageURL(productId: String) -> String{
        return HulaConstants.apiURL + "products/\(productId)/image"
    }
    
    func getThumbFor(url:String) -> String {
        if (url == ""){
            return HulaConstants.noProductThumb
        }
        if (url == HulaConstants.transparentImg){
            return HulaConstants.transparentImg
        }
        var parts = url.components(separatedBy: "/")
        let img_name = "tm_\(parts[parts.count - 1])"
        parts[parts.count - 1] = img_name
        return parts.joined(separator:"/")
    }
    
    
    func showTutorial(arrayTips: [HulaTip], named: String){
        if (currentTip == -1){
            currentTipArr = arrayTips
            self.tutorialToComplete = named
            if let vc = currentTipArr[0].view.parentViewController  {
                if bgViewToRemove != nil{
                    bgViewToRemove.removeFromSuperview()
                }
                bgViewToRemove = UIView(frame: vc.view.frame)
                bgViewToRemove.frame.size.width = max(vc.view.frame.width, vc.view.frame.height) + 100
                bgViewToRemove.frame.size.height = max(vc.view.frame.width, vc.view.frame.height) + 100
                bgViewToRemove.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(removeEasyTips))
                tap.delegate = self
                bgViewToRemove.addGestureRecognizer(tap)
                
                vc.view.addSubview(bgViewToRemove)
            }
            self.showNextTip(false)
        }
    }
    
    func showNextTip(_ direct:Bool){
        //self.lastTip.dismiss()
        //print("shownext")
        self.currentTip += 1
        if (self.currentTip < self.currentTipArr.count){
            var when = DispatchTime.now() + Double(currentTipArr[currentTip].delay)
            if (direct){
                when = DispatchTime.now()
            }
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                if (self.currentTip < self.currentTipArr.count){
                    EasyTipView.show(forView: self.currentTipArr[self.currentTip].view, withinSuperview: self.currentTipArr[self.currentTip].view.parentViewController?.view, text: self.currentTipArr[self.currentTip].text, delegate:self )
                    
                    //self.lastTip = EasyTipView(text: self.currentTipArr[self.currentTip].text)
                    //self.lastTip.show(forView: self.currentTipArr[self.currentTip].view)
                    
                    //self.showNextTip(false)
                } else {
                    self.bgViewToRemove.removeFromSuperview()
                    self.currentTip = -1
                    
                    HLDataManager.sharedInstance.onboardingTutorials.setObject("done", forKey: self.tutorialToComplete as NSCopying)
                    HLDataManager.sharedInstance.writeUserData()
                }
            }
        }else{
            self.currentTip = -1
            UIView.animate(withDuration: 0.5, animations: {
                self.bgViewToRemove.alpha = 0
            }, completion: {(success) in
                self.bgViewToRemove.removeFromSuperview()
            })
            
            HLDataManager.sharedInstance.onboardingTutorials.setObject("done", forKey: self.tutorialToComplete as NSCopying)
            HLDataManager.sharedInstance.writeUserData()
        }
    }
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        //print("dismissed")
        self.showNextTip(false)
    }
    
    func removeEasyTips(){
        //print("removing from...")
        print(self.currentTip)
        if let prnt = self.currentTipArr[self.currentTip].view.parentViewController?.view {
            for view in prnt.subviews {
                if let tipView = view as? EasyTipView {
                    tipView.dismiss(withCompletion: {
                        //nada
                    })
                }
            }
        }
    }
    
    func getTopViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            print(topController)
            return topController;
        } else {
            return nil
        }
        
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}


let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageFromURL(urlString: String) {
        
        
        var _urlString = ""
        if (urlString == ""){
            _urlString = HulaConstants.noProductThumb
        } else {
            _urlString = urlString
        }
        
        let url = URL(string: _urlString)!
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url, options: [.transition(.fade(0.5))]) { (im, er, ty, ur) in
            if !(er == nil) {
                self.kf.setImage(with: URL(string: HulaConstants.noProductThumb), options: [.transition(.fade(0.5))])
            }
        }
        
        
        /*
         
         //old manual way
         
        self.image = nil
        
        // check for cache
        if let cachedImage = imageCache.object(forKey: _urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        
        if let url = NSURL(string: _urlString) {
        
            URLSession.shared.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
                //print("getting: \(_urlString)")
                if error != nil {
                    print(error!)
                    return
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    let image = UIImage(data: data!)
                    self.image = image
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
                    })
                    if self.image != nil {
                        imageCache.setObject(image!, forKey: _urlString as AnyObject)
                    }
                })
                
            }).resume()
        }
         */
    }
}

extension UIView {
    
    func bouncer() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5,y: 1.5);
        }, completion: { action -> Void in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1,y: 1);
            })
        })
    }
}


extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
// character at position
extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[start ..< end]
    }
}


struct Device {
    // iDevice detection code
    static let IS_IPAD             = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE           = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA           = UIScreen.main.scale >= 2.0
    
    static let SCREEN_WIDTH        = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT       = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH   = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let SCREEN_MIN_LENGTH   = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    
    static let IS_IPHONE_4_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH  < 568
    static let IS_IPHONE_5         = IS_IPHONE && SCREEN_MAX_LENGTH == 568
    static let IS_IPHONE_6         = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    static let IS_IPHONE_6P        = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    static let IS_IPHONE_X         = IS_IPHONE && SCREEN_MAX_LENGTH == 812
}


extension UIImagePickerController{
    override open var shouldAutorotate: Bool {
        return true
    }
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
}

class LandscapeAVPlayerController: AVPlayerViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
}
