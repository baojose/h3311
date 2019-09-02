//
//  HulaNotifications.swift
//  Hula
//
//  Created by Jose Bao on 4/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HulaNotifications: NSObject {
    
    var NotificationsText: String!
    var NotificationsDate: String!
    var NotificationImageView: NSMutableArray!
    
    class var sharedInstance: HulaNotifications {
        struct Static {
            static let instance: HulaNotifications = HulaNotifications()
        }
        return Static.instance
    }
    override init() {
        super.init()
        self.NotificationsText = ""
        self.NotificationsDate = ""
        self.NotificationImageView = NSMutableArray.init()
    }
}
