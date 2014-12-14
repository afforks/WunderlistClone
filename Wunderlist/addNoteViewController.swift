//
//  addNoteViewController.swift
//  Wunderlist
//
//  Created by William McDuff on 2014-10-30.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit

class addNoteViewController: UIViewController {
    
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var subtitle: UILabel!
    
    
    
    var itemName: String? = nil
    
    var listName: String? = nil
    var noteString = String()
    var delegate: addToItemDictProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.subtitle.text = itemName
        self.noteTextView.text = noteString
        // Do any additional setup after loading the view.
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNote(sender: AnyObject) {
        
        if (noteTextView.text != nil) {
            
            if self.delegate != nil {
                
                self.navigationController?.popViewControllerAnimated(true)
                
                self.delegate!.addNote(self.noteTextView.text)
                
                
                
                
                
                
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
