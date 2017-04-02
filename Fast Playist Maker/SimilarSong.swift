//
//  SimilarSong.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 4/2/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import UIKit

struct SimilarSong {
    var imageUrl: URL
    var title: String
    var persitentID: UInt64
    var artist: String
    
    init(imageUrl: URL, title: String, id: UInt64, artist: String) {
        self.imageUrl = imageUrl
        self.title = title
        self.persitentID = id
        self.artist = artist
    }
}
