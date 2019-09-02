//
//  HLIntroViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SpriteKit

class HLIntroViewController: UserBaseViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var introView1: UIView!
    @IBOutlet weak var introView2: UIView!
    @IBOutlet weak var introView3: UIView!
    @IBOutlet weak var introView5: UIView!
    @IBOutlet weak var pageCtrl: UIPageControl!
    @IBOutlet weak var mainScrollView: UIScrollView!
    

    
    @IBOutlet weak var tradeModeLabel: UILabel!
    @IBOutlet weak var dashMask: UIView!
    @IBOutlet weak var dashImage: UIImageView!
    @IBOutlet weak var mobileImage: UIView!
    var initialFrame:CGRect = CGRect(x:0, y:0, width: 191, height: 108)
    var rotating:Bool = false
    
    weak var player1:AVPlayer?
    weak var playerLayer1: AVPlayerLayer!
    
    var jump_just_once : Bool = true
    //var scene: [HulaVideoTransp] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.initData()
        self.initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        jump_just_once = true
        HLDataManager.sharedInstance.ga("intro_animations")
        //scene[0].play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("will disappear")
        removeVideos()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("Memory warning")
        removeVideos()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func removeVideos(){
        print("removing previous vc")
        self.navigationController?.viewControllers.remove(at: 0)
        /*
        player1?.pause()
        player1 = nil
        playerLayer1.removeFromSuperlayer()
         */
    }
    
    func initUI(){
        
        guard let path1 = Bundle.main.path(forResource: "slide 1", ofType:"mp4") else {
            debugPrint("Video file not found")
            return
        }
        player1 = AVPlayer(url: URL(fileURLWithPath: path1))
        playerLayer1 = AVPlayerLayer(player: player1)
        playerLayer1.frame = introView1.bounds
        //introView1.layer.addSublayer(playerLayer1)
        introView1.layer.insertSublayer(playerLayer1, at: 1)

        player1!.play()
        
        /*
        guard let path2 = Bundle.main.path(forResource: "slide 2", ofType:"mp4") else {
            debugPrint("Video file not found")
            return
        }
        player2 = AVPlayer(url: URL(fileURLWithPath: path2))
        playerLayer2 = AVPlayerLayer(player: player2)
        playerLayer2.frame = introView1.bounds
        //introView2.layer.addSublayer(playerLayer2)
        introView2.layer.insertSublayer(playerLayer2, at: 0)
        //player2.play()
        
        
        guard let path3 = Bundle.main.path(forResource: "slide 3", ofType:"mp4") else {
            debugPrint("Video file not found")
            return
        }
        player3 = AVPlayer(url: URL(fileURLWithPath: path3))
        playerLayer3 = AVPlayerLayer(player: player3)
        playerLayer3.frame = introView1.bounds
        //introView3.layer.addSublayer(playerLayer3)
        introView3.layer.insertSublayer(playerLayer3, at: 0)
        //player3.play()
 
 */
        /*
        let margin = CGFloat(20)
        let animation_frame = CGRect(origin: CGPoint(x:margin, y:100), size: CGSize(width: self.view.frame.width-margin*2, height: self.view.frame.width-margin*2))
        
        
        scene.append(HulaVideoTransp(size: animation_frame.size, textureName:"slide_1_2.atlas"))
        let skView = SKView(frame: animation_frame)
        skView.showsFPS = false
        skView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene[0])
        introView1.addSubview(skView)
 
        
        scene.append(HulaVideoTransp(size: animation_frame.size, textureName:"slide_2.atlas"))
        let skView2 = SKView(frame: animation_frame)
        skView2.showsFPS = false
        skView2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        skView2.showsNodeCount = false
        skView2.ignoresSiblingOrder = true
        skView2.presentScene(scene[1])
        introView2.addSubview(skView2)
        
        
        
        scene.append(HulaVideoTransp(size: animation_frame.size, textureName:"slide_3.atlas"))
        let skView3 = SKView(frame: animation_frame)
        skView3.showsFPS = false
        skView3.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        skView3.showsNodeCount = false
        skView3.ignoresSiblingOrder = true
        skView3.presentScene(scene[2])
        introView3.addSubview(skView3)
        
        */
        
        self.dashImage.alpha = 0
        self.dashMask.alpha = 0
        self.mobileImage.alpha = 0
        self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2));
        self.tradeModeLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
    }
    func initData(){
        pageCtrl.currentPage = 0
    }
    func initView(){
        introView1.frame = CGRect(x: 0.0, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        introView2.frame = CGRect(x: mainScrollView.frame.size.width, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        introView3.frame = CGRect(x: mainScrollView.frame.size.width * 2.0, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        introView5.frame = CGRect(x: mainScrollView.frame.size.width * 3.0, y: 0.0, width: mainScrollView.frame.size.width, height: mainScrollView.frame.size.height)
        
        mainScrollView.addSubview(introView1)
        mainScrollView.addSubview(introView2)
        mainScrollView.addSubview(introView3)
        mainScrollView.addSubview(introView5)
        mainScrollView.contentSize = CGSize(width: mainScrollView.frame.size.width * 4.0, height: 0)
        mainScrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
    }
    
    
    func rotateAnimation(){
        if (rotating){
            return
        }
        rotating = true
        if pageCtrl.currentPage == 3 {
            self.mobileImage.alpha = 0
            self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2));
            
            self.dashImage.alpha = 0
            self.dashMask.alpha = 0
            self.dashMask.transform = .identity
            self.dashMask.frame = self.initialFrame
            
            UIView.animate(withDuration: 0.5, animations: {
                self.mobileImage.alpha = 1
            }, completion: { (success) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.mobileImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
                    self.dashMask.alpha = 1
                    self.dashImage.alpha = 1
                }, completion: { (success) in
                    
                    
                    
                    UIView.animate(withDuration: 2.0, animations: {
                        self.mobileImage.alpha = 0
                    }, completion: { (success) in
                        self.mobileImage.transform = .identity
                        let when = DispatchTime.now() + 0.5
                        DispatchQueue.main.asyncAfter(deadline: when) {
                            self.rotating = false
                            self.rotateAnimation()
                        }
                    })
                })
                
                UIView.animate( withDuration: 0.7, delay:0.4, animations: {
                    self.dashMask.frame.origin.x = 0
                    self.dashMask.frame.origin.y = -200
                    self.dashMask.transform = CGAffineTransform(rotationAngle: 0.8)
                })
            })
        }
    }
    
    //#MARK - ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        
        if (mainScrollView.contentOffset.x > 3.0 * mainScrollView.frame.size.width) {
            if (jump_just_once){
                playerLayer1.removeFromSuperlayer()
                jump_just_once = false;
                self.navToMainView()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let posX: Int! = Int(round( mainScrollView.contentOffset.x / mainScrollView.frame.size.width) )
        pageCtrl.currentPage = posX
        if (posX == 0 ){
            playVideo(1)
        }
        
        
        if (posX == 1){
            playVideo(2)
        }
        
        if (posX == 2){
            playVideo(3)
        }
        if (posX == 3){
            self.rotateAnimation()
        }
        
        
    }
    func playVideo(_ num: Int){
        
        player1?.pause()
        player1 = nil
        playerLayer1.removeFromSuperlayer()
        
       
        
        guard let path = Bundle.main.path(forResource: "slide \(num)", ofType:"mp4") else {
            debugPrint("Video file not found")
            return
        }
        //print("Loading video \(path)")
        player1 = AVPlayer(url: URL(fileURLWithPath: path))
        playerLayer1 = AVPlayerLayer(player: player1)
        playerLayer1.frame = introView1.bounds
        
        if num == 1 {
            //print("Moving video to 1")
            introView1.layer.insertSublayer(playerLayer1, at: 1)
        }
        if num == 2 {
            //print("Moving video to 2")
            introView2.layer.insertSublayer(playerLayer1, at: 1)
        }
        if num == 3 {
            //print("Moving video to 3")
            introView3.layer.insertSublayer(playerLayer1, at: 1)
        }
        //print("Playing video \(path)")
        player1?.play()
    }
}
