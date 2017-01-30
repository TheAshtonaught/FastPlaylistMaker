//
//  SongTableCell.swift
//  Fast Playist Maker
//
//  Created by Ashton Morgan on 1/28/17.
//  Copyright © 2017 Ashton Morgan. All rights reserved.
//

import UIKit

class SongTableCell: UITableViewCell {
    @IBOutlet weak var albumImageView: DraggableImage!
    @IBOutlet weak var songTitleLbl: UILabel!
    @IBOutlet weak var albumTitleLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
