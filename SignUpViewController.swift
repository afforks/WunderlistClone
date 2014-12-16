//
//  SignUpViewController.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-10-08.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit


// VC with Sign Up Instructions

class SignUpViewController: UIViewController {
    
    
    
    @IBOutlet weak var userNameLabel: UITextField!
    
    @IBOutlet weak var emailLabel: UITextField!
    
    
    @IBOutlet weak var passwordLabel: UITextField!
 
    var finished =  Bool()

    
    // the username and email and password of the user,

    // medita
    
    var username: String = ""
    var email: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    

 
    func setUserInfo() -> String {
        
        var message = ""
        
        if userNameLabel.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            message = "Please provide username"
        }
        
        if emailLabel.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            message = "Please provide email"
        }
        
        if passwordLabel.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            message = "Please provide password"
        }
        
     
            
        else {
            self.username = userNameLabel.text!
            self.email = emailLabel.text!
            self.password = passwordLabel.text!
        }
        
        return message
        
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func goToApp() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("userVC") as ListViewController
        
    
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    @IBAction func signUp(sender: AnyObject) {
        
        var message = String()
        message = setUserInfo()
        var user = PFUser()
        
        // if there is a message
        
        if message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
            var alert:UIAlertView = UIAlertView(title: "Message", message: message, delegate: nil, cancelButtonTitle: "Ok")
            
            alert.show()
        }
        
        else {
            
            // Info that we store for the PFUser
            user.username = self.username
            user.email = self.email
            user.password = self.password
            
            user.signUpInBackgroundWithBlock {
                
                
                (succeeded: Bool!, error: NSError!) -> Void in
                
                if !(error != nil) {
                    var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Successfully Signed Up. Please login using your Email address and Password.", delegate: self, cancelButtonTitle: "Ok")
                    
                    alert.show()
                    
                    self.addStandardListsToParseAndThenGoToApp()
                 
            
                }
                    
                else {
                    
                    if let errorString = error.userInfo?["error"] as? NSString
                    {
                        println(errorString)
                        var alert:UIAlertView = UIAlertView(title: "Welcome!", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                        
                        
                        
                        alert.show()
                       
                    }
                    else {
                        var alert:UIAlertView = UIAlertView(title: "Welcome!", message: "Unable to signup.", delegate: nil, cancelButtonTitle: "Ok")
                        
                        alert.show()
                     
                    }
                    
                    
                }
                
            }
            
         
            
            
        }
        
    }
    
    
    func addStandardListsToParseAndThenGoToApp()  {
        var inboxList:PFObject = PFObject(className: "List")
        inboxList["name"] = "Inbox"
        inboxList["user"] = PFUser.currentUser()
        inboxList["items"] = []
        inboxList["shared"]  = false

        
        inboxList.saveInBackgroundWithBlock {(succeeded: Bool!, error: NSError!) -> Void in
            var starredList:PFObject = PFObject(className: "List")
            starredList["name"] = "Starred"
            starredList["user"] = PFUser.currentUser()
            starredList["items"] = []
            starredList["shared"]  = false
            
            starredList.saveInBackgroundWithBlock {(succeeded: Bool!, error: NSError!) -> Void in
                
                self.finished = true

            var todayList:PFObject = PFObject(className: "List")
            todayList["name"] = "Today"
            todayList["user"] = PFUser.currentUser()
            todayList["items"] = []
            todayList["shared"]  = false
            todayList.saveInBackgroundWithBlock {(succeeded: Bool!, error: NSError!) -> Void in
            
            var weekList:PFObject = PFObject(className: "List")
            weekList["name"] = "Week"
            weekList["user"] = PFUser.currentUser()
            weekList["items"] = []
            weekList["shared"]  = false
            weekList.saveInBackgroundWithBlock {(succeeded: Bool!, error: NSError!) -> Void in
             self.goToApp()
                }
             }
            }
        
        }
        
      
    }
    
}
