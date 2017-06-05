//
//  LoadingLibraryUI.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 6/4/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit

class LoadingLibraryUI: UIView {
    
    
    
    @IBOutlet weak var cheetahImage: UIImageView!
    
    
    func cheetahAnimation(animate: Bool) {
        var imgArray = [UIImage]()
        for i in 0...7 {
            imgArray.append(UIImage(named: "cheetah\(i)")!)
        }
        if animate {
            cheetahImage.animationImages = imgArray
            cheetahImage.animationDuration = 0.4
            cheetahImage.startAnimating()
        } else {
            cheetahImage.stopAnimating()
            //self.removeFromSuperview()        
        }
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
