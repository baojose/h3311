//
//  HLProductEditTextViewController.swift
//  Hula
//
//  Created by Juan Searle on 30/07/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLProductEditTextViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var currentTextLabel: UILabel!
    @IBOutlet weak var editableTextView: UITextView!
    @IBOutlet weak var editPageTitleLabel: UILabel!
    @IBOutlet weak var lineSeparator: UILabel!
    @IBOutlet weak var conditionNewBtn: UIButton!
    @IBOutlet weak var conditionUsedBtn: UIButton!
    
    @IBOutlet weak var conditionSelectorView: UIView!
    @IBOutlet weak var categoryTableView: UITableView!
    
    
    @IBOutlet weak var saveButton: HLBouncingButton!
    var product:HulaProduct = HulaProduct()
    var originalText: String = ""
    var label: String = ""
    var item: String = ""
    var pageTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        switch(item){
        case "title":
            categoryTableView.isHidden = true
            conditionSelectorView.isHidden = true
        case "description":
            categoryTableView.isHidden = true
            conditionSelectorView.isHidden = true
        case "category":
            conditionSelectorView.isHidden = true
        case "condition":
            categoryTableView.isHidden = true
        default:
            break
        }
        
        
        editPageTitleLabel.text = pageTitle
        currentTextLabel.text = NSLocalizedString("CURRENT:", comment: "") + " \(originalText)"
        editableTextView.text = originalText
        if (self.product.productCondition == "new"){
            setBtnStatus(button:conditionNewBtn, selected:true)
            setBtnStatus(button:conditionUsedBtn, selected:false)
        } else {
            setBtnStatus(button:conditionNewBtn, selected:false)
            setBtnStatus(button:conditionUsedBtn, selected:true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        editableTextView.becomeFirstResponder()
        textViewDidChange(editableTextView)
        
        HLDataManager.sharedInstance.ga("product_edit")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func saveAction(_ sender: Any) {
        switch(item){
        case "title":
            product.productName = editableTextView.text
        case "description":
            product.productDescription = editableTextView.text
        default:
            break
        }
        product.updateServerData()
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func conditionUsedAction(_ sender: Any) {
        changeConditionState("used")
    }
    @IBAction func conditionNewAction(_ sender: Any) {
        changeConditionState("new")
    }
    
    func textViewDidChange(_: UITextView){
        let w = self.view.frame.size.width-30
        let h = commonUtils.heightString(width: w, font: editableTextView.font! , string: editableTextView.text) + 40
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.editableTextView.frame.size = CGSize(width: self.view.frame.size.width-30, height: h)
            self.lineSeparator.frame.origin.y = self.editableTextView.frame.origin.y + h + 15
            self.saveButton.frame.origin.y = self.lineSeparator.frame.origin.y + 30
        }, completion: nil)
        
    }
    
    
    func changeConditionState(_ mode: String){
        if mode == "new" {
            self.product.productCondition = "new"
            setBtnStatus(button:conditionNewBtn, selected:true)
            setBtnStatus(button:conditionUsedBtn, selected:false)
        } else if mode == "used" {
            self.product.productCondition = "used"
            setBtnStatus(button:conditionNewBtn, selected:false)
            setBtnStatus(button:conditionUsedBtn, selected:true)
        }
        product.updateServerData()
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func setBtnStatus(button:UIButton, selected:Bool){
        if selected{
            button.backgroundColor = HulaConstants.appMainColor
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(button, 0.0, UIColor.clear, button.frame.size.height / 2.0)
        } else {
            button.backgroundColor = UIColor.white
            button.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(button, 1.0, HulaConstants.appMainColor, button.frame.size.height / 2.0)
        }
    }
}

extension HLProductEditTextViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 60.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.arrCategories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "completeProductProfileCategoryCell") as! HLHomeCategoryTableViewCell
        let category : NSDictionary = dataManager.arrCategories.object(at: indexPath.row) as! NSDictionary
        
        cell.categoryName.attributedText = commonUtils.attributedStringWithTextSpacing(category.object(forKey: "name") as! String, CGFloat(2.33))
        cell.categoryImage.image = UIImage.init(named: category.object(forKey: "icon") as! String)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let category : NSDictionary = dataManager.arrCategories.object(at: indexPath.row) as! NSDictionary
        product.productCategory = category.object(forKey: "name") as! String
        product.productCategoryId = category.object(forKey: "_id") as! String
        product.updateServerData()
        let _ = self.navigationController?.popViewController(animated: true)
    }
}
