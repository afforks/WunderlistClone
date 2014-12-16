//
//  UserViewController.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-10-07.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit

// VC with all the lists of the user


class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userEmail: UILabel!
    
    var originalUserOfList: PFUser? = nil
    
    
    
    
    // array containing Dictionaries of lists
    var arrayOfListsDictionaries = [Dictionary<String, AnyObject>]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        // if there is a parse user connected show the name and username of the user
        
        let user = PFUser.currentUser() as PFUser!
        
        if (user != nil) {
            
            
            
            userName.text = user.objectForKey("username") as? String
            userEmail.text = user.objectForKey("email") as? String
        }
        
        
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.arrayOfListsDictionaries.removeAll(keepCapacity: false)
        self.loadListsWhereWeAreTheOwner()
        self.tableView.reloadData()
        
        
        
        
        
        
    }
    
    func viewDidAppear() {
        super.viewDidLoad()
        
        
        
        let user = PFUser.currentUser() as PFUser!
        
        // if there is a parse user connected show the name and username of the user
        if (user != nil) {
            
            
            
            userName.text = user.objectForKey("username") as? String
            userEmail.text = user.objectForKey("email") as? String
        }
        
        
        
        
        
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView.reloadData()
        
        
        
        
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    // load the lists where the user is the owner
    
    func loadListsWhereWeAreTheOwner() -> Bool {
        
        
        
        if (Reachability.isConnectedToNetwork()) {
            
            
            
            
            var query = PFQuery(className:"List")
            
            query.whereKey("user", equalTo: PFUser.currentUser())
            
            query.orderByAscending("createdAt")
            
            
            query.findObjectsInBackgroundWithBlock() {
                (objects:[AnyObject]!, error:NSError!)->Void in
                if ((error) == nil) {
                    
                    for object in objects {
                        
                        
                        
                        let list:PFObject = object as PFObject
                        
                        
                        
                        
                        
                        if (list["name"] != nil) {
                            
                            
                            
                            let listname = list["name"] as String
                            let listUser = list["user"] as PFUser
                            let shared = list["shared"] as Bool
                            
                            // if they are items in our lists, count the items and add create a dictionary with the keys corresponding to our listName and to the numberOfItems in our list. Add to our arrayOfListDictionaries
                            if list["items"] != nil {
                                var itemsArray = list["items"] as NSMutableArray
                                
                                list["numberOfItems"] = itemsArray.count
                                
                                
                                
                                var listDictionary = ["listName": listname, "itemsCount": itemsArray.count, "listUser": listUser, "shared": shared]
                                self.arrayOfListsDictionaries.append(listDictionary as Dictionary)
                                
                                list.saveInBackground()
                            }
                                
                                // if they are items no items in lists,  create a dictionary with the keys corresponding to our listName and to the numberOfItems in our list (in this case 0). Add to our arrayOfListDictionaries
                            else {
                                var listDictionary = ["listName": listname, "itemsCount": 0, "listUser": listUser, "shared": shared]
                                
                                self.arrayOfListsDictionaries.append(listDictionary as Dictionary)
                            }
                            
                            
                        }
                        
                        
                        
                        
                    }
                    
                    
                    
                    // After loading the lists where we are the owner, load the list that other users has shared with user
                    self.loadListsWhereWeAreContacts()
                    self.tableView.reloadData()
                }
                
                
                
            }
            
            
            
            
            
            
        }
        
        
        
        var finished = true
        return finished
    }
    
    // load the list that other users has shared with user
    func loadListsWhereWeAreContacts() -> Bool{
        
        
        
        if (Reachability.isConnectedToNetwork()) {
            
            
            var query = PFQuery(className:"List")
            
            
            
            query.orderByAscending("createdAt")
            
            // return all the lists
            query.findObjectsInBackgroundWithBlock() {
                (objects:[AnyObject]!, error:NSError!)->Void in
                if ((error) == nil) {
                    
                    
                    for object in objects {
                        
                        
                        
                        
                        
                        
                        
                        let list:PFObject = object as PFObject
                        
                        // take the array containing the objectIds of the users which are given access to the list
                        
                        var contactsArray = list["contacts"] as? NSMutableArray
                        
                        if contactsArray != nil {
                            var contactsArray = contactsArray as NSMutableArray!
                            
                            
                            for contactUsername in contactsArray! {
                                
                                // if the contactId is equal to our contactId, then take the info of the listDictionary and add it to our arrayOfListsDict
                                
                               
                                println(PFUser.currentUser().username)

                                if contactUsername as NSString  == PFUser.currentUser().username! {
                                    
                                    println("YES")
                                    println(contactUsername)
                                    println(PFUser.currentUser().username)
                                    
                                        if (list["name"] != nil) {
                                        let listname = list["name"] as String
                                        
                                        if list["items"] != nil {
                                            var itemsArray = list["items"] as NSMutableArray
                                            list["numberOfItems"] = itemsArray.count
                                            
                                            list.saveInBackground()
                                            
                                            
                                            // add the owner of the list to our dictionary
                                            var ownerOfList: PFUser? = nil
                                            if list["user"] != nil {
                                                ownerOfList = list["user"] as? PFUser
                                                
                                            }
                                            var listDictionary = ["listName": listname, "itemsCount": itemsArray.count, "listUser": ownerOfList!, "shared": true]
                                            
                                            
                                            self.arrayOfListsDictionaries.append(listDictionary as Dictionary)
                                        }
                                            
                                            
                                            // if there are no items
                                        else {
                                            var originalUser: PFUser? = nil
                                            if list["user"] != nil {
                                                originalUser = list["user"] as? PFUser
                                                
                                                
                                            }
                                            
                                            var listDictionary = ["listName": listname, "itemsCount": 0, "listUser": originalUser!, "shared": true]
                                            
                                            
                                            
                                            self.arrayOfListsDictionaries.append(listDictionary as Dictionary)
                                        }
                                        
                                        self.tableView.reloadData()
                                        
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                        
                        
                        
                        
                    }
                    
                }
                
                
                
            }
            
            
        }
        
        
        var finished = true
        return finished
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfListsDictionaries.count
    }
    
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? ListTableViewCell
        
        
        
        if (cell == nil) {
            let cell = ListTableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
            
        }
        
        
        
        // take the info of the listDictionary and add the listName and the number of items to our cell
        var listDictionary = arrayOfListsDictionaries[indexPath.row] as NSDictionary
        var listName = listDictionary.objectForKey("listName") as String
        var itemsCount = listDictionary.objectForKey("itemsCount") as NSNumber
        var itemsCountString = "\(itemsCount)"
        var shared = listDictionary.objectForKey("shared") as? Bool
        
        cell!.cellTextLabel!.text =  listName
        cell!.numberOfItemsLabel!.text = itemsCountString
        
        
        
        // the first four cells correspond to the Inbox, Starred, Today and Week lists. Each have a specific image.
        if (indexPath.row == 0) && (cell!.cellTextLabel!.text == "Inbox") {
            var starImage: UIImage = UIImage(named: "Inbox")!
            
            
            cell!.cellImage!.clipsToBounds = true
            
            
            
            cell!.cellImage!.image = starImage
        }
            
            
        else if (indexPath.row == 1) && (cell!.cellTextLabel!.text == "Starred") {
            var starImage: UIImage = UIImage(named: "Starred")!
            
            
            cell!.cellImage!.clipsToBounds = true
            
            
            
            cell!.cellImage!.image = starImage
        }
            
            
        else if (indexPath.row == 2 || indexPath.row == 3) && (cell!.cellTextLabel!.text == "Today" || cell!.cellTextLabel!.text == "Week") {
            var starImage: UIImage = UIImage(named: "calendar")!
            
            
            cell!.cellImage!.clipsToBounds = true
            
            
            
            cell!.cellImage!.image = starImage
        }
            
            
            // the other cells have a different image if they are shared with other users or not
        else {
            
            if (shared != nil) {
                
                if shared == true {
                    var sharedImage: UIImage = UIImage(named: "shared")!
                    cell!.cellImage!.clipsToBounds = true
                    cell!.cellImage!.image = sharedImage
                }
                    
                else {
                    var bulletImage: UIImage = UIImage(named: "bulletList")!
                    cell!.cellImage!.clipsToBounds = true
                    cell!.cellImage!.image = bulletImage
                }
                
                
            }
                
            else {
                var bulletImage: UIImage = UIImage(named: "bulletList")!
                cell!.cellImage!.clipsToBounds = true
                cell!.cellImage!.image = bulletImage
            }
            
        }
        
        
        // make the background a little transparent
        cell!.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        
        // make the cell blue when selected
        var selectedView = UIView()
        selectedView.backgroundColor = UIColor(red:0,green:0.4,blue:1,alpha:0.2)
        cell!.selectedBackgroundView = selectedView
        
        return cell!
        
    }
    
    
    
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let cell: ListTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as ListTableViewCell!
        
        var listName = ""
        if cell.cellTextLabel!.text != "" {
            listName = cell.cellTextLabel!.text!
        }
        
        if listName != "" {
            
            // transfer necessary info (listName, owner of the list) to the VC presenting the items in the list
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let vc = storyboard.instantiateViewControllerWithIdentifier("userTBC") as itemsOfListTabBarController;
            
            
            vc.listName = listName
            
            var listDictionary = arrayOfListsDictionaries[indexPath.row] as NSDictionary
            
            
            var ownerOfTheList = listDictionary.objectForKey("listUser") as? PFUser
            
            if ownerOfTheList != nil {
                vc.originalUserOfList = ownerOfTheList
                // if we are the ownerOfTheList, transfer that information to the itemsVc
                if ownerOfTheList == PFUser.currentUser() {
                    
                    vc.areWeOriginalUserOfList = true
                    
                }
            }
            
            else {
                vc.originalUserOfList = PFUser.currentUser()
                vc.areWeOriginalUserOfList = true

            }
          
            
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
        
    }
    
    // if we click on the + tabBarItem, the nshow the AddListVC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "userToAddListVC" {
            let viewController:AddListViewController = segue.destinationViewController as AddListViewController
            
        }
    }
    
    // If we click the logout button then show alert
    @IBAction func logOut(sender: AnyObject) {
        
        var alert:UIAlertView = UIAlertView(title: "Message", message: "Are you sure want to logout?", delegate: self, cancelButtonTitle: "NO", otherButtonTitles: "YES")
        
        alert.tag = 1
        
        alert.show()
        
    }
    
    // If we logout, return to the WelcomeVC
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int)
    {
        if (alertView.tag == 1)
        {
            if(buttonIndex == 1)
            {
                
                let user = PFUser.currentUser() as PFUser
                PFUser.logOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let vc = storyboard.instantiateViewControllerWithIdentifier("welcomeVC") as WelcomeViewController
                
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else
        {
            return
        }
        
    }
    
    
    
    // can't edit the first four standard lists (Inbox, starred, today, week)
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        
        if indexPath.row > 3 {
            return true
        }
        else {
            return false
        }
    }
    
    
    
    // remove the list from the tableView and from parse
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            var listDict = self.arrayOfListsDictionaries[indexPath.row] as Dictionary
            
            var listName: AnyObject? = listDict["listName"]
            var listNameString = listName as String
            self.arrayOfListsDictionaries.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
            
            self.removeList(listNameString)
            
            
            
            
        }
    }
    
    
    // remove the list from parse
    func removeList(listName: String) {
        
        var query = PFQuery(className:"List")
        
        query.whereKey("user", equalTo: PFUser.currentUser())
        
        query.whereKey("name", equalTo: listName)
        
        // query.findObjects:
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                
                for object in objects {
                    
                    
                    
                    
                    
                    
                    
                    let list:PFObject = object as PFObject
                    
                    list.deleteInBackground()
                    list.saveInBackground()
                    
                }
                
            }
            
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
    
    
    
}

