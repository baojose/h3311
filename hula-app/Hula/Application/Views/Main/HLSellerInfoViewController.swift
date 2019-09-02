//
//  HLSellerInfoViewController.swift
//  Hula
//
//  Created by Star on 3/17/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSellerInfoViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var lblOtherItemInStock: UILabel!
    @IBOutlet var sellerProductTableView: UITableView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerLocationLabel: UILabel!
    
    @IBOutlet weak var sellerFeedbackLabel: UILabel!
    
    @IBOutlet weak var tradeWithUserButton: UIButton!
    
    @IBOutlet weak var fbIcon: UIImageView!
    @IBOutlet weak var liIcon: UIImageView!
    @IBOutlet weak var twIcon: UIImageView!
    @IBOutlet weak var emIcon: UIImageView!
    
    @IBOutlet weak var addToTradeViewContainer: UIImageView!
    
    @IBOutlet weak var tradesStartedLabel: UILabel!
    @IBOutlet weak var tradesEndedLabel: UILabel!
    @IBOutlet weak var tradesClosedLabel: UILabel!
    
    @IBOutlet weak var sellerBioTextView: UITextView!
    @IBOutlet weak var declineTradeBtn: UIButton!
    @IBOutlet weak var acceptTradeBtn: UIButton!
    
    @IBOutlet weak var tradeButtonsHolder: UIView!
    var user = HulaUser();
    var userProducts: NSArray = []
    var userFeedback: NSArray = []
    var initialTradeFrame: CGRect!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
        self.initialTradeFrame = self.addToTradeViewContainer.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        var tabbarHeight : CGFloat = 50
        if Device.IS_IPHONE_X {
            tabbarHeight = 84
        }
        tradeButtonsHolder.frame.origin.y = self.view.frame.height - tradeButtonsHolder.frame.height - tabbarHeight
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
        UIView.animate(withDuration: 0.3) {
            self.addToTradeViewContainer.frame = CGRect(x: 0, y: self.view.frame.height - 120, width: self.view.frame.width, height: 60)
        }
 */
        HLDataManager.sharedInstance.ga("other_user_profile")
    }
    func initData(){
        
        let thumb = CommonUtils.sharedInstance.getThumbFor(url: user.userPhotoURL)
        profileImage.loadImageFromURL(urlString: thumb)
        sellerNameLabel.text = user.userNick
        self.declineTradeBtn.isHidden = true
        self.acceptTradeBtn.isHidden = true
        if HLDataManager.sharedInstance.amITradingWith(user.userId){
            self.tradeWithUserButton.setTitle(NSLocalizedString("Currently trading with", comment: "") + " \(user.userNick!)", for: .normal)
        } else {
            if HLDataManager.sharedInstance.amIOfferedToTradeWith(user.userId){
                // first offer
                self.tradeWithUserButton.isHidden = true
                self.declineTradeBtn.isHidden = false
                self.acceptTradeBtn.isHidden = false
                
                self.declineTradeBtn.layer.cornerRadius = 19
                self.declineTradeBtn.layer.borderColor = UIColor.white.cgColor
                self.declineTradeBtn.layer.borderWidth = 1.0
                
                self.acceptTradeBtn.layer.cornerRadius = 19
                self.acceptTradeBtn.layer.borderColor = UIColor.white.cgColor
                self.acceptTradeBtn.layer.borderWidth = 1.0
            } else {
                self.tradeWithUserButton.setTitle(NSLocalizedString("Trade with", comment: "") + " \(user.userNick!)", for: .normal)
            }
        }
        sellerLocationLabel.text = user.userLocationName
        tradeWithUserButton.layer.cornerRadius = 19
        tradeWithUserButton.layer.borderColor = UIColor.white.cgColor
        tradeWithUserButton.layer.borderWidth = 1.0
        
        if (user.twToken.count>1){
            twIcon.image = UIImage(named: "icon_twitter_on")
        }
        if (user.fbToken.count>1){
            fbIcon.image = UIImage(named: "icon_facebook_on")
        }
        if (user.liToken.count>1){
            liIcon.image = UIImage(named: "icon_linkedin_on")
        }
        if (user.status == "verified"){
            emIcon.image = UIImage(named: "icon_mail_on")
        }
        if (user.userBio.count>1){
            sellerBioTextView.text = user.userBio
        } else {
            sellerBioTextView.text = "..."
        }
        sellerFeedbackLabel.text = user.getFeedback()
        
        tradesStartedLabel.text = "\(Int(user.trades_started))"
        tradesClosedLabel.text = "\(Int(user.trades_closed))"
        tradesEndedLabel.text = "\(Int(user.trades_finished))"
        
        if user.userId == HulaUser.sharedInstance.userId {
            self.tradeButtonsHolder.isHidden = true
        }
    }
    func initView(){
        commonUtils.circleImageView(profileImage)
        
        lblOtherItemInStock.attributedText = commonUtils.attributedStringWithTextSpacing(NSLocalizedString("OTHER ITEMS IN STOCK", comment: ""), 2.33)
        
        var newFrame: CGRect! = sellerProductTableView.frame
        newFrame.size.height = CGFloat(userProducts.count) * 129 + 200;
        sellerProductTableView.frame = newFrame
        let totalHeight = sellerProductTableView.frame.origin.y + sellerProductTableView.frame.size.height
        mainScrollView.contentSize = CGSize(width: 0, height: totalHeight)
        
        containerView.frame.size.height = totalHeight
        
    }
    
    @IBAction func gotoFeedbackAction(_ sender: Any) {
        print(self.userFeedback)
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "userFeedback") as! HLFeedbackHistoryViewController
        viewController.feedbackList = self.userFeedback
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sellerProductCell") as! HLProductTableViewCell
        if let pr = userProducts[indexPath.row] as? [String:Any] as NSDictionary?{
            
            cell.productName.text = pr.object(forKey: "title") as? String
            
            if let im_ur = pr.object(forKey: "image_url") as? String {
                cell.productImage.loadImageFromURL(urlString:im_ur)
            } else {
                cell.productImage.loadImageFromURL(urlString: HulaConstants.noProductThumb)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "productDetailPage") as! HLProductDetailViewController
        
        if let product = userProducts[indexPath.row] as? [String:Any] as NSDictionary?{
            let hproduct = HulaProduct();
            hproduct.populate(with: product)
            viewController.productData = hproduct
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func addToTradeAction(_ sender: Any) {
        
        if HLDataManager.sharedInstance.amITradingWith(user.userId){
            // go directly to the trading room
            
            if let pnc = self.navigationController?.navigationController as? HulaPortraitNavigationController {
                pnc.openSwapView()
            }
        } else {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
            viewController.delegate = self
            if (HulaUser.sharedInstance.numProducts == 0){
                viewController.isCancelVisible = true
                viewController.cancelButtonText = NSLocalizedString("Add stuff", comment: "")
                viewController.trigger = "noproduct"
                viewController.message = NSLocalizedString("Sorry! If you want to trade, you have to upload your stuff.", comment: "")
            } else {
                if HLDataManager.sharedInstance.myRoomsFull() {
                    viewController.isCancelVisible = false
                    viewController.trigger = "fullrooms"
                    viewController.message = NSLocalizedString("Sorry! your Trade Rooms are busy. Turn your phone, get in the Trade Room and request a new one.", comment: "")
                } else {
                    viewController.isCancelVisible = true
                    viewController.okButtonText = NSLocalizedString("Accept", comment: "")
                    viewController.trigger = ""
                    viewController.message = NSLocalizedString("You're about to start a trade. One room will be reserved for this negotiation until it's finished.", comment: "")
                }
            }
            self.present(viewController, animated: true)
        }
    }
    
    @IBAction func declineTradeAction(_ sender: Any) {
        let tradeId = HLDataManager.sharedInstance.getTradeWith(user.userId)
        if tradeId != "" {
            // close trade
            let queryURL = HulaConstants.apiURL + "trades/\(tradeId)"
            let status = HulaConstants.cancel_status
            let dataString:String = "status=\(status)"
            //print(dataString)
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
                if (ok){
                    //print(json!)
                    DispatchQueue.main.async {
                        self.tradeButtonsHolder.isHidden = true
                    }
                    HLDataManager.sharedInstance.getTrades(taskCallback: { (success) in
                        // update trade counts
                        print("Trades loaded from sellerinfo")
                    })
                } else {
                    // connection error
                    print("Connection error")
                }
            })
        }
    }
    @IBAction func acceptTradeAction(_ sender: Any) {
        let tradeId = HLDataManager.sharedInstance.getTradeWith(user.userId)
        if tradeId != "" {
            // close trade
            let queryURL = HulaConstants.apiURL + "trades/\(tradeId)/agree"
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                if (ok){
                    print(json!)
                    if (json as? [String: Any]) != nil {
                        if let pnc = self.navigationController?.navigationController as? HulaPortraitNavigationController {
                            pnc.openSwapView()
                        }
                    }
                    //NotificationCenter.default.post(name: self.signupRecieved, object: signupSuccess)
                }
            })
        }
        
    }
    @IBAction func userOptionsAction(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("User options", comment: ""),
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        
        
        let removeAction = UIAlertAction(title: NSLocalizedString("Trade with this user", comment: ""), style: .default, handler: { action -> Void in
            self.addToTradeAction( UIButton() )
        })
        alert.addAction(removeAction)
        
        let reportAction = UIAlertAction(title: NSLocalizedString("Report this user to the admins", comment: ""), style: .destructive, handler: { action -> Void in
            self.reportUser()
        })
        alert.addAction(reportAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    func reportUser(){
        let queryURL = HulaConstants.apiURL + "users/report/\(user.userId!)"
        print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                //print(json!)
                DispatchQueue.main.async {
                    
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                    
                    viewController.delegate = self
                    viewController.isCancelVisible = false
                    viewController.trigger = "report"
                    viewController.message = NSLocalizedString("Sorry to hear that. We'll take care of your complaint and we will get back to you within less than 24 hours. Feel free to email us to hello@hula.trading, we will be happy to help you and learn from our own mistakes. For you to have a good experience with HULA is our priority.", comment: "")
                    
                    self.present(viewController, animated: true)
                    
                    
                }
            } else {
                // connection error
                print("Connection error")
            }
        })
    }
}

extension HLSellerInfoViewController: AlertDelegate{
    func alertResponded(response: String, trigger: String) {
        if trigger == "noproduct" && response == "ok" {
            self.tabBarController?.selectedIndex = 2
            return
        }
        if trigger == "fullrooms" {
            return
        }
        if trigger == "report" {
            return
        }
        if response == "ok" {
            let otherId = user.userId
            if(HulaUser.sharedInstance.userId != otherId){
                if (HulaUser.sharedInstance.userId.count>0){
                    // user is loggedin
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.addToTradeViewContainer.frame = self.view.frame
                        })
                    }
                    
                    let queryURL = HulaConstants.apiURL + "trades/"
                    let dataString:String = "product_id=&other_id=\(otherId!)"
                    HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: false, taskCallback: { (ok, json) in
                        if (ok){
                            // show barter screen
                            DispatchQueue.main.async {
                                if let pnc = self.navigationController?.navigationController as? HulaPortraitNavigationController {
                                    pnc.openSwapView()
                                }
                            }
                        } else {
                            // connection error
                            print("Connection error")
                        }
                    })
                }
            }
        }
        if trigger == "noproduct" && response == "cancel" {
            self.tabBarController?.selectedIndex = 2
        }
    }
}
