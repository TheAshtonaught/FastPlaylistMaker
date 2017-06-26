//
//  SavedSong+CoreDataClass.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/24/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class SavedSong: NSManagedObject {

    convenience init (song: Song, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "SavedSong", in: context) {
            self.init(entity: entity, insertInto: context)
            self.albumImg = song.artwork.lowQualityJPEGNSData
            self.albumTitle = getAlbumArtistString(song: song)
            self.id = Int64(song.persitentID)
            self.title = song.title
            
        } else {
            fatalError("unable to find entity name")
        }
        
    }
    
    func getAlbumArtistString(song: Song) -> String {
        var albumArtistString = ""
        
        let artistString = song.artist
        let albumString = song.album
        
        if artistString == "" || albumString == "" {
            albumArtistString = artistString + albumString
        } else {
           albumArtistString = artistString + " - " + albumString
        }
        
        return albumArtistString
    }
    
}
