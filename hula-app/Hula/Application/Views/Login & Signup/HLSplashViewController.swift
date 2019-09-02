//
//  HLSplashViewController.swift
//  Hula
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class HLSplashViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initPlayer()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playVideo()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initPlayer() {
        guard let path = Bundle.main.path(forResource: "splash_intro", ofType:"mp4") else {
            debugPrint("splash_intro.mp4 file not found")
            return
        }
        player? = AVPlayer(url: URL(fileURLWithPath: path))
        self.showsPlaybackControls = false
    }
    private func playVideo(){
        player?.play()
    }
}
