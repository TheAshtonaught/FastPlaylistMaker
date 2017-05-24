//
//  Playlist+CoreDataClass.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/24/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData
import MediaPlayer


public class Playlist: NSManagedObject {

    convenience init(title: String, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: context) {
            self.init(entity: entity, insertInto: context)
            self.name = title
        } else {
            fatalError("could not get entity name")
        }
    }
    
    func playSongsFromPlaylist(controller: MPMusicPlayerController) {
        
        if let songArray = querysongs() {
            
            let collection = MPMediaItemCollection(items: songArray)
            
            controller.setQueue(with: collection)
            controller.prepareToPlay()
            controller.play()
            
        }
        
        
    }
    
    private func querysongs() ->[MPMediaItem]? {
        
        var arr = [MPMediaItem]()
        
        guard let songs = self.savedSong?.allObjects as? [SavedSong] else {
            return nil
        }
        
        for song in songs {
            let query = MPMediaQuery.songs()
            let songPredicate = MPMediaPropertyPredicate(value: song.title, forProperty: MPMediaItemPropertyTitle)
            query.addFilterPredicate(songPredicate)
            
            if let items = query.items {
                if items.count > 0 {
                    let result = items[0]
                    arr.append(result)
                }
            }
        }
        return arr
        
    }
    
    
}
