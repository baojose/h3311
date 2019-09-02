//
//  HLDataManager.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import MapKit

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

class HLDataManager: NSObject {
    
    var currentUser: HulaUser!
    var newProduct: HulaProduct!
    var arrCategories : NSMutableArray!
    var arrTrades : [NSDictionary]! = []
    var arrCurrentTrades : [NSDictionary]! = []
    var arrPastTrades : [NSDictionary]! = []
    var arrNotifications : NSMutableArray!
    var uploadMode: Bool!
    var onboardingTutorials: NSMutableDictionary!
    var tradeMode:String = "current"
    var numNotificationsPending: Int = 0
    var lastServerMessage:String = ""
    var isLoadingNotifications:Bool = false
    var isInSwapVC : Bool = false
    var onlyLandscapeView : Bool = false
    
    let categoriesLoaded = Notification.Name("categoriesLoaded")
    let loginRecieved = Notification.Name("loginRecieved")
    let fbLoginRecieved = Notification.Name("fbLoginRecieved")
    let signupRecieved = Notification.Name("signupRecieved")
    let notificationsRecieved = Notification.Name("notificationsRecieved")
    
    class var sharedInstance: HLDataManager {
        struct Static {
            static let instance: HLDataManager = HLDataManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        
        uploadMode = false
        currentUser = HulaUser.init()
        newProduct = HulaProduct.init()
        numNotificationsPending = 0
        
        isInSwapVC = false
        
        arrCategories = []
        arrNotifications = []
        arrTrades = []
        arrCurrentTrades = []
        arrPastTrades = []
        getCategories()
//        arrCategories = [["icon" : "icon_cat_service" , "name" : "SERVICES"],
//                         ["icon" : "icon_cat_cars" , "name" : "CARS, BIKES & AUTO PARTS"],
//                         ["icon" : "icon_cat_clothing" , "name" : "CLOTHING"],
//                         ["icon" : "icon_cat_electronic" , "name" : "ELECTRONICS & MOBILE"],
//                         ["icon" : "icon_cat_furniture" , "name" : "FURNITURE"],
//                         ["icon" : "icon_cat_art" , "name" : "ART & ANTIQUES"],
//                         ["icon" : "icon_cat_house" , "name" : "HOUSE, YARD & FURNITURE"],
//                         ["icon" : "icon_cat_videogames" , "name" : "VIDEOGAMES"],
//                         ["icon" : "icon_cat_collectible" , "name" : "COLLECTIBLE & HOBBBIES"],
//                         ["icon" : "icon_cat_music" , "name" : "MUSIC & MUSICAL INSTRUMENTS"],
//                         ["icon" : "icon_cat_tool" , "name" : "TOOLS & REPAIR"],
//                         ["icon" : "icon_cat_photography" , "name" : "PHOTOGRAPHY"],
//                         ["icon" : "icon_cat_computer" , "name" : "COMPUTERS"],
//                         ["icon" : "icon_cat_sport" , "name" : "SPORTS"],
//                         ["icon" : "icon_cat_jewelry" , "name" : "JEWELRY"],
//                         ["icon" : "icon_cat_camping" , "name" : "CAMPING, SURVIVAL & OUTDOORS"],
//                         ["icon" : "icon_cat_other" , "name" : "OTHERS"]]
        
        
    }
    
    
    func getCategories() {
        let queryURL = HulaConstants.apiURL + "categories"
        httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            //print(ok)
            if (ok){
                self.arrCategories=[];
                if let array = json as? [Any] {
                    for cat in array {
                        // access all objects in array
                        self.arrCategories.add(cat)
                    }
                }
                
                NotificationCenter.default.post(name: self.categoriesLoaded, object: nil)
            }
        })
    }
    func getTrades(taskCallback: @escaping (Bool) -> ()) {
        let queryURL = HulaConstants.apiURL + "trades"
        httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            //print(ok)
            if (ok){
                self.arrTrades = [];
                self.arrCurrentTrades = [];
                self.arrPastTrades = []
                if let array = json as? [NSDictionary] {
                    for trade in array {
                        // access all objects in array
                        if let st = trade.object(forKey: "status") as? String{
                            //print(st)
                            var hideFromDashboard = false
                            if trade.object(forKey: "owner_id") as! String == HulaUser.sharedInstance.userId {
                                if trade.object(forKey: "owner_accepted") as? Bool == true {
                                    hideFromDashboard = true
                                }
                            } else {
                                if trade.object(forKey: "other_accepted") as? Bool == true {
                                    hideFromDashboard = true
                                }
                                if trade.object(forKey: "other_agree") as? Bool == false {
                                    hideFromDashboard = true
                                }
                            }
                            if st != HulaConstants.end_status && st != HulaConstants.cancel_status && !hideFromDashboard {
                                // status not ended and not cancelled and not agreed
                                if  (st != HulaConstants.pending_status || trade.object(forKey: "turn_user_id") as! String == HulaUser.sharedInstance.userId) {
                                    // status not pending
                                    self.arrCurrentTrades.append(trade)
                                }
                            } else {
                                if st == HulaConstants.end_status || st == HulaConstants.review_status {
                                    self.arrPastTrades.append(trade)
                                }
                            }
                        }
                        self.arrTrades.append(trade)
                    }
                }
                taskCallback(true)
            } else {
                taskCallback(false)
            }
        })
    }
    
    func ga(_ page: String){
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: page)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func loginUser(email:String, pass:String) {
        
        //print("Login in progress...")
        let queryURL = HulaConstants.apiURL + "authenticate"
        var loginSuccess = "";
        httpPost(urlstr: queryURL, postString: "email="+email+"&pass="+pass, isPut: false, taskCallback: { (ok, json) in
            
            //print("done")
            //print(ok)
            //print(json!)
            if (ok){
                let user = HulaUser.sharedInstance
                if let dictionary = json as? [String: Any] {
                    if (dictionary["token"] as? String) != nil {
                        // access individual value in dictionary
                        
                        self.updateUserFromDict(dict: dictionary as NSDictionary)
                        //user.token = token
                        //user.userId = dictionary["userId"] as? String
                        //print(token)
                        loginSuccess = "ok";
                        self.writeUserData()
                    }
                    if let resp = dictionary["message"] as? String {
                        loginSuccess = resp;
                    }
                } else {
                    user.token = ""
                    loginSuccess = NSLocalizedString("Incorrect login. Please try again.", comment: "");
                }
                self.lastServerMessage = loginSuccess
                NotificationCenter.default.post(name: self.loginRecieved, object: loginSuccess)
            }
        })
    }
    
    func loginUserWithFacebook(token:String){
        let queryURL = HulaConstants.apiURL + "fbauth"
        var loginSuccess = false;
        
        httpPost(urlstr: queryURL, postString: "fbtoken="+token, isPut: false, taskCallback: { (ok, json) in
            
            //print("done")
            //print(ok)
            //print(json!)
            self.lastServerMessage = NSLocalizedString("Facebook login error", comment: "")
            if (ok){
                let user = HulaUser.sharedInstance
                if let dictionary = json as? [String: Any] {
                    if (dictionary["token"] as? String) != nil {
                        
                        if let us = dictionary["allUser"] as? NSDictionary {
                            HulaUser.sharedInstance.logout();
                            //print(us)
                            // access individual value in dictionary
                            
                            self.updateUserFromDict(dict: dictionary as NSDictionary)
                            self.updateUserFromDict(dict: us as NSDictionary)
                            //print(token)
                            self.writeUserData()
                        }
                        loginSuccess = true;
                        self.lastServerMessage = "ok"
                    }
                } else {
                    user.token = ""
                }
                
                NotificationCenter.default.post(name: self.fbLoginRecieved, object: loginSuccess)
            }
        })
 
    }

    
    func logout() {
        //var user = HulaUser.sharedInstance
        HulaUser.sharedInstance.token = ""
        HulaUser.sharedInstance.userId = ""
        
        HulaUser.sharedInstance.logout();
        self.writeUserData()
        
        
    }
    
    func amITradingWith(_ user_id: String) -> Bool{
        for tr in arrCurrentTrades{
            if let trade = tr as? [String:Any] {
                //print(trade["owner_id"] as! String)
                if trade["owner_id"] as! String == user_id {
                    return true
                }
                if trade["other_id"] as! String == user_id {
                    return true
                }
            }
        }
        return false
    }
    
    func getTradeWith(_ user_id: String) -> String{
        
        for tr in arrCurrentTrades{
            if let trade = tr as? [String:Any] {
                //print(trade["owner_id"] as! String)
                if trade["owner_id"] as! String == user_id {
                    return trade["_id"] as! String
                }
                if trade["other_id"] as! String == user_id {
                    return trade["_id"] as! String
                }
            }
        }
        for tr in self.arrTrades {
            if let trade = tr as? [String:Any] {
                if let agreed = trade["other_agree"] as? Bool {
                    if !agreed && trade["owner_id"] as! String == user_id && ((trade["status"] as! String == HulaConstants.sent_status) || (trade["status"] as! String == HulaConstants.pending_status)) {
                        return trade["_id"] as! String
                    }
                }
            }
        }
        return ""
    }
    func amIOfferedToTradeWith(_ user_id: String) -> Bool{
        for tr in arrCurrentTrades{
            if let trade = tr as? [String:Any] {
                if trade["other_id"] as! String == user_id && (trade["status"] as! String == HulaConstants.pending_status ) {
                    return true
                }
            }
        }
        for tr in self.arrTrades {
            if let trade = tr as? [String:Any] {
                if let agreed = trade["other_agree"] as? Bool {
                    print(agreed)
                    if !agreed && trade["owner_id"] as! String == user_id   {
                        return true
                    }
                }
                //print(numBids)
                
            }
        }
        return false
    }
    
    func myRoomsFull() -> Bool{
        if (arrCurrentTrades.count >= HulaUser.sharedInstance.maxTrades){
            return true
        }
        return false
    }
    
    func signupUser(email:String, nick: String, pass:String) {
        
        //print("Login in progress...")
        let queryURL = HulaConstants.apiURL + "signup"
        var signupSuccess = false;
        httpPost(urlstr: queryURL, postString: "email="+email+"&pass="+pass+"&name="+nick+"&nick="+nick, isPut: false, taskCallback: { (ok, json) in
            
            //print("done")
            //print(ok)
            if (ok){
                //print(json!)
                let user = HulaUser.sharedInstance
                if let dictionary = json as? [String: Any] {
                    // access individual value in dictionary
                    if let token = dictionary["token"] as? String {
                        if (token != ""){
                            self.updateUserFromDict(dict: dictionary as NSDictionary)
                            //print(token)
                            signupSuccess = true;
                            self.writeUserData()
                            self.lastServerMessage = "ok"
                        } else {
                            
                            self.lastServerMessage = NSLocalizedString("User email already exists! Please use the login form.", comment: "")
                            
                        }
                        
                    }
                } else {
                    user.token = ""
                    self.lastServerMessage = NSLocalizedString("Server response unexpected", comment: "")
                }
                NotificationCenter.default.post(name: self.signupRecieved, object: signupSuccess)
            }
        })
    }
    
    
    func getUserProfile(userId:String, taskCallback: @escaping (HulaUser, NSArray, NSArray) -> ()) {
        //print("Getting user info...")
        let queryURL = HulaConstants.apiURL + "users/" + userId
        //print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? [String: Any] {
                        let userReturned = HulaUser()
                        //print("----------- User loaded")
                        //print(dictionary)
                        if let user = dictionary["user"] as? NSDictionary {
                            userReturned.populate(with: user)
                        }
                        var arrProducts = NSArray()
                        if let dpr = dictionary["products"] as? NSArray {
                            arrProducts = dpr
                        }
                        var arrFeedback = NSArray()
                        if let dpr = dictionary["feedback"] as? NSArray {
                            arrFeedback = dpr
                        }
                        taskCallback(userReturned, arrProducts, arrFeedback)
                    }
                }
            } else {
                // connection error
            }
        })
    }
    
    func getProduct(productId:String, taskCallback: @escaping (HulaProduct) -> ()) {
        //print("Getting user info...")
        let queryURL = HulaConstants.apiURL + "products/" + productId
        //print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? NSDictionary {
                        let productReturned = HulaProduct()
                        productReturned.populate(with: dictionary)
                        taskCallback(productReturned)
                    }
                }
            } else {
                // connection error
            }
        })
    }
    
    
    func httpGet(urlstr:String, taskCallback: @escaping (Bool, Any?) -> ()) {
        let url = URL(string: urlstr)
        //print(url!)
        var request:URLRequest = URLRequest(url: url!)
        
        let user = HulaUser.sharedInstance
        //print(user.token)
        if (user.token.count>10){
            request.setValue(user.token, forHTTPHeaderField: "x-access-token")
        }
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!)
                taskCallback(false, nil)
                return
            }
            guard let data = data else {
                print("Data is empty")
                taskCallback(false, nil)
                return
            }
            //print(request)
            //print(response)
            //print(data.count)
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            //print(json)
            taskCallback(true, json as AnyObject?)
        }
    
        task.resume()
    }

    func httpPost(urlstr:String, postString:String, isPut: Bool, taskCallback: @escaping (Bool, Any?) -> ()) {
        let url = URL(string: urlstr)
        var request = URLRequest(url: url!)
        if (isPut){
            request.httpMethod = "PUT"
        } else {
            request.httpMethod = "POST"
        }
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type") //Optional
        request.httpBody = postString.data(using: .utf8)
        let user = HulaUser.sharedInstance
        if (user.token.count>10){
            request.addValue(user.token, forHTTPHeaderField: "x-access-token")
        }
        //print(request.httpBody!)
        //print(request.httpMethod!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print(error!)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response ?? "No response")
            }
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            taskCallback(true, json as AnyObject?)
        }
        task.resume()
    }
    
    func uploadImage(_ image: UIImage, itemPosition: Int, taskCallback: @escaping (Bool, Any?) -> ()){
        let imageData = UIImageJPEGRepresentation(image,0.7)
        
        if imageData != nil{
            let queryURL = HulaConstants.apiURL + "upload/image"
            var request = URLRequest(url: URL(string:queryURL)!)
            let session:URLSession = URLSession.shared
            
            request.httpMethod = "POST"
            
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let user = HulaUser.sharedInstance
            if (user.token.count>10){
                request.setValue(user.token, forHTTPHeaderField: "x-access-token")
            }
            let body = createBody(parameters: ["position": "\(itemPosition)"],
                                  boundary: boundary,
                                  data: imageData!,
                                  mimeType: "image/jpeg",
                                  filename: "image1.jpg")
            
            
            request.httpBody = body as Data
            
            
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print(error!)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print(response ?? "No response")
                } else {
                    
                    let json = try! JSONSerialization.jsonObject(with: data, options: [])
                    taskCallback(true, json as AnyObject?)
                }
            }
            task.resume()
            
        }
    }
    
    func uploadVideo(_ videoPath: String, productId:String, tradeId:String, taskCallback: @escaping (Bool, Any?) -> ()){
        let videoData = NSData(contentsOfFile: videoPath)
        
        if videoData != nil{
            let queryURL = HulaConstants.apiURL + "upload/video"
            var request = URLRequest(url: URL(string:queryURL)!)
            let session:URLSession = URLSession.shared
            
            request.httpMethod = "POST"
            
            
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let user = HulaUser.sharedInstance
            if (user.token.count>10){
                request.setValue(user.token, forHTTPHeaderField: "x-access-token")
            }
            let body = createBody(parameters: ["product_id": "\(productId)", "trade_id": "\(tradeId)"],
                                  boundary: boundary,
                                  data: videoData! as Data,
                                  mimeType: "video/mp4",
                                  filename: "video.mp4")
            
            
            request.httpBody = body as Data
            
            
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print(error!)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print(response ?? "No response")
                } else {
                    
                    let json = try! JSONSerialization.jsonObject(with: data, options: [])
                    taskCallback(true, json as AnyObject?)
                }
            }
            task.resume()
            
        }
    }
    
    func createBody(parameters: [String: String],
                    boundary: String,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        //print(body)
        return body as Data
    }
    
    
    func writeUserData(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent(HulaConstants.userFile + ".plist")
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        
        //saving values
        
        let user = HulaUser.sharedInstance
        
        dict.setObject(user.token, forKey: "token" as NSCopying)
        dict.setObject(user.userId, forKey: "userId" as NSCopying)
        dict.setObject(user.userNick, forKey: "userNick" as NSCopying)
        dict.setObject(user.userName, forKey: "userName" as NSCopying)
        dict.setObject(user.userEmail, forKey: "userEmail" as NSCopying)
        dict.setObject(user.maxTrades, forKey: "max_trades" as NSCopying)
        dict.setObject(user.userLocationName, forKey: "userLocationName" as NSCopying)
        dict.setObject(self.onboardingTutorials, forKey: "onboardingTutorials" as NSCopying)
        dict.setObject([CGFloat(user.location.coordinate.latitude), CGFloat(user.location.coordinate.longitude)] as [CGFloat], forKey: "userLocation" as NSCopying)
        dict.setObject(user.userPhotoURL, forKey: "userPhotoURL" as NSCopying)
        dict.setObject(user.userBio, forKey: "userBio" as NSCopying)
        dict.setObject(user.numProducts, forKey: "numProducts" as NSCopying)
        
        //...
        dict.write(toFile: path, atomically: false)
        //let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //print("Saved UserData.plist file is --> \(String(describing: resultDictionary?.description))")
        
        self.loadUserData()
    }
    
    
    public func loadUserData() {
        // getting path to GameData.plist
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! NSString
        let path = documentsDirectory.appendingPathComponent(HulaConstants.userFile + ".plist")
        
        //        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        let fileManager = FileManager.default
        
        //check if file exists
        if(!fileManager.fileExists(atPath: path))
        {
            // If it doesn't, copy it from the default file in the Bundle
            
            if let bundlePath = Bundle.main.path(forResource: HulaConstants.userFile, ofType: "plist")
            {
                //let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                //print("Bundle UserData.plist file is --> \(String(describing: resultDictionary?.description))")
                
                do
                {
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                    //print("copy")
                }
                catch _
                {
                    print("error failed loading data")
                }
            }
            else
            {
                print("UserData.plist not found. Please, make sure it is part of the bundle.")
            }
        }
        else
        {
            //print("UserData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        
        //let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //print("Loaded UserData.plist file is --> \(String(describing: resultDictionary?.description))")
        let myDict = NSDictionary(contentsOfFile: path)
        
        if let dict = myDict {
            //loading values
            
            //print("User data loaded:")
            //print(dict)
            
            updateUserFromDict(dict: dict)
            if let tmp = dict.object(forKey: "onboardingTutorials") as? NSDictionary {
                let tmpMutable:NSMutableDictionary = NSMutableDictionary(dictionary: tmp)
                self.onboardingTutorials = tmpMutable
            } else {
                self.onboardingTutorials = ["XInitializerItem": "DoNotEverChangeMe"]
            }
            
            self.loadUserNotifications()
        } else {
            print("WARNING: Couldn't create dictionary from UserData.plist! Default values will be used!")
        }
        //self.onboardingTutorials = ["XInitializerItem": "DoNotEverChangeMe"]
        //print (self.onboardingTutorials)
    }//eom
    
    func updateUserFromDict(dict: NSDictionary){
        let user = HulaUser.sharedInstance
        if dict.object(forKey: "token") as? String != nil {
            user.token = dict.object(forKey: "token")! as! String
        }
        if dict.object(forKey: "userId") as? String != nil {
            user.userId = dict.object(forKey: "userId")! as! String
        }
        if dict.object(forKey: "userNick") as? String != nil {
            user.userNick = dict.object(forKey: "userNick")! as! String
        }
        if dict.object(forKey: "nick") as? String != nil {
            user.userNick = dict.object(forKey: "nick")! as! String
        }
        if dict.object(forKey: "userName") as? String != nil {
            user.userName = dict.object(forKey: "userName")! as! String
        }
        if dict.object(forKey: "name") as? String != nil {
            user.userName = dict.object(forKey: "name")! as! String
        }
        if dict.object(forKey: "userEmail") as? String != nil {
            user.userEmail = dict.object(forKey: "userEmail")! as! String
        }
        if dict.object(forKey: "email") as? String != nil {
            user.userEmail = dict.object(forKey: "email")! as! String
        }
        if dict.object(forKey: "userBio") as? String != nil {
            user.userBio = dict.object(forKey: "userBio")! as! String
        }
        if dict.object(forKey: "bio") as? String != nil {
            user.userBio = dict.object(forKey: "bio")! as! String
        }
        if dict.object(forKey: "userPhotoURL") as? String != nil {
            user.userPhotoURL = dict.object(forKey: "userPhotoURL")! as! String
        }
        if dict.object(forKey: "image") as? String != nil {
            user.userPhotoURL = dict.object(forKey: "image")! as! String
        }
        if dict.object(forKey: "userLocationName") as? String != nil {
            user.userLocationName = dict.object(forKey: "userLocationName")! as! String
        }
        if dict.object(forKey: "location_name") as? String != nil {
            user.userLocationName = dict.object(forKey: "location_name")! as! String
        }
        if dict.object(forKey: "max_trades") as? Int != nil {
            user.maxTrades = dict.object(forKey: "max_trades")! as! Int
        }
        if let loc = dict.object(forKey: "userLocation") as? [CGFloat] {
            user.location = CLLocation(latitude: CLLocationDegrees(loc[0]), longitude: CLLocationDegrees(loc[1]))
        }
        if let n = dict.object(forKey: "numProducts") as? Int {
            user.numProducts = n
        }
    }
    
    func loadUserNotifications(){
        //print("loading notifications...")
        if HulaUser.sharedInstance.isUserLoggedIn() {
            isLoadingNotifications = true
            let queryURL = HulaConstants.apiURL + "notifications"
            httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                //print(ok)
                var num_pending = 0
                if (ok){
                    self.arrNotifications = [];
                    if let array = json as? [Any] {
                        for not in array {
                            // access all objects in array
                            if let dict = not as? [String: Any]{
                                if let status = dict["status"] as? String{
                                    if (status != "deleted"){
                                        self.arrNotifications.add(not)
                                    }
                                }
                                if let isread = dict["is_read"] as? Int{
                                    if isread == 0{
                                        num_pending += 1
                                    }
                                }
                            }
                        }
                        
                    }
                    DispatchQueue.main.async { // Correct
                        HLDataManager.sharedInstance.numNotificationsPending = num_pending
                        UIApplication.shared.applicationIconBadgeNumber = num_pending
                        self.isLoadingNotifications = false
                        
                        NotificationCenter.default.post(name: self.notificationsRecieved, object: nil)
                    }
                }
            })
        } else {
            HLDataManager.sharedInstance.numNotificationsPending = 0
            UIApplication.shared.applicationIconBadgeNumber = 0
            self.isLoadingNotifications = false
            self.arrNotifications = []
            NotificationCenter.default.post(name: self.notificationsRecieved, object: nil)
        }
    }
}
