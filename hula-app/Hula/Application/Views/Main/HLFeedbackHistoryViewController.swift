//
//  HLFeedbackHistoryViewController.swift
//  Hula
//
//  Created by Star on 3/9/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLFeedbackHistoryViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var feedbackList: NSArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        HLDataManager.sharedInstance.ga("feedback_history")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //#MARK: - TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackList.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedbackHistoryCell") as! HLFeedbackHistoryTableViewCell
        if let this_fb = feedbackList[indexPath.row] as? NSDictionary{
            print(this_fb)
            if let tmp = this_fb["val"] as? CGFloat {
                let perc = round(tmp*20)
                cell.feedbackPercentage.text = "\( Int(perc) )%"
            }
            if let tmp = this_fb["comments"] as? String {
                cell.feedbackCommentLabel.text = "\(tmp)"
            }
            if let tmp = this_fb["giver_id"] as? String {
                cell.userImage.loadImageFromURL(urlString: CommonUtils.sharedInstance.userImageURL(userId: tmp))
            }
        }
        
        return cell
    }
}
