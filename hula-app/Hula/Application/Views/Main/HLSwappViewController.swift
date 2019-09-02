//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 14/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import SpriteKit
import FacebookShare
import CoreMotion

class HLSwappViewController: UIViewController {
    
    weak var barterDelegate: HLBarterScreenDelegate?
    
    @IBOutlet weak var tradeModeLabel: UILabel!
    @IBOutlet weak var dashMask: UIView!
    @IBOutlet weak var dashImage: UIImageView!
    @IBOutlet weak var mobileImage: UIView!
    
    @IBOutlet weak var portraitView: UIView!
    @IBOutlet weak var mainContainer: UIView!
    //@IBOutlet weak var swappPageControl: HLPageControl!
    //@IBOutlet weak var nextTradeBtn: UIButton!
    //@IBOutlet weak var extraRoomBtn: UIButton!
    //@IBOutlet weak var extraRoomImage: UIImageView!
    @IBOutlet weak var mainCentralLabel: UILabel!
    @IBOutlet weak var otherUserNick: UILabel!
    @IBOutlet weak var otherUserImage: UIImageView!
    @IBOutlet weak var otherUserView: UIView!
    @IBOutlet weak var myUserView: UIView!
    @IBOutlet weak var bottomBarView: UIImageView!
    @IBOutlet weak var sendOfferBtn: HLRoundedButton!
    @IBOutlet weak var otherOfferBtn: HLRoundedButton!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    @IBOutlet weak var chatCountLbl: UILabel!
    @IBOutlet weak var tradeModeLine: UIView!
    @IBOutlet weak var currentTradesBtn: UIButton!
    @IBOutlet weak var pastTradesBtn: UIButton!
    @IBOutlet weak var threeDotsView: UIView!
    @IBOutlet weak var addTradeRoomBtn: HLRoundedButton!
    @IBOutlet weak var chatButton: HLRoundedButton!
    @IBOutlet weak var myCheckMark: UIImageView!
    @IBOutlet weak var otherCheckMark: UIImageView!
    
    @IBOutlet weak var pastChatCountLbl: UILabel!
    var initialOtherUserX:CGFloat = 0.0
    
    var motionManager = CMMotionManager();
    
    var selectedScreen = 0
    var initialFrame:CGRect = CGRect(x:0, y:0, width: 191, height: 108)
    var prevUser: String = ""
    var tradeMode = "current"
    var last_index_setup:Int = 0
    var trade_id_closed : String = ""
    var user_id_closed : String = ""
    var redirect: String = ""
    var backFromChat: Bool = false
    var tempTag: Int = 0
    var detection_counter : Int = 0;
    
    let kTagJustAccept: Int = 1;
    let kTagCloseDeal: Int = 91053;
    let kTagProductsReceived: Int = 90441
    
    var firstLoad : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        CommonUtils.sharedInstance.circleImageView(otherUserImage)
        self.sendOfferBtn.alpha = 0;
        self.otherOfferBtn.alpha = 0;
        self.myCheckMark.alpha = 0;
        self.otherCheckMark.alpha = 0;
        self.remainingTimeLabel.alpha = 0;
        self.addTradeRoomBtn.alpha = 1;
        self.mainCentralLabel.alpha = 0;
        
        self.chatCountLbl.layer.cornerRadius = 6.5
        self.pastChatCountLbl.layer.cornerRadius = 6.5
        
        self.chatCountLbl.clipsToBounds = true
        self.pastChatCountLbl.clipsToBounds = true
        
        
        self.currentTradesBtn.alpha = 1;
        self.pastTradesBtn.alpha = 1
        self.tradeModeLine.frame.origin.x = self.currentTradesBtn.frame.origin.x
        self.tradeModeLine.frame.size.width = self.currentTradesBtn.frame.size.width
        HLDataManager.sharedInstance.tradeMode = "current"
        
        
        self.dashImage.alpha = 0
        self.dashMask.alpha = 0
        self.mobileImage.alpha = 0
        self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2));
        self.tradeModeLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        
        let threeDots = HLThreeDotsWaiting(size: CGSize(width:40, height:10))
        let skView = SKView(frame: CGRect(x: threeDotsView.frame.width/2 - 20, y: 0, width: 40, height: 10))
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        skView.presentScene(threeDots)
        threeDotsView.addSubview(skView)
        threeDots.animateDots()
        threeDotsView.isHidden = true
        controlSetupBottomBar(index:0);
        
        firstLoad = true
        
        motionManager.accelerometerUpdateInterval = 0.6;
        
        
        if #available(iOS 11.0, *) {
            print("####  setNeedsUpdateOfScreenEdgesDeferringSystemGestures");
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        //print("prefersHomeIndicatorAutoHidden in Swapp")
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        //print(UIDevice.current.orientation)
        
        if (firstLoad) {
            firstLoad = false
            var isNeutral = true
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
                //print("portrait!!!!")
                isNeutral = false
            }
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                //print("landscape!!!!")
                isNeutral = false
            }
            if isNeutral && self.view.frame.width > self.view.frame.height {
                isNeutral = false
                self.portraitView.frame.origin.y = 1000
                self.portraitView.transform = CGAffineTransform(rotationAngle: 0.8)
            }
            
            
            // rotation effect
            //self.portraitView.frame.origin.y = 0
            self.portraitView.frame = self.view.frame
            self.portraitView.transform = CGAffineTransform(rotationAngle: 0)
            if !UIDeviceOrientationIsPortrait(UIDevice.current.orientation) && !isNeutral {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.6) {
                        self.portraitView.frame.origin.y = 1000
                        self.portraitView.transform = CGAffineTransform(rotationAngle: 0.8)
                    }
                }
            }
        
        }
        HLDataManager.sharedInstance.onlyLandscapeView = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        threeDotsView.frame.origin.x = otherOfferBtn.frame.origin.x + otherOfferBtn.frame.width/2 - 20;
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!){ (data, error) in
            if let xc = data?.acceleration.x {
                if abs( xc ) > 0.8 {
                    // portrait mode
                    self.detection_counter += 1
                    if self.detection_counter > 5{
                        self.detection_counter = 0;
                        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation)  {
                            let alert = UIAlertController(title: NSLocalizedString("Rotation lock is activated", comment: ""), message: NSLocalizedString("Please unlock your iPhone rotation lock. You can do it from the control center.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            
        }
        
        
        if !self.backFromChat {
            controlSetupBottomBar(index:last_index_setup);
        }
        self.backFromChat = false
        self.rotateAnimation()
        
        
        if #available(iOS 11.0, *) {
            setNeedsUpdateOfHomeIndicatorAutoHidden()
        } else {
            // Fallback on earlier versions
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        motionManager.stopAccelerometerUpdates()
        let app = UIApplication.shared.delegate as! AppDelegate
        app.allowRotation = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let swappPageViewController = segue.destination as? HLSwappPageViewController {
            swappPageViewController.swappDelegate = self
        }
        
        
        if let chatVC = segue.destination as? ChatViewController {
            if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
                let thisTrade: NSDictionary = swappPageVC.arrTrades[swappPageVC.currentIndex]
                if let chat = thisTrade.object(forKey: "chat") as? [NSDictionary]{
                    chatVC.chat = chat
                    chatVC.trade_id = (thisTrade.object(forKey: "_id") as? String)!
                    //print(chat)
                    self.backFromChat = true
                    self.chatCountLbl.isHidden = true
                }
            }
        }
    }
    
    
    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        print("*preferredScreenEdges")
        return .all
    }
    
    @IBAction func closeSwappMode(_ sender: Any) {
        HLDataManager.sharedInstance.isInSwapVC = false
        self.dismiss(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func rotateAnimation(){
        var hasToDismiss = true
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            //print("portrait!!!!")
            hasToDismiss = false
        }
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            //print("landscape!!!!")
            hasToDismiss = false
        }
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) || hasToDismiss{
            mobileImage.alpha = 0
            self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2));
            
            self.dashImage.alpha = 0
            self.dashMask.alpha = 0
            self.dashMask.transform = .identity
            self.dashMask.frame = self.initialFrame
            
            UIView.animate(withDuration: 0.5, animations: {
                self.mobileImage.alpha = 1
            }, completion: { (success) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                    self.dashMask.alpha = 1
                    self.dashImage.alpha = 1
                }, completion: { (success) in
                    
                    UIView.animate(withDuration: 2.0, animations: {
                        self.mobileImage.alpha = 0
                    }, completion: { (success) in
                        self.mobileImage.transform = .identity
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            
                            self.rotateAnimation()
                        }
                    })
                })
                
                UIView.animate( withDuration: 0.7, delay:0.4, animations: {
                    self.dashMask.frame.origin.x = 0
                    self.dashMask.frame.origin.y = -200
                    self.dashMask.transform = CGAffineTransform(rotationAngle: 0.8)
                })
            })
        }
    }
    
    func rotated() {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation)  {
            self.portraitView.transform = CGAffineTransform(rotationAngle: 0)
            self.portraitView.frame.origin.y = 0
            self.portraitView.frame.size.height = self.view.frame.height
            portraitView.isHidden = false
            rotateAnimation()
            //print("pre dismiss")
            HLDataManager.sharedInstance.isInSwapVC = false
            if !HLDataManager.sharedInstance.onlyLandscapeView {
                //print(self.presentingViewController)
                self.presentingViewController?.dismiss(animated: true) {
                    //print("post dismiss")
                    // After dismiss
                }
            }
        } else {
            DispatchQueue.main.async {
                //portraitView.isHidden = true
                UIView.animate(withDuration: 0.6) {
                    self.portraitView.frame.origin.y = 1000
                    self.portraitView.transform = CGAffineTransform(rotationAngle: 0.8)
                }
            }
        }
    }
    
    @IBAction func extraRoomAction(_ sender: Any) {
    }
    
    /*
    @IBAction func nextTradeAction(_ sender: Any) {
        //print(self.childViewControllers)
        
        if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
            let nextPage = swappPageControl.currentPage + 1
            //print(nextPage)
            //print(swappPageVC.arrTrades.count)
            let thisTrade: NSDictionary = swappPageVC.arrTrades[nextPage - 1]
            swappPageVC.currentTrade = thisTrade
            swappPageVC.goTo(page: nextPage)
            
        }
        
    }
    */
    @IBAction func backToLobbyAction(_ sender: Any) {
        if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
            swappPageVC.goTo(page: 0)
        }
    }
    @IBAction func sendOfferAction(_ sender: Any) {
        if let tradeStatus = barterDelegate?.getCurrentTradeStatus() {
            
            self.tempTag = (sender as? UIButton)!.tag
            
            if (tradeStatus.owner_products.count == 0 || tradeStatus.other_products.count == 0)   {
                manageDonationMessages(tradeStatus: tradeStatus, okStatus:"donation")
                return
            }
            
            if self.tempTag == kTagCloseDeal {
                manageConfirmation(tradeStatus: tradeStatus, okStatus:"doit")
                return
            }
            
            executeOfferOptions(tradeStatus, buttonTag: self.tempTag)
            
        } else {
            print("No trade/barter delegate vc found!")
        }
    }
    
    func manageDonationMessages(tradeStatus:HulaTrade, okStatus:String){
        
        if (tradeStatus.owner_products.count == 0) && (tradeStatus.other_products.count == 0){
            showAlert(message:NSLocalizedString("Sorry, drag at least one item to send your offer.", comment: ""), trigger:"notrade", cancelVisible:false, okText:"Ok")
            return
        }
        if tradeStatus.owner_id == HulaUser.sharedInstance.userId {
            
            // i am the owner
            if tradeStatus.owner_products.count == 0 && tradeStatus.owner_money == 0 {
                showAlert(message:NSLocalizedString("No offer without an item from your side. Unless you wanna offer cash...", comment: ""), trigger:"notrade", cancelVisible:false, okText:NSLocalizedString("OK", comment: ""))
            } else {
                if tradeStatus.other_products.count == 0 && tradeStatus.other_money == 0 {
                    showAlert(message:NSLocalizedString("Are you giving your stuff away for free? If not, choose the item you want to exchange it with.", comment: ""), trigger:okStatus, cancelVisible:true, okText:NSLocalizedString("OK!", comment: ""))
                } else {
                    executeOfferOptions(tradeStatus, buttonTag: self.tempTag)
                }
            }
        } else {
            // i am the other
            if tradeStatus.other_products.count == 0 && tradeStatus.other_money == 0 {
                showAlert(message:NSLocalizedString("No offer without an item from your side. Unless you wanna offer cash...", comment: ""), trigger:"notrade", cancelVisible:false, okText: NSLocalizedString("OK", comment: ""))
            } else {
                if tradeStatus.owner_products.count == 0 && tradeStatus.owner_money == 0 {
                    showAlert(message:NSLocalizedString("Are you giving your stuff away for free? If not, choose something you want to exchange it with.", comment: ""), trigger:okStatus, cancelVisible:true, okText:NSLocalizedString("OK!", comment: ""))
                } else {
                    executeOfferOptions(tradeStatus, buttonTag: self.tempTag)
                }
            }
        }
    }
    
    func manageConfirmation(tradeStatus:HulaTrade, okStatus:String){
        showAlert(message:NSLocalizedString("You are about to close the deal. Confirm?", comment: ""), trigger:okStatus, cancelVisible:true, okText: NSLocalizedString("Yes!", comment: ""))
    }
    
    func showAlert(message:String, trigger:String, cancelVisible:Bool,  okText:String){
    
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
        
        viewController.delegate = self as AlertDelegate
        viewController.isCancelVisible = cancelVisible
        viewController.okButtonText = okText
        viewController.message = message
        viewController.trigger = trigger
        self.present(viewController, animated: true)
    }
    
    func executeOfferOptions(_ tradeStatus: HulaTrade, buttonTag: Int){
        
        //print("tradeStatus: \(tradeStatus)")
        let trade_id = tradeStatus.tradeId
        let turn_id = tradeStatus.turn_user_id
        self.trade_id_closed = trade_id!
        if (tradeStatus.owner_id != HulaUser.sharedInstance.userId){
            self.user_id_closed = tradeStatus.owner_id
        } else {
            self.user_id_closed = tradeStatus.other_id
        }
        
        //print(tradeStatus.owner_products)
        if (turn_id != HulaUser.sharedInstance.userId) && buttonTag != kTagProductsReceived && false{
            // always my turn
            print("This is not your turn!!!")
        } else {
            
            let queryURL = HulaConstants.apiURL + "trades/\(trade_id!)/ready";
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                if (ok){
                    
                    let queryURL2 = HulaConstants.apiURL + "trades/\(trade_id!)";
                    let owner_products = tradeStatus.owner_products.joined(separator: ",")
                    let other_products = tradeStatus.other_products.joined(separator: ",")
                    let owner_money:Int = Int(tradeStatus.owner_money)
                    let other_money:Int = Int(tradeStatus.other_money)
                    var status = HulaConstants.sent_status
                    var acceptedTrade: String = "false"
                    if buttonTag == self.kTagCloseDeal || buttonTag == self.kTagProductsReceived {
                        // offer sent or product received
                        status = HulaConstants.review_status
                    }
                    if buttonTag == self.kTagProductsReceived {
                        acceptedTrade = "true"
                    }
                    let dataString:String = "status=\(status)&owner_products=\(owner_products)&other_products=\(other_products)&owner_money=\(owner_money)&other_money=\(other_money)&accepted=\(acceptedTrade)"
                    //print(dataString)
                    
                    
                    self.sendDataToServer(queryURL: queryURL2, dataString: dataString, buttonTag:buttonTag);
                }
            }
            );
            
            
            /*
            */
        }
    }
    
    func sendDataToServer(queryURL:String, dataString:String, buttonTag:Int){
        HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                    
                    viewController.delegate = self as AlertDelegate
                    viewController.isCancelVisible = false
                    
                    if buttonTag == self.kTagCloseDeal {
                        viewController.message = NSLocalizedString("You accepted the deal. Now meet the trader and exchange your stuff.", comment: "")
                        viewController.trigger = "deal_review"
                    } else {
                        if buttonTag == self.kTagProductsReceived {
                            viewController.message = NSLocalizedString("Great! Enjoy your stuff and many thanks for using HULA.\nIn order to free up this trading room, this trade will be moved to your past trades tab.", comment: "")
                            viewController.trigger = "deal_closed"
                        } else {
                            viewController.message = NSLocalizedString("Your offer has been sent with your changes.", comment: "")
                        }
                    }
                    self.present(viewController, animated: true)
                }
            } else {
                // connection error
                print("Connection error")
            }
        })
    }
    @IBAction func showUserAction(_ sender: Any) {
        //print (prevUser)
        HLDataManager.sharedInstance.getUserProfile(userId: prevUser, taskCallback: {(user, prods, feedback) in
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "sellerHorizontal") as! HLSellerHorizontalViewController
            
            viewController.user = user
            self.present(viewController, animated: true)
            self.backFromChat = true
        })
    }
    func manageCheckMarks(trade:HulaTrade?){
        
        if trade != nil {
            self.otherCheckMark.alpha = 0;
            self.myCheckMark.alpha = 0;
            self.threeDotsView.isHidden = false;
            self.sendOfferBtn.tag = kTagJustAccept
            self.sendOfferBtn.setTitle(NSLocalizedString("Accept", comment: ""), for: .normal);
            
            if ( (trade!.owner_ready && trade!.owner_id == HulaUser.sharedInstance.userId) || (trade!.other_ready && trade!.other_id == HulaUser.sharedInstance.userId) ) {
                // I am ready
                self.myCheckMark.alpha = 1;
                self.sendOfferBtn.setTitle("", for: .normal);
            }
            if ( (trade!.other_ready && trade!.owner_id == HulaUser.sharedInstance.userId) || (trade!.owner_ready && trade!.other_id == HulaUser.sharedInstance.userId) ){
                self.sendOfferBtn.tag = kTagCloseDeal
                self.otherCheckMark.alpha = 1;
                self.otherOfferBtn.setTitle("", for: .normal)
                self.threeDotsView.isHidden = true;
            }
        } else {
            self.otherCheckMark.alpha = 0;
            self.myCheckMark.alpha = 0;
        }
    }
    
    func controlSetupBottomBar(index:Int){
        //print("setting up bottom bar with index: \(index)")
        
        initialOtherUserX = self.view.frame.width - self.otherUserView.frame.width
        
        if (index != 0){
            // hide/show elements on the bottom bar
            UIView.animate(withDuration: 0.3) {
                self.mainCentralLabel.alpha=0;
                self.myUserView.frame.origin.x = 0
                self.otherUserView.frame.origin.x = self.view.frame.width - self.otherUserView.frame.width
                self.sendOfferBtn.alpha = 1
                self.otherOfferBtn.alpha = 1
                self.addTradeRoomBtn.alpha = 0;
                self.mainCentralLabel.alpha = 0;
                self.currentTradesBtn.alpha = 0;
                self.pastTradesBtn.alpha = 0
                self.tradeModeLine.alpha = 0
                self.pastChatCountLbl.isHidden = true
            }
            self.threeDotsView.isHidden = true;
            
            if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
                if swappPageVC.arrTrades.count > 0 {
                    last_index_setup = swappPageVC.currentIndex
                    let thisTrade: NSDictionary = swappPageVC.arrTrades[swappPageVC.currentIndex]
                    var other_user_id = ""
                    var chat_count = 0
                    
                    // check chat counter
                    if (HulaUser.sharedInstance.userId == thisTrade.object(forKey: "owner_id") as! String){
                        // I am the owner
                        other_user_id = thisTrade.object(forKey: "other_id") as! String
                        if let ch_c = thisTrade.object(forKey: "owner_unread") as? Int{
                            chat_count = ch_c
                        }
                    } else {
                        other_user_id = thisTrade.object(forKey: "owner_id") as! String
                        if let ch_c = thisTrade.object(forKey: "other_unread") as? Int{
                            chat_count = ch_c
                        }
                    }
                    
                    
                    let currentStatus = thisTrade.object(forKey: "status") as! String
                    if currentStatus == HulaConstants.cancel_status || currentStatus == HulaConstants.end_status {
                        // closed or removed trade!
                        
                        self.sendOfferBtn.alpha = 0
                        self.otherOfferBtn.alpha = 0
                        self.mainCentralLabel.alpha = 0
                        self.remainingTimeLabel.alpha = 0
                        self.threeDotsView.isHidden = true
                        
                    } else {
                        if currentStatus == HulaConstants.review_status {
                            // pending exchange
                            
                            self.mainCentralLabel.alpha = 0
                            self.remainingTimeLabel.alpha = 0
                            self.threeDotsView.isHidden = true
                            
                            self.sendOfferBtn.setTitle( NSLocalizedString("I received my stuff", comment: ""), for: .normal)
                            self.sendOfferBtn.tag = kTagProductsReceived
                            
                            self.otherOfferBtn.alpha = 0;
                        } else {
                            // still bartering
                            
                            if let current_user_turn = thisTrade.object(forKey: "turn_user_id") as? String {
                                
                                if current_user_turn != HulaUser.sharedInstance.userId && false {
                                    // added "false" in order to avoid this case
                                    
                                    // other user turn
                                    
                                    self.sendOfferBtn.alpha = 0
                                    self.otherOfferBtn.alpha = 0
                                    self.mainCentralLabel.alpha=1;
                                    self.mainCentralLabel.text = NSLocalizedString("Waiting for user reply", comment: "")
                                    let h_str = thisTrade.object(forKey: "last_update") as! String
                                    let date = h_str.dateFromISO8601?.addingTimeInterval(HulaConstants.courtesyTime * 60.0 * 60.0)
                                    //print(date)
                                    
                                    let formatter = DateComponentsFormatter()
                                    formatter.allowedUnits = [.hour]
                                    formatter.unitsStyle = .short
                                    var str_hours = formatter.string(from: Date(), to: date!)!
                                    str_hours = (str_hours.replacingOccurrences(of: " hr", with: " h"))
                                    if (str_hours[0] == "-"){
                                        str_hours = "0";
                                    }
                                    
                                    self.remainingTimeLabel.alpha = 1
                                    self.remainingTimeLabel.text = NSLocalizedString("Remaining time for response:", comment: "") + " \(str_hours)"
                                    self.threeDotsView.isHidden = false;
                                    
                                } else {
                                    self.threeDotsView.isHidden = false;
                                    // my turn!
                                    self.remainingTimeLabel.alpha = 0;
                                    
                                    self.sendOfferBtn.setTitle( NSLocalizedString("Accept", comment: ""), for: .normal)
                                    //self.sendOfferBtn.tag = kTagJustAccept
                                    /*
                                    if self.tradeCanBeClosed(thisTrade) {
                                        // can be closed
                                        self.sendOfferBtn.setTitle( NSLocalizedString("Accept trade", comment: ""), for: .normal)
                                        self.sendOfferBtn.tag = kTagCloseDeal
                                        
                                    } else {
                                        // send counter offer
                                        self.sendOfferBtn.setTitle( NSLocalizedString("Accept trade", comment: ""), for: .normal)
                                        self.sendOfferBtn.tag = kTagJustAccept
                                    }
                                    */
                                }
                            }
                        }
                    }
                    
                    
                    
                    if let tr = self.barterDelegate?.getCurrentTradeStatus() {
                        //print("updating checkmarks...");
                        print("owner ready \(tr.owner_ready)");
                        print("other ready \(tr.other_ready)");
                        self.manageCheckMarks(trade: tr);
                        
                        if tr.other_agree {
                            self.otherUserView.alpha = 1
                            
                            if currentStatus != HulaConstants.cancel_status && currentStatus != HulaConstants.end_status {
                                // closed deals should not show the other's button
                                self.otherOfferBtn.alpha = 1
                            }
                        } else {
                            self.otherUserView.alpha = 0.5
                            self.otherOfferBtn.alpha = 0.5
                        }
                        
                    }
                    
                    if chat_count > 0 {
                        self.chatCountLbl.text = "\(chat_count)"
                        self.chatCountLbl.isHidden = false
                    } else {
                        self.chatCountLbl.isHidden = true
                    }
                    
                    if let bids = thisTrade.object(forKey: "bids") as? [Any] {
                        //print("Bids: \(bids.count)")
                        if (bids.count == 1 && thisTrade.object(forKey: "turn_user_id") as? String == HulaUser.sharedInstance.userId ){
                            // first turn
                            self.chatButton.alpha = 0.3
                        } else {
                            self.chatButton.alpha = 1
                        }
                    }
                    
                    
                    if (prevUser != other_user_id) {
                        prevUser = other_user_id
                        otherUserImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: other_user_id))
                        
                        let queryURL = HulaConstants.apiURL + "users/\(other_user_id)/nick"
                        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (result, json) in
                            
                            if let dict = json as? [String:String]{
                                //print(dict)
                                if let nick = dict["nick"] {
                                    //print(nick)
                                    DispatchQueue.main.async {
                                        if nick.count < 17 {
                                            self.otherUserNick.text = nick
                                        } else {
                                            self.otherUserNick.text = String( nick.prefix(15) ) + "...";
                                        }
                                    }
                                }
                            }
                        })
                    }
                    
                    
                    
                } else {
                    // no trades
                    self.addTradeRoomBtn.alpha = 0
                    self.mainCentralLabel.alpha = 0
                    self.myUserView.frame.origin.x = 0
                    self.otherUserView.frame.origin.x = self.initialOtherUserX + 500
                    self.sendOfferBtn.alpha = 0
                    self.otherOfferBtn.alpha = 0
                    self.chatButton.alpha = 0
                    self.remainingTimeLabel.alpha = 0;
                    self.threeDotsView.isHidden = true
                    self.currentTradesBtn.alpha = 0;
                    self.pastTradesBtn.alpha = 0
                    self.tradeModeLine.alpha = 0
                    self.chatCountLbl.isHidden = true
                    self.pastChatCountLbl.isHidden = true
                    
                    self.manageCheckMarks(trade: nil);
                }
            }
            
            if self.sendOfferBtn.tag == kTagProductsReceived {
                self.otherOfferBtn.alpha = 0;
            }
            
        } else {
            // index == 0
            
            last_index_setup = 0
            UIView.animate(withDuration: 0.3) {
                /*
                self.extraRoomBtn.alpha = 1
                self.extraRoomImage.alpha = 1
                self.nextTradeBtn.alpha = 1
                 */
                if HulaUser.sharedInstance.maxTrades >= 50{
                    self.addTradeRoomBtn.alpha = 0.3
                } else {
                    self.addTradeRoomBtn.alpha = 1;
                }
                self.mainCentralLabel.alpha=0;
                self.myUserView.frame.origin.x = -500
                self.otherUserView.frame.origin.x = self.initialOtherUserX + 500
                self.sendOfferBtn.alpha = 0
                self.otherOfferBtn.alpha = 0
                //self.mainCentralLabel.text = "Available Table Rooms"
                self.chatButton.alpha = 0
                self.remainingTimeLabel.alpha = 0;
                self.threeDotsView.isHidden = true
                self.currentTradesBtn.alpha = 1;
                self.pastTradesBtn.alpha = 1
                self.tradeModeLine.alpha = 1
                self.pastChatCountLbl.isHidden = true
            }
            self.chatCountLbl.isHidden = true
            
            var chat_count = 0
            var other_user_id = ""
            for oldTrade in HLDataManager.sharedInstance.arrPastTrades {
                let thisTrade: NSDictionary = oldTrade
                
                // check chat counter
                if (HulaUser.sharedInstance.userId == thisTrade.object(forKey: "owner_id") as! String){
                    // I am the owner
                    other_user_id = thisTrade.object(forKey: "other_id") as! String
                    if let ch_c = thisTrade.object(forKey: "owner_unread") as? Int{
                        chat_count = ch_c
                    }
                } else {
                    other_user_id = thisTrade.object(forKey: "owner_id") as! String
                    if let ch_c = thisTrade.object(forKey: "other_unread") as? Int{
                        chat_count = ch_c
                    }
                }
            }
            if chat_count > 0 {
                self.pastChatCountLbl.isHidden = false
                self.pastChatCountLbl.text = "\(chat_count)"
                print("chat_count")
                print(chat_count)
                print("other_user_id")
                print(other_user_id)
            } else {
                
                self.pastChatCountLbl.isHidden = true
            }
            
            self.manageCheckMarks(trade: nil);
        }
        
    }
    
    func tradeCanBeClosed(_ trade:NSDictionary) -> Bool{
        if let bids = trade.object(forKey: "bids") as? NSArray{
            //print(bids.count)
            
            if let isMutated = barterDelegate?.isTradeMutated(){
                
                if (bids.count > 1) && (!isMutated) {
                    return true
                }
            }
        }
        return false
    }
    
    @IBAction func showCurrentTrades(_ sender: Any) {
        
        self.tradeMode = "current"
        UIView.animate(withDuration: 0.3) {
            self.tradeModeLine.frame.origin.x = self.currentTradesBtn.frame.origin.x
            self.tradeModeLine.frame.size.width = self.currentTradesBtn.frame.size.width
        }
        updateTradesList()
    }
    @IBAction func showPastTrades(_ sender: Any) {
        self.tradeMode = "past"
        UIView.animate(withDuration: 0.3) {
            self.tradeModeLine.frame.origin.x = self.pastTradesBtn.frame.origin.x
            self.tradeModeLine.frame.size.width = self.pastTradesBtn.frame.size.width
        }
        updateTradesList()
    }
    
    func updateTradesList(){
        HLDataManager.sharedInstance.tradeMode = self.tradeMode
        for vc in (self.childViewControllers.first?.childViewControllers)! {
            if let db = vc as? HLDashboardViewController{
                db.refreshCollectionViewData()
            }
        }
    }
    @IBAction func addTradeRoomAction(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
        
        viewController.delegate = self as AlertDelegate
        viewController.isCancelVisible = true
        viewController.message = NSLocalizedString("Do you need more rooms? Spread the word! Share HULA with your friends and get up to 5 trade rooms.", comment: "")
        viewController.okButtonText = NSLocalizedString("Share Hula", comment: "")
        viewController.trigger = "share"
        self.present(viewController, animated: true)

        
    }
}

extension HLSwappViewController: SwappPageViewControllerDelegate {
    
    func swappPageViewController(swappPageViewController: HLSwappPageViewController,
                                    didUpdatePageCount count: Int) {
        //swappPageControl.numberOfPages = count
    }
    
    func swappPageViewController(swappPageViewController: HLSwappPageViewController,
                                    didUpdatePageIndex index: Int) {
        //swappPageControl.currentPage = index
        if (index == 0){
            barterDelegate?.reloadTrade()
        }
        controlSetupBottomBar(index: index)
    }
    
    
}

protocol HLBarterScreenDelegate: class {
    func getCurrentTradeStatus() -> HulaTrade
    func isTradeMutated() -> Bool!
    func reloadTrade()
}

extension HLSwappViewController: AlertDelegate{
    func alertResponded(response: String, trigger:String) {
        print("Response: \(response)")
        
        
        DispatchQueue.main.async {
            if trigger == "notrade"{
                return
            }
            
            if trigger == "donation"{
                if response == "ok"{
                    if let tradeStatus = self.barterDelegate?.getCurrentTradeStatus() {
                        self.executeOfferOptions(tradeStatus, buttonTag: self.tempTag)
                    }
                } else {
                    return
                }
            }
            if trigger == "doit"{
                if response == "ok"{
                    if let tradeStatus = self.barterDelegate?.getCurrentTradeStatus() {
                        self.executeOfferOptions(tradeStatus, buttonTag: self.tempTag)
                    }
                } else {
                    return
                }
            }
            if trigger == "share" && response == "ok"{
                self.shareHula()
            }
            if trigger == "deal_closed" && response == "ok"{
                self.feedback()
            }
            if trigger == "feedback_sent"{
                self.feedback_sent(response:response)
            }
            
            if let swappPageVC = self.childViewControllers.first as? HLSwappPageViewController {
                swappPageVC.goTo(page: 0)
            }
            
            
        }
    }
    
    func shareHula(){
        /*
        // Facebook app invite no longer supported
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
                    self.addExtraRoom()
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
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.5) {
            self.addExtraRoom()
        }

        
    }
    
    func addExtraRoom(){
        if (HulaUser.sharedInstance.maxTrades<50){
            HulaUser.sharedInstance.maxTrades += 1
            HulaUser.sharedInstance.updateServerData()
            HLDataManager.sharedInstance.writeUserData()
        }
    }
    
    func feedback(){
        //print("Deal closed. Requesting feedback")
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "finalFeedback") as! HLFinalFeedbackViewController
        
        //viewController.delegate = self as AlertDelegate
        //viewController.isCancelVisible = true
        //viewController.message = "We would love to hear how your trade was. Please rate it from one to five stars:"
        //viewController.okButtonText = "Send"
        //viewController.starsVisible = true
        //viewController.trigger = "feedback_sent"
        viewController.trade_id_closed = self.trade_id_closed
        viewController.user_id_closed = self.user_id_closed
        self.present(viewController, animated: true)
        
    }
    
    func feedback_sent(response:String){
        print("Feedback received. \(response)")
        
        if response != "ok" && response != "cancel"{
            let queryURL = HulaConstants.apiURL + "feedback"
            let comments = NSLocalizedString("Deal closed. Thank you", comment: "")
            let dataString:String = "trade_id=\(self.trade_id_closed)&user_id=\(self.user_id_closed)&comments=\(comments)&val=\(response)"
            //print(dataString)
            HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: false, taskCallback: { (ok, json) in
                if (ok){
                    print(json!)
                    DispatchQueue.main.async {
                        
                        
                    }
                }
            })
        }
    }
}
