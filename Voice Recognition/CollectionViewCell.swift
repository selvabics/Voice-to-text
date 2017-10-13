//
//  CollectionViewCell.swift
//  Voice Recognition
//
//  Created by jayaraj on 31/05/17.
//  Copyright © 2017 sample. All rights reserved.
//

import UIKit
import AVFoundation

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblSubTitle: UILabel?
    @IBOutlet weak var lblKeywords: UILabel?
    @IBOutlet weak var imgView: UIImageView?
    @IBOutlet weak var btnPlay: UIButton?
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    
    //This will be called everytime a new value is set on the videoplayer item
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Setup you avplayer while the cell is created
        self.setupMoviePlayer()
    }
    
    func setupMoviePlayer(){
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
//        avPlayer?.volume = 3
        avPlayer?.actionAtItemEnd = .none
        
//                You need to have different variations
//                according to the device so as the avplayer fits well
//        if UIScreen.main.bounds.width == 375 {
//            let widthRequired = self.frame.size.width - 20
//            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//        }else if UIScreen.main.bounds.width == 320 {
//            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: (self.frame.size.height - 120) * 1.78, height: self.frame.size.height - 120)
//        }else{
//            let widthRequired = self.frame.size.width
//            avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: widthRequired, height: widthRequired/1.78)
//        }
        self.avPlayerLayer?.frame = imgView!.bounds
        avPlayerLayer?.backgroundColor = UIColor.black.cgColor
        self.backgroundColor = .white
        self.imgView?.layer.insertSublayer(avPlayerLayer!, at: 0)
        
//        let trailingConstraint = NSLayoutConstraint(item: avPlayerLayer!, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
//        let topConstraint = NSLayoutConstraint(item: avPlayerLayer!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
//        let leadingConstraint = NSLayoutConstraint(item: avPlayerLayer!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
//        let bottomConstraint = NSLayoutConstraint(item: avPlayerLayer!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
//        self.addConstraints([trailingConstraint, topConstraint, leadingConstraint, bottomConstraint])
        // This notification is fired when the video ends, you can handle it in the method.
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
//                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
//                                               object: avPlayer?.currentItem)
    }
    
    func stopPlayback(){
        btnPlay?.tag = 0
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        btnPlay?.tag = 1
        self.avPlayer?.play()
    }
    
    @IBAction func btnPlayPauseAction(_ sender: AnyObject) {
        
        if btnPlay?.tag == 1 {
            btnPlay?.setImage(UIImage.init(named: "play"), for: .normal)
            stopPlayback()
        }else{
            btnPlay?.setImage(UIImage(), for: .normal)
            startPlayback()
        }
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
}
