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
    var persitentID: UInt64
    
    init(songItem: MPMediaItem) {
        title = songItem.title ?? ""
        album = songItem.albumTitle ?? ""
        persitentID = songItem.persistentID
        if let art = songItem.artwork?.image(at: CGSize(width: 245.0, height: 268.0)) {
           artwork = art
        } else {
            artwork = UIImage(named: "noAlbumArt.png")!
        }
    }
    
    static func newSongFromMPItemArray(itemArr: [MPMediaItem]) -> [Song]{
        var songArr = [Song]()
        for item in itemArr {
            songArr.append(Song(songItem: item))
        }
       return songArr
    }
}





















