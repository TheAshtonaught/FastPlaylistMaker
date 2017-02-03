//
//  BorderedButton.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/18/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit

class BorderedButton: UIButton {

    override func awakeFromNib() {
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }

}
