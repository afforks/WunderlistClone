//
//  UserTableViewCell.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-10-22.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellImage: UIImageView!
   
    @IBOutlet weak var cellTextLabel: UILabel!
    
    @IBOutlet weak var numberOfItemsLabel: UILabel!

    
   

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Initialization code
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
