//
//  ChatViewController.swift
//  Hula
//
//  Created by Juan Searle FC on 25/08/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var chatTextField: UITextField!

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var chatTextFrame: UIView!
    var chat:[NSDictionary] = [];
    var trade_id:String = "";
    
    var sortedChat:NSMutableDictionary = [:]
    var sectionKeys:[String] = []
    
    var keyboardHeight:CGFloat = 150
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updateData(forze: true)
        //print(sortedChat)
        
        chatTextFrame.layer.cornerRadius = 15
        chatTextFrame.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8).cgColor
        chatTextFrame.layer.masksToBounds = true
        chatTextFrame.layer.borderWidth = 1.0
        
        let tapper = UITapGestureRecognizer(target: self, action:#selector(endEditing))
        view.addGestureRecognizer(tapper)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
        
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.refreshChat), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.refreshChat), userInfo: nil, repeats: true)
        
        HLDataManager.sharedInstance.ga("chat")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        
        
        timer.invalidate()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func refreshChat(forze: Bool){
        //print("refreshing...")
        //print("trade id: \(trade_id)")
        let queryURL = HulaConstants.apiURL + "trades/\(trade_id)/chat"
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            //print("done")
            //print(ok)
            //print(json!)
            if (ok){
                if let dictionary = json as? [NSDictionary] {
                    DispatchQueue.main.async(execute: {
                        self.chat = dictionary
                        self.updateData(forze: forze)
                    })
                } else {
                    
                }
                
            }
        })
        
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            DispatchQueue.main.async(execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        
    }
    
    func updateData(forze: Bool){
        let prev_co = self.chatTableView.contentOffset
        let prev_sect = self.sectionKeys.count
        let prev_chats = self.sortedChat.hashValue
        self.sectionKeys = []
        self.sortedChat = [:]
        for message in self.chat{
            if let date = message.object(forKey: "date") as? String{
                let index = date.index(date.startIndex, offsetBy: 13)
                let date_extract = date.substring(to: index)
                //print(date_extract)
                if var exists = self.sortedChat.object(forKey: date_extract) as? [NSDictionary]{
                    exists.append(message)
                    self.sortedChat.setValue(exists, forKey: date_extract)
                } else {
                    self.sortedChat.setValue([message], forKey: date_extract)
                    self.sectionKeys.append(date_extract)
                }
            }
        }
        self.chatTableView.reloadData()
        if (prev_sect != self.sectionKeys.count) || (prev_chats != self.sortedChat.hashValue) || forze {
            print("refreshing chat...")
            
            DispatchQueue.main.async(execute: {
                self.chatTableView.setContentOffset(prev_co, animated: false)
                self.chatTableView.setContentOffset(CGPoint(x:0, y:self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
            })
        }
    }
    
    
    @IBAction func sendChatTextAction(_ sender: Any) {
        var tx = self.chatTextField.text!
        if tx.count > 300 {
            tx = String( tx.prefix(300)  );
        }
        //print("Sending...")
        //print("trade id: \(self.trade_id)")
        if tx.count > 0 {
            let queryURL = HulaConstants.apiURL + "trades/\(self.trade_id)/chat"
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: "message=\(tx)", isPut: false, taskCallback: { (ok, json) in
                //print("done")
                //print(ok)
                if (ok){
                    if (json as? NSDictionary) != nil {
                        DispatchQueue.main.async(execute: {
                            self.chatTextField.text = ""
                            self.refreshChat(forze:true)
                        })
                    } else {
                        
                    }
                    
                }
                HLDataManager.sharedInstance.getTrades {(succ) in
                    // trades refreshed
                    print("Trades loaded from chat")
                }
            })
        }
    }
    
    
    @IBAction func closeChatAction(_ sender: Any) {

        HLDataManager.sharedInstance.getTrades{(succ) in
            // trades refreshed
            print("Trades loaded from chat")
        }
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    func rotated() {
        /*
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            self.presentingViewController?.dismiss(animated: true)
            self.dismiss(animated: true)
        }
 */
    }
 
}
extension ChatViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.animateTextField(textField: textField, up:false)
    }
    func endEditing(){
        self.animateTextField(textField: UITextField(), up:false)
        chatTextField.resignFirstResponder()
    }
    
    func animateTextField(textField: UITextField, up: Bool){
        let movementDistance:CGFloat = -keyboardHeight
        var movementDuration: Double = 0.2
        //print(keyboardHeight)
        var newFrame:CGRect = CGRect(origin: CGPoint(x:0, y:0), size: self.view.frame.size)
        if up {
            newFrame = newFrame.offsetBy(dx: 0, dy: movementDistance)
            movementDuration = 0.3
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = newFrame
        UIView.commitAnimations()
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.animateTextField(textField: chatTextField, up:true)
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionKeys.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comments = sortedChat.object(forKey: sectionKeys[section]) as? [NSDictionary]{
            return comments.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 25
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        let label = UILabel(frame: CGRect(x: 20, y:1, width: tableView.frame.size.width, height: 23))
        label.textColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1.0)
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        
        var sectionTitle = sectionKeys[section]
        if let comments = sortedChat.object(forKey: sectionKeys[section]) as? [NSDictionary]{
            let lastDate = comments[0].object(forKey: "date") as! String
            let dt = CommonUtils.sharedInstance.isoDateToNSDate(date:lastDate)
            sectionTitle = CommonUtils.sharedInstance.timeAgoSinceDate(date: dt, numericDates: true)
        }
        label.text = sectionTitle
        label.textAlignment = .center
        view.addSubview(label)
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        
        if let comments = sortedChat.object(forKey: sectionKeys[indexPath.section]) as? [NSDictionary]{
            
            let data:NSDictionary = comments[indexPath.row]
            let h = CommonUtils.sharedInstance.heightString(width: cell.messageText.frame.width, font: cell.messageText.font!, string: data.object(forKey: "message") as! String)*1.3 + 30
            return h
        }
        return 100.0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        
        if let comments = sortedChat.object(forKey: sectionKeys[indexPath.section]) as? [NSDictionary]{
            
            let data:NSDictionary = comments[indexPath.row]
            cell.userNameLabel.text = NSLocalizedString("You", comment: "")
            cell.messageText.text = data.object(forKey: "message") as! String
            let user_id = data.object(forKey: "user_id") as! String
            if (user_id == HulaUser.sharedInstance.userId){
                // my message
                cell.userNameLabel.text = HulaUser.sharedInstance.userNick
                cell.userNameLabel.textAlignment = .left
                cell.messageText.textAlignment = .left
                cell.mainHolder.backgroundColor = HulaConstants.appMainColor
                cell.messageText.textColor = UIColor.white
                cell.leftUserImage.isHidden = false
                cell.rightUserImage.isHidden = true
                cell.leftUserImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: user_id))
                cell.mainHolder.frame.origin.x = 121
                //print(user_id)
                //print("+++++ my message")
                //print("+++++ pos: \(cell.mainHolder.frame.origin.x)")
            } else {
                // other's message
                cell.mainHolder.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                cell.userNameLabel.textAlignment = .right
                cell.messageText.textAlignment = .right
                cell.messageText.textColor = UIColor.darkGray
                cell.leftUserImage.isHidden = true
                cell.rightUserImage.isHidden = false
                cell.rightUserImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: user_id))
                
                
                cell.mainHolder.frame.origin.x = 182
                //print("+++++ others message")
                
            }
        }
        return cell
    }
}
