//
//  HLFilterViewController.swift
//  Hula
//
//  Created by Star on 3/10/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLFilterViewController: BaseViewController {

    var filterDelegate: FiltersDelegate?
    var currDistance = 1
    var currRep = 6
    var currCondition = 12
    
    var preselDistance: CGFloat = 0.0
    var preselRep: Int = 0
    var preselCondition: String = "all"
    
    //@IBOutlet weak var publishBtn: HLRoundedGradientNextButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        HLDataManager.sharedInstance.ga("discovery_filters")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initData() {
        
    }
    func initView() {
        //print("dist \(preselDistance)")
        //print("rep \(preselRep)")
        //print("cond \(preselCondition)")
        self.changeDistanceFilterButtonSelctedState( getTagForDistance(preselDistance) )
        self.changeTradeFilterButtonSelctedState( getTagForRep(preselRep)  )
        self.changeConditionFilterButtonSelctedState( getTagForCond(preselCondition) )
        
    }
    
    
    
    
    
    
    // IB Actions
    @IBAction func distanceFilterOptionBtnClicked(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        self.changeDistanceFilterButtonSelctedState(button.tag)
        
    }
    @IBAction func tradeFilterOptionBtnClicked(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        self.changeTradeFilterButtonSelctedState(button.tag)
        
    }
    @IBAction func conditionOptionBtnClicked(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        self.changeConditionFilterButtonSelctedState(button.tag)
        
    }
    
    
    
    
    
    // Custom functions for ViewController
    
    func changeDistanceFilterButtonSelctedState(_ index: Int!) {
        for i in 1 ..< 6 {
            let button: UIButton! = self.view.viewWithTag(i) as? UIButton
            if (index == Int(i)) {
                button.backgroundColor = HulaConstants.appMainColor
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 0.0, UIColor.clear, button.frame.size.height / 2.0)
                currDistance = index
            }else{
                button.backgroundColor = UIColor.white
                button.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 1.0, HulaConstants.appMainColor, button.frame.size.height / 2.0)
            }
        }
        filterDelegate?.filtersChanged(distance: getDistanceForTag(currDistance), reputation: getRepForTag(currRep), condition: getCondForTag(currCondition))
    }
    
    func getDistanceForTag(_ ind:Int) -> Int{
        var d:Int = 0
        switch ind {
        case 1:
            d = 5;
        case 2:
            d = 10;
        case 3:
            d = 20;
        case 4:
            d = 50;
        case 5:
            d = 0;
        default:
            d = 0
        }
        return d
    }
    func getTagForDistance(_ val:CGFloat) -> Int{
        var d: Int = 0
        switch val {
        case 5:
            d = 1;
        case 10:
            d = 2;
        case 20:
            d = 3;
        case 50:
            d = 4;
        case 0:
            d = 5;
        default:
            d = 5
        }
        return d
    }
    
    func getRepForTag(_ ind:Int) -> Int{
        var d:Int = 0
        switch ind {
        case 6:
            d = 0;
        case 7:
            d = 80;
        case 8:
            d = 85;
        case 9:
            d = 90;
        case 10:
            d = 95;
        case 11:
            d = 99;
        default:
            d = 0
        }
        return d
    }
    
    func getTagForRep(_ val:Int) -> Int{
        var d: Int = 0
        switch val {
        case 0:
            d = 6;
        case 80:
            d = 7;
        case 85:
            d = 8;
        case 90:
            d = 9;
        case 95:
            d = 10;
        default:
            d = 6
        }
        return d
    }
    
    
    
    func getCondForTag(_ ind:Int) -> String{
        var d:String = "all"
        switch ind {
        case 12:
            d = "new";
        case 13:
            d = "used";
        case 14:
            d = "all";
        default:
            d = "all";
        }
        return d
    }
    
    func getTagForCond(_ val:String) -> Int{
        var d: Int = 0
        switch val {
        case "new":
            d = 12;
        case "used":
            d = 13;
        case "all":
            d = 14;
        default:
            d = 14
        }
        return d
    }
    
    
    
    
    func changeTradeFilterButtonSelctedState(_ index: Int!) {
        for i in 6 ..< 12 {
            let button: UIButton! = self.view.viewWithTag(i) as? UIButton
            if (index == Int(i)) {
                button.backgroundColor = HulaConstants.appMainColor
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 0.0, UIColor.clear, button.frame.size.height / 2.0)
                currRep = index
            }else{
                button.backgroundColor = UIColor.white
                button.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 1.0, HulaConstants.appMainColor, button.frame.size.height / 2.0)
            }
        }
        filterDelegate?.filtersChanged(distance: getDistanceForTag(currDistance), reputation: getRepForTag(currRep), condition: getCondForTag(currCondition))
    }
    func changeConditionFilterButtonSelctedState(_ index: Int!) {
        for i in 12 ..< 15 {
            let button: UIButton! = self.view.viewWithTag(i) as? UIButton
            if (index == Int(i)) {
                button.backgroundColor = HulaConstants.appMainColor
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 0.0, UIColor.clear, button.frame.size.height / 2.0)
                
                currCondition = index
            }else{
                button.backgroundColor = UIColor.white
                button.setTitleColor(HulaConstants.appMainColor, for: UIControlState.normal)
                commonUtils.setRoundedRectBorderButton(button, 1.0, HulaConstants.appMainColor, button.frame.size.height / 2.0)
            }
        }
        filterDelegate?.filtersChanged(distance: getDistanceForTag(currDistance), reputation: getRepForTag(currRep), condition: getCondForTag(currCondition))
    }
}


protocol FiltersDelegate{
    func filtersChanged(distance:Int, reputation:Int, condition:String)
}
