//
//  dueDateTableViewCell.swift
//  Wunderlist
//
//  Created by William McDuff on 2015-01-26.
//  Copyright (c) 2015 Appfish. All rights reserved.
//

import UIKit

class dueDateTableViewCell: UITableViewCell {

    
    @IBOutlet weak var reminderImageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
