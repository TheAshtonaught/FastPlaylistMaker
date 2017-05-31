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
    var artist: String
    
    init(artwork: UIImage, title: String, album: String, id: UInt64, artist: String) {
        self.artwork = artwork
        self.title = title
        self.album = album
        self.persitentID = id
        self.artist = artist
    }
    
    init(similarSong: SimilarSong) {
        self.artist = similarSong.artist
        self.title = similarSong.title
        self.persitentID = similarSong.persitentID
        self.album = ""
        
        if let imageData = NSData(contentsOf: similarSong.imageUrl) as Data? {
            
            self.artwork = UIImage(data: imageData) ?? UIImage(named: "noAlbumArt.png")!
        } else {
            self.artwork = UIImage(named: "noAlbumArt.png")!
        }
    }
    
    init(similarSong: SimilarSong, albumImage: UIImage) {
        self.artist = similarSong.artist
        self.title = similarSong.title
        self.persitentID = similarSong.persitentID
        self.album = ""
        self.artwork = albumImage
        
    }
    
    
    init(songItem: MPMediaItem) {
        title = songItem.title ?? ""
        album = songItem.albumTitle ?? ""
        persitentID = songItem.persistentID
        artist = songItem.artist ?? ""
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
