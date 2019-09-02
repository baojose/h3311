//
//  HLIdentificationViewController.swift
//  Hula
//
//  Created by Juan Searle on 15/04/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class HLIdentificationViewController: UserBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginRecieved = Notification.Name("fbLoginRecieved")
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginDataRecieved), name: loginRecieved, object: nil)
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let user = HulaUser.sharedInstance
        if (user.token.count > 10){
            // user not logged in
            self.closeIdentification()
        }
        HLDataManager.sharedInstance.ga("identification")
    }
    
    @IBAction func facebookLoginAction(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(_, _, let accessToken):
                print("Logged in!")
                //print(accessToken)
                //print(grantedPermissions)
                HulaUser.sharedInstance.fbToken = accessToken.authenticationToken as String
                HLDataManager.sharedInstance.loginUserWithFacebook(token: HulaUser.sharedInstance.fbToken)
                
            }
        }
    }
    func loginDataRecieved(notification: NSNotification) {
        print("Login received. Going to welcome vc")
        let loginOk = notification.object as! Bool
        print(loginOk)
        if (loginOk){
            DispatchQueue.main.async {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "welcome") as! HLWelcomeViewController
                //self.present(nextViewController, animated:true, completion:nil)
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
            
        }
    }
    
    @IBAction func closeIdentificationVC(_ sender: Any) {
        self.closeIdentification()
        
        //_ = self.tabBarController?.selectedIndex = 0
        //_ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gotoTermsConditionsAction(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://hula.trading/legal.html")!)
    }
    
}
