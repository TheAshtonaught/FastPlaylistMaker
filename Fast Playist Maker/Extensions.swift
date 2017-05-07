//
//  Extensions.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 5/7/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUniqueString(_ uniqueString: String, imageData: NSData) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: uniqueString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
            
        DispatchQueue.main.async(execute: {
                
            if let downloadedImage = UIImage(data: imageData as Data) {
                imageCache.setObject(downloadedImage, forKey: uniqueString as NSString)
                    
                self.image = downloadedImage
            }
        })
            
    }
    
}
