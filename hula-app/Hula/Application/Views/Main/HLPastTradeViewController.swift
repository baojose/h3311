//
//  HLPastTradeViewController.swift
//  Hula
//
//  Created by Juan Searle on 07/10/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLPastTradeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var otherSelectedProductsCollection: UICollectionView!
    @IBOutlet weak var mySelectedProductsCollection: UICollectionView!
    
    @IBOutlet weak var myClosedView: UIImageView!
    @IBOutlet weak var otherClosedView: UIImageView!
    
    
    var currTrade: NSDictionary!
    var thisTrade: HulaTrade = HulaTrade()
    var otherProducts: [HulaProduct] = []
    var myProducts: [HulaProduct] = []
    var myTradedProducts: [HulaProduct] = []
    var otherTradedProducts: [HulaProduct] = []
    var otherUserId: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadProductsArrays()
        //print (thisTrade)
        let lastUpdate = thisTrade.last_update as NSDate
        dateLabel.text = CommonUtils.sharedInstance.timeAgoSinceDate(date: lastUpdate, numericDates: false)
        var tradeStatus = NSLocalizedString("Exchange completed", comment: "")
        //print(thisTrade.status)
        if (thisTrade.status == HulaConstants.cancel_status){
            tradeStatus = NSLocalizedString("Trade canceled", comment: "")
        }
        if (thisTrade.status == HulaConstants.review_status){
            tradeStatus = NSLocalizedString("Close the deal", comment: "")
            dateLabel.text = NSLocalizedString("We recommend confirming this trade only after exchanging stuff", comment: "")
        }
        mainLabel.text = tradeStatus
        
        // hide both check views
        myClosedView.isHidden = true
        otherClosedView.isHidden = true
        
        if (thisTrade.owner_id == HulaUser.sharedInstance.userId){
            // i am the trade owner
            if thisTrade.owner_accepted {
                myClosedView.isHidden = false
            }
            if thisTrade.other_accepted {
                otherClosedView.isHidden = false
            }
        } else {
            // i am NOT the trade owner
            if thisTrade.owner_accepted {
                otherClosedView.isHidden = false
            }
            if thisTrade.other_accepted {
                myClosedView.isHidden = false
            }
        }
        
        
        
        
        if let swappPageVC = self.parent as? HLSwappPageViewController{
            if let thisHolderScreen = swappPageVC.parent as? HLSwappViewController {
                thisHolderScreen.barterDelegate = self
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        HLDataManager.sharedInstance.ga("past_trades")
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return myTradedProducts.count
        case 2:
            return otherTradedProducts.count
        default:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HLProductCollectionViewCell
        
        let product:HulaProduct
        switch collectionView.tag {
        case 1:
            product = myTradedProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell_1", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "left"
            cell.type = "select"
        case 2:
            product = otherTradedProducts[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell_2", for: indexPath) as! HLProductCollectionViewCell
            cell.side = "right"
            cell.type = "select"
        default:
            print("Error: no product found")
            product = HulaProduct(id : "nada", name : "Test product", image: "https://api.hula.trading/v1/products/59400e5ce8825609f281bc68/image")
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productcell4", for: indexPath) as! HLProductCollectionViewCell
        }
        
        cell.label.text = product.productName
        
        let thumb = CommonUtils.sharedInstance.getThumbFor(url: product.productImage)
        cell.image.loadImageFromURL(urlString: thumb)
        
        cell.isHidden = false
        return cell

    }
    
    
    func loadProductsArrays(){
        var mtp:[String] = []
        var otp:[String] = []
        thisTrade.loadFrom(dict: currTrade!)
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
        
        self.myTradedProducts = []
        self.otherTradedProducts = []
        self.populateTradedProducts(list:otp, type:"other")
        self.populateTradedProducts(list:mtp, type:"owner")

    }
    
    func populateTradedProducts(list: [String], type: String){
        //print(thisTrade.last_bid_diff)
        for pr_id in list{
            getProduct(productId: pr_id, taskCallback: { (product) in
                DispatchQueue.main.async {
                    if (type == "other") {
                        self.otherTradedProducts.append(product)
                        self.otherSelectedProductsCollection.reloadData()
                    } else {
                        self.myTradedProducts.append(product)
                        self.mySelectedProductsCollection.reloadData()
                    }
                }
            })
            
        }
        
        
        switch type {
        case "other":
            if thisTrade.other_money > 0 {
                let moneyProd = HulaProduct(id: "xmoney", name: "+$\(Int(round(thisTrade.other_money)))", image: HulaConstants.transparentImg)
                self.otherTradedProducts.append(moneyProd)
                self.otherSelectedProductsCollection.reloadData()
            }
        default:
            
            if thisTrade.owner_money > 0 {
                let moneyProd = HulaProduct(id: "xmoney", name: "+$\( Int(round(thisTrade.owner_money)) )", image: HulaConstants.transparentImg)
                self.myTradedProducts.append(moneyProd)
                self.mySelectedProductsCollection.reloadData()
            }
        }
        
    }
    
    
    
    func getProduct(productId: String, taskCallback: @escaping (HulaProduct) -> ()) {
        //print("Getting user info...")
        if (HulaUser.sharedInstance.userId.count>0){
            let product: HulaProduct = HulaProduct()
            let queryURL = HulaConstants.apiURL + "products/" + productId
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                if (ok){
                    DispatchQueue.main.async {
                        //print(dictionary)
                        
                        //print(self.thisTrade.last_bid_diff)
                        if let pr = json as? NSDictionary{
                            product.populate(with: pr as NSDictionary)
                        
                        }
                        taskCallback(product)
                    }
                } else {
                    // connection error
                    taskCallback(product)
                }
            })
        }
    }
}

extension HLPastTradeViewController: HLBarterScreenDelegate{
    func getCurrentTradeStatus() -> HulaTrade{
        return self.thisTrade
    }
    
    func isTradeMutated() -> Bool!{
        return false
    }
    
    func reloadTrade(){
        
    }
}
