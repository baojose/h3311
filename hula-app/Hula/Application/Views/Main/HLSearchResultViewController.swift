//
//  HLSearchResultViewController.swift
//  Hula
//
//  Created by Star on 3/10/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import CoreLocation

class HLSearchResultViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var productsResultsList: UIView!
    @IBOutlet weak var noResultAlertView: UIView!
    @IBOutlet weak var screenTitle: UILabel!
    var searchByCategory: Bool = false;
    var categoryToSearch: NSDictionary = [:]
    var keywordToSearch: String = ""
    var productsResults: NSMutableDictionary = [:]
    var productsList: NSArray = []
    var foundUsersList: NSArray = []
    var usersList: NSDictionary = [:]
    var spinner: HLSpinnerUIView!
    var filteredList: [HulaProduct] = []
    var filterDistance:CGFloat = 0.0
    var filterReputation = 0
    var filterCondition = "all"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner = HLSpinnerUIView()
        self.view.addSubview(spinner)
        spinner.show(inView: self.view)
        
        initView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData(){
        
    }
    func initView(){
        noResultAlertView.isHidden = true
        if self.searchByCategory {
            var category_name = categoryToSearch.object(forKey: "name") as? String
            if (category_name == nil){
                category_name = "Category search"
            }
            screenTitle.text = NSLocalizedString(category_name!, comment: "");
        } else {
            screenTitle.text = keywordToSearch
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("getting results...")
        getSearchResults()
        if self.searchByCategory {
            HLDataManager.sharedInstance.ga("discovery_category")
        } else {
            HLDataManager.sharedInstance.ga("discovery_search")
        }
    }
    
    //#MARK: - TableViewDelegate
    /*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 48.0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.sectionHeaderHeight))
        let label = UILabel(frame: CGRect(x: 20.0, y:23.0, width: 200.0, height: 21.0))
        label.textColor = UIColor(red: 70.0/255, green: 70.0/255, blue: 70.0/255, alpha: 1.0)
        label.backgroundColor = UIColor.clear
        label.font = UIFont(name: "HelveticaNeue", size: 12.0)
        if self.searchByCategory {
            label.attributedText = commonUtils.attributedStringWithTextSpacing("CATEGORY RESULTS", 2.33)
        } else {
            label.attributedText = commonUtils.attributedStringWithTextSpacing("SEARCH RESULTS", 2.33)
        }
        view.addSubview(label)
        
        let lineLabel = UILabel(frame: CGRect(x: 0, y: tableView.sectionHeaderHeight - 1, width: tableView.frame.size.width, height: 1))
        lineLabel.backgroundColor = UIColor(red: 193.0/255, green: 193.0/255, blue: 193.0/255, alpha: 1.0)
        view.addSubview(lineLabel)
        view.backgroundColor = UIColor.white
        
        return view
    }
 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeProductCell") as! HLProductTableViewCell
        
        let product = filteredList[indexPath.row]
        
        
        //print(product)
        cell.productName.text = product.productName
        let prod_thumb = commonUtils.getThumbFor(url: product.productImage)
        cell.productImage.loadImageFromURL(urlString: prod_thumb)
        
        if product.productCategoryId == "xx_user" {
            commonUtils.circleImageView(cell.productImage);
            
            cell.productOwnerName.isHidden = true;
            cell.productTradeRate.isHidden = true;
            cell.productDistance.isHidden = true;
            cell.isMultipleTrades.isHidden = true;
            cell.productOwnerImage.isHidden = true;
        } else {
            cell.productImage.layer.cornerRadius = 0
            
            cell.productTradeRate.isHidden = false;
            cell.productDistance.isHidden = false;
            cell.productOwnerImage.isHidden = false;
            cell.productOwnerName.isHidden = false;
            
            if product.trading_count > 1 {
                cell.isMultipleTrades.isHidden = false
            } else {
                cell.isMultipleTrades.isHidden = true
            }
            
            let user_id = product.productOwner as String;
            if let user = self.usersList.object(forKey: user_id) as? NSDictionary {
                //print(user)
                cell.productOwnerName.text = user.object(forKey: "nick") as? String
                if let user_img = user.object(forKey: "image") as? String{
                    let thumb = commonUtils.getThumbFor(url: user_img)
                    cell.productOwnerImage.loadImageFromURL(urlString: thumb)
                }
                let up = user.object(forKey: "feedback_points") as? Float
                let uc = user.object(forKey: "feedback_count") as? Float
                if (up != nil) && (uc != nil) && (uc != 0) {
                    let perc_trade = round( up! / uc! * 100)
                    cell.productTradeRate.text = "\(perc_trade)%"
                } else {
                    cell.productTradeRate.text = "-"
                }
                cell.productDistance.text = "(" + commonUtils.getDistanceFrom(loc: product.productLocation) + ")"
                /*
                if let loc = user.object(forKey: "location") as? [Float]{
                    let userloc = CLLocation(latitude: Double( loc[0]), longitude:  Double(loc[1]) )
                    
                } else {
                    cell.productDistance.text = "-"
                }
 */
            }
            
            commonUtils.circleImageView(cell.productOwnerImage)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let product = filteredList[indexPath.row]
        
        if product.productCategoryId == "xx_user" {
            // not a product, but a user!!!
            HLDataManager.sharedInstance.getUserProfile(userId: product.productId, taskCallback: {(user, prods, userfeedback) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let myModalViewController = storyboard.instantiateViewController(withIdentifier: "sellerInfoPage") as! HLSellerInfoViewController
                myModalViewController.user = user
                myModalViewController.userProducts = prods
                myModalViewController.userFeedback = userfeedback
                self.navigationController?.pushViewController(myModalViewController, animated: true)
            });
        } else {
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "productDetailPage") as! HLProductDetailViewController
            
            viewController.productData = product
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private var finishedLoadingInitialTableCells = false
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var lastInitialDisplayableCell = false
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if filteredList.count > 0 && !finishedLoadingInitialTableCells {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                lastInitialDisplayableCell = true
            }
        }
        if !finishedLoadingInitialTableCells {
            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }
            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: 0, y: tableView.rowHeight/2)
            cell.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0.05*Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    
    
    
    // Custom functions for ViewController
    func getSearchResults() {
        var queryURL: String = ""
        if self.searchByCategory {
            var category_id = categoryToSearch.object(forKey: "_id") as? String
            if (category_id == nil){
                category_id = ""
            }
            queryURL = HulaConstants.apiURL + "products/category/" + category_id!
        } else {
            
            let encodedKw = keywordToSearch.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            //let lat = HulaUser.sharedInstance.location.coordinate.latitude;
            //let lng = HulaUser.sharedInstance.location.coordinate.longitude;
            queryURL = HulaConstants.apiURL + "products/search/" + encodedKw!;
            
        }
        print(queryURL)
        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
            if (ok){
                DispatchQueue.main.async {
                    if let dictionary = json as? [String: Any] {
                        self.spinner.hide()
                        print(dictionary)
                        if let products = dictionary["products"] as? NSArray {
                            //print(products)
                            self.productsList = products
                            if let ful = dictionary["found_users"] as? NSArray {
                                self.foundUsersList = ful;
                            } else {
                                self.foundUsersList = [];
                            }
                        }
                        if let users = dictionary["users"] as? NSDictionary {
                            //print(products)
                            self.usersList = users 
                        }
                        
                    }
                    self.getFilteredList()
                    self.productsTableView.reloadData()
                    if (self.filteredList.count == 0){
                        self.productsTableView.isHidden = true
                    } else {
                        self.productsTableView.isHidden = false
                    }
                }
            } else {
                // connection error
                print("Connection error")
            }
        })
    }
    
    func getFilteredList(){
        filteredList = []
        for prod in (productsList as? [NSDictionary])!{
            let hprod = HulaProduct()
            var isValidCond = false
            var isValidDist = false
            var isValidRep = false
            var isValidUser = false
            hprod.populate(with: prod)
            
            if filterCondition == "all" || hprod.productCondition == filterCondition{
                isValidCond = true
            }
            
            
            if filterReputation == 0 {
                isValidRep = true
            }
            
            
            if filterDistance == 0.0 || commonUtils.getCGDistanceFrom(loc: hprod.productLocation) < filterDistance {
                isValidDist = true
            }
            
            if hprod.productOwner != HulaUser.sharedInstance.userId {
                // remove my products from the list
                isValidUser = true
            }
            
            if(isValidCond && isValidRep && isValidDist && isValidUser){
                filteredList.append(hprod)
            }
            
        }
        
        print(filteredList)
        filteredList.sort { $0.distance < $1.distance  }
        print(filteredList)
        
        for us in (foundUsersList as? [NSDictionary])!{
            let hprod = HulaProduct()
            hprod.productName = String(NSLocalizedString("User", comment: "")) + ": " + (us["name"] as! String)
                + "\n(" + (us["nick"] as! String) + ")";
            hprod.productDescription = us["nick"] as! String;
            hprod.productImage = us["image"] as! String;
            hprod.productId = us["_id"] as! String;
            hprod.productCategoryId = "xx_user";
            filteredList.append(hprod)
        }
        
        
        
        //print(filteredList)
        productsTableView.reloadData()
    }
    
    @IBAction func showFiltersAction(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "filterPage") as! HLFilterViewController
        viewController.filterDelegate = self
        viewController.preselDistance = filterDistance
        viewController.preselRep = filterReputation
        viewController.preselCondition = filterCondition
        self.present(viewController, animated: true) { 
            // nada
        }
        
    }
    
    
}
extension HLSearchResultViewController: FiltersDelegate{
    
    func filtersChanged(distance:Int, reputation:Int, condition:String){
        //print("filters changed")
        //print("dist \(distance)")
        //print("rep \(reputation)")
        //print("cond \(condition)")
        //print("filter changed")
        filterDistance = CGFloat(distance)
        filterReputation = reputation
        filterCondition = condition
        getFilteredList()
    }
}
