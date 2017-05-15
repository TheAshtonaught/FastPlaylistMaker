//
//  MusicPlayerVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 5/15/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicPlayerVC: UIViewController, InteractivePlayerViewDelegate {
    
    let controller = MPMusicPlayerController.systemMusicPlayer()
    
    @IBOutlet weak var blurBgImage: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ipv: InteractivePlayerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playPauseButtonView: UIView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var nextTrackBtn: UIButton!
    @IBOutlet weak var previousTrackBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ipv!.delegate = self
        configUI()
        
        setupPlaybackNotifications()
        
        ipv.progress = 0
    }
    
    deinit {
        controller.endGeneratingPlaybackNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setSongInfo()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
        controller.play()
        
        setSongInfo()
        
        playButton.isHidden = true
        pauseButton.isHidden = false
        
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        
        controller.pause()
        
        ipv.stop()
        
        playButton.isHidden = false
        pauseButton.isHidden = true
    }
    
    @IBAction func nextTapped(sender: AnyObject) {
        controller.skipToNextItem()
        ipv.restartWithProgress(duration: 50)
        
        setSongInfo()
    }
    
    @IBAction func previousTapped(sender: AnyObject) {
        controller.skipToPreviousItem()
        ipv.restartWithProgress(duration: 50)
        
        setSongInfo()
    }
    
    func setSongInfo() {
        if controller.nowPlayingItem != nil {
            displayAlbumArtistString()
            displayAlbumImage()
            setSongTimeAndProgressCircle()
        }
    }
    
    func displayAlbumArtistString() {
        songTitleLabel.text = controller.nowPlayingItem?.title
        
        let artistString = controller.nowPlayingItem?.artist ?? ""
        let albumString = controller.nowPlayingItem?.albumTitle ?? ""
        
        if artistString == "" || albumString == "" {
            albumTitleLabel.text = artistString + albumString
        } else {
            albumTitleLabel.text = artistString + "-" + albumString
        }
    }
    
    func displayAlbumImage() {
        let albumImage = controller.nowPlayingItem?.artwork?.image(at: ipv.frame.size) ?? #imageLiteral(resourceName: "noAlbumArt")
        ipv.coverImage = albumImage
        blurBgImage.image = albumImage
    }
    
    func setSongTimeAndProgressCircle() {
        ipv.progress = (controller.nowPlayingItem?.playbackDuration) ?? 0
        ipv.duration = controller.currentPlaybackTime
        
        ipv.updateTime()
        
        if controller.playbackState == .playing {
            ipv.updateTime()
            ipv.start()
        } else {
            ipv.updateTime()
            ipv.stop()
        }
    }
    
    func configUI() {
        self.view.layoutIfNeeded()
        self.view.backgroundColor = UIColor.clear
        self.makeItRounded(view: self.playPauseButtonView, newSize: self.playPauseButtonView.frame.width)
        
        blurBgImage.addBlurEffect()
        blurBgImage.alpha = 0.8
        
        nextTrackBtn.tintColor = .darkGray
        previousTrackBtn.tintColor = .darkGray
        songTitleLabel.textColor = .darkGray
        albumTitleLabel.textColor = .white
        
    }
    
    /* InteractivePlayerViewDelegate METHODS */
    func actionOneButtonTapped(sender: UIButton, isSelected: Bool) {
        print("shuffle \(isSelected.description)")
    }
    
    func actionTwoButtonTapped(sender: UIButton, isSelected: Bool) {
        print("like \(isSelected.description)")
    }
    
    func actionThreeButtonTapped(sender: UIButton, isSelected: Bool) {
        print("replay \(isSelected.description)")
        
    }
    
    func interactivePlayerViewDidChangedDuration(playerInteractive: InteractivePlayerView, currentDuration: Double) {
        
        
        //print("current Duration : \(currentDuration)")
    }
    func userDidChangeTimer(currentTime: Double) {
        
        if controller.nowPlayingItem != nil {
            controller.currentPlaybackTime = currentTime
        }
        
        if controller.playbackState != .playing {
            ipv.stop()
        }
    }
    
    func interactivePlayerViewDidStartPlaying(playerInteractive: InteractivePlayerView) {
        print("interactive player did start")
    }
    
    
    func interactivePlayerViewDidStopPlaying(playerInteractive: InteractivePlayerView) {
        print("interactive player did stop")
    }
    
    func makeItRounded(view : UIView!, newSize : CGFloat!){
        let saveCenter : CGPoint = view.center
        let newFrame : CGRect = CGRect(x: view.frame.origin.x,y: view.frame.origin.y,width: newSize,height : newSize)
        view.frame = newFrame
        view.layer.cornerRadius = newSize / 2.0
        view.clipsToBounds = true
        view.center = saveCenter
        
    }
    
    func setupPlaybackNotifications() {
        controller.beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(self,selector:#selector(self.setSongInfo), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: controller)
        
        NotificationCenter.default.addObserver(self,selector:#selector(self.setSongInfo), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: controller)
    }
    
    
    
}










