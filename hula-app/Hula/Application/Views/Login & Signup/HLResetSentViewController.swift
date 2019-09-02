//
//  HLResetSentViewController.swift
//  Hula
//
//  Created by Juan Searle on 25/09/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLResetSentViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    var emailText:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        emailLabel.text = emailText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        HLDataManager.sharedInstance.ga("password_reset_sent")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func requestAnotherAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gotoLoginAction(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)

    }
}
