//
//  PlayMusicVC.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/15/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit
import MediaPlayer


class PlayMusicVC: UIViewController {
    
    var collection: MPMediaItemCollection!
    let controller = MPMusicPlayerController.systemMusicPlayer()

    @IBOutlet weak var albumImage: DraggableImage!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        controller.setQueue(with: collection)
        controller.prepareToPlay()
        controller.play()
        updateSongInfo()
        
    }
    
    @IBAction func play(_ sender: Any) {
        if controller.playbackState == .paused {
            controller.play()
            pauseButton.setImage(UIImage(named: "pauseIcon.png"), for: .normal)
        }
        if controller.playbackState == .playing {
            controller.pause()
            pauseButton.setImage(UIImage(named: "playButton.png"), for: .normal)
        }
        updateSongInfo()
 
    }
    
    @IBAction func skipBtnPressed(_ sender: Any) {
        controller.skipToNextItem()
        updateSongInfo()
    }
    
    @IBAction func prevBtnPressed(_ sender: Any) {
        controller.skipToPreviousItem()
        updateSongInfo()
    }
    
    func updateSongInfo() {
        albumImage.image = controller.nowPlayingItem?.artwork?.image(at: CGSize(width: 245.0, height: 268.0)) ?? UIImage(named: "noAlbumArt.png")
        albumTitleLabel.text = controller.nowPlayingItem?.albumTitle ?? ""
        songTitleLabel.text = controller.nowPlayingItem?.title ?? ""

        
        
    }
    
    
    

}
