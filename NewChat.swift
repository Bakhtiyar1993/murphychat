//
//  NewChat.swift
//  Chatty
//
//  Created by ciast on 8/12/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse

// MARK: - CUSTOM INBOX CELLS
class NewChatCell: UITableViewCell
{
    /* Views */
    @IBOutlet var avatarImg: UIImageView!
    @IBOutlet var nameLB: UILabel!
    @IBOutlet var statusLB: UILabel!
}

class NewChat: UIViewController,UITableViewDataSource,
    UITableViewDelegate
{

    @IBOutlet var NewChatTableView: UITableView!
    
    var usersArray = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize a BACK BarButton Item
        let backButt = UIButton(type: UIButtonType.custom)
        backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        backButt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
        
        
        // Layout setup
        self.title = "NEW CHAT"
        
        // swipe right gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(NewChat.backToScreen(_:)))
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
    // MARK: - BACK BUTTON
    func backButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GB.appUserArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewChatCell", for: indexPath) as! NewChatCell
        
        var userClass = PFUser(className: USER_CLASS_NAME)
        userClass = GB.appUserArray[(indexPath as NSIndexPath).row] as! PFUser
        
        // Get data
        cell.nameLB.text = "\(userClass[USER_FULLNAME]!)"
        cell.statusLB.text = "\(userClass[USER_STATUS]!)".replacingOccurrences(of: "Chatty", with: "Murphy Chat")

        // Get avatar
        let imageFile = userClass[USER_AVATAR] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.avatarImg.image = UIImage(data:imageData)
                }}})
        cell.avatarImg.layer.cornerRadius = cell.avatarImg.bounds.size.width/2
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    // MARK: -  CELL HAS BEEN TAPPED
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var aUser = PFUser(className: USER_CLASS_NAME)
        aUser = GB.appUserArray[(indexPath as NSIndexPath).row] as! PFUser
        
        // Check if a user has blocked you
        let currentUser = PFUser.current()!
        let blockedUsers = aUser[USER_HAS_BLOCKED] as! NSMutableArray
        if blockedUsers.contains(currentUser.objectId!) {
            simpleAlert("\(aUser[USER_FULLNAME]!) has blocked you. You can't send him/her any message!")
        } else {
            let inboxVC = storyboard?.instantiateViewController(withIdentifier: "InboxVC") as! InboxVC
            inboxVC.userObj = aUser
            GB.others = aUser
            navigationController?.pushViewController(inboxVC, animated: true)
        }
        
        
    }
    
    func backToScreen(_ sender: UISwipeGestureRecognizer){
        self.backButton()
    }
}
