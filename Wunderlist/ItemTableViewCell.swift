//
//  ItemTableViewCell.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-11-12.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit


// Cell representing an item of the list

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var starImageView: UIImageView!
   
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var checkboxButton: UIButton!
    
    
    // if the button is clicked then return
   

    
    var clicked = Bool()
    
    
        override func awakeFromNib() {
        super.awakeFromNib()
            self.starButton.enabled = true
            self.starButton.hidden = false
            
            self.starButton.backgroundColor = UIColor.clearColor()
            
            
            
            self.checkboxButton.setBackgroundImage(UIImage(named: "unchecked_checkbox@2x"), forState: .Normal)
            self.checkboxButton.setBackgroundImage(UIImage(named: "checked_checkbox@2x"), forState: .Selected)
          

            
            if self.starButton.state == .Selected  {
                self.starButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.63)
                self.starButton.alpha = 0.63
                
            }
                
            else {
                
                self.starButton.backgroundColor = UIColor.clearColor()
                self.starButton.alpha = 0.05
            }
            
          
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func starClicked() {
        
        if self.starButton.alpha < 0.60 {
            self.starButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.63)
            self.starButton.alpha = 0.63
            self.starButton.selected = true
            
        }
            
        else {
            
            self.starButton.backgroundColor = UIColor.clearColor()
            self.starButton.alpha = 0.05
            self.starButton.selected = false
        }
        
    }

    
    func checkboxClicked() {
        
        if checkboxButton.selected == false {
            checkboxButton.selected = true
            
        }
        else {
            checkboxButton.selected = false
        }
    }
    
}
