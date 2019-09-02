//
//  HulaUser.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import CoreLocation

class HulaUser: NSObject {
    
    var userId: String!
    var userName: String!
    var userNick: String!
    var userEmail: String!
    var userPhotoURL: String!
    var userLocationName: String!
    var userBio: String!
    var userPass: String!
    var token: String!
    var status: String!
    var zip: String!
    var location: CLLocation!
    var fbToken: String!
    var twToken: String!
    var liToken: String!
    var deviceId: String!
    var maxTrades: Int = 3
    var feedback_count: Float = 0.0
    var feedback_points: Float = 0.0
    var trades_started: Float = 0.0
    var trades_finished: Float = 0.0
    var trades_closed: Float = 0.0
    var arrayProducts = [] as Array
    var numProducts:Int = 0
    
    class var sharedInstance: HulaUser {
        struct Static {
            static let instance: HulaUser = HulaUser()
        }
        return Static.instance
    }
    override init() {
        super.init()
        self.userId = ""
        self.userNick = ""
        self.userName = ""
        self.userEmail = ""
        self.userPhotoURL = ""
        self.userLocationName = ""
        self.userPass = ""
        self.userBio = ""
        self.token = ""
        self.status = ""
        self.zip = ""
        self.fbToken = ""
        self.twToken = ""
        self.liToken = ""
        self.deviceId = ""
        self.feedback_count = 0.0
        self.feedback_points = 0.0
        self.trades_started = 0.0
        self.trades_finished = 0.0
        self.trades_closed = 0.0
        self.location = CLLocation(latitude: 0, longitude: 0)
        self.maxTrades = 3
        self.arrayProducts = []
        self.numProducts = 0
    }
    
    func isIncompleteProfile() -> Bool{
        var isIncomplete = false
        if (self.userName==""){
            isIncomplete = true
        }
        if (self.userNick==""){
            isIncomplete = true
        }
        if (self.userName==""){
            isIncomplete = true
        }
        if (self.userBio==""){
            isIncomplete = true
        }
        if (self.userPhotoURL==""){
            isIncomplete = true
        }
        return isIncomplete
    }
    func logout() {
        self.userId = ""
        self.userNick = ""
        self.userName = ""
        self.userEmail = ""
        self.userPhotoURL = ""
        self.userLocationName = ""
        self.userBio = ""
        self.userPass = ""
        self.token = ""
        self.status = ""
        self.zip = ""
        self.fbToken = ""
        self.twToken = ""
        self.liToken = ""
        self.maxTrades = 3
        self.deviceId = ""
        self.feedback_count = 0.0
        self.feedback_points = 0.0
        self.trades_started = 0.0
        self.trades_finished = 0.0
        self.trades_closed = 0.0
        //self.location = CLLocation(latitude: 0, longitude: 0)
        self.arrayProducts = []
        self.numProducts = 0
    }
    
    func isUserLoggedIn() -> Bool{
        var isLoggedIn = false;
        if (self.userId.count > 0) && (self.token.count > 0) {
            isLoggedIn = true;
        }
        return isLoggedIn
    }
    
    func updateServerData(){
        //print("Updating user...")
        if(isUserLoggedIn()){
            let queryURL = HulaConstants.apiURL + "users/" + self.userId
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: getPostString(), isPut: true, taskCallback: { (ok, json) in
                
                //print("done")
                //print(ok)
                if (ok){
                    //print(json!)
                    if (json as? [String: Any]) != nil {
                        //print(dictionary)
                    }
                    
                    //NotificationCenter.default.post(name: self.signupRecieved, object: signupSuccess)
                }
            })
        }
    }
    
    func resendValidationMail(){
        //print("Sending validation mail...")
        if(isUserLoggedIn()){
            let queryURL = HulaConstants.apiURL + "users/resend/" + self.userId
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: getPostString(), isPut: true, taskCallback: { (ok, json) in
                //print("Message sent!")
                if (ok){
                    if (json as? [String: Any]) != nil {
                        //print(dictionary)
                    }
                    
                    //NotificationCenter.default.post(name: self.signupRecieved, object: signupSuccess)
                }
            })
        }
    }
    func getPostString() -> String {
        var str = "email=" + self.userEmail + "&name=" + self.userName + "&bio=" + self.userBio
        str = str + "&nick=" + self.userNick + "&image=" + self.userPhotoURL + "&twtoken=" + self.twToken
        str = str + "&litoken=" + self.liToken + "&fbtoken=" + self.fbToken + "&push_device_id=" + self.deviceId
        str = str + "&zip=" + self.zip + "&max_trades=" + String(self.maxTrades)
        
        if (self.location.coordinate.latitude != 0 && self.location.coordinate.longitude != 0){
           str = str + "&lat=\(self.location.coordinate.latitude)&lng=\(self.location.coordinate.longitude)&location_name=" + self.userLocationName
        }
        return str
    }
    func getFeedback() -> String{
        var res = "-"
        if self.feedback_count > 0 {
            let perc: Int =  Int(round( self.feedback_points/self.feedback_count * 100))
            res = "\(perc)%"
        } else {
            res = "-"
        }
        return res
    }
    
    
    
    func populate(with: NSDictionary){
        if let tmp = with.object(forKey: "_id") as? String { userId = tmp }
        if let tmp = with.object(forKey: "name") as? String { userName = tmp }
        if let tmp = with.object(forKey: "nick") as? String { userNick = tmp }
        if let tmp = with.object(forKey: "bio") as? String { userBio = tmp }
        if let tmp = with.object(forKey: "email") as? String { userEmail = tmp }
        if let tmp = with.object(forKey: "image") as? String { userPhotoURL = tmp }
        if let tmp = with.object(forKey: "location") as? [CGFloat]  {
            let lat = tmp[0]
            let lon = tmp[1]
            location = CLLocation(latitude:CLLocationDegrees(lat), longitude:CLLocationDegrees(lon));
        }
        if let tmp = with.object(forKey: "location_name") as? String  {
            userLocationName = tmp;
        }
        if let tmp = with.object(forKey: "fb_token") as? String { fbToken = tmp }
        if let tmp = with.object(forKey: "tw_token") as? String { twToken = tmp }
        if let tmp = with.object(forKey: "li_token") as? String { liToken = tmp }
        if let tmp = with.object(forKey: "status") as? String { status = tmp }
        if let tmp = with.object(forKey: "zip") as? String { zip = tmp }
        
        if let tmp = with.object(forKey: "feedback_count") as? Float { feedback_count = tmp }
        if let tmp = with.object(forKey: "feedback_points") as? Float { feedback_points = tmp }
        
        
        if let tmp = with.object(forKey: "trades_started") as? Float { trades_started = tmp }
        if let tmp = with.object(forKey: "trades_finished") as? Float { trades_finished = tmp }
        if let tmp = with.object(forKey: "trades_closed") as? Float { trades_closed = tmp }
        
        if let tmp = with.object(forKey: "deviceId") as? String { deviceId = tmp }
        if let tmp = with.object(forKey: "max_trades") as? Int { maxTrades = tmp }
        
        
        
    }
    
    
    
    override var description : String {
        return "User id: \(self.userId!); nick:   \(self.userNick!)  location: \(self.location.coordinate.latitude) ,  \(self.location.coordinate.longitude)\n"
    }
}
