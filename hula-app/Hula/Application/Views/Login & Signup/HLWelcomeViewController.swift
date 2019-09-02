//
//  HLWelcomeViewController.swift
//  Hula
//
//  Created by Juan Searle on 04/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import CoreLocation

class HLWelcomeViewController: UserBaseViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!

    @IBOutlet weak var mobileImage: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var messagesView: UIView!
    
    var step: Int = 0;
    var title1:String = NSLocalizedString("Up for push notifications?", comment: "")
    var title2:String = NSLocalizedString("Allow HULA to access your location", comment: "")
    var description1:String = NSLocalizedString("Notifications may include alerts when a user sends you a message.", comment: "")
    var description2:String = NSLocalizedString("Find what you need near you!", comment: "")
    var button1:String = NSLocalizedString("Notify me", comment: "")
    var button2:String = NSLocalizedString("Use my location", comment: "")
    var messagesViewPosition:CGPoint = CGPoint(x:0, y:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        messagesViewPosition = self.mobileImage.frame.origin
        mobileImage.alpha = 0
        self.mobileImage.frame.offsetBy(dx: 0, dy: 400)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        HLDataManager.sharedInstance.ga("welcome")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func okButtonTapped(_ sender: Any) {
        
        switch step {
        case 0:
            showNotificationsScreen()
        case 1:
            askPushNotificationPermissions()
        case 2:
            askLocationPermission()
        default:
            self.closeIdentification()
            self.dismiss(animated: true)
            self.presentingViewController?.dismiss(animated: true)
        }
        step += 1
    }
    
    func showNotificationsScreen(){
        //print("notif: \(isPushNotificationEnabled())")
        let isRegisteredForRemoteNotifications = isPushNotificationEnabled()
        if !isRegisteredForRemoteNotifications {
            titleLabel.text = title1
            descriptionLabel.text = description1
            continueButton.setTitle(button1, for: .normal)
            UIView.animate(withDuration: 0.4) {
                self.messagesView.frame.size.height = self.view.frame.height - 110
                self.messagesView.frame.origin.y = 90
                self.mobileImage.frame.origin.y = 190
                self.mobileImage.alpha = 1
                self.backgroundImage.alpha = 0
            }
        } else {
            step += 1
            showLocationScreen()
        }
    }
    
    func askPushNotificationPermissions(){
        let app = UIApplication.shared.delegate as! AppDelegate
        app.registerForPushNotifications()
        
        
        showLocationScreen()
    }
    
    func isPushNotificationEnabled() -> Bool{
            return UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert) ?? false
    }
    func askLocationPermission(){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            
            
            if CLLocationManager.locationServicesEnabled() {
                print("Location services are enabled")
                switch(CLLocationManager.authorizationStatus()) {
                case .notDetermined, .restricted:
                    print("Pending...")
                    locationManager.requestWhenInUseAuthorization()
                //self.closeIdentification()
                case .denied:
                    print("Not authorized")
                    let alert = UIAlertController(title: NSLocalizedString("Allow HULA to access your location while you use the app?", comment: ""), message: NSLocalizedString("HULA uses this to help you to find stuff you like nearby, connect to other users and more. Go to Settings and turn on location for Hula.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: {
                        self.closeIdentification()
                    })
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Authorized")
                    self.closeIdentification()
                    self.dismiss(animated: true)
                    self.presentingViewController?.dismiss(animated: true)
                    
                    
                }
            } else {
                print("Location services are not enabled")
                self.closeIdentification()
            }
    }
    
    func showLocationScreen(){
        var locationPermissions = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                locationPermissions = false
            case .authorizedAlways, .authorizedWhenInUse:
                locationPermissions = true
            }
        }
        
        //print("locat: \(locationPermissions)")
        if locationPermissions {
            self.closeIdentification()
            self.dismiss(animated: true)
            self.presentingViewController?.dismiss(animated: true)
        } else {
            self.messagesViewPosition.x = self.messagesView.frame.origin.x
            UIView.animate(withDuration: 0.4, animations: { 
                self.messagesView.frame.origin.x = -500
            }) { (result) in
                self.titleLabel.text = self.title2
                self.descriptionLabel.text = self.description2
                self.continueButton.setTitle(self.button2, for: .normal)
                self.messagesView.frame.origin.x = 1000
                UIView.animate(withDuration: 0.4) {
                    self.messagesView.frame.origin.x = self.messagesViewPosition.x
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //print("changedAuth")
        //print(status)
        
        if status == .authorizedWhenInUse {
            self.closeIdentification()
            self.dismiss(animated: true)
        }
 
    }
}
