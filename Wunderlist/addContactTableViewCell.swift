//
//  addContactTableViewCell.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-12-06.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit

protocol addContactProtocol {
    func addContact(cellText: String)
}
class addContactTableViewCell: UITableViewCell {

    var delegate: addContactProtocol?
    @IBOutlet weak var contactUsername: UITextField!
    
    @IBOutlet weak var addContactButton: UIButton!
    
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
    


    @IBAction func addContact(sender: AnyObject) {
        
        if self.delegate != nil {
            
            
            
            if self.contactUsername.text != nil {
                var cellText = self.contactUsername.text as String
                
                if cellText == PFUser.currentUser().username {
                    self.contactUsername.enabled = true
                    self.contactUsername.text = ""
                    var alert:UIAlertView = UIAlertView(title: "message", message: "You can't add yourself to your list of contacts, please enter a Wunderlist user other than yourself", delegate: nil, cancelButtonTitle: "Ok")
                    
                    alert.show()
                }
                
                else {
                    self.checkIfUsernameIsValidThenAddIfValid(cellText)
                }
            }
            /*
            delegate!.addOrRemoveNewItemDictKeyValueToParse("subtaskList", value: cellText, remove: false)
*/
            
            
  
            
        }
            
    
       
    }
    
    func checkIfUsernameIsValidThenAddIfValid(cellText: String) {
        
        var query = PFQuery(className:"_User")
        
        query.whereKey("username", equalTo: cellText)
        
        
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if (objects.count > 0) {
                
              
                self.contactUsername.enabled = false
                self.addContactButton.enabled = false
                
             
                
                
                self.delegate!.addContact(cellText)
                
                
                
                
            }
                
            else {
                
                self.contactUsername.enabled = true
                self.contactUsername.text = ""
                var alert:UIAlertView = UIAlertView(title: "message", message: "\(self.contactUsername.text) is not a Wunderlist User, please enter a valid Wunderlist username", delegate: nil, cancelButtonTitle: "Ok")
                
                alert.show()
                
                
                
            }
        }
        
        
    }

    
}
