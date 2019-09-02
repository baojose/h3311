//
//  HLSettingViewController.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import FacebookShare

class HLSettingViewController: BaseViewController {

    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var profileImageView: UIImageView!
    var userData:HulaUser = HulaUser.sharedInstance
    
    @IBOutlet weak var smallProfileImage: UIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userBioLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    @IBOutlet weak var pictureView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var bioView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var fullNameView: UIView!
    
    var image_dismissing:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initView()
        
        HLDataManager.sharedInstance.ga("settings_profile")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initData() {
        
    }

    
    func initView() {
        commonUtils.circleImageView(profileImageView)
        mainScrollView.contentSize = CGSize(width: 0, height: 650)
        //print(userData.userPhotoURL)
        if (userData.userPhotoURL.count>1){
            self.removeAlertIcon(fromView: self.pictureView)
            self.smallProfileImage.loadImageFromURL(urlString: HulaUser.sharedInstance.userPhotoURL)
        } else {
            self.addAlertIcon(toView: self.pictureView)
        }
        
        
        if (userData.userNick.count>1){
            userNameLabel.text = userData.userNick
            self.removeAlertIcon(fromView: self.nameView)
        } else {
            userNameLabel.text = NSLocalizedString("Name", comment: "")
            self.addAlertIcon(toView: self.nameView)
        }
        
        if (userData.userEmail.count>1){
            userEmailLabel.text = userData.userEmail
        }
        
        if (userData.userName.count>1){
            userFullNameLabel.text = userData.userName
            self.removeAlertIcon(fromView: self.fullNameView)
        } else {
            userFullNameLabel.text = NSLocalizedString("Full name", comment: "")
            self.addAlertIcon(toView: self.fullNameView)
        }
        if (userData.userBio.count>1){
            userBioLabel.text = userData.userBio
            self.removeAlertIcon(fromView: self.bioView)
        } else {
            userBioLabel.text = NSLocalizedString("About you", comment: "")
            self.addAlertIcon(toView: self.bioView)
        }
        
        if (userData.userLocationName.count>1){
            locationLabel.text = userData.userLocationName
            self.removeAlertIcon(fromView: self.locationView)
        } else {
            locationLabel.text = NSLocalizedString("Location", comment: "")
            self.addAlertIcon(toView: self.locationView)
        }
    }
    
    
    // IB Actions
    @IBAction func userLogout(_ sender: Any) {
        
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
        
        viewController.delegate = self
        viewController.isCancelVisible = true
        viewController.message = NSLocalizedString("Are you sure you want to log out?", comment: "")
        
        self.parent?.navigationController?.present(viewController, animated: true)
        
        
    }
    @IBAction func editItemAction(_ sender: Any) {
        print((sender as! UIButton).tag)
        var title = "";
        var previous = "";
        var label = ""
        var item_toUpdate = "";
        var remChar:Int = 200
        switch (sender as! UIButton).tag {
        case 0:
            // image update
            selectedImageTapped()
        case 1:
            // Name
            title = NSLocalizedString("Change your nickname", comment: "")
            previous = userData.userNick
            label = NSLocalizedString("Nickname", comment: "")
            item_toUpdate = "userNick"
            remChar = 40
        case 2:
            // Full name
            title = NSLocalizedString("Validate your email", comment: "")
            previous = userData.userEmail
            label = NSLocalizedString("Email", comment: "")
            item_toUpdate = "userEmail"
            remChar = 120
        case 25:
            // Full name
            title = NSLocalizedString("Change your full name", comment: "")
            previous = userData.userName
            label = NSLocalizedString("Full name", comment: "")
            item_toUpdate = "userName"
            remChar = 120
        case 3:
            // Bio
            title = NSLocalizedString("Change your bio", comment: "")
            previous = userData.userBio
            label = NSLocalizedString("Bio", comment: "")
            item_toUpdate = "userBio"
            remChar = 200
        case 4:
            // Location
            title = NSLocalizedString("Change zip code", comment: "")
            previous = userData.zip
            label = NSLocalizedString("Zip code", comment: "")
            item_toUpdate = "zip"
            remChar = 80
        case 5:
            // Password
            title = NSLocalizedString("Change your password", comment: "")
            previous = ""
            label = NSLocalizedString("Password", comment: "")
            item_toUpdate = "userPassword"
            remChar = 40
        default:
            // nada
            break
        }
        
        if ((sender as! UIButton).tag == 5 ){
            let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "newPassword") as! NewPaswordViewController
            self.navigationController?.pushViewController(editViewController, animated: true)

        } else {
        
            if ((sender as! UIButton).tag != 0 ){
                let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "fieldEditor") as! HLEditFieldViewController
                editViewController.field_label = label
                editViewController.field_title = title
                editViewController.field_previous_val = previous
                editViewController.field_key = item_toUpdate
                editViewController.remainingChars = remChar
                self.navigationController?.pushViewController(editViewController, animated: true)
            }
        }
        
    }
    @IBAction func shareButton(_ sender: Any) {
        self.shareHula();
    }
    
    @IBAction func helpOptionAction(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "https://hula.trading/")!)
    }
    // Custom functions for ViewController
    func addAlertIcon(toView: UIView){
        let imageName = "icon_alert_thumbnails"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.tag = 220;
        imageView.frame = CGRect(x: toView.frame.width/2 + 20, y: toView.frame.height/2 - 8, width: 16, height: 16)
        toView.addSubview(imageView)
    }
    func removeAlertIcon(fromView: UIView){
        for view in fromView.subviews{
            if view.tag == 220{
                view.removeFromSuperview()
            }
        }
    }
}

extension HLSettingViewController: AlertDelegate{
    func alertResponded(response: String, trigger:String) {
        //print("Response: \(response)")
        
        if (response == "ok"){
            HLDataManager.sharedInstance.logout()
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            //self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
            self.goBackToPreviousPage("")
            
        }
    }
}

extension HLSettingViewController{
    
    // image management...
    
    
    func selectedImageTapped(){
        if (self.smallProfileImage.image != nil){
            fullScreenImage(image: self.smallProfileImage.image!, index: 1)
        } else {
            self.openCameraVC();
         }
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
            self.openCameraVC();
            
        })
        alertController.addAction(editButton)
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
            self.dismissFullscreenImageDirect()
        })
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }
    
    
    func openCameraVC() {
        let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "selectPictureGeneral") as! HLPictureSelectViewController
        cameraViewController.originalSettingsVC = self
        self.present(cameraViewController, animated: true)
        self.dismissFullscreenImageDirect()
    }
    
    
    func shareHula(){
        /*
        let alert = UIAlertController(title: NSLocalizedString("Sharing", comment: ""), message: NSLocalizedString("Please choose a sharing method", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Facebook", style: UIAlertActionStyle.default){
            UIAlertAction in
            self.shareHulaFB()
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Other", comment: ""), style: UIAlertActionStyle.default){
            UIAlertAction in
            self.shareHulaStandard()
        })
        self.present(alert, animated: true, completion: nil)
 */
        self.shareHulaStandard()
    }
    
    func shareHulaFB(){
        let appInvite = AppInvite(appLink: URL(string: "https://fb.me/128854257665971")!,
                                  deliveryMethod: .facebook,
                                  previewImageURL: URL(string: "https://hula.trading/img/logo-big.png"))
        do {
            try AppInvite.Dialog.show(from: self, invite: appInvite) { result in
                switch result {
                case .success(let result):
                    print("App Invite Sent with result \(result)")
                case .failed(let error):
                    print("Failed to send app invite with error \(error)")
                }
            }
        } catch let error {
            print("Failed to show app invite dialog with error \(error)")
        }
    }
    
    
    func shareHulaStandard(){
        let text = NSLocalizedString("Hey, I trade on HULA! I get what I want and give what I don't. https://hula.trading", comment: "")
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.assignToContact ]
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
        
        
        
    }
    
    
    
    
    
}
