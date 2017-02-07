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
            self.albumImg = UIImagePNGRepresentation(song.artwork) as NSData!
            self.albumTitle = song.album
            self.id = Int64(song.persitentID)
            self.title = song.title
            
        } else {
            fatalError("unable to find entity name")
        }
        
    }
    
}
