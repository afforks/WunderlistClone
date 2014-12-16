//
//  subtaskTableViewCell.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-10-29.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit


protocol addToItemDictProtocol {
    func addSubTask(cellText: String)
    func addOrRemoveNewItemDictKeyValueToParse(key: String, value: AnyObject, remove: Bool)
    func addNote(note: String)
}



// tableView with all the subtasks of a particular item


class subtaskTableViewCell: UITableViewCell

{
    var delegate: addToItemDictProtocol?
   
    @IBOutlet weak var subtaskTextField: UITextField!

    @IBOutlet weak var subtaskButton: UIButton!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    
    // make a protocol so that when click button calls a method in itemContentVC, then that methods updates the subtaskCellNumber (+1) and reloads tableView (adjust the height and number of cells method of the table view)
    
    
   
    @IBAction func addSubtask(sender: AnyObject) {
        
     
            if self.delegate != nil {
                
                
                if self.subtaskTextField.text != "" {
                    
                    var cellText = self.subtaskTextField.text as String
                    self.subtaskTextField.enabled = false
                    self.subtaskButton.enabled = false
                    delegate!.addOrRemoveNewItemDictKeyValueToParse("subtaskList", value: cellText, remove: false)
                    delegate!.addSubTask(cellText)
                    
                }
             
            
                
            }
            
            else {
                println("no delegate")
            }
            
       
           
    }

}
