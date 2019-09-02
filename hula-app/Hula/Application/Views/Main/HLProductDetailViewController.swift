//
//  HLProductDetailViewController.swift
//  Hula
//
//  Created by Star on 3/10/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import MapKit

class HLProductDetailViewController: BaseViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var productMainDetailView: UIView!
    @IBOutlet var sellerView: UIView!
    @IBOutlet var productTableView: UITableView!
    @IBOutlet var addToTradeBtn: UIButton!
    @IBOutlet weak var addToTradeBg: UIImageView!
    @IBOutlet weak var productDistance: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productCondition: UILabel!
    
    @IBOutlet weak var tradeWithUserButton: UIButton!
    @IBOutlet weak var addToTradeViewContainer: UIView!
    @IBOutlet var productsScrollView: UIScrollView!
    @IBOutlet var productNameLabel: UILabel!
    @IBOutlet var productDescriptionLabel: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var sellerImageView: UIImageView!
    @IBOutlet var sellerNameLabel: UILabel!
    @IBOutlet var sellerFeedbackLabel: UILabel!

    @IBOutlet var sellerLabel: UILabel!
    @IBOutlet var userInventoryLabel: UILabel!
    
    
    var productData: HulaProduct!
    var currentProduct: HulaProduct!
    var sellerProducts: NSArray! = []
    var sellerFeedback: NSArray! = []
    var sellerUser: HulaUser!
    
    
    var initialTradeFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.addToTradeViewContainer.frame.size.height = 60
        UIView.animate(withDuration: 0.3) {
            self.addToTradeViewContainer.frame = CGRect(x: 0, y: self.view.frame.height - 120, width: self.view.frame.width, height: 60)
        }
        HLDataManager.sharedInstance.ga("discovery_product")
        
        var tabbarHeight : CGFloat = 50
        if Device.IS_IPHONE_X {
            tabbarHeight = 84
        }
        addToTradeViewContainer.frame.origin.y = self.view.frame.height - addToTradeViewContainer.frame.height - tabbarHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initData() {
        //print(productData);
        //print(productData);
        currentProduct = productData
        
        sellerUser = HulaUser()
    }
    func initView() {
        var newFrame: CGRect! = productTableView.frame
        newFrame.size.height = CGFloat(sellerProducts.count) * 129.0;
        productTableView.frame = newFrame
        
        
        tradeWithUserButton.layer.cornerRadius = 19
        tradeWithUserButton.layer.borderColor = UIColor.white.cgColor
        tradeWithUserButton.layer.borderWidth = 1.0
        
        
        // product details
        productNameLabel.text = currentProduct.productName
        productDescriptionLabel.text = currentProduct.productDescription
        productCategory.text = NSLocalizedString(currentProduct.productCategory, comment: "")
        productCondition.text = NSLocalizedString(currentProduct.productCondition, comment: "").capitalized
        productDistance.text = commonUtils.getDistanceFrom(loc: sellerUser.location)

        
        // item height and position reset
        let h = commonUtils.heightString(width: productDescriptionLabel.frame.width, font: productDescriptionLabel.font! , string: productDescriptionLabel.text!) + 30
        productDescriptionLabel.frame.size = CGSize(width: productDescriptionLabel.frame.size.width, height: h)
        sellerView.frame.origin.y = productDescriptionLabel.frame.origin.y + productDescriptionLabel.frame.size.height
        
        
        
        
        productTableView.frame.origin.y = sellerView.frame.origin.y + sellerView.frame.size.height
        
        mainScrollView.contentSize = CGSize(width: 0, height: productTableView.frame.origin.y + productTableView.frame.size.height + 100)
        
        // seta product images
        self.setUpProductImagesScrollView()
        
        // product owner image
        sellerLabel.attributedText = commonUtils.attributedStringWithTextSpacing(NSLocalizedString("SELLER", comment: ""), 2.33)
        commonUtils.circleImageView(sellerImageView)
        sellerImageView.loadImageFromURL(urlString: HulaConstants.apiURL + "users/" + currentProduct.productOwner + "/image")
        
        
        // user inventory
        userInventoryLabel.attributedText = commonUtils.attributedStringWithTextSpacing(NSLocalizedString("USER'S INVENTORY", comment: ""), 2.33)
        
        
        // start bartering item button
        //commonUtils.setRoundedRectBorderButton(addToTradeBtn, 1.0, UIColor.white, addToTradeBtn.frame.size.height / 2.0)
        
        HLDataManager.sharedInstance.getUserProfile(userId: currentProduct.productOwner, taskCallback: {(user, prods, userfeedback) in
            self.sellerUser = user
            self.sellerFeedback = userfeedback
            self.sellerNameLabel.text = user.userNick;
            if HLDataManager.sharedInstance.amITradingWith(user.userId){
                self.tradeWithUserButton.setTitle(NSLocalizedString("Currently trading with", comment: "") + " \(user.userNick!)", for: .normal)
            } else {
                self.tradeWithUserButton.setTitle(NSLocalizedString("Trade with", comment: "") + " \(user.userNick!)", for: .normal)
            }
            self.sellerFeedbackLabel.text = user.getFeedback();
            self.sellerProducts = prods
            var newFrame: CGRect! = self.productTableView.frame
            newFrame.size.height = (CGFloat(self.sellerProducts.count) * 129.0);
            //print(newFrame.size.height)
            print(self.sellerUser.location)
            self.productDistance.text = self.commonUtils.getDistanceFrom(loc: self.sellerUser.location)
            
            self.productTableView.frame = newFrame
            self.mainScrollView.contentSize = CGSize(width: 0, height: self.productTableView.frame.origin.y + self.productTableView.frame.size.height + 100)
            self.productTableView.reloadData()
        })
        
        // button visible only on other users
        if (currentProduct.productOwner == HulaUser.sharedInstance.userId){
            // this is my own product, so i cannot swapp it with me
            addToTradeViewContainer.isHidden = true
        } else {
            addToTradeViewContainer.isHidden = false
        }
    }
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sellerProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeProductCell") as! HLProductTableViewCell
        
        if let pr = sellerProducts[indexPath.row] as? [String:Any] as NSDictionary?{
        
            cell.productName.text = pr.object(forKey: "title") as? String
            
            
            
            if let im_ur = pr.object(forKey: "image_url") as? String {
                let thumb = commonUtils.getThumbFor(url: im_ur)
                cell.productImage.loadImageFromURL(urlString:thumb)
            } else {
                cell.productImage.loadImageFromURL(urlString: HulaConstants.noProductThumb)
            }
            
            if let st = pr.object(forKey: "status") as? String{
                if st == "traded"{
                    cell.tradedAlertImage.isHidden = false
                    cell.tradedLabel.isHidden = false
                    cell.goArrow.isHidden = true
                    cell.isUserInteractionEnabled = false
                } else {
                    cell.tradedAlertImage.isHidden = true
                    cell.tradedLabel.isHidden = true
                    cell.goArrow.isHidden = false
                    cell.isUserInteractionEnabled = true
                    
                    
                    if let prid = pr.object(forKey: "_id") as? String {
                        if (prid == productData.productId){
                            cell.goArrow.isHidden = true
                            cell.isUserInteractionEnabled = false
                        }
                    }
                    
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //print("selected")
        //print(indexPath.row)
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "productDetailPage") as! HLProductDetailViewController
        
        let product = sellerProducts[indexPath.row] as! NSDictionary
        let hproduct = HulaProduct();
        hproduct.populate(with: product)
        if hproduct.productStatus != "traded" {
            viewController.productData = hproduct
        
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if (scrollView == productsScrollView) {
            let xPos = productsScrollView.contentOffset.x / productsScrollView.frame.size.width
            pageControl.currentPage = Int(xPos)
        }
    }
    
    
    
    // Custom functions for ViewController
    
    
    func setUpProductImagesScrollView() {
        var num_images: CGFloat = 0;
        if let img_arr = currentProduct.arrProductPhotoLink {
            //print(img_arr)
            for i in 0 ..< img_arr.count {
                let img_url = img_arr[i]
                if (img_url.count > 0){
                    let imageFrame = CGRect(x: (CGFloat)(i) * productsScrollView.frame.size.width, y: 0, width: productsScrollView.frame.size.width, height: productsScrollView.frame.size.height)
                    let imgView: UIImageView! = UIImageView.init(frame: imageFrame)
                    //commonUtils.loadImageOnView(imageView: imgView, withURL: img_url)
                    imgView.loadImageFromURL(urlString: img_url)
                    //imgView.image = UIImage(named: "temp_product")
                    imgView.contentMode = .scaleAspectFill
                    imgView.clipsToBounds = true
                    productsScrollView.addSubview(imgView)
                    num_images += 1
                }
                
            }
        }
        productsScrollView.contentSize = CGSize(width: num_images * productsScrollView.frame.size.width, height: 0.0)
        pageControl.numberOfPages = Int(num_images)
        pageControl.currentPage = 0
        productsScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    func insertIfAvailable(label: UILabel, maybeText: Any){
        if let tx = maybeText as? String {
            label.text = tx
        }
    }
    
    @IBAction func gotoUserPage(_ sender: Any) {
        print("Going to user...")
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "sellerInfoPage") as! HLSellerInfoViewController
        
        viewController.user = self.sellerUser
        viewController.userProducts = self.sellerProducts
        viewController.userFeedback = self.sellerFeedback
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addToTradeAction(_ sender: UIButton) {
        
        if !HulaUser.sharedInstance.isUserLoggedIn() {
            //print( self.tabBarController )
            
            if let tb = self.tabBarController as? BaseTabBarViewController {
                tb.openUserIdentification()
            }
            print("User is not logged in!")
                
            return
                
        }
        
        
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
        
        if let btTitle = sender.titleLabel?.text {
            if btTitle.range(of: NSLocalizedString("Currently trading", comment: "")) != nil {
                if let pnc = self.navigationController?.navigationController as? HulaPortraitNavigationController {
                    pnc.openSwapView()
                    return
                }
            }
        }
        
        self.present(viewController, animated: true)
    }
    
    
   /*
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if productsScrollView == scrollView {
            let page: Int = Int(round(productsScrollView.contentOffset.x / productsScrollView.frame.width))
            pageControl.currentPage = page
        }
    }
    */
    
    @IBAction func productOptionsAction(_ sender: Any) {
                let alert = UIAlertController(title: NSLocalizedString("Product options", comment: ""),
                                              message: nil,
                                              preferredStyle: .actionSheet)
        
                
                
                let removeAction = UIAlertAction(title: NSLocalizedString("Add product to barter screen", comment: ""), style: .default, handler: { action -> Void in
                    self.addToTradeAction( UIButton() )
                })
                alert.addAction(removeAction)
        
                let reportAction = UIAlertAction(title: NSLocalizedString("Report this product as abusive", comment: ""), style: .destructive, handler: { action -> Void in
                    
                    self.reportProduct()
                    
                })
                alert.addAction(reportAction)
        
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                alert.addAction(cancelAction)
                self.present(alert, animated: true)
    }
    
    func reportProduct(){
        let queryURL = HulaConstants.apiURL + "products/report/\(currentProduct.productId!)"
        print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                //print(json!)
                DispatchQueue.main.async {
                    
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                    
                    viewController.delegate = self
                    viewController.isCancelVisible = false
                    viewController.trigger = "report"
                    viewController.message = NSLocalizedString("The product has been reported. We will review this content and take necessary actions. Thanks for keeping Hula trustworthy.", comment: "")
                    
                    self.present(viewController, animated: true)
                    
                    
                }
            } else {
                // connection error
                print("Connection error")
            }
        })
    }
}

extension HLProductDetailViewController: AlertDelegate{
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
            if (currentProduct.productOwner != HulaUser.sharedInstance.userId) {
                
                if let productId = currentProduct.productId {
                    //print(productId)
                    let otherId = currentProduct.productOwner
                    if (HulaUser.sharedInstance.userId.count>0){
                        // user is loggedin
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.5, animations: {
                                self.addToTradeViewContainer.frame.size.height = self.view.frame.height
                                self.addToTradeViewContainer.frame.origin.y = 0
                                //print(self.addToTradeViewContainer.frame)
                                //self.addToTradeViewContainer.layoutIfNeeded()
                            })
                        }
                        let queryURL = HulaConstants.apiURL + "trades/"
                        let dataString:String = "product_id=\(productId)&other_id=\(otherId!)"
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
        }
    }
}
