//
//  itemContentViewController.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-10-26.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit


// send the items to the previous VCs


class itemContentViewController: UIViewController, UITableViewDelegate, addToItemDictProtocol  {
    
    
    
    
    
    @IBOutlet weak var dueDateTableView: UITableView!
    
    @IBOutlet weak var reminderTableView: UITableView!
    
    
    @IBOutlet weak var subtaskTableView: UITableView!
    
    
    
    
    
    @IBOutlet weak var datePickerView: UIView!
    
    
    @IBOutlet weak var dateAndTimePicker: UIDatePicker!
    
    
    @IBOutlet weak var dateTableView: UITableView!
    
    
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    
    @IBOutlet weak var addNoteView: UIView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let timeZone = NSTimeZone(name: "UTC")
    
    
    
    @IBOutlet weak var addNoteButton: UIButton!
    
    var itemName = String()
    
    var listName = String()
    
    var originalUserOfList: PFUser? = nil
    
    var areWeOriginalUserOfList: Bool? = nil
    var dueDateString = "due date"
    
    var repeatDateString = "repeat"
    
    var reminderDate = "reminder"
    
    var itemDictionary = Dictionary<String, AnyObject>()
    var itemDictSubtaskList = [String]()
    
  
    
    
    var note = "Add a note"
    var subtaskArray = [String]()
    
    var starred: String? = nil
    
    // Change
    var dueDate: NSDate? = nil
    
    @IBOutlet weak var subtaskHeightConstraint: NSLayoutConstraint!
    
    
    // Booleans
    
    var didSelectDueDateCell = false
    var didSelectRepeatCell = false
    var didSelectReminderCell = false
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        self.view.bringSubviewToFront(datePickerView)
        self.view.bringSubviewToFront(dateTableView)
        
        
        
        
        
        
        self.navigationItemTitle.title = self.itemName
        // Do any additional setup after loading the view.
        
        
        
        itemDictionary["name"] = self.itemName as AnyObject
        
        if self.starred == "true" {
            self.itemDictionary["starred"] = "true"
        }
            
        else {
            self.itemDictionary["starred"] = "false"
        }
        
        
        self.loadData()
        
        
        
        
    }
    
    
    
    //
    
    
    
    func viewWillAppear() {
        super.viewDidLoad()
        
    }
    
    

    
    
    // NO NEED TO UPDATE STARRED OR WEEK SINCE WE JUST CHANGE THE ORIGINAL ITEM AND WE LOAD IT
    
    override func viewWillDisappear(animated: Bool) {
        
        
        updateItemInOtherLists()
        
        
        if (self.listName == "Starred" || self.listName == "Today" || self.listName == "Week") {
            
            if itemDictionary["originalList"] != nil {
                
                
                self.updateItemInOriginalList()
                
            }
        }
        
        
        
        
        
    }
    
    
    
    func loadData() {
        
        
        
        
        
        var query = PFQuery(className:"List")
        
        
        var user = self.originalUserOfList?
        
        
        query.whereKey("user", equalTo: user!)
        
        query.whereKey("name", equalTo: self.listName)
        
        
        
        println(self.listName)
        // query.findObjects:
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                if objects.count > 0 {
                    var list: PFObject = objects.first as PFObject
                    var arrayItems = list["items"] as NSMutableArray
                    
                    
                    
                    
                    for item in arrayItems {
                        
                        var item = item as Dictionary<String, AnyObject>
                        
                        var name = item["name"]! as String
                        
                        if name == self.itemName {
                            self.itemDictionary = item
                            if item["dueDate"] != nil {
                                let dueDateParse = item["dueDate"]! as NSDate
                                
                                
                                self.dueDate = dueDateParse
                                let dateFormatter = NSDateFormatter()
                                
                                let timeZone = NSTimeZone(name: "UTC")
                                
                                dateFormatter.timeZone = timeZone
                                dateFormatter.locale = NSLocale.currentLocale()
                                
                                dateFormatter.dateFormat = "EEEE, MMM d, y"
                                var dueDateString = "Due \(dateFormatter.stringFromDate(dueDateParse))"
                                
                                
                                
                                self.dueDateString = dueDateString
                                
                            }
                            
                            if item["repeat"] != nil {
                                let repeat = item["repeat"]! as String
                                self.repeatDateString = repeat
                            }
                            
                            if item["reminderDate"] != nil {
                                let reminder = item["reminderDate"]! as String
                                self.reminderDate = reminder
                            }
                            
                            if item["subtaskList"] != nil {
                                
                                var subtaskList = item["subtaskList"] as NSMutableArray
                                self.subtaskArray = [String]()
                                for subtask in subtaskList {
                                    
                                    
                                    var subtaskString = subtask as String
                                    self.addSubTask(subtaskString)
                                    
                                    
                                }
                                
                                
                                self.subtaskTableView.reloadData()
                            }
                            
                            
                            
                            
                            
                            if item["note"] != nil {
                                self.note = item["note"]! as String
                                
                                self.noteTextView.text = self.note
                            }
                            
                            
                            if item["originalUser"] != nil {
                                let user = item["originalUser"]! as PFUser
                                self.itemDictionary["originalUser"] = user
                                
                                
                            }
                            
                            if item["contacts"] != nil {
                                let contacts = item["contacts"] as NSMutableArray
                                self.itemDictionary["contacts"] = contacts
                            }
                            
                            
                            
                            var listUser: PFUser? = nil
                            if self.itemDictionary["originalUser"] != nil {
                                listUser = self.itemDictionary["originalUser"] as PFUser!
                            }
                                
                            else {
                                if self.areWeOriginalUserOfList == true {
                                    listUser = PFUser.currentUser()
                                    
                                }
                                    
                                else {
                                    listUser = self.originalUserOfList!
                                }
                            }
                            
                            
                            var originalListName: String? = nil
                            if self.itemDictionary["originalList"] != nil {
                                originalListName = self.itemDictionary["originalList"]! as? String
                                self.returnOriginalListOfItem(originalListName!, user: listUser!)
                            }
                            
                        }
                        
                    }
                    
                    self.dueDateTableView.reloadData()
                    
                    self.reminderTableView.reloadData()
                    
                    
                    
                    
                }
            }
            
        }
        
    }
    
    // if didreceivememorywarning return else:
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == dueDateTableView) {
            return 2
        }
        
        if (tableView == dateTableView) {
            return 4
        }
        if (tableView == subtaskTableView) {
            
            return self.subtaskArray.count + 1
        }
            
        else {
            return 4
        }
    }
    
    func tableView(tableView:  UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        return 44
        
    }
    
    
    
    // if a tableView is larger than the footer than create another tableView.
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if (tableView == dueDateTableView) {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            
            if indexPath.row == 0 {
                cell.textLabel!.text = self.dueDateString
            }
            
            if indexPath.row == 1 {
                cell.textLabel!.text = self.repeatDateString
            }
            
            
            return cell
            
        }
        
        if (tableView == reminderTableView) {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel!.text = self.reminderDate
            
            return cell
        }
        
        if (tableView == dateTableView) {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
            var cellString = ""
            
            
            if indexPath.row == 0 {
                cellString = "Every day"
                
                
            }
            
            if (indexPath.row == 1) {
                cellString  = "Every week"
                
                
            }
            
            if indexPath.row == 2 {
                cellString = "Every month"
                
                
            }
            
            if indexPath.row == 3 {
                cellString  = "Every year"
                
                
            }
            
            self.repeatDateString = cellString
            
            cell.textLabel!.text = cellString
            
            
            
            return cell
            
        }
        
        
        
        if (tableView == subtaskTableView) {
            
            
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? subtaskTableViewCell
            
            
            cell!.delegate = self
            
            
            if (indexPath.row == self.subtaskArray.count) {
                cell!.subtaskTextField.text = nil
            }
                
            else {
                cell!.subtaskTextField.text = subtaskArray[indexPath.row]
            }
            /*
            if (self.subtaskArray[indexPath.row].isEmpty) {
            cell!.subtaskTextField.text = cell!.subtaskTextField.placeholder
            }
            
            else {
            cell!.subtaskTextField.text = cell!.subtaskTextField.placeholder
            
            }
            
            */
            
            return cell!
            
            
        }
            
            
            
            
            // if tableView == subtastTableView
        else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? UITableViewCell
            
            if ((cell != nil)) {
                return cell!
            }
            else {
                
                return cell!
            }
            
            
        }
        
        
        
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        
        self.noteTextView.hidden = true
        
        if (tableView == dueDateTableView) {
            var  cell = tableView.cellForRowAtIndexPath(indexPath)!
            
            
            UIView.animateWithDuration(2, animations: {
                
                cell.setSelected(true, animated: true)
                cell.selectionStyle = UITableViewCellSelectionStyle.Blue
                }, completion: {
                    (value: Bool) in
                    UIView.animateWithDuration(1, animations: {
                        
                        cell.setSelected(false, animated: true)
                        
                        }, completion: {
                            (value: Bool) in
                            
                            
                            
                    })
                    
                    
                    
                    
            })
            
            
            
            
            
            // .date mode only shows day, month and year (not hours and minutes)
            
            
            if indexPath.row == 0 {
                
                showDatePicker()
                
            }
            
            if indexPath.row == 1 {
                showRepeatTableView()
                
            }
            
            
            return cell
            
            
        }
        
        // the repeat tableView
        
        if (tableView == dateTableView) {
            var  cell = tableView.cellForRowAtIndexPath(indexPath)!
            self.repeatDateString = cell.textLabel!.text!
            
            self.dueDateTableView.reloadData()
            
        }
        
        if (tableView == reminderTableView) {
            showDateAndTimePicker()
            
        }
        
        
        
        if (tableView == subtaskTableView) {
            
            self.noteTextView.hidden = false
            self.datePickerView.hidden = true
            
        }
        
        
        return nil
        
    }
    
    
    
    // if the datePicker is open then return, else: try again
    func showDatePicker() {
        self.didSelectDueDateCell = true
        self.didSelectRepeatCell = false
        self.didSelectReminderCell = false
        
        
        
        datePicker.datePickerMode = .Date
        
        datePicker.timeZone = timeZone
        datePickerView.hidden = false
        datePicker.hidden = false
        dateAndTimePicker.hidden = true
        dateTableView.hidden = true
        
    }
    
    
    func showRepeatTableView() {
        self.didSelectRepeatCell = true
        self.didSelectDueDateCell = false
        self.didSelectReminderCell = false
        
        datePickerView.hidden = false
        dateAndTimePicker.hidden = true
        datePicker.hidden = true
        dateTableView.hidden = false
        
    }
    
    func showDateAndTimePicker() {
        self.didSelectReminderCell = true
        self.didSelectRepeatCell = false
        self.didSelectDueDateCell = false
        
        dateAndTimePicker.datePickerMode = .DateAndTime
        
        
        
        dateAndTimePicker.locale = NSLocale.currentLocale()
        dateAndTimePicker.timeZone = timeZone
        datePickerView.hidden = false
        dateAndTimePicker.hidden = false
        datePicker.hidden = true
        dateTableView.hidden = true
        
    }
    
    
    
    func hideDatePicker() {
        datePickerView.hidden = true
        datePicker.hidden = true
        dateAndTimePicker.hidden = true
        dateTableView.hidden = true
        
        
    }
    
    
    
    @IBAction func confirmDate(sender: AnyObject) {
        
        
        if self.didSelectDueDateCell == true {
            let dateFormatter = NSDateFormatter()
            
            /*
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            
            */
            
            dateFormatter.dateFormat = "EEEE, MMM d, y"
            let timeZone = NSTimeZone(name: "UTC")
            
            dateFormatter.timeZone = timeZone
            dateFormatter.locale = NSLocale.currentLocale()
            
            var dueDateString = "Due \(dateFormatter.stringFromDate(self.datePicker.date))"
            
            self.dueDate = self.datePicker.date
            
            self.itemDictionary["dueDate"] = self.datePicker.date
            
            
            self.dueDateString = dueDateString
            
            self.addOrRemoveNewItemDictKeyValueToParse("dueDate", value: self.datePicker.date, remove: false)
            
            self.dueDateTableView.reloadData()
            
            self.didSelectDueDateCell == false
            
            hideDatePicker()
            
            
            
            
            let todayDate = NSDate()
            let calendar = NSCalendar.currentCalendar()
            
            let todayComponents = calendar.components(.CalendarUnitDay | .CalendarUnitWeekOfYear | .CalendarUnitYear, fromDate: todayDate)
            let today = todayComponents.day
            
            let week = todayComponents.weekOfYear
            
            let year = todayComponents.year
            
            let dueDateComponents = calendar.components(.CalendarUnitDay | .CalendarUnitWeekOfYear | .CalendarUnitYear, fromDate: self.datePicker.date)
            let dueDateDay = dueDateComponents.day
            let dueDateWeek = dueDateComponents.weekOfYear
            let dueDateYear = dueDateComponents.year
            
            
            
            
            
            
        }
        
        
        
        // if the cells are selected return: else
        if self.didSelectRepeatCell {
            
            if (self.repeatDateString != "repeat") {
                self.itemDictionary["repeat"] = self.repeatDateString
                
            }
            self.addOrRemoveNewItemDictKeyValueToParse("repeat", value: repeatDateString, remove: false)
            self.didSelectRepeatCell = false
            
            self.dueDateTableView.reloadData()
            
            
            hideDatePicker()
        }
        
        if self.didSelectReminderCell {
            
            self.didSelectReminderCell == false
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "H:mm, EEEE, MMM d"
            
            let timeZone = NSTimeZone(name: "UTC")
            
            dateFormatter.timeZone = timeZone
            
            dateFormatter.locale = NSLocale.currentLocale()
            
            var reminderDateString = "Remind me at \(dateFormatter.stringFromDate(self.dateAndTimePicker.date))"
            
            
            self.addOrRemoveNewItemDictKeyValueToParse("reminderDate", value: reminderDateString, remove: false)
            
            self.reminderDate = reminderDateString
            
            self.itemDictionary["reminderDate"] = reminderDateString
            
            
            self.reminderTableView.reloadData()
            
            
            
            hideDatePicker()
            
        }
        
        // if noteTextView.hidden = false,
        //
        self.noteTextView.hidden = false
        
        
    }
    
    
    
    
    
    @IBAction func removeDate(sender: AnyObject) {
        
        if self.didSelectDueDateCell == true {
            self.didSelectDueDateCell = false
            self.dueDateString = "due date"
            
            self.dueDate = nil
            self.addOrRemoveNewItemDictKeyValueToParse("dueDate", value: "", remove: true)
            self.itemDictionary["dueDate"] = nil
            self.dueDateTableView.reloadData()
            hideDatePicker()
            
            
            self.addOrRemoveItemDictToOtherList("Today", itemDict: self.itemDictionary, remove: true, user: nil)
            
            
            self.addOrRemoveItemDictToOtherList("Week", itemDict: self.itemDictionary, remove: true, user: nil)
            
            
            
        }
        
        
        if self.didSelectRepeatCell == true {
            self.didSelectRepeatCell = false
            self.repeatDateString = "repeat"
            self.itemDictionary["repeat"] = ""
            self.addOrRemoveNewItemDictKeyValueToParse("repeat", value: "", remove: true)
            self.dueDateTableView.reloadData()
            
            hideDatePicker()
            
        }
        
        
        
        if self.didSelectReminderCell == true {
            self.didSelectReminderCell = false
            self.reminderDate = "reminder"
            self.itemDictionary["reminderDate"] = ""
            self.addOrRemoveNewItemDictKeyValueToParse("reminderDate", value: "", remove: true)
            self.reminderTableView.reloadData()
            
            hideDatePicker()
            
        }
        
        self.noteTextView.hidden = false
        
    }
    
    
    
    
    func addSubTask(cellText: String) {
        
        
        
        
        if cellText != "" {
            self.itemDictSubtaskList.append(cellText)
            
            
            self.itemDictionary["subtaskList"] = self.itemDictSubtaskList
            
            self.subtaskArray.append(cellText)
            
            
            
            self.updateViewSizes()
            
            self.subtaskTableView.reloadData()
        }
        
        
        
    }
    
    
    func  updateViewSizes(){
        
        
        self.subtaskTableView.frame.size.height += 44
        
        
        
        self.subtaskHeightConstraint.constant = subtaskTableView.frame.size.height
        
        self.addNoteView.frame.origin.y += 44
        
        
        self.subtaskTableView.reloadData()
        
    }
    
    
    
    
    func addOrRemoveNewItemDictKeyValueToParse(key: String, value: AnyObject, remove: Bool) {
        
        
        var query = PFQuery(className:"List")
        
        var user: PFUser? = nil
        
        if self.originalUserOfList == nil {
            user = PFUser.currentUser()
            
        }
            
        else {
            
            user = self.originalUserOfList!
        }
        
        query.whereKey("user", equalTo: user!)
        
        query.whereKey("name", equalTo: self.listName)
        
        // query.findObjects:
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                if objects.count > 0 {
                    
                    
                    var list: PFObject = objects.last as PFObject
                    var arrayItems = list["items"] as NSMutableArray
                    
                    
                    
                    
                    for item in arrayItems {
                        
                        var item = item as Dictionary<String, AnyObject>
                        
                        
                        let itemName = item["name"]! as String
                        
                        
                        if itemName == self.itemName {
                            
                            if remove == true {
                                // remove old object
                                arrayItems.removeObject(item)
                                item[key] = nil
                                arrayItems.addObject(item)
                                
                                list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                                    
                                    return
                                })
                                
                            }
                            else {
                                // remove old object
                                
                                if (key == "subtaskList") {
                                    
                                    if item[key] == nil {
                                        arrayItems.removeObject(item)
                                        var subtaskList = NSMutableArray()
                                        subtaskList.addObject(value)
                                        item[key] = subtaskList
                                        arrayItems.addObject(item)
                                        list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                                            
                                            return
                                        })
                                    }
                                        
                                    else {
                                        var subtaskList = item[key]! as NSMutableArray
                                        
                                        arrayItems.removeObject(item)
                                        subtaskList.addObject(value)
                                        item[key] = subtaskList
                                        arrayItems.addObject(item)
                                        list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                                            
                                            return
                                        })
                                    }
                                    return
                                    
                                }
                                    
                                    
                                    
                                else {
                                    arrayItems.removeObject(item)
                                    item[key] = value
                                    arrayItems.addObject(item)
                                    list.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                                        
                                        return
                                    })
                                    return
                                    
                                }
                            }
                        }
                        
                        
                    }
                    
                    
                    
                    
                }
                
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "itemVCtoAddNoteVC" {
            let viewController:addNoteViewController = segue.destinationViewController as addNoteViewController
            
            viewController.delegate = self
            
            
            viewController.itemName = self.itemName
            viewController.listName = self.listName
            
            
            viewController.noteString = self.noteTextView.text
            // WHERE WE SAY WE ARE THE DELEGATE OF CONTACTSTABLEVC, the delegate is set the first time we click on this segway
            
        }
    }
    
    
    
    
    
    func addOrRemoveItemDictToOtherList(listName: String, itemDict: Dictionary<String, AnyObject>, remove: Bool, user: PFUser?) {
        
        
        if (Reachability.isConnectedToNetwork()) {
            
            
            var query = PFQuery(className:"List")
            
            var listUser: PFUser? = nil
            if user == nil {
                
                
                
                if itemDict["originalUser"] != nil {
                    listUser = itemDict["originalUser"] as PFUser!
                }
                    
                else {
                    if self.areWeOriginalUserOfList == true {
                        listUser = PFUser.currentUser()
                        
                    }
                        
                    else {
                        listUser = self.originalUserOfList!
                    }
                }
                
                
            }
                
                
            else {
                listUser = user!
                
            }
            
            
            query.whereKey("user", equalTo: listUser!)
            
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
    
    
    
    
    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        
        if (tableView == subtaskTableView) {
            return true
        }
        else {
            return false
        }
    }
    
    
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            var itemName = self.subtaskArray[indexPath.row] as String
            
            
            
            
            self.subtaskArray.removeAtIndex(indexPath.row)
            
            self.subtaskTableView.reloadData()
            
            self.removeList(itemName)
            
            
            
            
        }
    }
    
    
    
    func removeList(subtaskName: String) {
        
        var query = PFQuery(className:"List")
        
        var user: PFUser? = nil
        
        if self.originalUserOfList == nil {
            user = PFUser.currentUser()
            
        }
            
        else {
            user = self.originalUserOfList!
        }
        
        query.whereKey("user", equalTo: user!)
        
        query.whereKey("name", equalTo: self.listName)
        
        // query.findObjects:
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                
                for object in objects {
                    
                    
                    let list:PFObject = object as PFObject
                    
                    
                    var itemsArray = list["items"] as NSMutableArray
                    for item in itemsArray {
                        var item = item as Dictionary<String, AnyObject>
                        
                        let itemNameParse: AnyObject? = item["name"]
                        
                        let itemNameString = itemNameParse as String
                        if itemNameString == self.itemName {
                            
                            let itemSubArray = item["subtaskList"] as NSMutableArray
                            
                            for subItem in itemSubArray {
                                let subItemString = subItem as String
                                if subItemString == subtaskName {
                                    itemSubArray.removeObject(subItem)
                                    item["subtaskList"] = itemSubArray
                                    list.saveInBackground()
                                    
                                }
                            }
                            
                            
                            
                        }
                        
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    // if click star or checked update the dictionary in original list
    
    
    
    func updateItemInOriginalList() {
        
        
        
        
        
        self.addOrRemoveItemDictToOtherList(self.itemDictionary["originalList"]! as String, itemDict: self.itemDictionary, remove: false, user: nil)
    }
    
    
    func updateItemInOtherLists() {
        
        
        
        checkAndUpdateIfStarredOrIfDueDateIsTodayOrThisWeek()
        
        
    }
    
    
    //
    func checkAndUpdateIfStarredOrIfDueDateIsTodayOrThisWeek() {
        
        let todayDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        let todayComponents = calendar.components(.CalendarUnitDay | .CalendarUnitWeekOfYear | .CalendarUnitYear, fromDate: todayDate)
        let today = todayComponents.day
        
        let week = todayComponents.weekOfYear
        
        let year = todayComponents.year
        
        
        
        // find the original User of the list containing this item
        var listUser: PFUser? = nil
        if self.itemDictionary["originalUser"] != nil {
            listUser = self.itemDictionary["originalUser"] as PFUser!
        }
            
        else {
            if self.areWeOriginalUserOfList == true {
                listUser = PFUser.currentUser()
                
            }
                
            else {
                listUser = self.originalUserOfList!
            }
        }
        
        
        
        // return the original list of this item and the shared users of this list
        
        var contacts: NSMutableArray? = nil
        
        if self.originalListOfItem != nil {
            if self.originalListOfItem!["contacts"] != nil {
                contacts = self.originalListOfItem!["contacts"] as? NSMutableArray
            }
        }
        
        
        
        if (self.dueDate != nil) {
            let dueDateComponents = calendar.components(.CalendarUnitDay | .CalendarUnitWeekOfYear | .CalendarUnitYear, fromDate: self.dueDate!)
            let dueDateDay = dueDateComponents.day
            let dueDateWeek = dueDateComponents.weekOfYear
            let dueDateYear = dueDateComponents.year
            
            
            
            
            if today == dueDateDay && year == dueDateYear {
                
                
                
                
                
                
                
                
                if (self.listName != "Starred" && self.listName != "Today" && self.listName != "Week") {
                    
                    
                    
                    
                    
                    self.itemDictionary["originalList"] = self.listName
                    
                    var originalListName: AnyObject? = self.itemDictionary["originalList"]
                    
                    
                    
                    
                    
                }
                
                
                self.addOrRemoveItemDictToOtherList("Today", itemDict: self.itemDictionary, remove: false, user: listUser)
                
                
                if contacts != nil {
                    
                    for contactUsername in contacts! {
                        
                        
                        
                        var contactUsername = contactUsername as String
                        self.findUserWithContactUsernameAndUpdateOtherListsOfUser(contactUsername, listName: "Today", remove: false)
                    }
                }
                
            }
                
                
            else {
                
                
                self.addOrRemoveItemDictToOtherList("Today", itemDict: self.itemDictionary, remove: true, user: listUser)
                
                
                
                
                if contacts != nil {
                    
                    for contactUsername in contacts! {
                        
                        
                        
                        var contactUsername = contactUsername as String
                        self.findUserWithContactUsernameAndUpdateOtherListsOfUser(contactUsername, listName: "Today", remove: true)
                    }
                    
                }
                
                
            }
            
            
            if week == dueDateWeek && year == dueDateYear  {
                
                
                if (self.listName != "Starred" && self.listName != "Today" && self.listName != "Week") {
                    
                    
                    
                    
                    
                    self.itemDictionary["originalList"] = self.listName
                    
                    var originalListName: AnyObject? = self.itemDictionary["originalList"]
                    
                    
                    
                }
                
                
                
                self.addOrRemoveItemDictToOtherList("Week", itemDict: self.itemDictionary, remove: false, user: listUser)
                
                
                
                
                if contacts != nil {
                    
                    for contactUsername in contacts! {
                        
                        
                        
                        
                        var contactUsername = contactUsername as String
                        self.findUserWithContactUsernameAndUpdateOtherListsOfUser(contactUsername, listName: "Week", remove: false)
                    }
                }
            }
                
            else {
                self.addOrRemoveItemDictToOtherList("Week", itemDict: self.itemDictionary, remove: true, user: listUser)
                
                
                if contacts != nil {
                    
                    for contactUsername in contacts! {
                        
                        
                        
                        
                        var contactUsername = contactUsername as String
                        self.findUserWithContactUsernameAndUpdateOtherListsOfUser(contactUsername, listName: "Week", remove: true)
                    }
                }
            }
            
            if self.starred == "true" {
                
                
                if (self.listName != "Starred" && self.listName != "Today" && self.listName != "Week") {
                    
                    
                    
                    
                    self.itemDictionary["originalList"] = self.listName
                    
                    var originalListName: AnyObject? = self.itemDictionary["originalList"]
                    
                    
                    
                }
                
                
                self.addOrRemoveItemDictToOtherList("Starred", itemDict: self.itemDictionary, remove: false, user: listUser)
                
                
                
                
                if contacts != nil {
                    
                    for contactUsername in contacts! {
                        
                        
                        
                        
                        
                        var contactUsername = contactUsername as String
                        self.findUserWithContactUsernameAndUpdateOtherListsOfUser(contactUsername, listName: "Starred", remove: false)
                    }
                }
            }
                
            else {
                if (self.listName != "Starred" && self.listName != "Today" && self.listName != "Week") {
                    
                    
                    
                    
                    self.itemDictionary["originalList"] = self.listName
                    
                    var originalListName: AnyObject? = self.itemDictionary["originalList"]
                    
                    
                    
                }
                self.addOrRemoveItemDictToOtherList("Starred", itemDict: self.itemDictionary, remove: true, user: listUser)
                
                
                
                
                if contacts != nil {
                    
                    for contactUsername in contacts! {
                        
                        
                        
                        
                        var contactUsername = contactUsername as String
                        self.findUserWithContactUsernameAndUpdateOtherListsOfUser(contactUsername, listName: "Starred", remove: true)
                    }
                }
                
                
            }
            
        }
        
        
        
        
        
        
        
    }
    
    
    var originalListOfItem: PFObject? = nil
    
    func returnOriginalListOfItem(listName: String, user: PFUser)  {
        
        var query = PFQuery(className:"List")
        
        
        query.whereKey("name", equalTo: self.listName)
        query.whereKey("user", equalTo: user)
        
        
        
        
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                var lastObject: AnyObject? = objects.last
                
                var list = lastObject as PFObject!
                
                self.originalListOfItem = list
                
                var contacts = list["contacts"] as? NSMutableArray
                
                
                if contacts != nil {
                    
                    self.itemDictionary["contacts"] = contacts
                }
            }
            
        }
        
        
    }
    
    
    
    func findUserWithContactUsernameAndUpdateOtherListsOfUser(username: String, listName: String, remove: Bool)  {
        
        var query = PFQuery(className:"_User")
        
        
        query.whereKey("username", equalTo: username)
        
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
                
                var lastObject: AnyObject? = objects.last
                
                var user = lastObject as PFUser!
            
                println(self.itemDictionary)
                
                self.addOrRemoveItemDictToOtherList(listName, itemDict: self.itemDictionary, remove: remove, user: user)
                
            }
        }
    }
    
    func addNote(note: String) {
        self.noteTextView.text = note
        self.itemDictionary["note"] = note
        self.addOrRemoveNewItemDictKeyValueToParse("note", value: note, remove: false)
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
