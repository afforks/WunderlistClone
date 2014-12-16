//
//  AddListViewController.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-10-05.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit
import CoreData



class AddListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addContactProtocol {
    
    
    
    

    @IBOutlet weak var addListLabel: UITextField!
    
    @IBOutlet weak var addContactLabel: UITextField!
    
    @IBOutlet weak var addContactTableView: UITableView!
    
    var contactsArray = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        addListLabel.becomeFirstResponder()
        
        
        self.addContactTableView.delegate = self
        self.addContactTableView.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet, withEvent: UIEvent) {
        self.view.endEditing(true)
    }
    
    // textFieldDelegate methods
    
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        // in this case, keyboard=firstResponder, so if finished it resigns
        addListLabel.resignFirstResponder()
        
        
        return true
        
    }
    
    // if is not connected addList to offlineList in coreData, and when connected again add offline to parse and delete offlineLists in coreData
    
    
    
    @IBAction func addList(sender: AnyObject) {
        
        
        
        if addListLabel.text != "" {
            var listName = addListLabel.text
            
            
            
            if (Reachability.isConnectedToNetwork()) {
                var list:PFObject = PFObject(className: "List")
                list["name"] = listName
                list["user"] = PFUser.currentUser()
                
                
                list["contacts"] = self.contactsArray
                
                
                
                if self.contactsArray.count > 0 {
                    list["contacts"] = self.contactsArray
                    list["shared"] = true
                    
                    var storyboard = UIStoryboard(name: "Main", bundle: nil);
                    var vc = storyboard.instantiateViewControllerWithIdentifier("userTBC") as UserTabBarController;
                    
                    vc.listName = self.addListLabel.text
                    
                    vc.originalUserOfList = PFUser.currentUser()
                    vc.areWeOriginalUserOfList = true
                    
                    list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                        
                        
                        self.navigationController!.pushViewController(vc, animated: true)
                        
                        
                    })

                }
                
          
                    // if list is not shared with any user
                else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    var vc = storyboard.instantiateViewControllerWithIdentifier("userTBC") as UserTabBarController;
                    
                    vc.listName = self.addListLabel.text
                    
                    vc.areWeOriginalUserOfList = true
                    vc.originalUserOfList = PFUser.currentUser()
                    
                    list["contacts"] = []
                    list["shared"] = false
                    list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                        
        
                        self.navigationController!.pushViewController(vc, animated: true)
                        
                        

                    })
                    
                }
                
                
                
                
                
            }
            
            
            
            
        }
        
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        
        
        return self.contactsArray.count + 1
        
        
    }
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        

            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? addContactTableViewCell
            cell!.delegate = self
            
            
            
            
            
            
            
            
            return cell!
       

       
            
        
       
        
        
        
    }
    

    
    func addContact(cellText: String) {
        
        
        
        
        if cellText != "" {
            /*
            self.itemDictSubtaskList.append(cellText)
            
            self.itemDictionary["subtaskList"] = self.itemDictSubtaskList
            
            */
            self.contactsArray.addObject(cellText)
            
            
            
            self.updateViewSizes()
            
            
            self.addContactTableView.reloadData()
            
            
         
            
      
        }
        
        
    }
    
    
   
    
    func checkIfUsernameIsValidThenAddIfValid(cellText: String) {
        
        var query = PFQuery(className:"_User")
        
        query.whereKey("username", equalTo: cellText)
        
        
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if (objects.count > 0) {
                
                self.contactsArray.addObject(cellText)
                
                
                self.addContactLabel.enabled = false
                self.updateViewSizes()
               
                
                self.addContactTableView.reloadData()
                
            
                

            }
            
            else {
                
                self.addContactLabel.enabled = true
                self.addContactLabel!.text == ""
                var alert:UIAlertView = UIAlertView(title: "message", message: "\(self.addContactLabel.text) is not a Wunderlist User, please enter a valid Wunderlist username", delegate: nil, cancelButtonTitle: "Ok")
                
                alert.show()
                
                
                
            }
        }
        
       
    }
    
    func tableView(tableView:  UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        return 44
        
    }
    
     
    
    func  updateViewSizes() {
        
        
        self.addContactTableView.frame.size.height += 44
        
        /*
        self.addContactHeightConstraint.constant = addContactTableView.frame.size.height
        self.addContactButton.frame.origin.y += 44
        */
        
        self.addContactTableView.reloadData()
        
    }
    
    
    
    
    
}




/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
// Get the new view controller using segue.destinationViewController.
// Pass the selected object to the new view controller.
}
*/


