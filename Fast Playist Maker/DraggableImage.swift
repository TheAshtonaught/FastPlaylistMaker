//
//  DraggableImage.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/16/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit

class DraggableImage: UIImageView {

    override func awakeFromNib() {
        styleImage()
    }
    
    func styleImage() {
        self.superview?.layoutIfNeeded()
        self.clipsToBounds = true
        layer.masksToBounds = true
        layer.cornerRadius = 20.0
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1.0
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    
    
        


}
