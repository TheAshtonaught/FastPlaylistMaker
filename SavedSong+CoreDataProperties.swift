//
//  SavedSong+CoreDataProperties.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/24/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData


extension SavedSong {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedSong> {
        return NSFetchRequest<SavedSong>(entityName: "SavedSong");
    }

    @NSManaged public var albumImg: NSData?
    @NSManaged public var title: String?
    @NSManaged public var albumTitle: String?
    @NSManaged public var id: Int64
    @NSManaged public var playlist: Playlist?

}
