//
//  HLAPIClient.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLAPIClient: NSObject {
    
    class var sharedInstance: HLAPIClient {
        struct Static {
            static let instance: HLAPIClient = HLAPIClient()
        }
        return Static.instance
   }

}
