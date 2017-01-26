//
//  Playlist+CoreDataClass.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/24/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import CoreData


public class Playlist: NSManagedObject {

    convenience init(title: String, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Playlist", in: context) {
            self.init(entity: entity, insertInto: context)
            self.name = title
        } else {
            fatalError("could not get entity name")
        }
    }
}
