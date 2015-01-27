//
//  BackgroundViewController.swift
//  Wunderlist
//
//  Created by William McDuff on 2015-01-21.
//  Copyright (c) 2015 Appfish. All rights reserved.
//

import UIKit



protocol changeBackgroundOrImageProtocol {
    func changeBackground(imageName: String)
    func changeUserImage(image: UIImage)
}



class BackgroundViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate

{

  
    @IBOutlet weak var chooseFromGalleryButton: UIButton!
    
    @IBOutlet weak var BackgroundCollectionView: UICollectionView!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userImageButton: UIButton!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIImageView!
    
    
    
    var username: String?
    var email: String?
    
    var arrayOfBackgroundImageNames: NSArray!
    
    
    var delegate: changeBackgroundOrImageProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.backgroundView.contentMode = UIViewContentMode.ScaleToFill

        // Do any additional setup after loading the view.
        
        if username != nil {
            nameLabel.text = username
            emailLabel.text = email
        }
        
        if globalUserImage != nil {
            self.userImageView.image = globalUserImage
        }
        
        if globalBackgroundImage != nil {
            self.backgroundView.image = globalBackgroundImage!
        }
        BackgroundCollectionView.dataSource = self;
        BackgroundCollectionView.delegate = self;
        BackgroundCollectionView.backgroundColor = UIColor.clearColor()
        
        arrayOfBackgroundImageNames = ["CentrakPark1.JPG", "Murakami - Gero Tan.jpg", "Van Gogh-Starry.jpg", "Van Gogh-Terrasse.jpg"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func chooseUserImage(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
         imagePickerController.view.tag = 1
        
        // add an alert action where we can take a photo with our camera
        let actionSheet = UIAlertController(title: "Choose image source", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction!) -> Void in
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePickerController, animated: true, completion: nil)
            
        }))
        
        // another action where we take a photo from our library
        actionSheet.addAction(UIAlertAction(title: "Camera Roll", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction!) -> Void in
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePickerController, animated: true, completion: nil)
            
        }))
        
        // and a cancel action
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
        
        
        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: FilterCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as FilterCollectionViewCell
        
        var imageName = self.arrayOfBackgroundImageNames[indexPath.row] as String
        
        cell.cellImageView.image = UIImage(named: imageName)
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var imageName = self.arrayOfBackgroundImageNames[indexPath.row] as String
        
        var image = UIImage(named: imageName)
        globalBackgroundImage = image!
        backgroundView.image = image!
        saveImageToParse(image!, background: true)
        
        if delegate != nil {
            delegate!.changeBackground(imageName)
        }
    
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.arrayOfBackgroundImageNames.count
    }
    
    @IBAction func changeBackground(sender: AnyObject) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.view.tag = 2
        
        // add an alert action where we can take a photo with our camera
        let actionSheet = UIAlertController(title: "Choose image source", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction!) -> Void in
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePickerController, animated: true, completion: nil)
            
        }))
        
        // another action where we take a photo from our library
        actionSheet.addAction(UIAlertAction(title: "Camera Roll", style: UIAlertActionStyle.Default, handler: { (alert:UIAlertAction!) -> Void in
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePickerController, animated: true, completion: nil)
            
        }))
        
        // and a cancel action
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image:UIImage = info[UIImagePickerControllerOriginalImage] as UIImage
        
        if picker.view.tag == 1 {
            userImageView.contentMode = UIViewContentMode.ScaleAspectFill
            
            userImageView.backgroundColor = UIColor.blueColor()
            userImageView.image = image
            saveImageToParse(image, background: false)
            if delegate != nil {
                delegate!.changeUserImage(image)
            }
            
        }
        
        if picker.view.tag == 2 {
            backgroundView.contentMode = UIViewContentMode.ScaleAspectFill
            backgroundView.image = image
            saveImageToParse(image, background: true)
            
           
        }
        
        
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        
        
    }

    
    func saveImageToParse(userImage: UIImage, background: Bool) {
        
        
        var query = PFQuery(className:"_User")
        
        query.whereKey("objectId", equalTo: PFUser.currentUser().objectId)
        
    
        
        
        query.findObjectsInBackgroundWithBlock() {
            (objects:[AnyObject]!, error:NSError!)->Void in
            if ((error) == nil) {
             
                    
                let userObject:PFUser =  objects.last as PFUser
                
                let imageName = PFUser.currentUser().username + ".jpg" as String
                
               
                let imageData = UIImagePNGRepresentation(userImage)
                
                let imageFile = PFFile(name:imageName, data:imageData)
                
                if background == true {
                    
                    userObject["backgroundImageFile"] = imageFile
                    
                    userObject["backgroundImageName"] = imageName
                   
                }
                
                if background == false {
                    userObject["imageFile"] = imageFile
                    
                    userObject["imageName"] = imageName
                    
                }
         
           
                
                
                
                userObject.saveInBackgroundWithBlock({ (succeeded: Bool!, error: NSError!) -> Void in
                
                    if (succeeded == true) {
                        println("YES")
                            println(succeeded)
                        
                        if background == false {
                            globalUserImage = self.userImageView.image
                        }
                        
                    }
                
                
                
                })
                    
                
                
            }
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
