//
//  Song.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/20/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

struct Song {
    
    var artwork: UIImage
    var title: String
    var album: String
    
    init(songItem: MPMediaItem) {
        if let art = songItem.artwork?.image(at: CGSize(width: 245.0, height: 268.0)) {
           artwork = art
        } else {
            artwork = UIImage(named: "placeholderimg.png")!
        }
        
        if let track = songItem.title {
            title = track
        } else {
            title = ""
        }
        
        if let albumTitle = songItem.albumTitle {
            album = albumTitle
        } else {
            album = ""
        }
        
        
    }
}





















