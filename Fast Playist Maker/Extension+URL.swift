//
//  Extension+URL.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 7/19/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation

extension URL {
    
    func queryItemValueFor (key: String) -> String? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
            else {
                return nil
        }
        
        return queryItems.first(where: { $0.name == key })?.value
    }
    
}

