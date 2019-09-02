//
//  HLLogInViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLLogInViewController: UserBaseViewController, UITextFieldDelegate {
    @IBOutlet weak var nextButton: HLRoundedNextButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var greenBackgroundImage: UIImageView!
    @IBOutlet weak var loginErrorView: UIView!
    @IBOutlet weak var inputElements: UIView!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginRecieved = Notification.Name("loginRecieved")
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginDataRecieved), name: loginRecieved, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        nextButton.setup()
        nextButton.stopAnimation()
        HLDataManager.sharedInstance.ga("login")
    }
    @IBAction func closeIdentificationVC(_ sender: Any) {
        //self.closeIdentification()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func emailValueChanged(_ sender: Any) {
        checkUserInput()
    }

    @IBAction func passwordValueChanged(_ sender: Any) {
        checkUserInput()
    }
    
    
    @IBAction func beginEditPass(_ sender: Any) {
        moveUpView()
    }
    @IBAction func endEditPass(_ sender: Any) {
        moveDownView()
    }
    @IBAction func beginEditText(_ sender: Any) {
        moveUpView()
    }
    @IBAction func endEditText(_ sender: Any) {
        moveDownView()
    }
    
    func moveUpView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.inputElements.frame.origin.y = -140
        })
    }
    func moveDownView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.inputElements.frame.origin.y = 0
        })
    }
    
    @IBAction func gotoNextStep(_ sender: Any) {
        // check credentials over the API
        dismissKeyboard()
        HLDataManager.sharedInstance.loginUser(email: emailField.text!, pass: passwordField.text!)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.loginErrorView.frame.origin.y = self.view.frame.height
            self.greenBackgroundImage.alpha = 1
        })
        
    }
    func checkUserInput(){
        let email_str = emailField.text!
        let pass_str = passwordField.text!
        if ((pass_str.count>4) && (email_str.count>4)){
            nextButton.startAnimation()
        } else {
            nextButton.stopAnimation()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func loginDataRecieved(notification: NSNotification) {
        //print("Login received. Going to welcome vc")
        let loginOk = notification.object as! String
        //print(loginOk)
        if (loginOk == "ok"){
            DispatchQueue.main.async {
                self.errorMessageLabel.text = NSLocalizedString("User logged in", comment: "")
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "welcome") as! HLWelcomeViewController
                //self.present(nextViewController, animated:true, completion:nil)
                self.navigationController?.pushViewController(nextViewController, animated: true)
                self.view.setNeedsDisplay()
            }
            
        } else {
            DispatchQueue.main.async {
                self.errorMessageLabel.text = loginOk;
                //print(loginOk);
                UIView.animate(withDuration: 0.5, animations: {
                    self.loginErrorView.frame.origin.y = self.view.frame.height - self.loginErrorView.frame.height
                    self.greenBackgroundImage.alpha = 0
                    self.forgotPasswordBtn.frame.origin.y = self.inputElements.frame.height - 40 - self.loginErrorView.frame.height
                })
                self.view.setNeedsDisplay()
            }
        }
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
}
