//
//  UserTabBarController.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-10-04.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit


// VC with all the items inside a particular list of the user

protocol changeDueDateProtocol {
    func changeDueDate(dueDate: String)
}

class itemsOfListTabBarController: UIViewController, UITableViewDelegate, UITableViewDataSource, changeDueDateProtocol {
    
    
    // the four tab bar items at the bottom
    @IBOutlet weak var shareTabBarItem: UITabBarItem!
    @IBOutlet weak var publishTabBarItem: UITabBarItem!
    @IBOutlet weak var sortTabBarItem: UITabBarItem!
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    
    
    
    var listName: String = String()
    var originalUserOfList: PFUser? = nil
    
    var areWeOriginalUserOfList: Bool? = nil
    var starred = Bool()
    
    var itemsDict = Array<Dictionary<String, AnyObject>>()
    
    var tableFooterView: UIView?
    
    var arrayOfOriginalListNames = NSMutableArray()
    
    var arrayOfOriginalListsDict = NSMutableArray()
    
    var arrayOfDatedDictionaries = NSMutableArray()
    
    
    var arrayOfCheckedDictionaryItems = NSMutableArray()
    
    
    @IBOutlet weak var tableView: UITableView!
    
   @IBOutlet weak var checkedItemsTableView: UITableView!
    @IBOutlet weak var addItemLabel: UITextField!
    
    @IBOutlet weak var addItemButton: UIButton!
    
    var lastTwoDatesEqual = Bool()
    
    var currentDueDateDictionary = Dictionary<String, AnyObject>()
    
    
    var putStarredItemAtTop = Bool()
    
    
    
    @IBOutlet weak var backgroundView: UIImageView!
    
 
    @IBOutlet weak var showCheckedItemsButton: UIButton!
    
    var checkedItemsHidden: Bool = true
    
    var checkedItemString: String!
    override func viewDidLoad() {
        
    
        
        super.viewDidLoad()
        
        
        self.tableView.delegate = self
  
        self.checkedItemsTableView.hidden = true
       
        self.showCheckedItemsButton.titleLabel!.text = checkedItemString
        
        self.backgroundView.contentMode = UIViewContentMode.ScaleToFill

        if globalBackgroundImage != nil {
            self.backgroundView.image = globalBackgroundImage!
        }
        
    
         //  self.checkedItemsTableView.tag = 1000
        
      self.checkedItemsTableView.delegate = self
      self.checkedItemsTableView.dataSource = self
     
  //   self.checkedItemsTableView.reloadData()

        // if it is the WeekList, we can't add item
        if self.listName == "Week" {
            self.addItemLabel.hidden = true
            self.addItemButton.hidden = true
        }
        
        
        setTabBarItemsTitles()
        
        
        self.navigationItemTitle.title = self.listName as String
        
        
        
        // return the correctArray
        self.itemsDict.removeAll(keepCapacity: false)
        self.loadData()
        
        
        
        
        
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = self.tableFooterView
        
       
        self.checkedItemsTableView.alpha = 0.5
        self.checkedItemsTableView.tableFooterView = self.tableFooterView
        self.checkedItemsTableView.separatorInset = UIEdgeInsetsZero
        self.checkedItemsTableView.layoutMargins = UIEdgeInsetsZero
        self.checkedItemsTableView.layer.cornerRadius = 3

        
        // create a custom back button, so that the data gets updated when we return to the prevous vc
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        var myBackButton:UIButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        myBackButton.addTarget(self, action: "popToRoot:", forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setTitle("Back", forState: UIControlState.Normal)
        myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        myBackButton.sizeToFit()
        var myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        self.tableView.separatorStyle = .None
        
        
    }
    
    
    
    
    
    
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: ListViewController, animated: Bool) {
        self.navigationController?.popToViewController(ListViewController(), animated: true)
        
    }
    
    
    // instantiate and push, so that the data gets updated when we go back to the previous vc
    func popToRoot(sender:UIBarButtonItem){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("userVC") as ListViewController
        
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    // load items of the list
    func loadData() {
        
        
        
        if (Reachability.isConnectedToNetwork()) {
            
            
            // make sure the array is empty at first
            self.itemsDict.removeAll(keepCapacity: false)
    
            var query = PFQuery(className:"List")
            
            
            
            
            // the user is the owner of the list
            query.whereKey("user", equalTo: self.originalUserOfList!)
            query.whereKey("name", equalTo: self.listName)
            
            
            println("ORIGINALUSER")
            println(self.originalUserOfList!)
            
            query.orderByAscending("createdAt")
            
            // query.findObjects:
            query.findObjectsInBackgroundWithBlock() {
                (objects:[AnyObject]!, error:NSError!)->Void in
                if ((error) == nil) {
                    
                    // for each item transfer relevant data to an item dictionary, then add to our array of items dict
                    if objects.count > 0 {
                        var list: PFObject = objects.last as PFObject
                        
                        var arrayItems = list["items"] as? NSMutableArray
                        
                        
                        
                        if arrayItems != nil {
                            
                            
                            for item in arrayItems!  {
                                
                                let itemName = item["name"] as String
                                
                                
                                
                                var itemDict = Dictionary<String, AnyObject>()
                                
                                itemDict["name"] = itemName
                                
                                
                                let itemStarred = item["starred"]
                                
                                if itemStarred != nil {
                                    
                                    
                                    
                                    
                                    var itemStarredString = itemStarred as? String
                                    if itemStarredString != nil {
                                        itemDict["starred"] = itemStarredString
                                        if itemStarredString == "true" {
                                            self.starred = true
                                        }
                                            
                                        else if itemStarredString == "false" {
                                            self.starred = false                                    }
                                    }
                                    
                                }
                                
                                let itemDueDate = item["dueDate"]
                                
                                if itemDueDate != nil {
                                    
                                    itemDict["dueDate"] = itemDueDate as? NSDate
                                    
                                }
                                
                                let itemOriginalUser = item["originalUser"]
                                if itemOriginalUser != nil {
                                    itemDict["originalUser"] = itemOriginalUser
                                }
                                
                                
                                let itemOriginalList = item["originalList"]
                                if itemOriginalList != nil {
                                    itemDict["originalList"] = itemOriginalList
                                }
                                
                                
                                let itemChecked = item["checked"]
                                
                                if itemChecked != nil {
                                    
                                    itemDict["checked"] = itemChecked as? String
                                 
                                   
                                    let itemCheckedString = itemChecked as String?
                                    if (itemCheckedString == "true") {
                                        self.arrayOfCheckedDictionaryItems.addObject(itemDict)
                                        
                                    }


                                    
                                }
                                
                               
                                
                                
                                
                                
                                
                                if (self.listName == "Today" || self.listName == "Starred") {
                                    
                                    
                                    
                                    self.addItemToCorrespondingOriginalListDict(item as Dictionary<String, AnyObject>)
                                    
                                    
                                }
                                
                                if itemStarred != nil {
                                    
                                    
                                    
                                    
                                    var itemStarredString = itemStarred as? String
                                    if itemStarredString != nil {
                                        itemDict["starred"] = itemStarredString
                                        if itemStarredString == "true" {
                                          self.itemsDict.insert(itemDict, atIndex: 0)
                                            continue;
                                        }
                                        
                                        else {
                                            
                                        }
                                    }
                                    
                                }

                                
                                
                                self.itemsDict.append(itemDict)
                                
                                
                            }
                            
                            
                            if self.listName == "Week" {
                                
                                // for all items in the list, put the ones with the same dueDate in the same dictionary
                                self.sortWeekListElementsByDate()
                            }
                            
                            
                            
                        }
                        
                        
                    }
                    
                }
                
                self.tableView.reloadData()
                self.checkedItemsTableView.reloadData()
            }
            
            
        }
        
        
        
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // add each item to a dictionary containing only other items from the same original list
    func addItemToCorrespondingOriginalListDict(item: Dictionary<String, AnyObject>) {
        var itemOriginalList = item["originalList"] as NSString!
        var itemOriginalUser = item["originalUser"] as PFUser!
        var itemName = item["name"] as NSString!
        
        if itemOriginalList != nil {
            
            
            
            var itemOriginalListString = itemOriginalList as String!
            
            // check in our array of original list name, if our listName is there. If not: create a new dictionary representing the original list and add our item to our array of dicts
            if !(self.arrayOfOriginalListNames.containsObject(itemOriginalListString)) {
                self.arrayOfOriginalListNames.addObject(itemOriginalListString)
                
                var dictionary = [String: AnyObject]()
                dictionary["originalList"] = itemOriginalListString
                dictionary["originalUser"] = itemOriginalUser as PFUser!
                var itemsArray = NSMutableArray()
                
                
                itemsArray.addObject(item)
                
                dictionary["items"] = itemsArray
                self.arrayOfOriginalListsDict.addObject(dictionary)
                
                
            }
                
                // if our listName is already in our array of original list names, then there is already a dictionary corresponding to our originalList so add our item to this dictionary
            else {
                for dict in self.arrayOfOriginalListsDict {
                    
                    
                    var dict:Dictionary = dict as Dictionary<String, AnyObject>
                    var originalListDict: AnyObject? = dict["originalList"]
                    
                    var originalListDictString = originalListDict as String
                    if itemOriginalListString == originalListDictString {
                        
                        // remove old dict representing the original list
                        self.arrayOfOriginalListsDict.removeObject(dict)
                        
                        
                        
                        var itemsDict = dict["items"] as NSMutableArray
                        var itemsArray = itemsDict as NSMutableArray
                        
                        // add our item to the array
                        itemsArray.addObject(item)
                        
                        dict["items"] = itemsArray as NSMutableArray
                        
                        // add the dict representing the original list to the array of dicts
                        self.arrayOfOriginalListsDict.addObject(dict)
                        
                        
                        
                    }
                }
                
            }
            
        }
    }
    
    
    
    var temp = 0
    
    // for all items in the list, put the ones with the same dueDate in the same dictionary
    func sortWeekListElementsByDate() {
        if self.listName == "Week" && self.itemsDict.count > 0 {
            
            
            // create a function to sort two dictionaries by their dueDate
            var sortedArray = sorted(self.itemsDict) {
                (dictOne, dictTwo)  in
                
                var dictOneDateObject: AnyObject? =  dictOne["dueDate"]
                var dictTwoDateObject: AnyObject? =  dictTwo["dueDate"]
                
                var dictOneDate =  dictOne["dueDate"] as NSDate
                var dictTwoDate =  dictTwo["dueDate"] as NSDate
                
                
                return dictOneDate.compare(dictTwoDate) == NSComparisonResult.OrderedAscending
            }
            
            
            // our items are now all sorted by their dueDate
            
            self.itemsDict = sortedArray
            
            
            
            
            
            var indexOfArray: Int? = nil
            
            //  loop through the first element to the one before the last
            // Our items are already sorted by date, but we want to add each one in a dictionary corresponding to their dueDate. So, we compare every item with the next one in the sorted array, and if it is not the same date, we create a second dictionary corresponding to another due date for the second item
            
            for i in 0...self.itemsDict.count-1 {
                
                if self.itemsDict.count < 1  {
                    return
                }
                
                if self.itemsDict.count > 1 && (i == self.itemsDict.count-1 ) {
                    return
                }
                
                
                
                var dictOne = self.itemsDict[i]
                
                
                var dictOneDate =  dictOne["dueDate"]! as NSDate
                
                
                
                let calendar = NSCalendar.currentCalendar()
                let timeZone = NSTimeZone(name: "UTC")
                calendar.timeZone = timeZone!
                
                
                let dictOneDateComponents = calendar.components(.CalendarUnitDay | .CalendarUnitWeekOfYear | .CalendarUnitYear, fromDate: dictOneDate)
                let dateOneDay = dictOneDateComponents.day
                let dateOneWeek = dictOneDateComponents.weekOfYear
                let dateOneYear = dictOneDateComponents.year
                var dictOneNameObject: AnyObject? =  dictOne["name"]
                var dictOneName =  dictOneNameObject as String
                
                
                // for the first element, create a dictionary corresponding to the dueDate of the firstElement and add the item to this dictionary
                if i == 0 {
                    
                    
                    
                    self.temp = 0
                    var newDict = Dictionary<String, AnyObject>()
                    newDict["dueDate"] = dictOneDate
                    
                    var itemsArray = NSMutableArray()
                    itemsArray.addObject(dictOne)
                    newDict["items"] = itemsArray
                    
                    
                    
                    arrayOfDatedDictionaries.addObject(newDict)
                    
                    
                    
                }
                
                
                // if there is more than one element, take the second one, and compare its dueDate with the element before. If they don't have the same duedate create a newdict corresponding to the duedate of the second item and add the second item to it
                if self.itemsDict.count > 1 {
                    
                    var dictTwo = self.itemsDict[i+1]
                    
                    var dictTwoDate =  dictTwo["dueDate"]! as NSDate
                    
                    
                    let dictTwoDateComponents = calendar.components(.CalendarUnitDay | .CalendarUnitWeekOfYear | .CalendarUnitYear, fromDate: dictTwoDate)
                    let dateTwoDay = dictTwoDateComponents.day
                    
                    let dateTwoWeek = dictTwoDateComponents.weekOfYear
                    
                    let dateTwoYear  = dictTwoDateComponents.year
                    
                    
                    
                    var dictTwoNameObject: AnyObject? =  dictTwo["name"]
                    
                    
                    var dictTwoName =  dictTwoNameObject as String
                    
                    
                    // if this item and the next one are the same date, no need to create a new dictionary for the second dictionary corresponding to a new duedate for the next item, just add the next item to the same dictionary as this item
                    
                    if (dateOneDay == dateTwoDay) && (dateTwoWeek == dateTwoWeek) && (dateOneYear == dateTwoYear) {
                        
                        
                        
                        var lastDictObject: AnyObject = arrayOfDatedDictionaries[self.temp]
                        var lastDict = lastDictObject as Dictionary<String, AnyObject>
                        
                        
                        
                        var itemsArrayObject: AnyObject? = lastDict["items"]
                        
                        if itemsArrayObject != nil {
                            
                            
                            var itemsArray = itemsArrayObject as NSMutableArray
                            
                            
                            arrayOfDatedDictionaries.removeObject(lastDict)
                            itemsArray.addObject(dictTwo)
                            
                            
                            lastDict["items"] = itemsArray
                            
                            arrayOfDatedDictionaries.addObject(lastDict)
                            
                            
                            
                        }
                        
                        
                    }
                        
                        // if this item and the next are not the same date, then create a new dictionary for the second one and add the second item to this dictionary
                        
                    else {
                        
                        self.temp += 1
                        
                        
                        var newDict = Dictionary<String, AnyObject>()
                        newDict["dueDate"] = dictTwoDate
                        var itemsArray = NSMutableArray()
                        itemsArray.addObject(dictTwo)
                        newDict["items"] = itemsArray
                        
                        arrayOfDatedDictionaries.addObject(newDict)
                        
                        
                    }
                    
                }
            }
            
            
            
            
            
            
            
            
            
        }
        
        
        
    }
    
    
    
    
    @IBAction func addItem(sender: UIButton) {
        
        
        if addItemLabel.text != ""  {
            
            
            if (Reachability.isConnectedToNetwork()) {
                
                
                var query = PFQuery(className:"List")
                
                
                
                
                var user = self.originalUserOfList!
                
                
                
                query.whereKey("user", equalTo:user)
                
                
                query.whereKey("name", equalTo: self.listName)
                
                // query.findObjects:
                query.findObjectsInBackgroundWithBlock() {
                    (objects:[AnyObject]!, error:NSError!)->Void in
                    if ((error) == nil) {
                        if objects.count > 0 {
                            var list: PFObject = objects.last as PFObject!
                            
                            
                            var itemsArray = list["items"] as? NSMutableArray
                            
                            if itemsArray != nil {
                                
                                var itemName = self.addItemLabel.text
                                var newItemDict = ["name": self.addItemLabel.text, "originalUser": user]
                                
                                
                                
                                if self.listName == "Starred" || self.listName == "Today" {
                                    
                                    newItemDict["originalList"] = "Inbox"
                                    
                                    
                                    
                                    if self.listName == "Starred" {
                                        
                                        newItemDict["starred"] = "true"
                                        
                                    }
                                    
                                    if self.listName == "Today" {
                                        newItemDict["starred"] = "false"
                                        newItemDict["dueDate"] = NSDate()
                                        
                                    }
                                    
                                    // add each item to a dictionary containing only other items from the same original list
                                    self.addItemToCorrespondingOriginalListDict(newItemDict)
                                    
                                    self.addOrRemoveItemDictToOtherList("Inbox", itemDict: newItemDict, remove: false)
                                    
                                }
                                    
                                else {
                                    newItemDict["starred"] = "false"
                                    newItemDict["originalList"] = self.listName
                                }
                                itemsArray!.addObject(newItemDict)
                                
                                list["items"] = itemsArray
                                list["numberOfItems"] = itemsArray!.count
                                
                                
                                
                                list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                                    
                                    if self.listName == "Starred" || self.listName == "Today" {
                                        self.tableView.reloadData()
                                    }
                                        
                                    else {
                                        self.loadData()
                                    }
                                    
                                })
                                
                                
                            }
                                
                            else {
                                var newItemsArray = NSMutableArray()
                                
                                var itemName = self.addItemLabel.text
                                var newItemDict = ["name": self.addItemLabel.text, "originalUser": user]
                                
                                if self.listName == "Starred" || self.listName == "Today" {
                                    
                                    newItemDict["originalList"] = "Inbox"
                                    
                                    
                                    
                                    if self.listName == "Starred" {
                                        
                                        newItemDict["starred"] = "true"
                                        
                                    }
                                    
                                    if self.listName == "Today" {
                                        
                                    }
                                    
                                    self.addItemToCorrespondingOriginalListDict(newItemDict)
                                    
                                    self.addOrRemoveItemDictToOtherList("Inbox", itemDict: newItemDict, remove: false)
                                    
                                }
                                    
                                else {
                                    newItemDict["originalList"] = self.listName
                                }
                                
                                
                                newItemsArray.addObject(newItemDict)
                                
                                list["items"] = newItemsArray
                                list["numberOfItems"] = newItemsArray.count
                                list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                                    
                                    if self.listName == "Starred" || self.listName == "Today" {
                                        self.tableView.reloadData()
                                    }
                                        
                                    else {
                                      
                                        self.loadData()
                                    }
                                })
                                
                            }
                            
                            
                            
                            
                            
                            
                        }
                        
                    }
                    
                }
                
                
                
            }
            
            
            
        }
        
        
    }
    
    
    
    // add each item to a dictionary containing only other items from the same original list
    func addOrRemoveItemDictToOtherList(listName: String, itemDict: Dictionary<String, AnyObject>, remove: Bool) {
        
        if (Reachability.isConnectedToNetwork()) {
            
            
            
            var query = PFQuery(className:"List")
            
            var user: PFUser? = nil
            if itemDict["originalUser"] != nil {
                user = itemDict["originalUser"] as PFUser!
                
            }
            else {
                if self.areWeOriginalUserOfList == true {
                    user = PFUser.currentUser()
                    
                }
                    
                else {
                    user = self.originalUserOfList!
                }
            }
            
            query.whereKey("user", equalTo: user!)
            query.whereKey("name", equalTo: listName)
            
            // query.findObjects:
            query.findObjectsInBackgroundWithBlock() {
                (objects:[AnyObject]!, error:NSError!)->Void in
                if ((error) == nil) {
                    
                    var list = objects.last as PFObject!
                    
                    
                    
                    var itemsArray = list["items"] as? NSMutableArray
                    
                    if (itemsArray!.count > 0) {
                        
                        
                        
                        
                        var itemNameObject: AnyObject? = itemDict["name"]
                        
                        var itemNameString = itemNameObject as String
                        
                        // remove old item if already there
                        
                        
                        if remove == false {
                            
                            
                            for item in itemsArray! {
                                
                                // the item is already there so don't add it another time
                                var itemString = item["name"] as String
                                if itemString == itemNameString {
                                    // remove old object
                                    itemsArray!.removeObject(item)
                                }
                                
                            }
                            
                            
                            
                            itemsArray!.addObject(itemDict)
                            list["items"] = itemsArray
                            list["numberOfItems"] = itemsArray!.count
                            
                            list.saveInBackground()
                        }
                            
                        else {
                            
                            
                            
                            for item in itemsArray! {
                                var itemString = item["name"] as String
                                if itemString == itemNameString {
                                    itemsArray!.removeObject(item)
                                    list["items"] = itemsArray
                                    list["numberOfItems"] = itemsArray!.count
                                    
                                    list.saveInBackground()
                                }
                                
                                
                                
                            }
                            
                            
                        }
                    }
                        
                        // if there is no object
                        
                    else {
                        
                        
                        
                        if remove == false {
                            
                            
                            var newItemsArray = NSMutableArray()
                            
                            var item = itemDict
                            
                            newItemsArray.addObject(itemDict)
                            
                            list["items"] = newItemsArray
                            list["numberOfItems"] = newItemsArray.count
                            
                            list.saveInBackground()
                        }
                        
                    }
                    
                    
                    
                    
                }
                
            }
            
            
            // if there is no list in today or week list
            
            
            
            
        }
        
        
        
    }
    
    
    
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String? {
        if (self.listName == "Starred" || self.listName == "Today") && (tableView != checkedItemsTableView){
            var dictionary: AnyObject = self.arrayOfOriginalListsDict[section]
            
            
            var itemsOriginalList = dictionary["originalList"] as String
            
            return itemsOriginalList
        }
        
        if self.listName == "Week" && (tableView != checkedItemsTableView) {
            var dictionary: AnyObject = self.arrayOfDatedDictionaries[section]
            
            
            
            var dueDate = dictionary["dueDate"] as NSDate
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "EEEE, MMM d"
            
            let timeZone = NSTimeZone(name: "UTC")
            
            dateFormatter.timeZone = timeZone
            
            var dueDateString = dateFormatter.stringFromDate(dueDate) as String
            
            return dueDateString
        }
            
        else {
            return nil
        }
        
    }
    
    
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView? {
        
        
      
        if (self.listName == "Starred" || self.listName == "Today" || self.listName == "Week") && (tableView != checkedItemsTableView){
            var headerFrame:CGRect = tableView.frame
            
            var title = UILabel(frame: CGRectMake(10, 10,  500, 30))
            
            
            if self.listName == "Starred" || self.listName  == "Today" {
                var dictionary: AnyObject = self.arrayOfOriginalListsDict[section]
                var itemsOriginalList = dictionary["originalList"] as String
                title.text = itemsOriginalList
                title.textColor = UIColor.whiteColor()
                
            }
            
            if self.listName == "Week" {
                var dictionary: AnyObject = self.arrayOfDatedDictionaries[section]
                var dueDate = dictionary["dueDate"] as NSDate
                
                let dateFormatter = NSDateFormatter()
                
                dateFormatter.dateFormat = "EEEE, MMM d"
                
                let timeZone = NSTimeZone(name: "UTC")
                
                dateFormatter.timeZone = timeZone
                
                var dueDateString = dateFormatter.stringFromDate(dueDate) as String
                title.text = dueDateString
                title.textColor = UIColor.whiteColor()
            }
            var headerView:UIView = UIView(frame: CGRectMake(0, 0, headerFrame.size.width, headerFrame.size.height))
            headerView.addSubview(title)
            
            return headerView
        }
            
        else {
            var headerView = UIView()
            headerView.backgroundColor = UIColor.clearColor()
            return headerView
            
        }
        
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        
        if tableView == self.checkedItemsTableView {
          
            return 1
            
        }
        
        
        else {
            
            if self.listName == "Starred" || self.listName == "Today"{
                
                return self.arrayOfOriginalListsDict.count
                
            }
            
            if self.listName == "Week" {
                
                return self.arrayOfDatedDictionaries.count
            }
            
            
            
            return self.itemsDict.count
            
        

        }
      
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if tableView == checkedItemsTableView {
            
            self.checkedItemString = "\(self.arrayOfCheckedDictionaryItems.count) COMPLETED ITEMS"
            
          
            self.showCheckedItemsButton.titleLabel!.text = checkedItemString
            self.showCheckedItemsButton.setTitle(checkedItemString!, forState: UIControlState.Normal)
            self.showCheckedItemsButton.setTitle(checkedItemString!, forState: UIControlState.Selected)
        
            
          return self.arrayOfCheckedDictionaryItems.count
            
      
            
        }
        
        
            
        else {

        
        if self.listName == "Starred" || self.listName == "Today" {
            var dictionary: AnyObject = self.arrayOfOriginalListsDict[section]
            var itemsArray = dictionary["items"] as NSMutableArray
            return itemsArray.count
            }
            
            if self.listName == "Week" {
                var dictionary: AnyObject = self.arrayOfDatedDictionaries[section]
                var itemsArray = dictionary["items"] as NSMutableArray
                return itemsArray.count
            }
        
        }


        
        return 1
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    
    /*

if tableView == checkedItemsTableView {


/*
var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? ItemTableViewCell

if !(cell != nil) {
let cell  = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell") as ItemTableViewCell

}

*/


var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? ItemTableViewCell

if !(cell != nil) {
let cell  = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell") as ItemTableViewCell

}

//  println(self.arrayOfCheckedDictionaryItems[indexPath.row])
//  var item: AnyObject = self.arrayOfCheckedDictionaryItems[indexPath.row]

println(self.arrayOfCheckedDictionaryItems)

// var itemName =  item["listName"]! as String

// cell!.textLabel!.text  = itemName
cell!.cellLabel!.text = "bob"
return cell!


}

*/

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        
        
        
        if tableView == checkedItemsTableView {
            
            
            /*
            var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? ItemTableViewCell
            
            if !(cell != nil) {
            let cell  = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell") as ItemTableViewCell
            
            }
            
            */
            
            
            var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? ItemTableViewCell
            
           
             cell!.separatorInset = UIEdgeInsetsZero
            cell!.layoutMargins = UIEdgeInsetsZero
            
            if !(cell != nil) {
                let cell  = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell") as ItemTableViewCell
                
            }
            
            
        
            if self.listName == "Starred" {
                cell?.starButton.enabled = false
            }
             var item: AnyObject = self.arrayOfCheckedDictionaryItems[indexPath.row]
        
            
          
            if (self.arrayOfCheckedDictionaryItems.count > indexPath.row) {
               
                
                println("ARRAY OF CHECKEDITEMS \(self.arrayOfCheckedDictionaryItems)")
                
                var itemName =  item["name"]! as String
                
                // cell!.textLabel!.text  = itemName
                cell!.cellLabel!.text = itemName
            }
          
            else {
                cell!.cellLabel!.text = ""
            }
            
            
            cell!.checkboxButton.enabled = false
            cell!.starButton.enabled = false
            
            
            cell!.checkboxButton.setBackgroundImage(UIImage(named: "checked_checkbox@2x"), forState: .Normal)
            
        
    
            var itemStarred: AnyObject? = item["starred"]
            if itemStarred != nil  {
                
                var itemStarredString = itemStarred as String
                
                if itemStarredString == "true"{
                    cell!.starButton.selected = true
                    
                    
                    cell!.starButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.63)
                    cell!.starButton.alpha = 0.63
                    
                }
                    
                else {
                    cell!.starButton.selected = false
                    cell!.starButton.backgroundColor = UIColor.clearColor()
                }
                
                
                
            }
                
            else {
                cell!.starButton.selected = false
            }
            
            cell!.starImageView.image = UIImage(named: "Starred")
            
            cell!.starImageView.clipsToBounds = true
            
            cell!.starImageView.contentMode = .ScaleAspectFit
            
           

            return cell!
            
            
        }
        
        
        else {
            
        }

        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? ItemTableViewCell
        
        
        if !(cell != nil) {
            let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"Cell") as ItemTableViewCell
            
        }
        
        
        
        
        cell!.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        
        
        
        cell!.layer.cornerRadius = 3
        
        cell!.tag = 0
        
        var selectedView = UIView()
        selectedView.backgroundColor = UIColor(red:0,green:0.4,blue:1,alpha:0.2)
        selectedView.layer.cornerRadius = 3
        cell!.selectedBackgroundView = selectedView
        
        
        
        
        var listItem: AnyObject
        
        
        if self.listName == "Starred" || self.listName == "Today" {
            
            var itemDict: AnyObject = self.arrayOfOriginalListsDict[indexPath.section]
            
            // array of DICT
            var itemsArray = itemDict["items"] as NSMutableArray
            
            listItem = itemsArray[indexPath.row]
            
            
            var itemName = listItem["name"]! as String
            
            cell!.cellLabel!.text = itemName
            
            
            
            var dueDate: NSDate? = listItem["dueDate"] as? NSDate
            
            if dueDate != nil {
                let dateFormatter = NSDateFormatter()
                
                dateFormatter.dateFormat = "EEE, MMM d"
                
                let timeZone = NSTimeZone(name: "UTC")
                
                dateFormatter.timeZone = timeZone
                
                var dueDateString = dateFormatter.stringFromDate(dueDate!) as String
                
                cell!.subtitle.text = dueDateString
                cell!.subtitle.textColor = UIColor.blueColor()
                
            }
          
            
            
        }
            
        else if self.listName == "Week" {
            var itemDict: AnyObject = self.arrayOfDatedDictionaries[indexPath.section]
            
            // array of DICT
            var itemsArray = itemDict["items"] as NSMutableArray
            
            listItem = itemsArray[indexPath.row]
            
            
            var itemName = listItem["name"]! as String
            
            cell!.cellLabel!.text = itemName
            
            var dueDate: NSDate? = listItem["dueDate"] as? NSDate
            
            if dueDate != nil {
                let dateFormatter = NSDateFormatter()
                
                dateFormatter.dateFormat = "EEE, MMM d"
                
                let timeZone = NSTimeZone(name: "UTC")
                
                dateFormatter.timeZone = timeZone
                
                var dueDateString = dateFormatter.stringFromDate(dueDate!) as String
                
                cell!.subtitle.text = dueDateString
                cell!.subtitle.textColor = UIColor.blueColor()
                
            }
            
        }
            
        else {
            
            
            listItem = itemsDict[indexPath.section]
            var listItemString = listItem["name"]! as String
            cell!.cellLabel!.text = listItemString
            
            var dueDate: NSDate? = listItem["dueDate"] as? NSDate
            
            if dueDate != nil {
                let dateFormatter = NSDateFormatter()
                
                dateFormatter.dateFormat = "EEE, MMM d"
                
                let timeZone = NSTimeZone(name: "UTC")
                
                dateFormatter.timeZone = timeZone
                
                var dueDateString = dateFormatter.stringFromDate(dueDate!) as String
                
                cell!.subtitle.text = dueDateString
                cell!.subtitle.textColor = UIColor.blueColor()
                
            }
        }
        
        
        
        
        cell!.checkboxButton.setBackgroundImage(UIImage(named: "checked_checkbox@2x"), forState: .Selected)
        cell!.checkboxButton.setBackgroundImage(UIImage(named: "unchecked_checkbox@2x"), forState: .Normal)
        
        
        
        
        
        
        var itemChecked: AnyObject? = listItem["checked"]
        if itemChecked != nil {
            
            
            
            
            var itemCheckedString = itemChecked as String!
            
            println("INDEX: \(indexPath.section)")
            println("IS ITEM CHECKED: \(itemCheckedString)")
            if itemCheckedString == "true" {
                cell!.checkboxButton.selected = true
                
                
            }
                
            else {
                cell!.checkboxButton.selected = false
                
            }
            
            
            
        }
            
        else  {
            cell!.checkboxButton.selected = false
        }
        
        
        
        
        
        var itemStarred: AnyObject? = listItem["starred"]
        if itemStarred != nil  {
            
            var itemStarredString = itemStarred as String
            
            if itemStarredString == "true"{
                cell!.starButton.selected = true
                
                
                cell!.starButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.63)
                cell!.starButton.alpha = 0.63
                
            }
                
            else {
                cell!.starButton.selected = false
                cell!.starButton.backgroundColor = UIColor.clearColor()
            }
            
            
            
        }
            
        else {
            cell!.starButton.selected = false
        }
        
        cell!.starImageView.image = UIImage(named: "Starred")
        
        cell!.starImageView.clipsToBounds = true
        
        cell!.starImageView.contentMode = .ScaleAspectFit
    
        if self.listName == "Starred" {
            cell!.starButton.selected = true
            
            
            cell!.starButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.63)
            cell!.starButton.alpha = 0.63

        }
        
        if self.listName == "Today" || self.listName  == "Week" || self.listName == "Starred" {
            
            cell!.checkboxButton.tag = indexPath.section*1000 + indexPath.row
            
            cell!.starButton.tag = indexPath.section*1000 + indexPath.row
        }
            
        else {
            cell!.checkboxButton.tag = indexPath.section
            
            cell!.starButton.tag = indexPath.section
            
        }
        
        
        if cell!.cellLabel.text == "last" {
            println("SECTION: \(indexPath.section)")
            println("Row: \(indexPath.row)")
        }
        
        
        
        return cell!
        
        
        
        
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as ItemTableViewCell!
        cell!.layer.cornerRadius = 3
        
        // 0 = not clicked, 1 = clicked
        cell!.tag = 1
        
        
        
        
        var itemString = cell.cellLabel!.text as String!
        
        var isStarred: String? = nil
        if cell.starButton.selected == true {
            isStarred = "true"
        }
            
        else {
            isStarred = "false"
        }
        
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("itemVC") as itemContentViewController;
        
        if (tableView == self.checkedItemsTableView) {
            
            vc.isChecked = true
            println(" IS VC CHECKED: \(vc.isChecked)")

        }
        vc.itemName = itemString
        vc.delegate = self
        
        
        
        
        
        if self.listName == "Starred" || self.listName == "Today" {
            
            var dictionary: AnyObject = self.arrayOfOriginalListsDict[indexPath.section]
            
            var itemsOriginalList = dictionary["originalList"] as String
            
            
            
            if dictionary["originalUser"] != nil {
                vc.originalUserOfList = dictionary["originalUser"] as? PFUser
                
                
                
            }
            
      
            
         
            
            vc.listName = itemsOriginalList
            vc.starred = isStarred
            
            vc.delegate = self
            
            NSThread.sleepForTimeInterval(0.1)
            
            self.navigationController?.pushViewController(vc, animated: true)
            
            
            
        }
        
        if self.listName == "Week" {
            
            var itemDict: AnyObject = self.arrayOfDatedDictionaries[indexPath.section]
            
            // array of DICT
            var itemsArray = itemDict["items"] as NSMutableArray
            
            
            
            var listItem: AnyObject = itemsArray[indexPath.row]
            
            
            var list: AnyObject? = listItem["originalList"]
            var listString = list as String
            
            
            
            vc.listName = listString
            vc.starred = isStarred
            vc.delegate = self
            
            
            if listItem["originalUser"] != nil {
                vc.originalUserOfList = listItem["originalUser"] as? PFUser
                
            }
            
            NSThread.sleepForTimeInterval(0.1)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
            
            
        else if self.listName != "Week" && self.listName != "Starred" && self.listName != "Today" {
            vc.listName = self.listName
            vc.starred = isStarred
            vc.delegate = self
            if originalUserOfList != nil {
                vc.originalUserOfList = originalUserOfList
                
                
                
            }
                
            else {
                vc.areWeOriginalUserOfList == true
                vc.originalUserOfList = PFUser.currentUser()
                vc.delegate = self
          }
           
            
            NSThread.sleepForTimeInterval(0.1)

            
            
           
               self.navigationController?.pushViewController(vc, animated: true)
            
            
        }
        
        
        
 
    }
    
 
    
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView == self.checkedItemsTableView {
            return 0
        }
        
        else {
            if self.listName == "Starred" || self.listName == "Today" || self.listName == "Week" {
                return 50
            }
            else {
                return 20
            }
            
        }
        
       
    }
    
    
    // to hide the line between views create a transparent base at the base of each cell and at top
    
    
    
    // footer (base) just big enough to hide the line but not imped on the other cell
    
    
    
    
    
    
    
    
    
    
    
    
    
    func setTabBarItemsTitles() {
        self.shareTabBarItem.title = "Share"
        
        self.publishTabBarItem.title = "Publish"
        self.sortTabBarItem.title = "Sort"
    }
    
    
    
/* (TO PUT AFTER IF BUTTON.SELECTED = FALSE

let itemChecked: AnyObject? = item!["checked"]


if itemChecked != nil {


var itemDict = Dictionary<String, AnyObject>()


var itemCheckedString = itemChecked as? String

if itemCheckedString != nil {
item!["checked"] = "true"
NSLog("YES")
}
}

*/




    @IBAction func checkboxClicked(sender: AnyObject) {
        
        
        var button = sender as UIButton
        
        
        var item: Dictionary<String, AnyObject>? = nil
        
        
        var section = button.tag/1000
        var row = button.tag%1000
        
        var itemDict: AnyObject? = nil
        var itemsArray: AnyObject? = nil
        if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
            
            
            if self.listName == "Week" {
                var itemDict: AnyObject = self.arrayOfDatedDictionaries[section]
                itemsArray = itemDict["items"] as NSMutableArray
                
                
                item = itemsArray![row] as? Dictionary<String, AnyObject>
            }
                
            else {
                var itemDict: AnyObject = self.arrayOfOriginalListsDict[section]
                itemsArray = itemDict["items"] as NSMutableArray
                
                
                item = itemsArray![row] as? Dictionary<String, AnyObject>
            }
            
            // array of DICT
            
            
            
            
            
            
        }
            
        else {
            item = self.itemsDict[button.tag]
            
        }
        
        
        var itemStringObject: AnyObject? = item!["name"]
        var itemString = itemStringObject as String
        
        var user = item!["originalUser"] as PFUser!
        
        if button.selected == false {
            button.selected = true
     
            var itemCopy = item
            itemCopy!["checked"] = "true"
            
             if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
                itemsArray?.removeObjectAtIndex(row)
                itemsArray!.insertObject(itemCopy!, atIndex: row)
            }
            
             else {
                
                self.itemsDict.removeAtIndex(button.tag)
                self.itemsDict.insert(itemCopy!, atIndex: button.tag)
            }
            
            self.arrayOfCheckedDictionaryItems.addObject(itemCopy!)
         
            
            
            self.addOrRemoveNewItemDictKeyValueToParse("checked", itemDict: item!, starred: "false", remove: false, user: user)
        }
            
        else {
            button.selected = false
            var itemCopy = item
            itemCopy!["checked"] = "false"
            
            
            self.arrayOfCheckedDictionaryItems.removeObject(item!)
            
            if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
                itemsArray?.removeObjectAtIndex(row)
                itemsArray!.insertObject(itemCopy!, atIndex: row)
            }
            
            else {
                
                self.itemsDict.removeAtIndex(button.tag)
                self.itemsDict.insert(itemCopy!, atIndex: button.tag)
            }
            self.arrayOfCheckedDictionaryItems.removeObject(item!)
        
            self.addOrRemoveNewItemDictKeyValueToParse("checked", itemDict: item!, starred: "false", remove: true, user: user)
        }
        
            self.checkedItemsTableView.reloadData()
        self.tableView.reloadData()
    }
    
    
    // Previous
    
    /*
    if button.selected == false {
    button.selected = true
    
    
    
    item!["checked"] = "true"
    
    
    
    
    if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
    
    var section = button.tag/1000
    var row = button.tag%1000
    
    var itemsArray: AnyObject? = nil
    if self.listName == "Week" {
    var itemDict: AnyObject = self.arrayOfDatedDictionaries[section]
    itemsArray = itemDict["items"] as NSArray
    
    itemsArray!.removeObjectAtIndex(row)
    itemsArray!.insertObject(item!, atIndex: row)
    }
    
    else {
    var itemDict: AnyObject = self.arrayOfOriginalListsDict[section]
    itemsArray = itemDict["items"] as NSArray
    itemsArray?.removeObjectAtIndex(row)
    itemsArray!.insertObject(item!, atIndex: row)
    }
    
    }
    
    else {
    self.itemsDict.removeAtIndex(button.tag)
    self.itemsDict.insert(item!, atIndex: button.tag)
    
    
    }
    
    
    self.arrayOfCheckedDictionaryItems.addObject(item!)
    self.checkedItemsTableView.reloadData()
    self.tableView.reloadData()
    
    self.addOrRemoveNewItemDictKeyValueToParse("checked", itemDict: item!, starred: "false", remove: false, user: user)
    }
    
    else {
    button.selected = false
    
    
    // REMOVEOBJECT BEFORE CHANGING A KEY-VALUE OTHERWISE WON'T REMOVE OBJECT (DON'T RECOGNIZE IT AS THE SAME)
    
    var itemCopy = item
    
    
    self.arrayOfCheckedDictionaryItems.removeObject(item!)
    
    itemCopy!["checked"] = "false"
    
    if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
    
    var section = button.tag/1000
    var row = button.tag%1000
    
    var itemsArray: AnyObject? = nil
    if self.listName == "Week" {
    var itemDict: AnyObject = self.arrayOfDatedDictionaries[section]
    itemsArray = itemDict["items"] as NSArray
    }
    
    else {
    var itemDict: AnyObject = self.arrayOfOriginalList
    
    itemsArray!.removeObjectAtIndex(row)
    itemsArray!.insertObject(item!, atIndex: row)sDict[section]
    itemsArray = itemDict["items"] as NSArray
    itemsArray?.removeObjectAtIndex(row)
    itemsArray!.insertObject(itemCopy!, atIndex: row)
    }
    
    }
    
    else {
    
    self.itemsDict.removeAtIndex(button.tag)
    self.itemsDict.insert(itemCopy!, atIndex: button.tag)
    
    }
    
    self.checkedItemsTableView.reloadData()
    
    
    self.addOrRemoveNewItemDictKeyValueToParse("checked", itemDict: item!, starred: "false", remove: true, user: user)
    }

    */
    
    
    // NEW
    
    /*
    @IBAction func starbuttonClicked(sender: AnyObject) {
        
        
        
        var button = sender as UIButton
        
        var item: Dictionary<String, AnyObject>;
        
        var section = button.tag/1000
        var row = button.tag%1000
        
        // if listName = today,starred or week
        
        var itemDict: AnyObject? = nil
        
        var itemsArray: AnyObject? = nil
        
        if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
            
            
            
            if self.listName == "Week" {
                var itemDict: AnyObject = self.arrayOfDatedDictionaries[section]
                itemsArray = itemDict["items"] as NSMutableArray
                
                
                item = itemsArray![row] as Dictionary<String, AnyObject>!
            }
                
            else {
                var itemDict: AnyObject = self.arrayOfOriginalListsDict[section]
                itemsArray = itemDict["items"] as NSMutableArray
                
                
                item = itemsArray![row] as Dictionary<String, AnyObject>!
            }
            
            // array of DICT
            
            
            
        }
            
            // else if it is not a standard list
        else {
            
            // take the item
            item = self.itemsDict[button.tag] as Dictionary<String, AnyObject>!
            
            
            
            
        }
        
        
        
        var itemStringObject: AnyObject? = item["name"]
        var itemString = itemStringObject as String
        
        var user = item["originalUser"] as PFUser!
        
        // if we are selecting the star
        if button.selected == false {
            
            
            
            
            
            
            button.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.63)
            button.alpha = 0.63
            
            button.selected = true
            
            self.starred = true
            
            
            item["starred"] = "true"
            
            
            if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
                itemsArray?.removeObjectAtIndex(row)
                itemsArray!.insertObject(item, atIndex: 0)
            }
                
            else {
                
                self.itemsDict.removeAtIndex(button.tag)
                self.itemsDict.insert(item, atIndex: 0)
            }
            
            
            
            
            self.tableView.reloadData()
            // add to originalList and update rest
            
            self.addOrRemoveNewItemDictKeyValueToParse("starred", itemDict: item, starred: "true", remove: false, user: user)
            
            
            
            
            
        }
            
            // if we are unselecting the star
            
            
        else {
            
            button.backgroundColor = UIColor.clearColor()
            
            button.selected = false
            
            self.starred = false
            
            if self.listName == "Starred" {
                
                var listDict: AnyObject = self.arrayOfOriginalListsDict[section]
                
                // array of DICT
                var itemsArray = listDict["items"] as NSMutableArray
                
                var itemDict = itemsArray[row] as? Dictionary<String, AnyObject>
                
                
                
                itemsArray.removeObjectAtIndex(row)
                
                
                item["starred"] = "false"
                
                
                if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
                    itemsArray.removeObjectAtIndex(row)
                    itemsArray.insertObject(item, atIndex: 0)
                }
                    
                else {
                    
                    self.itemsDict.removeAtIndex(button.tag)
                    self.itemsDict.insert(item, atIndex: 0)
                }
                
                
                
                self.tableView.reloadData()
                
                
            }
            
            self.addOrRemoveNewItemDictKeyValueToParse("starred", itemDict: item, starred: "true", remove: true, user: user)
            
            
            
        }
        
        
    }





*/
    @IBAction func starbuttonClicked(sender: AnyObject) {
        
        
        
        
        var button = sender as UIButton
        
        var item: Dictionary<String, AnyObject>? = nil
        
        var section = button.tag/1000
        var row = button.tag%1000
        
        var itemDict: AnyObject? = nil
        
        var itemsArray: NSMutableArray? = nil
        
        if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
            
            
            
            if self.listName == "Week" {
                var itemDict: AnyObject = self.arrayOfDatedDictionaries[section]
                itemsArray = itemDict["items"] as? NSMutableArray
                
                
                item = itemsArray![row] as? Dictionary<String, AnyObject>
            }
                
            else {
                var itemDict: AnyObject = self.arrayOfOriginalListsDict[section]
                itemsArray = itemDict["items"] as? NSMutableArray
                
                
                item = itemsArray![row] as? Dictionary<String, AnyObject>
            }
            
            // array of DICT
            
            
            
            
            
            
        }
            
        else {
            item = self.itemsDict[button.tag]
            
        }
        
        
        // if
        var itemStringObject: AnyObject? = item!["name"]
        var itemString = itemStringObject as String
        
        var user = item!["originalUser"] as PFUser!
        
        if button.selected == false {
            button.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.63)
            button.alpha = 0.63
            
            button.selected = true
            
            self.starred = true
            
            // add to originalList and update rest
            
            var itemCopy = item
            itemCopy!["starred"] = "true"
            
            if self.listName == "Today" || self.listName == "Starred" || self.listName == "Week"{
                
                
              
                
                                
                itemsArray!.removeObjectAtIndex(row)
                itemsArray!.insertObject(itemCopy!, atIndex: 0)
                
            }
            
            
            else {
           
                
            
             
                
            
            
           
                
                self.itemsDict.removeAtIndex(button.tag)
                self.itemsDict.insert(itemCopy!, atIndex: 0)
                
         
                    
                    /*
                    self.tableView.beginUpdates()
                    var initialPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 4)
                    var finalPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                    self.tableView.moveRowAtIndexPath(initialPath, toIndexPath: finalPath)

                    self.tableView.endUpdates()
*/
                   
                
            }
            
            self.tableView.reloadData()
            self.addOrRemoveNewItemDictKeyValueToParse("starred", itemDict: item!, starred: "true", remove: false, user: user)
            
           
            
            
        }
            
        else {
            
            button.backgroundColor = UIColor.clearColor()
            
            button.selected = false
            
            self.starred = false
            var itemCopy = item
            
            
            itemCopy!["starred"] = "false"
            
            
            if self.listName == "Starred" {
                
                var listDict: AnyObject = self.arrayOfOriginalListsDict[section]
                
                // array of DICT
                var itemsArray = listDict["items"] as NSMutableArray
                
                var itemDict = itemsArray[row] as? Dictionary<String, AnyObject>
                
                
                itemsArray.removeObjectAtIndex(row)
                self.itemsDict.removeAtIndex(row)
                
                
                
            }
            
           
            else if self.listName == "Today" || self.listName == "Week"{
                itemsArray!.removeObjectAtIndex(row)
                itemsArray!.insertObject(itemCopy!, atIndex: row)
            }
            
            else {
                
                
                
                
          
            self.itemsDict.removeAtIndex(button.tag)
                
                
                /*
self.tableView.deleteRowsAtIndexPaths(button.tag, withRowAnimation: UITableViewRowAnimation.Left)
[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:0]
withRowAnimation:UITableViewRowAnimation.Left];
*/
          
                
                
            self.itemsDict.insert(itemCopy!, atIndex: button.tag)
            }
            
            self.tableView.reloadData()
            
            self.addOrRemoveNewItemDictKeyValueToParse("starred", itemDict: item!, starred: "true", remove: true, user: user)
            
            
            
        }
        
        
        
        

            
        }
   


    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    return true // Yes, the table view can be reordered
    }
    
  

    func addOrRemoveNewItemDictKeyValueToParse(key: String, itemDict: Dictionary<String, AnyObject>,  starred: String, remove: Bool, user: PFUser) {
        
        
        var itemStringObject: AnyObject? = itemDict["name"]
        var itemString = itemStringObject as String
        
        var itemOriginalListObject: AnyObject? = itemDict["originalList"]
        var itemOriginalList = itemOriginalListObject as String
        
        var query = PFQuery(className:"List")
        
        
        
        
        
        query.whereKey("user", equalTo: user)
        query.whereKey("name", equalTo: itemOriginalList)
        
        
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                if objects.count > 0 {
                    var list: PFObject = objects.last as PFObject
                    var arrayItems = list["items"] as? NSMutableArray
                    var contactsArray = list["contacts"] as NSMutableArray!
                    
                    
                    if arrayItems != nil {
                        for item in arrayItems! {
                            
                            // POINTER TO THE ITEM OBJET IN ARRAY (SO IF WE DELETE THE ITEM IN ARRAY ALSO DELETES THIS VARIABLE)
                            var item = item as Dictionary<String, AnyObject>
                            
                            
                            let itemName = item["name"]! as String
                            let itemUser = item["originalUser"] as PFUser!
                            
                            
                            if itemName == itemString {
                                
                                
                                if remove == true {
                                    // remove old object
                                    
                                    
                                    var itemCopy = item
                                    
                                
                                    arrayItems!.removeObject(item)
                                    itemCopy[key] = "false"
                                    
                                    arrayItems!.addObject(itemCopy)
                                    list.saveInBackground()
                                    
                                    
                                    if (starred == "true") {
                                        
                                        if (item["originalList"] != nil) {
                                            var itemOriginalList: AnyObject? = item["originalList"]
                                            var itemOriginalListString = itemOriginalList as String
                                            
                                            self.updateStarredOrCheckedOfOtherLists(itemOriginalListString, key: "starred", itemDict: item, remove: true, user: user)
                                            
                                        }
                                        
                                        self.addOrRemoveItemDictToStarredList("Starred", itemDict: item, remove: true, user: user)
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Today", key: "starred", itemDict: item, remove: true, user: user)
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Week", key: "starred", itemDict: item, remove: true, user: user)
                                        
                                        
                                        
                                        if contactsArray != nil {
                                            for contactUsername in contactsArray! {
                                                
                                                
                                                
                                                let contactUsername = contactUsername as String
                                           
                                                self.findContactFromContactUsernameAndUpdateItemFromList(itemName, itemDict: item, username: contactUsername, remove: true, starred: true )
                                            }
                                        }
                                    }
                                    
                                    if key == "checked" {
                                        
                                        if (item["originalList"] != nil) {
                                            var itemOriginalList: AnyObject? = item["originalList"]
                                            var itemOriginalListString = itemOriginalList as String
                                            
                                            self.updateStarredOrCheckedOfOtherLists(itemOriginalListString, key: "checked", itemDict: item, remove: true, user: user)
                                            
                                        }
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Starred", key: "checked", itemDict: item, remove: true, user: user)
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Today", key: "checked", itemDict: item, remove: true, user: user)
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Week", key: "checked", itemDict: item, remove: true, user: user)
                                        
                                        
                                        
                                        if contactsArray != nil {
                                            for contactUsername in contactsArray! {
                                                let contactUsername = contactUsername as String
                                                self.findContactFromContactUsernameAndUpdateItemFromList(itemName, itemDict: item, username: contactUsername, remove: true, starred: false)
                                            }
                                        }
                                        
                                        
                                    }
                                }
                                    
                                    // if remove = false
                                else {
                                    // remove old objec
                                    
                                    var itemCopy = item
                                    arrayItems!.removeObject(item)
                                    
                                    println("Item: \(item)")
                                    println("Key: \(key)")
                                    println("item[key]: \(item[key])")
                                    
                                    itemCopy[key] = "true"
                                    
                                    arrayItems!.addObject(itemCopy)
                                    list.saveInBackground()
                                    if (starred == "true") {
                                        
                                        
                                        if (item["originalList"] != nil) {
                                            var itemOriginalList: AnyObject? = item["originalList"]
                                            var itemOriginalListString = itemOriginalList as String
                                            
                                            self.updateStarredOrCheckedOfOtherLists(itemOriginalListString, key: "starred", itemDict: item, remove: false, user: user)
                                            
                                        }
                                        
                                        self.addOrRemoveItemDictToStarredList("Starred", itemDict: item, remove: false, user: user)
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Today", key: "starred", itemDict: item, remove: false, user: user)
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Week", key: "starred", itemDict: item, remove: false, user: user)
                                        
                                        if contactsArray != nil {
                                            for contactUsername in contactsArray! {
                                                let contactUsername = contactUsername as String
                                                self.findContactFromContactUsernameAndUpdateItemFromList(itemName, itemDict: item, username: contactUsername, remove: false, starred: true )
                                            }
                                        }
                                    }
                                    
                                    if (key == "checked") {
                                        
                                        if (item["originalList"] != nil) {
                                            var itemOriginalList: AnyObject? = item["originalList"]
                                            var itemOriginalListString = itemOriginalList as String
                                            
                                            self.updateStarredOrCheckedOfOtherLists(itemOriginalListString, key: "checked", itemDict: item, remove: false, user: user)
                                            
                                        }
                                        
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Starred", key: "checked", itemDict: item, remove: false, user: user)
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Today", key: "checked", itemDict: item, remove: false, user: user)
                                        
                                        self.updateStarredOrCheckedOfOtherLists("Week", key: "checked", itemDict: item, remove: false, user: user)
                                        
                                        
                                        
                                        
                                        if contactsArray != nil {
                                            for contactUsername in contactsArray! {
                                                let contactUsername = contactUsername as String
                                                self.findContactFromContactUsernameAndUpdateItemFromList(itemName, itemDict: item, username: contactUsername, remove: false, starred: false)
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                            
                        }
                        
                        
                    }
                    
                    
                    
                    
                }
                
            }
        }
        
    }
    
    
    
    
    
    
    func addOrRemoveItemDictToStarredList(listName: String, itemDict: Dictionary<String, AnyObject>, remove: Bool, user: PFUser) {
        
        if (Reachability.isConnectedToNetwork()) {
            
            
            var query = PFQuery(className:"List")
            
            
            
            query.whereKey("user", equalTo: user)
            
            query.whereKey("name", equalTo: listName)
            
            
            
            // query.findObjects:
            query.findObjectsInBackgroundWithBlock() {
                (objects:[AnyObject]!, error:NSError!)->Void in
                if ((error) == nil) {
                    if objects.count > 0 {
                        var list: PFObject = objects.last as PFObject!
                        
                        var itemsArray = list["items"] as? NSMutableArray
                        
                        if itemsArray != nil {
                            
                            
                            
                            var itemNameObject: AnyObject? = itemDict["name"]
                            var itemName = itemNameObject as String
                            
                            
                            
                            // FIND THE NAME AND REMOVE THE STARREDITEM WITH THE SAME NAME AS ITEM NOT THE SAME
                            
                            
                            
                            // remove old object if it exists
                            
                            itemsArray!.removeObject(itemDict)
                            
                            
                            if remove == false {
                                
                                
                                
                                var itemDict = itemDict
                                if self.listName != "Starred" && self.listName != "Today" && self.listName != "Week" {
                                    
                                    itemDict["originalList"] = self.listName
                                    itemsArray!.addObject(itemDict)
                                }
                                else {
                                    
                                    var itemOriginalListObject: AnyObject? = itemDict["originalList"]
                                    
                                    
                                    var itemOriginalList = itemOriginalListObject as String
                                    
                                    
                                    itemDict["originalList"] = itemOriginalList
                                    itemsArray!.addObject(itemDict)
                                    
                                    
                                }
                                
                                list["items"] = itemsArray
                                list["numberOfItems"] = itemsArray!.count
                                
                                list.saveInBackground()
                                
                                
                            }
                                
                                // if remove == true
                            else {
                                
                                if itemsArray != nil {
                                    
                                    for item in itemsArray! {
                                        var itemString = item["name"] as? String
                                        if itemString != nil {
                                        if itemString == itemName {
                                            itemsArray!.removeObject(item)
                                        }
                                        }
                                    }
                                        
                                    
                                }
                                
                                list["items"] = itemsArray
                                list["numberOfItems"] = itemsArray!.count
                                
                                list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                                    
                                    
                                })
                                
                                
                                
                            }
                            
                        }
                            
                            // if object.count is > 0 but no items (there is an empty starred list
                        else {
                            
                            if remove == false {
                                
                                var newItemsArray = NSMutableArray()
                                
                                var item = itemDict
                                
                                if self.listName != "Starred" && self.listName != "Today" ||  self.listName != "Week"  {
                                    item["originalList"] = self.listName
                                    itemsArray!.addObject(item)
                                }
                                else {
                                    itemsArray!.addObject(item)
                                }
                                
                                
                                
                                list["items"] = newItemsArray
                                list["numberOfItems"] = newItemsArray.count
                                
                                list.saveInBackground()
                                
                                
                            }
                        }
                        
                        
                    }
                    
                    
                    
                    
                }
                
            }
            
            
            
        }
        
        
        
        
    }
    
    
    
    
    func updateStarredOrCheckedOfOtherLists(listName: String, key: String, itemDict: Dictionary<String, AnyObject>, remove: Bool, user: PFUser) {
        
        if (Reachability.isConnectedToNetwork()) {
            
            
            
            var query = PFQuery(className:"List")
            
            
            
            
            
            query.whereKey("user", equalTo: user)
            query.whereKey("name", equalTo: listName)
            
            // query.findObjects:
            query.findObjectsInBackgroundWithBlock() {
                (objects:[AnyObject]!, error:NSError!)->Void in
                if ((error) == nil) {
                    
                    var list = objects.last as PFObject!
                    
                    
                    
                    var itemsArray = list["items"] as? NSMutableArray
                    
                    if (itemsArray!.count > 0) {
                        
                        
                        
                        
                        var itemNameObject: AnyObject? = itemDict["name"]
                        
                        var itemNameString = itemNameObject as String
                        
                        // remove old item if already there
                        
                        
                        if remove == false {
                            
                            
                            
                            
                            for item in itemsArray! {
                                
                                // the item is already there so don't add it another time
                                
                                var item = item as Dictionary<String, AnyObject>
                                var itemStringObject: AnyObject? = item["name"]
                                var itemString = itemStringObject as String
                                if itemString == itemNameString {
                                    // remove old object
                                    
                                    var itemCopy = item
                                    itemsArray!.removeObject(item)
                                    
                                    
                                    
                                    var keyString: String? = key as String
                                    if keyString != nil {
                                     itemCopy[keyString!] = "true"
                                    
                                    }
                                   
                                    
                                    
                                    itemsArray!.addObject(itemCopy)
                                    
                                    list["items"] = itemsArray
                                    list.saveInBackground()
                                }
                                
                            }
                            
                            
                            
                            
                        }
                            
                            // if remove = false
                        else {
                            
                            
                            
                            for item in itemsArray! {
                                
                                // the item is already there so don't add it another time
                                
                                var item = item as Dictionary<String, AnyObject>
                                var itemStringObject: AnyObject? = item["name"]
                                var itemString = itemStringObject as String
                                if itemString == itemNameString {
                                    // remove old object
                                    
                                    // CREATE A COPY BEFORE COPYING OBJECT
                                    var itemCopy = item
                                    itemsArray!.removeObject(item)
                                    itemCopy[key] = "false"
                                    itemsArray!.addObject(itemCopy)
                                    list["items"] = itemsArray
                                    list.saveInBackground()
                                }
                                
                            }
                            
                            
                            
                        }
                    }
                    
                    
                    
                    
                    
                    
                    
                }
                
            }
            
        }
        
        
        
    }
    
    
    
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        
        return true
    }
    
    
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            
            var itemDict: Dictionary<String, AnyObject>? = nil
            var itemName: String
            var originalList: String
            var originalUser: PFUser
            
            
            // 1. a. if not starred, week, today, we find the originalUser, if its us: find contacts and delete all, belse if its other user, take the contacts of the user and delete all
            
            // 2. a. if starred, week, today, we find original list and user, b. if original user is us then find contact and delete all, else if its user, take the contacts of the user and delete all
            if self.listName == "Starred" || self.listName == "Today" {
                
                var listDict: AnyObject = self.arrayOfOriginalListsDict[indexPath!.section]
                
                // array of DICT
                var itemsArray = listDict["items"] as NSMutableArray
                
                itemDict = itemsArray[indexPath!.row] as? Dictionary<String, AnyObject>
                
                
                itemName = itemDict!["name"]! as String
                
                originalList = itemDict!["originalList"]! as String
                
                originalUser = itemDict!["originalUser"]! as PFUser
                
                itemsArray.removeObjectAtIndex(indexPath!.row)
                
                
                
            }
                
            else if self.listName == "Week" {
                var listDict: AnyObject = self.arrayOfDatedDictionaries[indexPath!.section]
                
                
                var itemsArray = listDict["items"] as NSMutableArray
                
                itemDict = itemsArray[indexPath!.row] as? Dictionary<String, AnyObject>
                
                
                itemName = itemDict!["name"]! as String
                
                originalList = itemDict!["originalList"]! as String
                
                originalUser = itemDict!["originalUser"]! as PFUser
                
                itemsArray.removeObjectAtIndex(indexPath!.row)
                
            }
                
            else {
                
                itemDict = self.itemsDict[indexPath.section] as  Dictionary<String, AnyObject>
                
                var itemNameObject: AnyObject? = itemDict!["name"]
                itemName = itemNameObject as String
                
                originalList = itemDict!["originalList"]! as String
                
                originalUser = itemDict!["originalUser"]! as PFUser
                
                self.itemsDict.removeAtIndex(indexPath.section)
                
            }
            
            self.tableView.reloadData()
            
            
            self.removeItemFromList(originalList, itemDict: itemDict!, user: originalUser)
            
            self.removeItemFromList("Starred", itemDict: itemDict!, user: originalUser)
            self.removeItemFromList("Week", itemDict: itemDict!, user: originalUser)
            self.removeItemFromList("Today", itemDict: itemDict!, user: originalUser)
            self.removeItemFromList("Inbox", itemDict: itemDict!, user: originalUser)
            
            self.findContactsUsernameAndRemoveItemFromTheirLists(originalList, itemDict: itemDict!, user: originalUser)
            
            
            
            
            
        }
        
        
        
        
    }
    
    func changeDueDate(dueDate: String) {
        
    
        println("DELEGATE WORKING")
        var cell: ItemTableViewCell? =  tableView.viewWithTag(1) as? ItemTableViewCell
        println(tableView.viewWithTag(1) as? AnyObject)
        println(cell)

        if cell != nil {
            
    
        
            cell!.subtitle!.text = dueDate
            cell!.tag = 0
                
            
            
        }
        
    
    
       

    
        
    }
    
    
    func  findContactFromContactUsernameAndUpdateItemFromList(listName: String, itemDict: Dictionary<String, AnyObject>, username: String, remove: Bool, starred: Bool)  {
        
        var query = PFQuery(className:"_User")
        
        
        query.whereKey("username", equalTo: username)
        
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                var lastObject: AnyObject? = objects.last
                
                var user = lastObject as PFUser!
                
                
                println(user)
                
                if starred == true {
                    self.addOrRemoveItemDictToStarredList("Starred", itemDict: itemDict, remove: remove, user: user)
                    self.updateStarredOrCheckedOfOtherLists("Today", key: "starred", itemDict: itemDict, remove: remove, user: user)
                    
                    self.updateStarredOrCheckedOfOtherLists("Week", key: "starred", itemDict: itemDict, remove: remove, user: user)
                    
                }
                    
                    
                else {
                    
                    self.updateStarredOrCheckedOfOtherLists("Starred", key: "checked", itemDict: itemDict, remove: remove, user: user)
                    
                    self.updateStarredOrCheckedOfOtherLists("Today", key: "checked", itemDict: itemDict, remove: remove, user: user)
                    
                    self.updateStarredOrCheckedOfOtherLists("Week", key: "checked", itemDict: itemDict, remove: remove, user: user)
                }
            }
        }
    }
    
    
    
    
    func findContactsUsernameAndRemoveItemFromTheirLists(listName: String, itemDict: Dictionary<String, AnyObject>, user: PFUser) {
        
        
        var query = PFQuery(className:"List")
        
        
        
        query.whereKey("user", equalTo: user)
        
        
        query.whereKey("name", equalTo: listName)
        
        // query.findObjects:
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                
                let list  = objects.last as PFObject
                
                var contacts = list["contacts"] as? NSMutableArray
                
                if contacts != nil {
                    for contactUsername in contacts! {
                        let contactUsername = contactUsername as String
                        
                        self.findContactFromContactUsernameAndRemoveItemFromList(listName, itemDict: itemDict, username: contactUsername)
                        
                    }
                }
                
                
                
            }
            
        }
    }
    
    func  findContactFromContactUsernameAndRemoveItemFromList(listName: String, itemDict: Dictionary<String, AnyObject>, username: String)  {
        
        var query = PFQuery(className:"_User")
        
        
        query.whereKey("username", equalTo: username)
        
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                var lastObject: AnyObject? = objects.last
                
                var user = lastObject as PFUser!
                
                self.removeItemFromList("Starred", itemDict: itemDict, user: user!)
                self.removeItemFromList("Today", itemDict: itemDict, user: user!)
                self.removeItemFromList("Week", itemDict: itemDict, user: user!)
                
            }
        }
    }
    
    @IBAction func showCheckedItems(sender: AnyObject) {
        
        if self.checkedItemsHidden == true {
     
            self.checkedItemsTableView.hidden = false
            self.checkedItemsHidden = false
            
            self.checkedItemString = "\(self.arrayOfCheckedDictionaryItems.count) COMPLETED ITEMS"
            self.showCheckedItemsButton.titleLabel!.text! = self.checkedItemString!
            
            self.showCheckedItemsButton.setTitle(checkedItemString!, forState: UIControlState.Normal)
            self.showCheckedItemsButton.setTitle(checkedItemString!, forState: UIControlState.Selected)
            
              println(checkedItemString!)
            
        }
        
        else {
  
            self.checkedItemsTableView.hidden = true
            self.checkedItemsHidden = true
         
           self.checkedItemString = "\(self.arrayOfCheckedDictionaryItems.count) COMPLETED ITEMS"
            self.showCheckedItemsButton.titleLabel!.text! = self.checkedItemString!
            
            self.showCheckedItemsButton.setTitle(checkedItemString!, forState: UIControlState.Normal)
            self.showCheckedItemsButton.setTitle(checkedItemString!, forState: UIControlState.Selected)
              println(checkedItemString!)
            
        }
   
    }
  
    func removeItemFromList(listName: String, itemDict: Dictionary<String, AnyObject>, user: PFUser) {
        
        
        
        var query = PFQuery(className:"List")
        
        
        
        query.whereKey("user", equalTo: user)
        
        
        query.whereKey("name", equalTo: listName)
        
        var itemStringObject: AnyObject? = itemDict["name"]
        var itemString = itemStringObject as String
        
        
        // query.findObjects:
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                
                
                
                
                let list  = objects.last as PFObject
                
                
                var itemsArray = list["items"] as NSMutableArray
                for item in itemsArray {
                    let item = item as Dictionary<String, AnyObject>
                    
                    let itemNameParse: AnyObject? = item["name"]
                    
                    let itemNameString = itemNameParse as String
                    
                    
                    if itemNameString == itemString {
                        
                        
                        itemsArray.removeObject(item)
                        list.saveInBackground()
                        
                    }
                    
                    
                }
                
                
                
            }
            
        }
        
        
        
    }
    
    
    
    
    
    // for item in self.itemsDict, if item[originalList] != dictionary["oringallistName"] else add item["name"] (array of dictionary, key: listName)
    /*
    
    
    , // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
