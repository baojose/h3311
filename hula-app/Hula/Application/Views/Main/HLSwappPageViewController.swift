//
//  HLSwappViewController.swift
//  Hula
//
//  Created by Juan Searle on 13/06/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLSwappPageViewController: UIPageViewController {
    
    weak var swappDelegate: SwappPageViewControllerDelegate?
    var currentTrade: NSDictionary?
    var arrTrades: [NSDictionary] = []
    var arrPastTrades: [NSDictionary] = []
    var currentIndex: Int = 0
    
    var orderedViewControllers: [UIViewController] = [UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "dashboard"),
                UIStoryboard(name: "Main", bundle: nil) .
                    instantiateViewController(withIdentifier: "barterRoom")
                ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        swappDelegate?.swappPageViewController(swappPageViewController: self,
                                                     didUpdatePageCount: orderedViewControllers.count)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open var shouldAutorotate: Bool {
        //print("Shouldautorotate")
        return false
    }
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        //print("supportedInterfaceOrientations")
        return .landscape
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HLSwappPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    

    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            swappDelegate?.swappPageViewController(swappPageViewController: self,
                                                      didUpdatePageIndex: index)
            
            
            // removed. Now index is controled by selection, not by pagination
            //self.currentIndex = index
            
            
            if (index == 0){
                if let dashboardVc = firstViewController as? HLDashboardViewController{
                    dashboardVc.refreshCollectionViewData()
                }
            }
        }
    }
    
    public func goTo(page: Int){
        if (page < orderedViewControllers.count){
            let newVC = orderedViewControllers[page]
            if (page != 0){
                setViewControllers([newVC],
                               direction: .forward,
                               animated: true,
                               completion: nil)
            } else {
                setViewControllers([newVC],
                               direction: .reverse,
                               animated: true,
                               completion: nil)
            }
            swappDelegate?.swappPageViewController(swappPageViewController: self,
                                                   didUpdatePageIndex: page)
        }
    }
    
    
}

protocol SwappPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func swappPageViewController(swappPageViewController: HLSwappPageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func swappPageViewController(swappPageViewController: HLSwappPageViewController,
                                    didUpdatePageIndex index: Int)
    
    
    
}
