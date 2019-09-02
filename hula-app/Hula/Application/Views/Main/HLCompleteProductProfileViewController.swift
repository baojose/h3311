//
//  HLCompleteProductProfileViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLCompleteProductProfileViewController: BaseViewController, UIScrollViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var productNameFld: UITextField!
    @IBOutlet var perkScrollView: UIScrollView!
    @IBOutlet var desciptionTxtField: UITextField!
    @IBOutlet var conditionNewBtn: UIButton!
    @IBOutlet var conditionUsedBtn: UIButton!
    @IBOutlet weak var doneBtn: HLRoundedGradientButton!
    
    @IBOutlet weak var charactersRemainingLabel: UILabel!
    @IBOutlet weak var conditionGroup: UIView!
    
    @IBOutlet weak var productReferenceImage: UIImageView!
    var productCondition:String = "new"
    var productImage:UIImage!
    var currentMode:Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        HLDataManager.sharedInstance.ga("product_complete")
    }
    
    func initData(){
        
    }
    func initView(){
        
        commonUtils.circleImageView(productReferenceImage)
        if productImage != nil{
            productReferenceImage.image = productImage
        } else{
            productReferenceImage.loadImageFromURL(urlString: HLDataManager.sharedInstance.newProduct.productImage)
        }
        pageTitleLabel.attributedText = commonUtils.attributedStringWithTextSpacing(pageTitleLabel.text!, 2.33)

        
        self.changeConditionState(conditionNewBtn.tag)
        
        //doneBtn.setup()
        desciptionTxtField.addTarget(self, action: #selector(textchange(_:)), for: UIControlEvents.editingChanged)
        let tapGesture: UITapGestureRecognizer! = UITapGestureRecognizer.init(target: self, action: #selector(onTapScreen))
        self.view.addGestureRecognizer(tapGesture)
        
        //perkScrollView.contentSize = CGSize(width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height+130)
        print("Cat: \(dataManager.newProduct.productCategoryId)");
        print("Cat: \(dataManager.newProduct.productCategory)");
        if dataManager.newProduct.productCategoryId! == "59124d47a0716d0938e9276c" {
            // service product. No need to set as used or new
            conditionGroup.isHidden = true;
        } else {
            conditionGroup.isHidden = false;
        }
    }
    
    @IBAction func newConditionClicked(_ sender: UIButton!) {
        self.changeConditionState(sender.tag)
    }
    @IBAction func usedConditionClicked(_ sender: UIButton) {
        self.changeConditionState(sender.tag)
    }
    func changeConditionState(_ mode: Int!){
        if mode == 10 {
            productCondition = "new"
            conditionNewBtn.backgroundColor = HulaConstants.appMainColor
            conditionNewBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionNewBtn, 0.0, UIColor.clear, conditionNewBtn.frame.size.height / 2.0)
            conditionUsedBtn.backgroundColor = UIColor.white
            conditionUsedBtn.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionUsedBtn, 1.0, HulaConstants.appMainColor, conditionUsedBtn.frame.size.height / 2.0)
        }else if mode == 20{
            productCondition = "used"
            conditionUsedBtn.backgroundColor = HulaConstants.appMainColor
            conditionUsedBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionUsedBtn, 0.0, UIColor.clear, conditionUsedBtn.frame.size.height / 2.0)
            conditionNewBtn.backgroundColor = UIColor.white
            conditionNewBtn.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
            commonUtils.setRoundedRectBorderButton(conditionNewBtn, 1.0, HulaConstants.appMainColor, conditionNewBtn.frame.size.height / 2.0)
        }
    }
    func onTapScreen(){
        desciptionTxtField.resignFirstResponder()
        perkScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
    //#MARK - TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return true
    }
    func textchange(_ textField:UITextField) {
        self.changeDoneBtnState(textField.text!)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        perkScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
        return textField.resignFirstResponder()
    }
    func changeDoneBtnState(_ string: String){
        let charCount = string.count
        if string.count != 0  {
            doneBtn.isEnabled = true
            doneBtn.alpha = 1
            //doneBtn.startAnimation()
            //print("Is enabled")
        }else{
            doneBtn.isEnabled = false
            doneBtn.alpha = 0.5
            //doneBtn.stopAnimation()
        }
        
        var theRemainingChars = 200 - charCount
        if (theRemainingChars < 1){
            let str = self.desciptionTxtField.text!
            let index = str.index(str.startIndex, offsetBy: 200)
            desciptionTxtField.text = str.substring(to: index)
            theRemainingChars = 0
        }
        charactersRemainingLabel.text = "\(theRemainingChars) " + NSLocalizedString("characters remaining", comment: "")
    }
    
    @IBAction func doneBtnPRessed(_ sender: Any) {
        //print("Complete button pressed")
        //if (dataManager.newProduct.arrProductPhotoLink.count>0 || dataManager.newProduct.productImage != ""){
            dataManager.newProduct.productDescription = desciptionTxtField.text
            dataManager.newProduct.productName = productNameFld.text
            dataManager.newProduct.productCondition = productCondition
            dataManager.uploadMode = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadModeUpdateDesign"), object: nil)
            self.dismiss(animated: true, completion: nil)
        //} else {
            //print("Images still uploading...")
        //}
    }
    
}
