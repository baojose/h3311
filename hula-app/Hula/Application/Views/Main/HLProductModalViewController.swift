//
//  HLProductModalViewController.swift
//  Hula
//
//  Created by Juan Searle on 31/07/2017.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import BRYXBanner

class HLProductModalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, AVPlayerViewControllerDelegate {

    var product: HulaProduct!
    
    @IBOutlet weak var mainBoxView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet weak var productDistance: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productCondition: UILabel!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var multipleDealsImg: UIImageView!
    @IBOutlet weak var multipleDealLbl: UILabel!
    @IBOutlet weak var videoStatusImg2: UIImageView!
    
    @IBOutlet weak var productDescriptionLabel: UITextView!
    @IBOutlet var productsScrollView: UIScrollView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet weak var videoStatusImg: UIImageView!
    @IBOutlet weak var videoBtnHolder: UIView!
    @IBOutlet weak var videoStatusLbl: UILabel!
    
    
    let imagePicker = UIImagePickerController()
    var videoPath: NSURL? = nil
    var image_dismissing : Bool = false
    var hideVideoBtn: Bool = false
    var currentTradeId : String = ""
    var calledFrom : Int = 0
    var isTradeAgreed : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainBoxView.layer.cornerRadius = 4
        mainScrollView.clipsToBounds = true
        
        
        productSetup()
    }
    
    func productSetup(){
        titleLabel.text = product.productName
        productDistance.text = CommonUtils.sharedInstance.getDistanceFrom(loc: product.productLocation)
        productCategory.text = NSLocalizedString(product.productCategory, comment: "")
        productCondition.text = NSLocalizedString(product.productCondition, comment: "")
        if product.productDescription.count > 0 {
            productDescriptionLabel.text = product.productDescription
        } else {
            productDescriptionLabel.text = NSLocalizedString("No product description provided.", comment: "")
        }
        self.setupVideoButtons()
        
        self.multipleDealsImg.isHidden = true
        self.multipleDealLbl.isHidden = true
        //print(product.trading_count)
        if product.trading_count > 1 {
            self.multipleDealsImg.isHidden = false
            self.multipleDealLbl.isHidden = false
            self.multipleDealLbl.text = "\(product.trading_count!) " + NSLocalizedString("trades", comment: "")
        }
        
        // item height and position reset
        let h = CommonUtils.sharedInstance.heightString(width: productDescriptionLabel.frame.width, font: productDescriptionLabel.font! , string: productDescriptionLabel.text!) + 30
        productDescriptionLabel.frame.size = CGSize(width: productDescriptionLabel.frame.size.width, height: h)
        
        
        mainScrollView.contentSize = CGSize(width: 0, height: productDescriptionLabel.frame.origin.y + productDescriptionLabel.frame.size.height + 100)
        // seta product images
        self.setUpProductImagesScrollView()
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        HLDataManager.sharedInstance.ga("product_detail_barter")
        
        if HLDataManager.sharedInstance.onboardingTutorials.object(forKey: "product_modal") as? String == nil{
            CommonUtils.sharedInstance.showTutorial(arrayTips: [
                HulaTip(delay: 2, view: self.videoBtn, text: NSLocalizedString("You can request a video-proof for this product.", comment: ""))
                ], named: "product_modal")
            //print(HLDataManager.sharedInstance.onboardingTutorials)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeModalAction(_ sender: Any) {
        //print(self.parent)
        if let pvc = self.presentingViewController as? HLBarterScreenViewController{
            pvc.updateProductsFromTrade()
        }
        HLDataManager.sharedInstance.onlyLandscapeView = false
        self.dismiss(animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if productsScrollView == scrollView {
            let page: Int = Int(round(productsScrollView.contentOffset.x / productsScrollView.frame.width))
            pageControl.currentPage = page
        }
    }
    
    func setUpProductImagesScrollView() {
        var num_images: CGFloat = 0;
        
        productsScrollView.subviews.forEach({ $0.removeFromSuperview() })
        
        for i in 0 ..< product.arrProductPhotoLink.count {
            let img_url = product.arrProductPhotoLink[i]
            if (img_url.count > 0){
                let imageFrame = CGRect(x: (CGFloat)(i) * productsScrollView.frame.size.width, y: 0, width: productsScrollView.frame.size.width, height: productsScrollView.frame.size.height)
                let imgView: UIImageView! = UIImageView.init(frame: imageFrame)
                //commonUtils.loadImageOnView(imageView: imgView, withURL: img_url)
                imgView.loadImageFromURL(urlString: img_url)
                //imgView.image = UIImage(named: "temp_product")
                imgView.contentMode = .scaleAspectFill
                imgView.tag = i + 1000
                
                productsScrollView.addSubview(imgView)
                num_images += 1
            }
        }
        
        productsScrollView.contentSize = CGSize(width: num_images * productsScrollView.frame.size.width, height: 0.0)
        pageControl.numberOfPages = Int(num_images)
        pageControl.currentPage = 0
        productsScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    func setupVideoButtons(){
        print("Called from: \(calledFrom)")
        hideVideoBtn = false
        if calledFrom == 1 {
            hideVideoBtn = true
            videoStatusImg.isHidden = true;
            videoStatusImg2.isHidden = true;
        }
        if !hideVideoBtn {
            videoBtnHolder.isHidden = false
            var vreq : Bool = false
            var vurl : String = ""
            if let t = product.video_requested[currentTradeId] {
                vreq = t
            }
            if let t = product.video_url[currentTradeId] {
                vurl = t
            }
            if (product.productOwner != HulaUser.sharedInstance.userId){
                // not my product
                if (vreq || vurl.count  > 0) {
                    // video has been requested
                    if (vurl.count > 0) {
                        // video was requested and is available
                        videoStatusImg.image = UIImage(named: "video-player-icon-red")
                        videoStatusImg2.image = UIImage(named: "video-player-icon-red")
                        videoStatusLbl.text = NSLocalizedString("Video proof available", comment: "")
                        videoBtn.setTitle(NSLocalizedString(" Play video", comment: ""), for: .normal)
                        videoBtn.setImage(UIImage(named: "video-player-icon-red"), for: .normal)
                        videoBtn.tag = 43909
                    } else {
                        // video is still pending recod
                        videoStatusImg.image = UIImage(named: "video-requested-red")
                        videoStatusImg2.image = UIImage(named: "video-requested-red")
                        videoBtn.setTitle(NSLocalizedString(" Waiting for video proof...", comment: ""), for: .normal)
                        videoStatusLbl.text = NSLocalizedString("Video proof requested", comment: "")
                        videoBtn.tag = -43904
                    }
                } else {
                    // video has not been requested
                    videoBtn.setTitle(" Request video proof", for: .normal)
                    videoStatusImg.image = nil
                    videoStatusImg2.image = nil
                    videoStatusLbl.text = ""
                    videoBtn.tag = 1
                }
            } else {
                // it is my product
                if (vurl.count > 0){
                    // I've already recorded a video
                    videoStatusImg.image = UIImage(named: "video-player-icon-red")
                    videoStatusImg2.image = UIImage(named: "video-player-icon-red")
                    videoStatusLbl.text = NSLocalizedString("Video proof available", comment: "")
                    videoBtn.setTitle(NSLocalizedString(" Play video", comment: ""), for: .normal)
                    videoBtn.setImage(UIImage(named: "video-player-icon-red"), for: .normal)
                    videoBtn.tag = 43909
                } else {
                    // video is still pending recod
                    videoStatusImg.image = UIImage(named: "video-requested-red")
                    videoStatusImg2.image = UIImage(named: "video-requested-red")
                    videoStatusLbl.text = NSLocalizedString("User waiting for video proof", comment: "")
                    videoBtn.setTitle(NSLocalizedString(" Record video proof", comment: ""), for: .normal)
                    videoBtn.tag = 43904
                }
            }
        } else {
            videoBtnHolder.isHidden = true
            videoStatusLbl.text = ""
        }
    }
    
    @IBAction func videoAction(_ sender: Any) {
        let tag = (sender as! UIButton).tag
            if (tag == 43904){
                if product.productOwner == HulaUser.sharedInstance.userId {
                    recordVideo()
                }
            } else {
                if (tag == 43909){
                    playVideo()
                } else {
                    var vreq : Bool = false
                    if let t: Bool = product.video_requested[currentTradeId] {
                        vreq = t
                    }
                    
                    if !vreq {
                        let queryURL = HulaConstants.apiURL + "products/\(product.productId!)/requestvideo/\(currentTradeId)"
                        HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                            if (ok){
                                if let _ = json as? NSDictionary {
                                    
                                    DispatchQueue.main.async {
                                        let alert = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                                        alert.delegate = self as AlertDelegate
                                        alert.isCancelVisible = false
                                        alert.message = NSLocalizedString("You have requested a video for this product. You will receive a notification when the user uploads it.", comment: "")
                                        alert.trigger = "video_request"
                                        self.present(alert, animated: true)
                                    }
                                } else {
                                    print("Error connecting")
                                }
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            let alert = self.storyboard?.instantiateViewController(withIdentifier: "alertView") as! AlertViewController
                            alert.delegate = self as AlertDelegate
                            alert.isCancelVisible = false
                            alert.message = NSLocalizedString("This product is already waiting for a video proof. The owner will record a video and you will be notified.", comment: "")
                            alert.trigger = "video_request"
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        
    }
    func playVideo(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = true
        
        print("do not allow rotation")
        
        var vurl : String = ""
        print(product.video_url)
        if let t = product.video_url[currentTradeId] {
            vurl = t
        }
        let videoURL = URL(string: vurl)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = LandscapeAVPlayerController()
        if #available(iOS 9.0, *) {
            HLDataManager.sharedInstance.onlyLandscapeView = true
            playerViewController.delegate = self
        } else {
            // Fallback on earlier versions
        }
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func playerViewControllerWillBeginDismissalTransition(_ playerViewController: AVPlayerViewController){
        
        print("allow rotation again")
        HLDataManager.sharedInstance.onlyLandscapeView = false
    }
    
    func recordVideo() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.allowRotation = true
            HLDataManager.sharedInstance.onlyLandscapeView = true
            
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                HLDataManager.sharedInstance.onlyLandscapeView = true
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [ kUTTypeMovie as String ]
                imagePicker.allowsEditing = false
                imagePicker.videoQuality = .typeMedium
                imagePicker.videoMaximumDuration = 20
                imagePicker.delegate = self
                
                present(imagePicker, animated: true, completion: {})
            } else {
                print("Rear camera doesn't exist. Application cannot access the camera.")
            }
        } else {
            print("Camera inaccessable. Application cannot access the camera.")
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        HLDataManager.sharedInstance.onlyLandscapeView = false
        imagePicker.dismiss(animated: true, completion: {
            
        })
    }
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [String:Any]) {
        //print("Got a video")
        
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            // Save video to the main photo album
            //print(pickedVideo.relativePath)
            /*
            let selectorToCall = #selector(HLProductModalViewController.videoWasSavedSuccessfully)
            UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, selectorToCall, nil)
            
             */
            // Save the video to the app directory so we can play it later
            let videoData = NSData(contentsOf: pickedVideo as URL)
            
            
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let documentsDirectory = paths[0] as! NSString
            let path = documentsDirectory.appendingPathComponent("testvideo.mov")
            videoPath = NSURL(string: path )
            videoData?.write(toFile: path, atomically: false)
            //self.dismiss(animated: true, completion: nil)
            notify(NSLocalizedString("Uploading video...", comment: ""))
            videoBtn.setTitle(NSLocalizedString(" Uploading", comment: ""), for: .normal)
            // three-dots animation
            
            HLDataManager.sharedInstance.uploadVideo(path, productId: product.productId, tradeId: self.currentTradeId, taskCallback: { (success, json) in
                print("Uploaded")
                //print(json)
                DispatchQueue.main.async {
                    if let dict = json as? [String: Any] {
                        if let vp = dict["path"] as? String{
                            self.product.video_requested[self.currentTradeId] = true
                            self.product.video_url[self.currentTradeId] = HulaConstants.staticServerURL + vp
                        }
                    }
                    self.videoBtn.setTitle(NSLocalizedString(" Video uploaded", comment: ""), for: .normal)
                    self.videoBtn.setImage(UIImage(named: "video-player-icon-red"), for: .normal)
                    self.videoBtn.tag = 43909
                    self.notify(NSLocalizedString("Video uploaded!", comment: ""))
                    //self.setupVideoButtons()
                    self.refreshProduct()
                }
                
            })
        }
        
        HLDataManager.sharedInstance.onlyLandscapeView = false
        imagePicker.dismiss(animated: true, completion: {
            // Anything you want to happen when the user saves an video
            
            
        })
    }
    
    func videoWasSavedSuccessfully(_ data:Any){
        //print(data)
        
    }
    
    func notify(_ txt: String){
        let banner = Banner(title: nil, subtitle: txt, backgroundColor: HulaConstants.appMainColor)
        banner.dismissesOnTap = true
        banner.show(duration: 0.7)
    }
    @IBAction func fsImageAction(_ sender: Any) {
        print("Fullingscreening")
        if let im = productsScrollView.viewWithTag(pageControl.currentPage + 1000) as? UIImageView{
            fullScreenImage(im.image!)
        }
    }
    
    func refreshProduct(){
        HLDataManager.sharedInstance.getProduct(productId:product.productId, taskCallback: {(pr) in
            self.product = pr;
            self.productSetup()
        })
        
    }
    
}

extension HLProductModalViewController: AlertDelegate{
    
    func alertResponded(response: String, trigger: String) {
        if trigger == "video_request" {
            print("Requesting trades reload...")
            HLDataManager.sharedInstance.getTrades(taskCallback: { (success) in
                DispatchQueue.main.async {
                    
                    self.dismiss(animated: true, completion: {
                        //print("Dismissed")
                    })
                }
            })
        }
    }

}


extension HLProductModalViewController {
    func fullScreenImage(_ image: UIImage) {
        //print("Fullingscreening")
        let newImageView = UIImageView(image: image)
        
        newImageView.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 10, height:10)
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.alpha = 0.0
        newImageView.tag = 10001
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(optionsFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(swipe)
        self.view.addSubview(newImageView)
        image_dismissing = false
        UIView.animate(withDuration: 0.3, animations: {
            newImageView.frame = UIScreen.main.bounds
            newImageView.alpha = 1
        }) { (success) in
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
 
    }
    
    func dismissFullscreenImage(_ sender: UIGestureRecognizer) {
        if (!image_dismissing){
            guard let panRecognizer = sender as? UIPanGestureRecognizer else {
                return
            }
            let velocity = panRecognizer.velocity(in: self.view)
            
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                sender.view?.frame = CGRect(x: self.view.frame.width/2 + velocity.x/2, y: self.view.frame.height/2 + velocity.y/2, width: 30, height:30)
                sender.view?.alpha = 0
                sender.view?.transform.rotated(by: CGFloat( arc4random_uniform(100)/12))
            }) { (success) in
                sender.view?.removeFromSuperview()
            }
            image_dismissing = true
        }
    }
    func dismissFullscreenImageDirect() {
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        if let imageView = self.view.viewWithTag(10001) as? UIImageView {
            UIView.animate(withDuration: 0.3, animations: {
                imageView.frame = CGRect(x: self.view.frame.width/2 , y: self.view.frame.height/2, width: 30, height:30)
                imageView.alpha = 0
                imageView.transform.rotated(by: CGFloat( arc4random_uniform(100)/12))
            }) { (success) in
                imageView.removeFromSuperview()
            }
        }
        image_dismissing = true
    }
    func optionsFullscreenImage(_ sender: UIGestureRecognizer) {
        let alertController = UIAlertController(title: NSLocalizedString("Image options...", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Close", comment: ""), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
            self.dismissFullscreenImageDirect( )
        })
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }
}

