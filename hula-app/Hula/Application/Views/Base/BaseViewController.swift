//
//  BaseViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    
    var isUserLoggedIn = false
    var dataManager: HLDataManager! = HLDataManager.sharedInstance
    var commonUtils: CommonUtils! = CommonUtils.sharedInstance
    
    
    @IBOutlet var pageTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //#MARK: Common Functions
    
    //#MARK: Common Actions
    @IBAction func goBackToPreviousPage(_ sender: Any) {
        if let _ = sender as? String {
            DispatchQueue.main.async {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "identification") as! HLIdentificationViewController
                self.navigationController?.navigationController?.pushViewController(viewController, animated: true)
            }
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    @IBAction func dismissToPreviousPage(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openUserIdentification(){
        
        //
        DispatchQueue.main.async {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "identification") as! HLIdentificationViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
//        let modalViewController = HLIdentificationViewController()
//        modalViewController.modalPresentationStyle = .overCurrentContext
//        present(modalViewController, animated: true, completion: nil)
    }
    func checkUserLogin() -> Bool{
        let user = HulaUser.sharedInstance
        if (user.token.count < 10){
            isUserLoggedIn = false
        } else {
            isUserLoggedIn = true
        }
        return isUserLoggedIn
    }
}
