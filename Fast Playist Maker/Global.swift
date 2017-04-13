//
//  Global.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 2/1/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation

class Global {
    var appleMusicPicks: [Song]? = nil
    var showExplainer: Bool? = nil
    
    
    static var sharedInstance = Global()
    class func sharedClient() -> Global {
        return sharedInstance
    }
}
