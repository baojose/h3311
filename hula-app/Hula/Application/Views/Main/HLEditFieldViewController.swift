//
//  HLEditFieldViewController.swift
//  Hula
//
//  Created by Juan Searle on 04/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import CoreLocation

class HLEditFieldViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {
    var userData:HulaUser = HulaUser.sharedInstance
    var locationManager = CLLocationManager()
    
    var field_title:String = NSLocalizedString("Change data", comment: "")
    var field_label: String = NSLocalizedString("not selected", comment: "")
    var field_previous_val: String = ""
    var field_new_val: String = ""
    var field_key: String = "userNick"
    var spinner: HLSpinnerUIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var newValueTextView: UITextView!
    @IBOutlet weak var lineSeparator: UILabel!
    @IBOutlet weak var saveButton: HLBouncingButton!
    @IBOutlet weak var remainigLabel: UILabel!
    @IBOutlet weak var useMyLocationBtn: HLRoundedButton!
    
    @IBOutlet weak var grayLocationLabel: UILabel!
    
    var remainingChars: Int = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //titleLabel.text = "Change \(field_label)"
        // Do any additional setup after loading the view.
        newValueTextView.delegate = self
        
        
        useMyLocationBtn.isHidden = true
        grayLocationLabel.text = ""
        if (field_key == "zip"){
            useMyLocationBtn.isHidden = false
            remainigLabel.isHidden = true
            grayLocationLabel.isHidden = false
            
            grayLocationLabel.text = HulaUser.sharedInstance.userLocationName
            currentValueLabel.text = NSLocalizedString("CURRENT ZIP CODE:", comment: "") + " \(field_previous_val)"
            newValueTextView.keyboardType = UIKeyboardType.numberPad
            
            if field_previous_val.count == 0{
                useMyLocationAction(useMyLocationBtn)
            }
        } else {
            if (field_key == "userEmail"){
                useMyLocationBtn.isHidden = true
                remainigLabel.isHidden = true
                grayLocationLabel.isHidden = true
                
                saveButton.setTitle(NSLocalizedString("Validate", comment: ""), for: .normal)
                newValueTextView.isEditable = false
            } else {
                remainigLabel.isHidden = false
                grayLocationLabel.isHidden = true
            }
            currentValueLabel.text = NSLocalizedString("CURRENT:", comment: "") + " \(field_previous_val)"
            newValueTextView.keyboardType = UIKeyboardType.default
        }
        
        titleLabel.text = field_title
        newValueTextView.text = field_previous_val
        newValueTextView.isScrollEnabled = false
        textViewDidChange(newValueTextView)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        newValueTextView.becomeFirstResponder()
        textViewDidChange(newValueTextView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func textViewDidChange(_: UITextView){
        let w = newValueTextView.frame.size.width
        let h = commonUtils.heightString(width: w, font: newValueTextView.font! , string: newValueTextView.text + "mmmm") + 50
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.newValueTextView.frame.size = CGSize(width: self.view.frame.size.width-30, height: h)
            self.lineSeparator.frame.origin.y = self.newValueTextView.frame.origin.y + h + 15
            self.saveButton.frame.origin.y = self.lineSeparator.frame.origin.y + 30
            self.useMyLocationBtn.frame.origin.y = self.lineSeparator.frame.origin.y + 30
            self.grayLocationLabel.frame.origin.y = self.lineSeparator.frame.origin.y + 5
        }, completion: nil)
        var theRemainingChars = self.remainingChars - newValueTextView.text.count
        if (theRemainingChars < 1){
            let index = newValueTextView.text.index(newValueTextView.text.startIndex, offsetBy: self.remainingChars)
            newValueTextView.text = newValueTextView.text.substring(to: index)
            theRemainingChars = 0
        }
        remainigLabel.text = "\(theRemainingChars) " + NSLocalizedString("characters remaining", comment: "")
        
        
        
        if (field_key == "zip"){
            getLatLngForZip(zipCode: newValueTextView.text)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if (field_key == "zip"){
            getLatLngForZip(zipCode: textView.text)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        print(userLocation)
        
        //print(long, lat)
        userData.location = CLLocation(latitude:lat, longitude:long);
        if (field_key == "userLocationName" || field_key == "zip"){
            setUsersClosestCity(userLocation: userLocation)
        }
        locationManager.stopUpdatingLocation()
        //Do What ever you want with it
    }
    func setUsersClosestCity(userLocation: CLLocation){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            
            let placeArray: [CLPlacemark] = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray[0]
            
            // Address dictionary
            //print(placeMark.addressDictionary)
            let country = placeMark.addressDictionary?["Country"] as? String
            let city = placeMark.addressDictionary?["City"] as? String
            let zip = placeMark.addressDictionary?["ZIP"] as? String
            
            self.newValueTextView.text = zip!
            self.userData.zip = zip!
            self.userData.userLocationName = city! + ", " + country!
            self.grayLocationLabel.text = city! + ", " + country!
            self.spinner.hide()
            
            
            
        }
    }
    
    @IBAction func useMyLocationAction(_ sender: Any) {
        // location manager
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        spinner = HLSpinnerUIView()
        self.view.addSubview(spinner)
        spinner.show(inView: self.view)
        
    }
    
    
    @IBAction func saveNewValueAction(_ sender: Any) {
        
        if (field_key == "userEmail"){
            HulaUser.sharedInstance.resendValidationMail()
            let alert = UIAlertController(title: NSLocalizedString("Email validation", comment: ""), message: "We have just sent you an email to \(HulaUser.sharedInstance.userEmail!). Please follow the instructions provided on that message.",
                preferredStyle: UIAlertControllerStyle.alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        field_new_val = newValueTextView.text!
        userData.setValue(field_new_val, forKey: field_key)
        userData.updateServerData()
        HLDataManager.sharedInstance.writeUserData()
        let _ = self.navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func goBackAction(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func getLatLngForZip(zipCode: String) {
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(zipCode) { (places, error) in
            if let placemarks = places, let placemark = placemarks.first {
                if let loc = placemark.locality {
                    self.userData.userLocationName = loc + ", " + placemark.country!
                    self.grayLocationLabel.text = loc + ", " + placemark.country!
                    self.userData.location = placemark.location
                }
            }
        }
    }

}
