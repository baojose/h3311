//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 19/05/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import EasyTipView


class HLDashboardViewController: BaseViewController {
    
    @IBOutlet weak var fakeFirstTradeView: UIView!
    @IBOutlet weak var fakeAddTradeView: UIView!
    @IBOutlet weak var fakeCenterView: UIView!
    @IBOutlet weak var landscapeView: UIView!
    @IBOutlet weak var portraitView: UIView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    var selectedBarter: Int = 0
    let productImagesWidth: CGFloat = 27.0
    let productImagesMargin: CGFloat = 10.0
    //var isExpandedFlowLayoutUsed:Bool = false
    var swappPageVC : HLSwappPageViewController?
    
    
    let sectionInsets = UIEdgeInsets(top: 4, left: 0, bottom: 30, right: 0)
    var lastTradeInteracted:String = ""
    var last_trade_request : Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        let notificationsRecieved = Notification.Name("notificationsRecieved")
        NotificationCenter.default.removeObserver(self, name: notificationsRecieved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationsLoadedCallback), name: notificationsRecieved, object: nil)
        //refreshCollectionViewData()
        mainCollectionView.collectionViewLayout = HLDashboardNormalViewFlowLayout()
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
    }

    override func viewWillAppear(_ animated: Bool) {
        //print(self.view.frame)
        //print(self.mainCollectionView.frame)
        refreshCollectionViewData()
        
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            if let thisHolderScreen = swappPageVC.parent as? HLSwappViewController {
                thisHolderScreen.last_index_setup = 0
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        //self.mainCollectionView.frame = self.view.frame
        self.mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0) , at: .top, animated: true)
        self.mainCollectionView.collectionViewLayout.invalidateLayout()
        
        /*
        self.mainCollectionView.setCollectionViewLayout(HLDashboardNormalViewFlowLayout(), animated: false)
        self.mainCollectionView.collectionViewLayout.invalidateLayout()
        refreshCollectionViewData()
        
        self.mainCollectionView.reloadData()
        */
        
        HLDataManager.sharedInstance.ga("dashboard")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func notificationsLoadedCallback() {
        //print("Refreshing...")
        refreshCollectionViewData()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true) { 
            // After dismiss
        }
        
    }
    
    func rotated(){
        if !UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            mainCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func refreshCollectionViewData(){
        if let vc = self.parent as? HLSwappPageViewController {
            swappPageVC = vc
            if (HLDataManager.sharedInstance.tradeMode == "current"){
                if (HLDataManager.sharedInstance.arrCurrentTrades.count > 0){
                    swappPageVC?.arrTrades = HLDataManager.sharedInstance.arrCurrentTrades as [NSDictionary]
                } else {
                    swappPageVC?.arrTrades = []
                }
            } else {
                if (HLDataManager.sharedInstance.arrPastTrades.count > 0){
                    swappPageVC?.arrTrades = HLDataManager.sharedInstance.arrPastTrades as [NSDictionary]
                } else {
                    swappPageVC?.arrTrades = []
                }
            }
            
            let now = Double(DispatchTime.now().rawValue)
            //print ("Tiempo entre llamadas: \((now - self.last_trade_request)/10000000)")
            self.mainCollectionView.reloadData()
            if ((now - self.last_trade_request)/10000000 > 10) {
                
                HLDataManager.sharedInstance.getTrades { (success) in
                    if (success){
                        self.last_trade_request = Double(DispatchTime.now().rawValue)
                        //print("Trades loaded from dashboard")
                        //print("Trades ok")
                        DispatchQueue.main.async {
                            if (HLDataManager.sharedInstance.tradeMode == "current"){
                                self.swappPageVC?.arrTrades = HLDataManager.sharedInstance.arrCurrentTrades as [NSDictionary]
                            } else {
                                self.swappPageVC?.arrTrades = HLDataManager.sharedInstance.arrPastTrades as [NSDictionary]
                            }
                            self.mainCollectionView.reloadData()
                            self.mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0) , at: .top, animated: true)
                        
                            //HLDataManager.sharedInstance.onboardingTutorials = [:]
                            // TUTORIAL
                            //print("tuto")
                            //print(HLDataManager.sharedInstance.tradeMode)
                            //print(HLDataManager.sharedInstance.arrCurrentTrades.count)
                            if (HLDataManager.sharedInstance.tradeMode == "current"){
                                if HLDataManager.sharedInstance.onboardingTutorials.object(forKey: "dashboard_mix") as? String == nil {
                                    CommonUtils.sharedInstance.showTutorial(arrayTips: [
                                        HulaTip(delay: 0.5, view: self.fakeFirstTradeView, text: NSLocalizedString("Welcome to your first trade! Get some advice. Click on the Trade Room you used.", comment: "")),
                                        HulaTip(delay: 0.5, view: self.fakeAddTradeView, text: NSLocalizedString("Need more trading rooms? tap here to add more spaces!", comment: ""))
                                        ], named: "dashboard_mix")
                                }
                            }
                        }
                    }
                }
            } else {
                print("Recarga de trades demasiado pronto. Omitida.");
            }
            
            
            //self.mainCollectionView.reloadData()
            //isExpandedFlowLayoutUsed = false
        } else {
            print("Error. Not detected parent parent vc")
        }
    }
    
    
    func closeTrade(_ tradeId: String){
        
        lastTradeInteracted = tradeId
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
        viewController.delegate = self
        viewController.isCancelVisible = true
        viewController.cancelButtonText = NSLocalizedString("Don't cancel", comment: "")
        viewController.okButtonText = NSLocalizedString("Cancel", comment: "")
        viewController.trigger = "cancelconfirm"
        viewController.message = NSLocalizedString("Cancel this trade?", comment: "")
        self.present(viewController, animated: true)
        
    }
    
    func reportUser(_ userId:String){
        let queryURL = HulaConstants.apiURL + "users/report/\(userId)"
        //print(dataString)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                //print(json!)
                DispatchQueue.main.async {
                    
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                    
                    viewController.delegate = self
                    viewController.isCancelVisible = false
                    viewController.message = NSLocalizedString("The user has been reported. We will review the user behavior and take necessary actions. Thanks for keeping Hula trustworthy.", comment: "")
                    
                    self.present(viewController, animated: true)
                    
                    
                    self.last_trade_request = 0
                    self.refreshCollectionViewData()
                }
            } else {
                // connection error
                print("Connection error")
            }
        })
    }
    
}

extension HLDashboardViewController: AlertDelegate{
    func alertResponded(response: String, trigger:String) {
        //print("Response: \(response)")
        self.refreshCollectionViewData()
        
        
        if (trigger == "cancelconfirm" && response == "ok"){
            let tradeId = lastTradeInteracted
            if (tradeId != ""){
                let queryURL = HulaConstants.apiURL + "trades/\(tradeId)"
                let status = HulaConstants.cancel_status
                let dataString:String = "status=\(status)"
                //print(dataString)
                HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: dataString, isPut: true, taskCallback: { (ok, json) in
                    if (ok){
                        //print(json!)
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: NSLocalizedString("Trade cancelled", comment: ""), message: NSLocalizedString("Help us to improve, tell us why:", comment: ""), preferredStyle: UIAlertControllerStyle.actionSheet)
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Not interested anymore", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Unhappy with trader", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Product deleted", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                            alert.addAction(UIAlertAction(title: NSLocalizedString("Other", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.last_trade_request = 0
                            self.refreshCollectionViewData()
                        }
                    } else {
                        // connection error
                        print("Connection error")
                    }
                })
            }
        }
    }
}

extension HLDashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max((swappPageVC?.arrTrades.count)!, HulaUser.sharedInstance.maxTrades)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell",
                                                      for: indexPath) as! HLTradesCollectionViewCell
        cell.tradeNumber.text = "\(indexPath.row+1)"
        
        cell.dbDelegate = self
        
        //print(cell.frame)
        // Configure the cell
        if ((swappPageVC?.arrTrades.count)! > indexPath.row){
            //print("Drawing row \(indexPath.row)")
            cell.isEmptyRoom = false
            let thisTrade : NSDictionary = (swappPageVC?.arrTrades[indexPath.row])!
            cell.emptyRoomLabel.text = ""
            //print(thisTrade)
            
            let trade_status =  (thisTrade.object(forKey: "status") as? String)!
            var status = trade_status
            if status == HulaConstants.end_status || status == HulaConstants.cancel_status {
                status = "past"
            } else {
                status = "current"
            }
            cell.tradeStatus = status
            
            cell.tradeId = (thisTrade.object(forKey: "_id") as? String)!
            
            var otherUserId = thisTrade.object(forKey: "other_id") as? String
            if otherUserId == HulaUser.sharedInstance.userId {
                otherUserId = thisTrade.object(forKey: "owner_id") as? String
            }
            if( otherUserId != nil){
                cell.userImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: otherUserId!) )
                
            }
            cell.userId = otherUserId!;
            cell.chatCountLabel.isHidden = true
            var owner_money : Float = 0;
            var other_money : Float = 0;
            
            if let tmp = thisTrade.object(forKey: "owner_money") as? Float{
                owner_money = tmp
            }
            if let tmp = thisTrade.object(forKey: "other_money") as? Float{
                other_money = tmp
            }
            
            if (HulaUser.sharedInstance.userId == thisTrade.object(forKey: "other_id") as? String ){
                // i am the other of the trade
                if let other_products_arr = thisTrade.object(forKey: "other_products") as? [String]{
                    drawProducts(inCell: cell, fromArr: other_products_arr, money: other_money, side: "left")
                }
                if let owner_products_arr = thisTrade.object(forKey: "owner_products") as? [String]{
                    drawProducts(inCell: cell, fromArr: owner_products_arr, money: owner_money, side: "right")
                }
                
                if let chat_count = thisTrade.object(forKey: "other_unread") as? Int{
                    if chat_count > 0 {
                        cell.chatCountLabel.text = "\(chat_count)"
                        cell.chatCountLabel.isHidden = false
                    }
                }
            } else {
                if let other_products_arr = thisTrade.object(forKey: "other_products") as? [String]{
                    drawProducts(inCell: cell, fromArr: other_products_arr, money: other_money, side: "right")
                }
                if let owner_products_arr = thisTrade.object(forKey: "owner_products") as? [String]{
                    drawProducts(inCell: cell, fromArr: owner_products_arr, money: owner_money, side: "left")
                }
                if let chat_count = thisTrade.object(forKey: "owner_unread") as? Int{
                    if chat_count > 0 {
                        cell.chatCountLabel.text = "\(chat_count)"
                        cell.chatCountLabel.isHidden = false
                    }
                }
            }
            
            cell.myImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: HulaUser.sharedInstance.userId))
            cell.myImage.isHidden = false
            cell.middleArrows.isHidden = false
            cell.tradeNumber.textColor = HulaConstants.appMainColor
            
            
            cell.dealClosedLbl.isHidden = true
            if status == "current"{
                // current trades
                if let turnUser = thisTrade.object(forKey: "turn_user_id") as? String{
                    if trade_status == HulaConstants.review_status {
                        cell.dealClosedLbl.isHidden = false
                        cell.myTurnView.isHidden = true
                        cell.otherTurnView.isHidden = true
                    } else {
                        if turnUser != HulaUser.sharedInstance.userId {
                            cell.myTurnView.isHidden = true
                            cell.otherTurnView.isHidden = false
                        } else {
                            cell.myTurnView.isHidden = false
                            cell.otherTurnView.isHidden = true
                        }
                    }
                } else {
                    cell.myTurnView.isHidden = false
                    cell.otherTurnView.isHidden = true
                }
                cell.boxView.layer.shadowColor = UIColor.black.cgColor
                cell.boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.boxView.layer.shadowOpacity = 0.2
                cell.boxView.layer.shadowRadius = 3
                cell.optionsDotsImage.alpha = 1
            } else {
                // past trades
                cell.tradeNumber.textColor = UIColor.gray
                cell.myTurnView.isHidden = true
                cell.otherTurnView.isHidden = true
                cell.boxView.layer.shadowColor = UIColor(red:1, green:1, blue:1, alpha: 0).cgColor
                cell.boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.boxView.layer.shadowOpacity = 0
                cell.boxView.layer.shadowRadius = 0
                cell.optionsDotsImage.alpha = 0.2
                
            }
            cell.userImage.isHidden = false
        } else {
            //print("Empty row \(indexPath.row)")
            cell.isEmptyRoom = true
            cell.tradeId = "";
            cell.emptyRoomLabel.text = NSLocalizedString("Empty Trade Room", comment: "")
            cell.myImage.isHidden = true
            cell.userImage.image = nil
            cell.userImage.isHidden = true
            cell.middleArrows.isHidden = true
            cell.left_side.subviews.forEach({ $0.removeFromSuperview() })
            cell.right_side.subviews.forEach({ $0.removeFromSuperview() })
            cell.tradeNumber.textColor = UIColor.gray
            cell.myTurnView.isHidden = true
            cell.otherTurnView.isHidden = true
            cell.boxView.layer.shadowColor = UIColor(red:1, green:1, blue:1, alpha: 0).cgColor
            cell.boxView.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.boxView.layer.shadowOpacity = 0
            cell.boxView.layer.shadowRadius = 0
            cell.optionsDotsImage.alpha = 0.2
            cell.chatCountLabel.isHidden = true
            cell.dealClosedLbl.isHidden = true
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        //print("Barter room clicked")
        //print(indexPath.row)
        
        if ((swappPageVC?.arrTrades.count)! > indexPath.row){

            
            //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tradeCell", for: indexPath) as! HLTradesCollectionViewCell

            //isExpandedFlowLayoutUsed = !isExpandedFlowLayoutUsed
            let when = DispatchTime.now() + 0.2
            
            
            DispatchQueue.main.asyncAfter(deadline: when) {
                if let swappPageVC = self.parent as? HLSwappPageViewController{
                    self.selectedBarter = indexPath.row
                    let thisTrade: NSDictionary = swappPageVC.arrTrades[indexPath.row]
                    self.swappPageVC?.currentTrade = thisTrade
                    self.swappPageVC?.currentIndex = indexPath.row
                    //print(swappPageVC.currentTrade!)
                    
                    let tradeStatus = thisTrade.object(forKey: "status") as! String
                    if HLDataManager.sharedInstance.tradeMode == "current" && tradeStatus != HulaConstants.review_status {
                        let vc = (self.storyboard?.instantiateViewController( withIdentifier: "barterRoom")) as! HLBarterScreenViewController
                        self.swappPageVC?.orderedViewControllers[1] = vc
                    } else {
                        let vc = (self.storyboard?.instantiateViewController( withIdentifier: "pastTrade")) as! HLPastTradeViewController
                        vc.currTrade = thisTrade
                        self.swappPageVC?.orderedViewControllers[1] = vc
                    }
                    
                    self.swappPageVC?.goTo(page: 1)
                }
                //print(self.parent!)
            }
            
        
        }
 
    }
    

    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with: coordinator)
        
        mainCollectionView.collectionViewLayout.invalidateLayout()
    }
 
    
    func drawProducts(inCell:HLTradesCollectionViewCell, fromArr: [String], money: Float, side: String){
        var counter:Int = 0;
        if (side=="right"){
            inCell.right_side.subviews.forEach({ $0.removeFromSuperview() })
        } else {
            inCell.left_side.subviews.forEach({ $0.removeFromSuperview() })
        }
        let verticalCenter:CGFloat = (59.0/2) - productImagesWidth/2;
        for img in fromArr {
            if (img != ""){
                let newImg = UIImageView()
                if (side=="right"){
                    newImg.frame = CGRect(x: ( CGFloat(counter) * (productImagesWidth + productImagesMargin)) + productImagesMargin*2,
                                          y: verticalCenter,
                                          width: productImagesWidth,
                                          height: productImagesWidth)
                    inCell.right_side.addSubview(newImg)
                } else {
                    newImg.frame = CGRect(x: inCell.left_side.frame.width - ( CGFloat(counter) * (productImagesWidth + productImagesMargin)) - (productImagesMargin) - productImagesWidth,
                                          y: verticalCenter,
                                          width: productImagesWidth,
                                          height: productImagesWidth)
                    inCell.left_side.addSubview(newImg)
                    
                    
                    /*
                    
                    let horizontalConstraint = NSLayoutConstraint(item: newImg, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: inCell.left_side, attribute: NSLayoutAttribute.right, multiplier: 1, constant:  -( ( CGFloat(counter) * (productImagesWidth + productImagesMargin)) - (productImagesMargin) - productImagesWidth))
                    
                    NSLayoutConstraint.activate([horizontalConstraint])
                    */
                }
                
                let thumb = commonUtils.getThumbFor(url: HulaConstants.apiURL + "products/\(img)/image")
                newImg.loadImageFromURL(urlString: thumb)
                

                
                
                counter += 1
            }
        }
        if money > 0 {
            let mn = UILabel()
            mn.text = "$\(Int(money))";
            mn.font = UIFont(name: HulaConstants.regular_font, size: 10.0)
            mn.textColor = HulaConstants.appMainColor
            if (side=="right"){
                mn.frame = CGRect(x: ( CGFloat(counter) * (productImagesWidth + productImagesMargin)) + productImagesMargin*2,
                                      y: verticalCenter,
                                      width: productImagesWidth,
                                      height: productImagesWidth)
                inCell.right_side.addSubview(mn)
            } else {
                mn.frame = CGRect(x: inCell.left_side.frame.width - ( CGFloat(counter) * (productImagesWidth + productImagesMargin)) - (productImagesMargin) - productImagesWidth,
                                      y: verticalCenter,
                                      width: productImagesWidth,
                                      height: productImagesWidth)
                inCell.left_side.addSubview(mn)
                
            }
        }
    }
    
}
/*
extension HLDashboardViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width
        return CGSize(width: availableWidth, height: 70)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
 */
