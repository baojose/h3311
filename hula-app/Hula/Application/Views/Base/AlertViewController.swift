//
//  AlertViewController.swift
//  Hula
//
//  Created by Juan Searle on 02/09/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet weak var alertBackground: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    @IBOutlet weak var starView: UIView!
    
    var message:String = ""
    var delegate:AlertDelegate?
    var isCancelVisible = true
    var okButtonText = NSLocalizedString("OK", comment: "")
    var cancelButtonText = NSLocalizedString("Cancel", comment: "")
    var trigger:String = ""
    var starsVisible:Bool = false
    var points:Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        alertBackground.layer.cornerRadius = 4.0;
        alertBackground.clipsToBounds = true
        messageLabel.text = message
        okButton.setTitle(okButtonText, for: .normal)
        cancelButton.setTitle(cancelButtonText, for: .normal)
        if (isCancelVisible){
            cancelButton.isHidden = false;
        } else {
            cancelButton.isHidden = true;
        }
        
        
        if starsVisible {
            starView.isHidden = false
        } else {
            starView.isHidden = true
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func okButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            var response = "ok"
            if self.points > 0 {
                response = "\(self.points)"
            }
            self.delegate?.alertResponded(response:response, trigger: self.trigger)
        })
    }
    @IBAction func canceButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.delegate?.alertResponded(response:"cancel", trigger: self.trigger)
        })
    }
    
    @IBAction func starButtonTapped(_ sender: Any) {
        let index = (sender as! UIButton).tag - 10
        self.points = index
        for i in 1 ... 5 {
            let star = self.view.viewWithTag(i) as! UIImageView
            if i <= index {
                star.image = UIImage(named: "star-fill")
                star.bouncer()
            } else {
                star.image = UIImage(named: "star-empty")
            }
        }
    }
    
}

protocol AlertDelegate {
    func alertResponded(response:String, trigger:String)
}
