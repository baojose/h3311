//
//  HLBarterScreenViewController.swift
//  Hula
//
//  Created by Juan Searle on 13/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLBarterScreenViewController: BaseViewController {
    
    
    @IBOutlet weak var mainViewHolder: UIView!
    @IBOutlet weak var moneyBtn: UIButton!
    
    @IBOutlet weak var sectionCover: UIButton!
    @IBOutlet weak var otherProductsCollection: KDDragAndDropCollectionView!
    @IBOutlet weak var otherSelectedProductsCollection: KDDragAndDropCollectionView!
    @IBOutlet weak var myProductsCollection: KDDragAndDropCollectionView!
    @IBOutlet weak var mySelectedProductsCollection: KDDragAndDropCollectionView!
    
    @IBOutlet weak var ChatFakeView: UIView!
    
    @IBOutlet weak var rightBackground: UIView!
    @IBOutlet weak var leftBackground: UIView!
    @IBOutlet weak var otherProductsDragView: UIImageView!
    @IBOutlet weak var myProductsDragView: UIImageView!
    
    @IBOutlet weak var addMoneyBtn2: UIButton!
    @IBOutlet weak var addMoneyBtn1: UIButton!
    @IBOutlet weak var sendOfferFakeView: UIView!
    @IBOutlet weak var otherOkFakeView: UIView!
    
    @IBOutlet weak var otherProductsLabel: UILabel!
    @IBOutlet weak var myProductsLabel: UILabel!
    
    var myProducts : [HulaProduct] = []
    var otherProducts : [HulaProduct] = []
    var myInitialProducts : [HulaProduct] = []
    var otherInitialProducts : [HulaProduct] = []
    var myTradedProducts : [HulaProduct] = []
    var otherTradedProducts : [HulaProduct] = []
    var myProductsDiff : [String] = []
    var otherProductsDiff : [String] = []
    var myTradeIndex: Int = 1
    
    var mainSwapViewHolder: HLSwappViewController?
    
    var thisTrade: HulaTrade = HulaTrade()
    
    let arrowImagesName = ["","icon-product-added", "icon-product-removed", "icon-product-multipledeals"]
    
    var otherUserId: String = ""
    
    var didTradeMutate:Bool = false
    
    var dragAndDropManager1 : KDDragAndDropManager?
    var dragAndDropManager2 : KDDragAndDropManager?
    var alreadyLoaded = false
    
    var liveTimer = Timer()
    var productsTimer = Timer()
    
    var first_time_load_other : Bool = true
    var first_time_load_owner : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        otherProductsLabel.isHidden = true
        myProductsLabel.isHidden = true
        otherProductsDragView.isHidden = true
        myProductsDragView.isHidden = true
        
        
        
        if Device.IS_IPHONE_X {
            self.mainViewHolder.frame.origin.x = 25
            self.mainViewHolder.frame.size.width = self.view.frame.width - 50
        }
        
        // draw borders on collectionviews
        let border = UIView()
        border.frame = CGRect(x:myProductsCollection.frame.width-1, y: 0, width: 1, height: self.mainViewHolder.frame.height)
        border.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.mainViewHolder.addSubview(border)
        let border2 = UIView()
        border2.frame = CGRect(x: self.mainViewHolder.frame.width - otherProductsCollection.frame.width, y: 0, width: 1, height: self.mainViewHolder.frame.height)
        border2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.mainViewHolder.addSubview(border2)
        
        
        // tag each collectionview
        otherSelectedProductsCollection.currentSide = "otherSide"
        mySelectedProductsCollection.currentSide = "mySide"
        myProductsCollection.currentSide = "-"
        otherProductsCollection.currentSide = "-"
        
        
        if #available(iOS 11.0, *) {
            //print("####  setNeedsUpdateOfScreenEdgesDeferringSystemGestures");
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadProductsArrays(){
        alreadyLoaded = true
        var mtp:[String] = []
        var otp:[String] = []
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            
            //print(swappPageVC.parent)
            
            myTradeIndex = min(swappPageVC.currentIndex, swappPageVC.arrTrades.count)
            
            let ct = swappPageVC.arrTrades[swappPageVC.currentIndex]
            //print("ct \(ct)")
            thisTrade.loadFrom(dict: ct)
            if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
                // I am the owner
                mtp = thisTrade.owner_products
                otp = thisTrade.other_products
                otherUserId = thisTrade.other_id
                
            } else {
                // I am the other
                otp = thisTrade.owner_products
                mtp = thisTrade.other_products
                otherUserId = thisTrade.owner_id
            }
            
            if self.thisTrade.turn_user_id == HulaUser.sharedInstance.userId || true {
                // "true  for forcing always my turn
                // my turn
                self.sectionCover.isHidden = true
                self.addMoneyBtn1.isUserInteractionEnabled = true
                self.addMoneyBtn2.isUserInteractionEnabled = true
            } else {
                self.sectionCover.isHidden = true // provisional
                self.addMoneyBtn1.isUserInteractionEnabled = false
                self.addMoneyBtn2.isUserInteractionEnabled = false
                
            }
            //print(otp)
            //print(mtp)
            getUserProducts(user: otherUserId, taskCallback: {(result) in
                //print (self.otherProducts)
                self.otherProducts = result
                self.otherInitialProducts = result
                self.populateTradedProducts(list:otp, type:"other")
                self.otherProductsCollection.reloadData()
                self.otherSelectedProductsCollection.reloadData()
                if self.first_time_load_other {
                    //print("animating th")
                    self.animateAddedProducts("other")
                    self.animateDisolveProducts("other")
                    self.first_time_load_other = false
                }
            })
            
            getUserProducts(user: HulaUser.sharedInstance.userId, taskCallback: {(result) in
                //print (self.myProducts)
                self.myProducts = result
                self.myInitialProducts = result
                self.populateTradedProducts(list:mtp, type:"owner")
                self.myProductsCollection.reloadData()
                self.mySelectedProductsCollection.reloadData()
                if self.first_time_load_owner {
                    //print("animating wn")
                    self.animateAddedProducts("owner")
                    self.animateDisolveProducts("owner")
                    self.first_time_load_owner = false
                }
            })
            HulaTrade.sharedInstance.owner_products = thisTrade.owner_products
            HulaTrade.sharedInstance.other_products = thisTrade.other_products
            
            
            
            
            //print(thisTrade.other_money)
            //print(thisTrade.owner_money)
            
            
            self.addMoneyBtn1.alpha = 1
            self.addMoneyBtn2.alpha = 1
            // my draganddrop
            self.dragAndDropManager2 = KDDragAndDropManager(canvas: self.view, collectionViews: [myProductsCollection, mySelectedProductsCollection ])
            // other draganddrop
            self.dragAndDropManager1 = KDDragAndDropManager(canvas: self.view, collectionViews: [otherProductsCollection, otherSelectedProductsCollection ])
      
            
            
            // TUTORIAL
            
            
            if HLDataManager.sharedInstance.onboardingTutorials.object(forKey: "barter_any_turn") as? String == nil{
                CommonUtils.sharedInstance.showTutorial(arrayTips: [
                    HulaTip(delay: 0.4, view: self.otherProductsCollection, text: NSLocalizedString("Here is their stuff.", comment: "")),
                    HulaTip(delay: 0.2, view: self.otherSelectedProductsCollection, text: NSLocalizedString("Drag & drop here what you want.", comment: "")),
                    HulaTip(delay: 0.2, view: self.otherProductsCollection, text: NSLocalizedString("Tap on the product to get more info and ask for a live video to check it.", comment: "")),
                    HulaTip(delay: 0.2, view: self.myProductsCollection, text: NSLocalizedString("Here is your stuff.", comment: "")),
                    HulaTip(delay: 0.2, view: self.addMoneyBtn1, text: NSLocalizedString("You can also offer money.", comment: "")),
                    HulaTip(delay: 0.2, view: self.otherOkFakeView, text: NSLocalizedString("This is the other user's status. When you see a check mark, he/she is waiting for your final approval.", comment: "")),
                    HulaTip(delay: 0.2, view: self.sendOfferFakeView, text: NSLocalizedString("Once you've selected what you want, click this button to let the other know you agree.", comment: "")),
                    HulaTip(delay: 0.2, view: self.ChatFakeView, text: NSLocalizedString("Start chat here if you need to talk.", comment: ""))
                    ], named: "barter_any_turn")
                //print(HLDataManager.sharedInstance.onboardingTutorials)
            }
            if self.thisTrade.turn_user_id == HulaUser.sharedInstance.userId{
                // my turn
            } else {
                // other's turn
            }
            
            
            if let thisHolderScreen = swappPageVC.parent as? HLSwappViewController {
                self.mainSwapViewHolder = thisHolderScreen
                self.mainSwapViewHolder?.barterDelegate = self
                self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
            }
        }
    }
    
    
    
    func refreshProductsArrays(){
        
        getUserProducts(user: HulaUser.sharedInstance.userId, taskCallback: {(result) in
            if (result.count > 0){
                for j in 0 ... (result.count - 1) {
                    if (self.myTradedProducts.count > 0){
                        for i in 0 ... (self.myTradedProducts.count - 1) {
                            if (self.myTradedProducts[i].productId == result[j].productId){
                                //print("found product!")
                                self.myTradedProducts[i].video_url = result[j].video_url;
                                self.myTradedProducts[i].video_requested = result[j].video_requested;
                                
                            }
                        }
                    }
                    if (self.myProducts.count > 0){
                        for i in 0 ... (self.myProducts.count - 1) {
                            if (self.myProducts[i].productId == result[j].productId){
                                //print("found product!")
                                self.myProducts[i].video_url = result[j].video_url;
                                self.myProducts[i].video_requested = result[j].video_requested;
                                
                            }
                        }
                    }
                }
                self.mySelectedProductsCollection.reloadData()
                self.myProductsCollection.reloadData()
            }
        });
        
        
        
        getUserProducts(user: self.otherUserId, taskCallback: {(result) in
            if (result.count > 0){
                for j in 0 ... (result.count - 1) {
                    if (self.otherTradedProducts.count > 0){
                        for i in 0 ... (self.otherTradedProducts.count - 1) {
                            if (self.otherTradedProducts[i].productId == result[j].productId){
                                //print("found product!")
                                self.otherTradedProducts[i].video_url = result[j].video_url;
                                self.otherTradedProducts[i].video_requested = result[j].video_requested;
                                
                            }
                        }
                    }
                    if (self.otherProducts.count > 0){
                        for i in 0 ... (self.otherProducts.count - 1) {
                            if (self.otherProducts[i].productId == result[j].productId){
                                //print("found product!")
                                self.otherProducts[i].video_url = result[j].video_url;
                                self.otherProducts[i].video_requested = result[j].video_requested;
                            }
                        }
                    }
                }
                self.otherSelectedProductsCollection.reloadData()
                self.otherProductsCollection.reloadData()
            }
        })
    }
    
    
    func populateTradedProducts(list: [String], type: String){
        let reference_list: [HulaProduct]
        var final_arr: [HulaProduct] = []
        switch type {
        case "other":
            reference_list = self.otherProducts
        default:
            reference_list = self.myProducts
        }
        
        //print(thisTrade.last_bid_diff)
        for pr_id in list{
            var found : Bool = false
            for pr in reference_list{
                if pr.productId == pr_id{
                    final_arr.append(pr)
                    found = true
                }
            }
            
            if !found && pr_id != "" {
                //self.animateDisolveProduct(pr_id, type: type)
                let tmp_prod = HulaProduct(id: pr_id, name: NSLocalizedString("Deleted product", comment: ""), image: CommonUtils.sharedInstance.productImageURL(productId: pr_id))
                tmp_prod.productStatus = "deleted"
                tmp_prod.productDescription = NSLocalizedString("This product is not available anymore.", comment: "")
                tmp_prod.tradeStatus = 2
                final_arr.append(tmp_prod)
                
                // update button. We cannot close the deal directly
                self.didTradeMutate = true
                self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
            }
            
            if (self.otherProducts.count > 0){
                for i in 0 ... (self.otherProducts.count - 1) {
                    if (self.otherProducts[i].productId == pr_id){
                        self.otherProducts.remove( at: i)
                    }
                    if (i >= self.otherProducts.count - 1){
                        break
                    }
                }
            }
            if (self.myProducts.count > 0){
                for i in 0 ... (self.myProducts.count - 1) {
                    if (self.myProducts[i].productId == pr_id){
                        self.myProducts.remove( at: i)
                    }
                    if (i >= self.myProducts.count - 1){
                        break
                    }
                }
            }
        }
        
        
        switch type {
        case "other":
            if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
                if thisTrade.other_money > 0 {
                    let moneyProd = HulaProduct(id: "xmoney", name: "+$\(Int(round(thisTrade.other_money)))", image: HulaConstants.transparentImg)
                    final_arr.append(moneyProd)
                }
            } else {
                if thisTrade.owner_money > 0 {
                    let moneyProd = HulaProduct(id: "xmoney", name: "+$\(Int(round(thisTrade.owner_money)))", image: HulaConstants.transparentImg)
                    final_arr.append(moneyProd)
                }
            }
            otherTradedProducts = final_arr
        default:
            if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
                if thisTrade.owner_money > 0 {
                    let moneyProd = HulaProduct(id: "xmoney", name: "+$\(Int(round(thisTrade.owner_money)))", image: HulaConstants.transparentImg)
                    final_arr.append(moneyProd)
                }
            } else {
                if thisTrade.other_money > 0 {
                    let moneyProd = HulaProduct(id: "xmoney", name: "+$\(Int(round(thisTrade.other_money)))", image: HulaConstants.transparentImg)
                    final_arr.append(moneyProd)
                }
            }
            myTradedProducts = final_arr
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            if ( swappPageVC.arrTrades.count == 0 ){
                //print("yendo")
                DispatchQueue.main.async {
                    swappPageVC.goTo(page: 0)
                }
            } else {
                HLDataManager.sharedInstance.ga("barter_screen")
                
                scheduledTimerWithTimeInterval()
            }
        }
        view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.liveTimer.invalidate();
        self.productsTimer.invalidate();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            self.addMoneyBtn1.alpha = 1
            self.addMoneyBtn2.alpha = 1
            if ( swappPageVC.arrTrades.count > 0 ){
                if Device.IS_IPHONE_X {
                    self.mainViewHolder.frame.origin.x = 25
                    self.mainViewHolder.frame.size.width = self.view.frame.width - 50
                }
                if !alreadyLoaded{
                    loadProductsArrays();
                }
                if let swappPageVC = self.parent as? HLSwappPageViewController{
                    if let thisHolderScreen = swappPageVC.parent as? HLSwappViewController {
                        thisHolderScreen.last_index_setup = 1
                    }
                }
            } else {
                self.addMoneyBtn1.alpha = 0.3
                self.addMoneyBtn2.alpha = 0.3
            }
        }
        
        
    }

    override func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        print("*preferredScreenEdges")
        return .all	
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func animateDisolveProducts(_ type:String){
        //print("Disolve")
        
        DispatchQueue.main.async {
            var counter = 0
            if (type == "owner"){
                for p in self.myTradedProducts {
                    if p.productStatus == "deleted" {
                        let indexPath = IndexPath(row: counter, section: 0)
                        let cell = self.mySelectedProductsCollection.cellForItem(at: indexPath)
                        UIView.animate(withDuration: 0.9, delay: 1, options: [], animations: {
                            cell?.alpha = 0
                        }, completion: { (success) in
                            if (success){
                                self.updateMyRemovedProducts()
                            } else {
                                cell?.alpha = 0
                            }
                        })
                    }
                    counter += 1
                }
            } else {
                for p in self.otherTradedProducts {
                    if p.productStatus == "deleted" {
                        let indexPath = IndexPath(row: counter, section: 0)
                        let cell = self.otherSelectedProductsCollection.cellForItem(at: indexPath)
                        UIView.animate(withDuration: 0.9, delay: 0.5, options: [], animations: {
                            cell?.alpha = 0
                        }, completion: { (success) in
                            if (success){
                                self.updateOtherRemovedProducts()
                            } else {
                                cell?.alpha = 0
                            }
                        })
                    }
                    counter += 1
                }
            }
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        liveTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.getLiveBarter), userInfo: nil, repeats: true);
        productsTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.refreshProductsArrays), userInfo: nil, repeats: true);
    }
    func updateLiveBarter(){
        let queryURL = HulaConstants.apiURL + "live_barter/" + self.thisTrade.tradeId;
        
        var otherp:String = "";
        var ownerp:String = "";
        if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
            // I am the owner
            otherp = generateProductArray(from: self.otherTradedProducts).joined(separator:",");
            ownerp = generateProductArray(from: self.myTradedProducts).joined(separator:",");
        } else {
            // I am the other
            otherp = generateProductArray(from: self.myTradedProducts).joined(separator:",");
            ownerp = generateProductArray(from: self.otherTradedProducts).joined(separator:",");
        }
        let postStr = "other_products=\(otherp)&owner_products=\(ownerp)&other_money=\(thisTrade.other_money)&owner_money=\(thisTrade.owner_money)";
        print(postStr)
        HLDataManager.sharedInstance.httpPost(urlstr: queryURL, postString: postStr, isPut: false, taskCallback:  { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? NSDictionary {
                        self.updateTradeInterface(dict: dictionary);
                    }
                }
            } else {
                // connection error
                print("Connection error");
            }
        })
    }
    func getLiveBarter(){
        let queryURL = HulaConstants.apiURL + "live_barter/" + self.thisTrade.tradeId
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? NSDictionary {
                        self.updateTradeInterface(dict: dictionary);
                    }
                }
            } else {
                // connection error
                print("Connection error");
            }
        })
    }
    
    func updateTradeInterface(dict: NSDictionary){
        let newTrade: HulaTrade = HulaTrade();
        newTrade.loadFrom(dict: dict);
        
        if (newTrade.other_products != self.thisTrade.other_products) || (newTrade.owner_products != self.thisTrade.owner_products) || (newTrade.owner_money - newTrade.other_money != self.thisTrade.owner_money - self.thisTrade.other_money){
            print ("trades are different. Updating interface");
            
            
            self.thisTrade = newTrade;
            var mtp:[String] = []
            var otp:[String] = []
            if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
                // I am the owner
                mtp = thisTrade.owner_products
                otp = thisTrade.other_products
            } else {
                // I am the other
                otp = thisTrade.owner_products
                mtp = thisTrade.other_products
            }
            self.otherProducts = self.otherInitialProducts;
            self.myProducts = self.myInitialProducts;
            print("otp");
            print(otp);
            print("mtp");
            print(mtp);
            self.populateTradedProducts(list:otp, type:"other")
            self.otherProductsCollection.reloadData()
            self.otherSelectedProductsCollection.reloadData()
            self.animateAddedProducts("other")
            self.animateDisolveProducts("other")
            
            self.populateTradedProducts(list:mtp, type:"owner")
            self.myProductsCollection.reloadData()
            self.mySelectedProductsCollection.reloadData()
            self.animateAddedProducts("owner")
            self.animateDisolveProducts("owner")
            
            
        }
        self.thisTrade.other_ready = newTrade.other_ready;
        self.thisTrade.owner_ready = newTrade.owner_ready;
        // update bottom bar!
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
        
    }
    
    func updateMyRemovedProducts(){
        var newArr: [HulaProduct] = []
        for i in 0 ..< self.myTradedProducts.count {
            let p = self.myTradedProducts[i]
            if p.productStatus != "deleted" {
                newArr.append(p)
            }
        }
        self.myTradedProducts = newArr
        self.mySelectedProductsCollection.reloadData()
    }
    func updateOtherRemovedProducts(){
        var newArr: [HulaProduct] = []
        for i in 0 ..< self.otherTradedProducts.count {
            let p = self.otherTradedProducts[i]
            if p.productStatus != "deleted" {
                newArr.append(p)
            }
        }
        self.otherTradedProducts = newArr
        self.otherSelectedProductsCollection.reloadData()
    }
    
    func animateAddedProducts(_ type : String){
        var array_to_traverse : [HulaProduct]
        var array_to_traverse2 : [HulaProduct]
        var posx : CGFloat = 0
        let posy : CGFloat = self.view.frame.height / 3
        var destx :CGFloat = 0
        let smallSide :CGFloat = (mySelectedProductsCollection.frame.width - 10)/3 - 8
        let largeSide :CGFloat =  128
        var col : KDDragAndDropCollectionView
        var col2 : KDDragAndDropCollectionView
        var column_x : CGFloat = 5
        if type == "owner" {
            array_to_traverse = myTradedProducts
            array_to_traverse2 = myProducts
            posx = 20
            destx = 128
            col = mySelectedProductsCollection
            col2 = myProductsCollection
            column_x = 5
        } else {
            array_to_traverse = otherTradedProducts
            array_to_traverse2 = otherProducts
            posx = self.view.frame.width - 20
            destx = self.view.frame.width/2
            col = otherSelectedProductsCollection
            col2 = otherProductsCollection
            column_x = self.view.frame.width - 128
        }
        var counter : Int = 0
        DispatchQueue.main.async {
        for p in array_to_traverse{
            
            
            //removed animations -> false
            if p.tradeStatus == 1 && false {
                // added product
                let fakeImg = UIImageView(frame: CGRect(x:posx, y:posy, width: 120, height:120))
                fakeImg.contentMode = .scaleAspectFill
                fakeImg.clipsToBounds = true
                fakeImg.loadImageFromURL(urlString: p.arrProductPhotoLink[0])
                self.view.insertSubview(fakeImg, at: self.view.subviews.count - 2)
                let cell = col.cellForItem(at: IndexPath(item: counter, section: 0))
                cell?.alpha = 0
                //let animDuration = 0.3 + Double(counter)/10;
                let animDuration = 0.1;
                UIView.animate(withDuration: animDuration , animations: {
                    fakeImg.alpha = 1
                    if cell != nil{
                        var rct = (cell?.frame)!
                        rct.origin.x += col.frame.origin.x + (col.superview?.frame.origin.x)! + 5
                        rct.origin.y += col.frame.origin.y + (col.superview?.frame.origin.y)! + 5
                        rct.size.width -= 10
                        rct.size.height -= 10
                        fakeImg.frame = rct
                    } else {
                        fakeImg.frame.origin = CGPoint(x:destx + CGFloat(counter%3) * smallSide + 8, y:7)
                        fakeImg.frame.size = CGSize(width:smallSide, height:smallSide)
                    }
                }, completion:  { (success) in
                    UIView.animate(withDuration: 0.1, animations: {
                        fakeImg.alpha = 0
                        cell?.alpha = 1
                    })
                })
            }
            counter += 1
        }
        for p in array_to_traverse2{
            
            //removed animations -> false
            if p.tradeStatus == 2 && false{
                // removed product
                let fakeImg = UIImageView(frame: CGRect(x:destx + smallSide, y:80, width: smallSide, height:smallSide))
                fakeImg.contentMode = .scaleAspectFill
                fakeImg.clipsToBounds = true
                fakeImg.loadImageFromURL(urlString: p.arrProductPhotoLink[0])
                self.view.insertSubview(fakeImg, at: self.view.subviews.count - 2)
                //self.view.addSubview(fakeImg)
                let cell = col2.cellForItem(at: IndexPath(item: counter, section: 0))
                cell?.alpha = 0
                //let animDuration = 0.2 + Double(counter)/10;
                let animDuration = 0.1;
                UIView.animate(withDuration: animDuration, animations: {
                    fakeImg.alpha = 1
                    if cell != nil{
                        fakeImg.frame = (cell?.frame)!
                    } else {
                        fakeImg.frame.origin = CGPoint(x:column_x, y: 5 + CGFloat(counter-1) * largeSide)
                        fakeImg.frame.size = CGSize(width:120, height:85)
                    }
                }, completion:  { (success) in
                    UIView.animate(withDuration: 0.1, animations: {
                        fakeImg.alpha = 0
                        cell?.alpha = 1
                    })
                })
            }
            counter += 1
        }
        }
    }
    
    func getUserProducts(user: String, taskCallback: @escaping ([HulaProduct]) -> ()) {
        //print("Getting user info...")
        if (HulaUser.sharedInstance.userId.count>0){
            let queryURL = HulaConstants.apiURL + "products/user/" + user
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                if (ok){
                    DispatchQueue.main.async {
                        if let dictionary = json as? [Any] {
                            //print(dictionary)
                            var productList: [HulaProduct] = []
                            
                            //print(self.thisTrade.last_bid_diff)
                            
                            for item in dictionary{
                                //print("item")
                                //print(item)
                                if let product_data = item as? [String : Any]{
                                    let id = product_data["_id"] as! String
                                    let name = product_data["title"] as! String
                                    var image = product_data["image_url"] as? String
                                    if (image == nil){
                                        image = CommonUtils.sharedInstance.productImageURL(productId: id)
                                    }
                                    let newProd = HulaProduct(id : id, name : name, image: image!)
                                    newProd.populate(with: product_data as NSDictionary)
                                    
                                    for difprod in self.thisTrade.last_bid_diff {
                                        if (difprod == newProd.productId!) || (self.thisTrade.num_bids < 3) {
                                            // recently added
                                            newProd.tradeStatus = 1
                                        }
                                        if (difprod == "-\(newProd.productId!)"){
                                            // recently removed
                                            newProd.tradeStatus = 2
                                        }
                                    }
                                    
                                    productList.append(newProd)
                                }
                            }
                            taskCallback(productList)
                        } else {
                            taskCallback([])
                        }
                    }
                } else {
                    // connection error
                    taskCallback([])
                }
            })
        }
    }
    
    func generateProductArray(from:[HulaProduct]) -> [String]{
        var final_arr = [String]();
        
        for prod in from {
            if (prod.productId != "xmoney") && (prod.productStatus != "deleted"){
                final_arr.append(prod.productId)
            }
        }
        //print(final_arr)
        return final_arr
    }
    
    func updateProductsFromTrade(){
        //print("Updating products from trade...")
        getUserProducts(user: HulaUser.sharedInstance.userId, taskCallback: {(result) in
            var ctr = 0;
            for tr_prod in self.myTradedProducts {
                for my_prod in result {
                    if tr_prod.productId == my_prod.productId {
                        self.myTradedProducts[ctr].video_requested = my_prod.video_requested
                        self.myTradedProducts[ctr].video_url = my_prod.video_url
                    }
                }
                ctr += 1
            }
        })
        getUserProducts(user: otherUserId, taskCallback: {(result) in
            var ctr = 0;
            for tr_prod in self.otherTradedProducts {
                for other_prod in result {
                    if tr_prod.productId == other_prod.productId {
                        self.otherTradedProducts[ctr].video_requested = other_prod.video_requested
                        self.otherTradedProducts[ctr].video_url = other_prod.video_url
                    }
                }
                ctr += 1
            }
        })
    }
    
    @IBAction func addMoneyToOther(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "calculatorView") as! HLCalculatorViewController
        
        viewController.calculatorDelegate = self
        viewController.side = "other"
        if thisTrade.owner_id == HulaUser.sharedInstance.userId{
            viewController.amount = Int(thisTrade.other_money)
        } else {
            viewController.amount = Int(thisTrade.owner_money)
        }
        self.present(viewController, animated: true)
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
    }
    
    @IBAction func addMonewToOwner(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "calculatorView") as! HLCalculatorViewController
        
        viewController.calculatorDelegate = self
        viewController.side = "owner"
        if thisTrade.owner_id == HulaUser.sharedInstance.userId{
            viewController.amount = Int(thisTrade.owner_money)
        } else {
            viewController.amount = Int(thisTrade.other_money)
        }
        self.present(viewController, animated: true)
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
    }
}

extension HLBarterScreenViewController: KDDragAndDropCollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return myProducts.count
        case 2:
            return myTradedProducts.count
        case 3:
            return otherTradedProducts.count
        case 4:
            return otherProducts.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("Collection: \(collectionView.tag) item \(indexPath.item)")
        let product:HulaProduct
        switch collectionView.tag {
        case 1:
            product = myProducts[indexPath.item]
        case 2:
            product = myTradedProducts[indexPath.item]
        case 3:
            product = otherTradedProducts[indexPath.item]
        case 4:
            product = otherProducts[indexPath.item]
        default:
            product = HulaProduct(id : "nada", name : "Test product", image: "https://api.hula.trading/v1/products/59400e5ce8825609f281bc68/image")
        }
        //print(product)
        
        if (product.productId == "xmoney"){
            if collectionView.tag == 2 {
                addMonewToOwner("")
            } else {
                addMoneyToOther("")
            }
        } else {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ProductModal") as! HLProductModalViewController
            
            viewController.product = product
            if collectionView.tag == 2 || collectionView.tag == 3 {
                // product on the barter table
                viewController.hideVideoBtn = false
            } else {
                // product on the user lists
                viewController.hideVideoBtn = true
            }
            viewController.calledFrom = collectionView.tag
            viewController.currentTradeId = self.thisTrade.tradeId
            viewController.isTradeAgreed = self.thisTrade.other_agree
            //print("viewController.isTradeAgreed \(viewController.isTradeAgreed)")
            viewController.modalPresentationStyle = .overCurrentContext
            
            self.present(viewController, animated: true)
            //print("presented vc")
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: HLProductCollectionViewCell
    
        let product:HulaProduct
        switch collectionView.tag {
        case 1:
            product = myProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell1", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "left"
            cell.type = "user"
        case 2:
            product = myTradedProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell2", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "left"
            cell.type = "select"
        case 3:
            product = otherTradedProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell3", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "right"
            cell.type = "select"
        case 4:
            
            product = otherProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell4", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "right"
            cell.type = "user"
        default:
            print("Error: no product found")
            product = HulaProduct(id : "nada", name : "Test product", image: "https://api.hula.trading/v1/products/59400e5ce8825609f281bc68/image")
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell4", for: indexPath) as! HLProductCollectionViewCell
        }
        
        cell.label.text = product.productName
        //print(product.productImage)
        
        let thumb = commonUtils.getThumbFor(url: product.productImage)
        cell.image.loadImageFromURL(urlString: thumb)
        //print(product.tradeStatus)
        if (product.tradeStatus != 0){
            if (product.tradeStatus == 1){
                cell.is_added()
            } else {
                cell.is_removed()
            }
        }
        //print(product.video_requested)
        //print(product.video_url)
        var vreq : Bool = false
        var vurl : String = ""
        if let t = product.video_requested[thisTrade.tradeId] {
            vreq = t
        }

        if let t = product.video_url[thisTrade.tradeId] {
            vurl = t
        }
        
        cell.statusImage.isHidden = false
        if ( vreq || vurl.count > 0 ){
            if vurl.count > 0 {
                cell.statusImage.image = UIImage(named: "video-player-icon-red")
            } else {
                cell.statusImage.image = UIImage(named: "video-requested-red")
            }
        } else {
            cell.statusImage.image = nil
        }
        
        
        if (product.productStatus == "deleted"){
            cell.statusImage.image = UIImage(named: "icon-product-removed")
            cell.statusImage.isHidden = false
        }
        
        cell.isHidden = false
        
        
        if let kdCollectionView = collectionView as? KDDragAndDropCollectionView {
            
            if let draggingPathOfCellBeingDragged = kdCollectionView.draggingPathOfCellBeingDragged {
                
                if draggingPathOfCellBeingDragged.item == indexPath.item {
                    
                    cell.isHidden = true
                    
                }
            }
        }
        
        return cell
    }
    
    // MARK : KDDragAndDropCollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, dataItemForIndexPath indexPath: IndexPath) -> AnyObject {
        let product:HulaProduct
        switch collectionView.tag {
        case 1:
            product = myProducts[indexPath.item]
        case 2:
            product = myTradedProducts[indexPath.item]
        case 3:
            product = otherTradedProducts[indexPath.item]
        case 4:
            product = otherProducts[indexPath.item]
        default:
            product = HulaProduct(id : "nada", name : "Test product", image: "https://hula.trading/v1/products/59400e5ce8825609f281bc68/image")
        }
        return product
    }
    func collectionView(_ collectionView: UICollectionView, insertDataItem dataItem : AnyObject, atIndexPath indexPath: IndexPath) -> Void {
        
        if let di = dataItem as? HulaProduct {
            switch collectionView.tag {
            case 1:
                myProducts.insert(di, at: indexPath.item)
            case 2:
                myTradedProducts.insert(di, at: indexPath.item)
                
                self.updateLiveBarter()
            case 3:
                otherTradedProducts.insert(di, at: indexPath.item)
                
                self.updateLiveBarter()
            case 4:
                otherProducts.insert(di, at: indexPath.item)
            default: break
            }
        }
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
        
    }
    func collectionView(_ collectionView: UICollectionView, deleteDataItemAtIndexPath indexPath : IndexPath) -> Void {
        switch collectionView.tag {
        case 1:
            myProducts.remove( at: indexPath.item)
        case 2:
            myTradedProducts.remove( at: indexPath.item)
            self.updateLiveBarter()
        case 3:
            otherTradedProducts.remove( at: indexPath.item)
            self.updateLiveBarter()
        case 4:
            otherProducts.remove( at: indexPath.item)
        default: break
        }
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, moveDataItemFromIndexPath from: IndexPath, toIndexPath to : IndexPath) -> Void {
        
        let fromDataItem: HulaProduct
        switch collectionView.tag {
        case 1:
            fromDataItem = myProducts[from.item]
            myProducts.remove(at: from.item)
            myProducts.insert(fromDataItem, at: to.item)
        case 2:
            fromDataItem = myTradedProducts[from.item]
            myTradedProducts.remove(at: from.item)
            myTradedProducts.insert(fromDataItem, at: to.item)
            self.updateLiveBarter()
        case 3:
            fromDataItem = otherTradedProducts[from.item]
            otherTradedProducts.remove(at: from.item)
            otherTradedProducts.insert(fromDataItem, at: to.item)
            self.updateLiveBarter()
        case 4:
            fromDataItem = otherProducts[from.item]
            otherProducts.remove(at: from.item)
            otherProducts.insert(fromDataItem, at: to.item)
        default:
            print("Error: No product found!")
            fromDataItem = myProducts[from.item]
            myProducts.remove(at: from.item)
            myProducts.insert(fromDataItem, at: to.item)
        }
        
        self.didTradeMutate = true
        self.mainSwapViewHolder?.controlSetupBottomBar(index: myTradeIndex + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, indexPathForDataItem dataItem: AnyObject) -> IndexPath? {
        
        if let candidate : HulaProduct = dataItem as? HulaProduct {
            let dataArr: [HulaProduct]
            switch collectionView.tag {
            case 1:
                dataArr = myProducts
            case 2:
                dataArr = myTradedProducts
            case 3:
                dataArr = otherTradedProducts
            case 4:
                dataArr = otherProducts
            default:
                dataArr = []
                
            }
            
            
            for item : HulaProduct in dataArr {
                if candidate  == item {
                    
                    let position = dataArr.index(of: item)! // ! if we are inside the condition we are guaranteed a position
                    let indexPath = IndexPath(item: position, section: 0)
                    return indexPath
                }
            }
        }
        
        return nil
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let size: CGSize
        switch collectionView.tag {
        case 1:
            size = CGSize(width: collectionView.frame.size.width, height: 122)
        case 2:
            size = CGSize(width: collectionView.frame.size.width/3, height: collectionView.frame.size.width/3)
        case 3:
            size = CGSize(width: collectionView.frame.size.width/3, height: collectionView.frame.size.width/3)
        case 4:
            size = CGSize(width: collectionView.frame.size.width, height: 122)
        default:
            size = CGSize(width: collectionView.frame.size.width, height: 122)
        }
        return size
    }
    
    
}

extension HLBarterScreenViewController: HLBarterScreenDelegate{
    func getCurrentTradeStatus() -> HulaTrade{
        let trade = HulaTrade();
        //print(myTradedProducts)
        if thisTrade.owner_id == HulaUser.sharedInstance.userId {
            // my trade
            trade.other_products = generateProductArray(from: otherTradedProducts)
            trade.owner_products = generateProductArray(from: myTradedProducts)
            
        } else {
            // other user trade
            trade.other_products = generateProductArray(from: myTradedProducts)
            trade.owner_products = generateProductArray(from: otherTradedProducts)
        }
        trade.other_agree = thisTrade.other_agree
        trade.turn_user_id = thisTrade.turn_user_id
        trade.tradeId = thisTrade.tradeId
        trade.owner_money = thisTrade.owner_money
        trade.other_money = thisTrade.other_money
        trade.owner_id = thisTrade.owner_id
        trade.other_id = thisTrade.other_id
        trade.owner_ready = thisTrade.owner_ready
        trade.other_ready = thisTrade.other_ready
        trade.num_bids = thisTrade.num_bids
        return trade
    }
    
    func isTradeMutated() -> Bool!{
        return self.didTradeMutate
    }
    
    func reloadTrade(){
        self.alreadyLoaded = false
    }
}

extension HLBarterScreenViewController: CalculatorDelegate{
    
    func amountSelected(amount:Int, side:String){
        print("Calculator amount: \(amount)")
        if (amount > 0){
            // amount valid
            let final_amount = Float(amount)
            let moneyProd = HulaProduct(id: "xmoney", name: "+$\( Int(round(final_amount)) )", image: HulaConstants.transparentImg)
            if (side == "owner"){
                if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
                    thisTrade.owner_money = final_amount
                    
                } else {
                    thisTrade.other_money = final_amount
                }
                self.myTradedProducts = removeMoneyProduct(fromProducts:self.myTradedProducts)
                self.myTradedProducts.append(moneyProd)
                self.mySelectedProductsCollection.reloadData()
            } else {
                if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
                    thisTrade.other_money = final_amount
                } else {
                    thisTrade.owner_money = final_amount
                }
                self.otherTradedProducts = removeMoneyProduct(fromProducts:self.otherTradedProducts)
                self.otherTradedProducts.append(moneyProd)
                self.otherSelectedProductsCollection.reloadData()
            }
        } else {
            // if value is 0 then remove all money
            if (side == "owner"){
                self.myTradedProducts = removeMoneyProduct(fromProducts:self.myTradedProducts)
                if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
                    thisTrade.owner_money = 0
                } else {
                    thisTrade.other_money = 0
                }
                self.mySelectedProductsCollection.reloadData()
            } else {
                self.otherTradedProducts = removeMoneyProduct(fromProducts:self.otherTradedProducts)
                if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
                    thisTrade.other_money = 0
                } else {
                    thisTrade.owner_money = 0
                }
                self.otherSelectedProductsCollection.reloadData()
            }
        }
        self.updateLiveBarter()
    }
    
    func removeMoneyProduct(fromProducts:[HulaProduct]) -> [HulaProduct]{
        var newArr:[HulaProduct] = []
        for prod in fromProducts{
            if prod.productId != "xmoney" {
                newArr.append(prod)
            }
        }
        return newArr
    }
}
