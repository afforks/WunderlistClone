//
//  WelcomeViewController.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-10-07.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UITextField!
    
    
    @IBOutlet weak var passwordLabel: UITextField!
    
    var username: String = ""
    var password: String = ""
    
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let user = PFUser.currentUser() as PFUser!
        
        
        
        // if facebook login = true, display the tabbarcontroller (containing our VCs) (cal function displaytabs), and set facebooklogin=false (we are no longer logging in)
        if (user != nil)
            
        {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("goToApp"), userInfo: nil, repeats: false)
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUserInfo() -> String {
        
        var message = ""
        
        if usernameLabel.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            message = "Please provide username"
        }
        
        
        
        if passwordLabel.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            message = "Please provide username"
        }
            
            
            
        else {
            self.username = usernameLabel.text!
            self.password = passwordLabel.text!
        }
        
        
        return message
        
        
    }
    
    
    
    @IBAction func logIn(sender: AnyObject) {
        
        var message = String()
        message = setUserInfo()
        
        if message.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) != 0 {
            var alert:UIAlertView = UIAlertView(title: "Message", message: message, delegate: nil, cancelButtonTitle: "Ok")
            
            alert.show()
        }
            
        else {
            PFUser.logInWithUsernameInBackground(self.username, password:self.password) {
                (user: PFUser!, error: NSError!) -> Void in
                
                if (user != nil) {
                    
                    self.goToApp()
                }
                    
                else
                {
                    if let errorString = error.userInfo?["error"] as? NSString
                    {
                        var alert:UIAlertView = UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
                        
                        alert.show()
                    }
                        
                    else {
                        var alert:UIAlertView = UIAlertView(title: "Error", message: "Unable to login" , delegate: nil, cancelButtonTitle: "Ok")
                        
                        alert.show()
                        
                    }
                    
                    
                    
                }
            }
            
        }
        
        
    }
    
    
    
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    func goToApp() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("userVC") as UserViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
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
