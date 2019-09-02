//
//  HLProfileViewController.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import TwitterKit
import CoreLocation
import LinkedinSwift


class HLProfileViewController: BaseViewController {
    
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var settingsAlertBadge: UIImageView!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userNickLabel: UILabel!
    @IBOutlet weak var userFeedbackLabel: UILabel!
    @IBOutlet weak var tradesStartedLabel: UILabel!
    @IBOutlet weak var tradesEndedLabel: UILabel!
    @IBOutlet weak var tradesClosedLabel: UILabel!
    @IBOutlet weak var verFacebookIcon: UIImageView!
    @IBOutlet weak var verLinkedinIcon: UIImageView!
    @IBOutlet weak var verTwitterIcon: UIImageView!
    @IBOutlet weak var verMailIcon: UIImageView!
    @IBOutlet weak var completeProfileTooltip: UIView!
    @IBOutlet weak var viewFeedbackBtn: UIButton!
    @IBOutlet weak var fullsizeViewReference: UIView!
    
    
    private let linkedinHelper = LinkedinSwiftHelper(configuration: LinkedinSwiftConfiguration(clientId: "77pqp8cu8tj7vb", clientSecret: "yx3RJzo3X9guNEhY", state: "DLKDJF46ikMMZADfdfds", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl: "https://hula.trading/"))
    
    var arrFeedback: NSArray!
    var spinner: HLSpinnerUIView!
    var image_dismissing:Bool = false
    var current_image_url:String = ""
    var last_logged_user:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(selectedImageTapped))
        profileImageView.addGestureRecognizer(recognizer)
        
        spinner = HLSpinnerUIView()
        self.view.addSubview(spinner)
        spinner.show(inView: self.view)
        
        
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        if !HulaUser.sharedInstance.isUserLoggedIn() {
            self.tabBarController?.selectedIndex = 0
        } else {
            if last_logged_user != HulaUser.sharedInstance.userId {
                setupView()
            }
            self.profileImageView.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if (HulaUser.sharedInstance.isUserLoggedIn()){
            
            if (HulaUser.sharedInstance.userPhotoURL != ""){
                if (current_image_url != HulaUser.sharedInstance.userPhotoURL) {
                    //print("Changing image")
                    //print(HulaUser.sharedInstance.userPhotoURL)
                    let thumb = commonUtils.getThumbFor(url: HulaUser.sharedInstance.userPhotoURL)
                    self.profileImageView.loadImageFromURL(urlString: thumb)
                    self.current_image_url = HulaUser.sharedInstance.userPhotoURL
                }
            } else {
                self.profileImageView.image = UIImage(named: "profile_placeholder")
            }
            
            
            if (HulaUser.sharedInstance.isIncompleteProfile()){
                // badges to inform the user
                UIView.animate(withDuration: 0.4, animations: {
                    self.completeProfileTooltip.alpha = 1
                    self.settingsAlertBadge.alpha = 1
                })
            } else {
                self.completeProfileTooltip.alpha = 0
                self.settingsAlertBadge.alpha = 0
            }
        
        } else {
            self.profileImageView.image = UIImage(named: "profile_placeholder")
        }
        
        HLDataManager.sharedInstance.ga("my_profile")
    }
    
    func setupView(){
        self.initData()
        self.initView()
        
        self.getUserProfile()
        last_logged_user = HulaUser.sharedInstance.userId
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("Preparing for segue...")
        if let destinationVC = segue.destination as? HLFeedbackHistoryViewController{
            destinationVC.feedbackList = arrFeedback
            //print("Total feedback: \(destinationVC.feedbackList.count)")
        }
    }
    
    
    func initData() {
        arrFeedback = []
    }
    func initView() {
        commonUtils.circleImageView(profileImageView)
        mainScrollView.contentSize = CGSize(width: 0, height: fullsizeViewReference.frame.size.height + 100)
        mainScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
        
        settingsAlertBadge.alpha = 0
        completeProfileTooltip.alpha = 0
        
        
        
    }
    
    // IB Actions
    
    @IBAction func closeTooltip(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.completeProfileTooltip.alpha = 0
        })
    }
    
    @IBAction func validateAction(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Select a validation method", comment: ""),
                                       message: nil,
                                       preferredStyle: .actionSheet)
        
        if HulaUser.sharedInstance.fbToken.count == 0 {
            let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: { action -> Void in
                self.facebookValidate()
            })
            alert.addAction(facebookAction)
        }
        
        if HulaUser.sharedInstance.liToken.count == 0 {
            let linkedinAction = UIAlertAction(title: "Linkedin", style: .default, handler: { action -> Void in
                self.linkedinValidate()
            })
            alert.addAction(linkedinAction)
        }
        
        
        if HulaUser.sharedInstance.twToken.count == 0 {
            let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: { action -> Void in
                self.twitterValidate()
            })
            alert.addAction(twitterAction)
        }
        
        
        if HulaUser.sharedInstance.status != "verified" {
            let emailAction = UIAlertAction(title: "Email", style: .default, handler: { action -> Void in
                self.emailValidate()
            })
            alert.addAction(emailAction)
        }
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                           style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    
    
    
    
    func facebookValidate(){
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                //print("Logged in!")
                print(grantedPermissions)
                print(declinedPermissions)
                HulaUser.sharedInstance.fbToken = accessToken.authenticationToken as String
                self.verFacebookIcon.image = UIImage(named: "icon_facebook_on")
                self.verFacebookIcon.bouncer()
                HulaUser.sharedInstance.updateServerData()
            }
        }
    }
    
    
    func twitterValidate(){
        //print("Opening twitter...")
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            //print("Session open!")
            //print(session)
            if let unwrappedSession = session {
                //print("Twitter ok!")
                //print(unwrappedSession);
                self.verTwitterIcon.image = UIImage(named: "icon_twitter_on")
                self.verTwitterIcon.bouncer()
                HulaUser.sharedInstance.twToken = unwrappedSession.authToken as String
                HulaUser.sharedInstance.updateServerData()
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        })
        
    }
    
    
    func emailValidate(){
        
        HulaUser.sharedInstance.resendValidationMail()
        let alert = UIAlertController(title: NSLocalizedString("Email validation", comment: ""), message: NSLocalizedString("If you're a real person with a real email, open your email and follow the instructions.", comment: ""),
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func linkedinValidate(){
        print("Validating linkedin...")
        linkedinHelper.authorizeSuccess({ (token) in
            
            print(token)
            self.verLinkedinIcon.image = UIImage(named: "icon_linkedin_on")
            self.verLinkedinIcon.bouncer()
            HulaUser.sharedInstance.liToken = token.accessToken
            HulaUser.sharedInstance.updateServerData()
            //This token is useful for fetching profile info from LinkedIn server
        }, error: { (error) in
            
            print(error.localizedDescription)
            //show respective error
        }) {
            //show sign in cancelled event
        }
    }
    
    // Custom functions for ViewController
    
    func getUserProfile() {
        
        //print("Getting user info...")
        let queryURL = HulaConstants.apiURL + "me"
        print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            
            
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? [String: Any] {
                        
                        if let user = dictionary["user"] as? [String: Any]  {
                            //print(user)
                            self.spinner.hide()
                            HulaUser.sharedInstance.populate(with: user as NSDictionary)
                            
                            if (HulaUser.sharedInstance.fbToken != ""){
                                self.verFacebookIcon.image = UIImage(named: "icon_facebook_on")
                                self.verFacebookIcon.bouncer()
                            }
                            if (HulaUser.sharedInstance.liToken != ""){
                                self.verLinkedinIcon.image = UIImage(named: "icon_linkedin_on")
                                self.verLinkedinIcon.bouncer()
                            }
                            if (HulaUser.sharedInstance.twToken != ""){
                                self.verTwitterIcon.image = UIImage(named: "icon_twitter_on")
                                self.verTwitterIcon.bouncer()
                            }
                            if (HulaUser.sharedInstance.status == "verified"){
                                self.verMailIcon.image = UIImage(named: "icon_mail_on")
                                self.verMailIcon.bouncer()
                            }
                            
                            self.userFeedbackLabel.text = HulaUser.sharedInstance.getFeedback()
                            //let thumb = self.commonUtils.getThumbFor(url: HulaUser.sharedInstance.userPhotoURL)
                            self.userFullNameLabel.text = HulaUser.sharedInstance.userName
                            self.current_image_url = HulaUser.sharedInstance.userPhotoURL
                            if (self.current_image_url != "") {
                                self.profileImageView.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
                            } else {
                                self.profileImageView.image = UIImage(named: "profile_placeholder")
                            }
                            self.userNickLabel.text = HulaUser.sharedInstance.userNick
                            self.userBioLabel.text = HulaUser.sharedInstance.userBio
                            
                            self.tradesStartedLabel.text = "\(Int(HulaUser.sharedInstance.trades_started))"
                            self.tradesEndedLabel.text = "\(Int(HulaUser.sharedInstance.trades_finished))"
                            self.tradesClosedLabel.text = "\(Int(HulaUser.sharedInstance.trades_closed))"
                            
                            
                            HLDataManager.sharedInstance.writeUserData()
                            
                            
                            if (HulaUser.sharedInstance.isIncompleteProfile()){
                                // badges to inform the user
                                UIView.animate(withDuration: 0.4, animations: {
                                    self.completeProfileTooltip.alpha = 1
                                    self.settingsAlertBadge.alpha = 1
                                })
                            }
                            
                            if let feedback = dictionary["feedback"] as? NSArray {
                                self.arrFeedback = feedback
                            }
                            DispatchQueue.main.async {
                                let app = UIApplication.shared.delegate as! AppDelegate
                                app.registerForPushNotifications()
                            }
                        } else {
                            self.expiredTokenAlert()
                        }
                        
                    }
                }
            } else {
                // connection error
                self.expiredTokenAlert()
            }
        })
    }
    func expiredTokenAlert(){
        
        let alert = UIAlertController(title: "User token expired", message: "Your Hula session is expired. Please log in again.", preferredStyle: UIAlertControllerStyle.alert)
        
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (e) in
            
            DispatchQueue.main.async {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "identification") as! HLIdentificationViewController
                self.navigationController?.navigationController?.pushViewController(viewController, animated: true)
            }
        }))
        self.present(alert, animated: true, completion:{} )

        
    }
    
    
    
    
    func selectedImageTapped(_ sender: UITapGestureRecognizer){
        fullScreenImage(image:profileImageView.image!, index: 1)
    }
    
    
    func fullScreenImage(image: UIImage, index: Int) {
        let newImageView = UIImageView(image: image)
        
        newImageView.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 10, height:10)
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.alpha = 0.0
        newImageView.tag = 10001
        newImageView.isUserInteractionEnabled = true
        
        
        newImageView.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(optionsFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(swipe)
        self.view.addSubview(newImageView)
        image_dismissing = false
        UIView.animate(withDuration: 0.3, animations: {
            newImageView.frame = UIScreen.main.bounds
            newImageView.alpha = 1
        }) { (success) in
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func dismissFullscreenImage(_ sender: UIGestureRecognizer) {
        if (!image_dismissing){
            guard let panRecognizer = sender as? UIPanGestureRecognizer else {
                return
            }
            let velocity = panRecognizer.velocity(in: self.view)
            
            self.tabBarController?.tabBar.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                sender.view?.frame = CGRect(x: self.view.frame.width/2 + velocity.x/2, y: self.view.frame.height/2 + velocity.y/2, width: 30, height:30)
                sender.view?.alpha = 0
                sender.view?.transform.rotated(by: CGFloat( arc4random_uniform(100)))
            }) { (success) in
                sender.view?.removeFromSuperview()
            }
            image_dismissing = true
        }
    }
    func dismissFullscreenImageDirect() {
        
        
        self.tabBarController?.tabBar.isHidden = false
        
        if let imageView = self.view.viewWithTag(10001) as? UIImageView {
            UIView.animate(withDuration: 0.3, animations: {
                imageView.frame = CGRect(x: self.view.frame.width/2 , y: self.view.frame.height/2, width: 30, height:30)
                imageView.alpha = 0
                imageView.transform.rotated(by: CGFloat( arc4random_uniform(100)/12))
            }) { (success) in
                imageView.removeFromSuperview()
            }
        }
        image_dismissing = true
    }
    func optionsFullscreenImage(_ sender: UIGestureRecognizer) {
        let alertController = UIAlertController(title: NSLocalizedString("Do you wanna change your profile picture?", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        
        let  editButton = UIAlertAction(title: NSLocalizedString("Change image", comment: ""), style: .destructive, handler: { (action) -> Void in
            //print("Delete button tapped")
            let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "selectPictureGeneral") as! HLPictureSelectViewController
            cameraViewController.originalProfileVC = self
            self.present(cameraViewController, animated: true)
            self.dismissFullscreenImageDirect()
            
        })
        alertController.addAction(editButton)
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
            self.dismissFullscreenImageDirect()
        })
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }
}
