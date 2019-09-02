//
//  UserBaseViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class UserBaseViewController: UIViewController {
    
    var commonUtils: CommonUtils! = CommonUtils.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func navToMainView() {
        
        DispatchQueue.main.async {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "baseTabBarPage") as! BaseTabBarViewController
            //self.navigationController?.viewControllers = []
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    func closeIdentification() {
        
        DispatchQueue.main.async {
            //self.navigationController?.popViewController(animated: true);
            //self.navigationController?.popToRootViewController(animated: true)
            
            
            
            if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
                for aViewController:UIViewController in viewControllers {
                    if aViewController.isKind(of: BaseTabBarViewController.self) {
                        if let tb = aViewController as? BaseTabBarViewController {
                            //print("BaseTabBarViewController index:")
                            //print(tb.selectedIndex)
                            
                            if HulaUser.sharedInstance.isUserLoggedIn() {
                                tb.tabBarController?.selectedIndex = 3
                                tb.selectedIndex = 3
                            } else {
                                tb.tabBarController?.selectedIndex = 0
                                tb.selectedIndex = 0
                            }
                        }
                        _ = self.navigationController?.popToViewController(aViewController, animated: true)
                    }
                }
            }
            /*
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "baseTabBarPage") as! BaseTabBarViewController
            
            self.navigationController?.popToViewController(viewController, animated: true)
 */
        }
    }
    
}
