//
//  ContactInfo.swift
//  Chatty
//
//  Created by ciast on 8/11/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse
class ContactInfo: UIViewController {

    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var ContactImage: UIImageView!
    @IBOutlet var ContactNameTxt: UITextField!
    @IBOutlet var StatusTxt: UITextField!
    @IBOutlet var BlockTxt: UITextField!
    @IBOutlet var PhoneNumberTxt: UITextField!
    @IBOutlet var EmailTxt: UITextField!
    @IBOutlet var Whenregister: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup layout views
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 550)
        // Initialize a BACK BarButton Item
        let backButt = UIButton(type: UIButtonType.custom)
        backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        backButt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
        
        // Layout setup
        self.title = "Contact Info"
        
        //Init Variable
        ContactNameTxt.isUserInteractionEnabled = false
        PhoneNumberTxt.isUserInteractionEnabled = false
        EmailTxt.isUserInteractionEnabled = false
        StatusTxt.isUserInteractionEnabled = false
        BlockTxt.isUserInteractionEnabled = false
        Whenregister.isUserInteractionEnabled = false
        
        ContactNameTxt.text = GB.others[USER_FULLNAME] as? String
        PhoneNumberTxt.text = GB.others[USER_PHONE_NUMBER] as? String
        EmailTxt.text = GB.others[USER_EMAIL] as? String
        StatusTxt.text = GB.others[USER_STATUS] as? String
        
        let blockedUsers =  PFUser.current()![USER_HAS_BLOCKED] as! NSMutableArray
        if blockedUsers.contains(GB.others.objectId!) {
            BlockTxt.text = "Unblock"
        } else {
            BlockTxt.text = "Block"
        }
        
        let imageFile = GB.others[USER_AVATAR] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.ContactImage.image = UIImage(data:imageData)
                    self.ContactImage.layer.cornerRadius = self.ContactImage.bounds.size.width / 2
                }}})
        
        // Get Date
        let date = GB.others.createdAt
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM dd yyyy"
        Whenregister.text = "member since " + dateFormat.string(from: date!)
        
        // swipe right gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ContactInfo.backToScreen(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func SendMessage(_ sender: AnyObject) {
        
    }
    
    @IBAction func AllMediaButt(_ sender: AnyObject) {
        let amVC = storyboard?.instantiateViewController(withIdentifier: "AllMedia") as! AllMedia
        navigationController?.pushViewController(amVC, animated: true)
    }

    @IBAction func DeleteConversation(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Are you sure you want to clear all messages?",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "Clear", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.showHUD("")
            let inboxId1 = "\(PFUser.current()!.objectId!)\(GB.others.objectId!)"
            let inboxId2 = "\(GB.others.objectId!)\(PFUser.current()!.objectId!)"
            
            let predicate = NSPredicate(format:"inboxID = '\(inboxId1)' OR inboxID = '\(inboxId2)'")
            let query = PFQuery(className: INBOX_CLASS_NAME, predicate: predicate)
            query.order(byAscending: "createdAt")
            query.findObjectsInBackground { (objects, error)-> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                        self.hideHUD()
                    }
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                }}
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
        
        alert.addAction(ok); alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    // MARK: - BACK BUTTON
    func backButton() {
        navigationController?.popViewController(animated: true)
    }
    func backToScreen(_ sender: UISwipeGestureRecognizer){
        self.backButton()
    }
    @IBAction func blockButton(_ sender: AnyObject) {
        
        showHUD("")
        let currentUser = PFUser.current()!
        let blockedUsers = currentUser[USER_HAS_BLOCKED] as! NSMutableArray
        
        // UNBLOCK USER
        if blockedUsers.contains(GB.others.objectId!) {
            blockedUsers.remove(GB.others.objectId!)
            currentUser[USER_HAS_BLOCKED] = blockedUsers
            currentUser.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.hideHUD()
                    self.simpleAlert("You've unblocked this user!")
                    self.BlockTxt.text = "Block"
                }
            })
            
            
            // BLOCK USER
        } else {
            blockedUsers.add(GB.others.objectId!)
            currentUser[USER_HAS_BLOCKED] = blockedUsers
            currentUser.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.hideHUD()
                    self.simpleAlert("You've blocked this user. He/she will no longer be able to send you messages.")
                    self.BlockTxt.text = "UnBlock"
                }
            })
        }
    }
    
}
