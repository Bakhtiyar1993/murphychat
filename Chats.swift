/* ------------------------------------------
 
 
 Copyright © 2016 Sevenstar Infotech.
 All rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse
import AudioToolbox




// MARK: - CUSTOM NICKNAME CELL
class ChatsCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var lastMessLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var senderLabel: UILabel!
}

// MARK: - CHATS CONTROLLER
class Chats: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate
{

    /* Views */
    @IBOutlet weak var chatsTableView: UITableView!

    // Ad banners properties
    
    
    /* Variables */
    var chatsArray = [PFObject]()
    override func viewDidAppear(_ animated: Bool) {
        if GB.isNeedChatReload == true {
            queryChats()
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        queryChats()
    }
override func viewDidLoad() {
        super.viewDidLoad()

    // Layout
    chatsTableView.backgroundColor = UIColor.clear
    
    let butt = UIButton(type: UIButtonType.custom)
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "saveButt"), for: UIControlState())
    butt.addTarget(self, action: #selector(createNewChatButt), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
}
    
// QUERY CHATS
func queryChats() {
    showHUD("")
    

    // Set currentUser online
    let currentUser = PFUser.current()!
    currentUser[USER_IS_ONLINE] = true
    currentUser.saveInBackground()
    print("online!")
    // Make query
    let query = PFQuery(className: CHATS_CLASS_NAME)
    query.includeKey(USER_CLASS_NAME)
    query.whereKey(CHATS_ID, contains: "\(currentUser.objectId!)")
    query.order(byDescending: "createdAt")
    
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.chatsArray.removeAll()
            self.chatsArray = objects!
            self.chatsTableView.reloadData()
            self.hideHUD()
        
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}

}
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return chatsArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsCell
    
    var chatsClass = PFObject(className: CHATS_CLASS_NAME)
    chatsClass = chatsArray[(indexPath as NSIndexPath).row]
    
    // Get User Pointer
    let userPointer = chatsClass[CHATS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground { (user, error) in
    
        let otherUser = chatsClass[CHATS_OTHER_USER] as! PFUser
        otherUser.fetchIfNeededInBackground(block: { (user2, error) in
            if error == nil {
                
                // userPointer = Current User
                if userPointer.objectId == PFUser.current()!.objectId {
                    cell.fullNameLabel.text = "\(otherUser[USER_FULLNAME]!)"
                    
                    // Get image
                    cell.avatarImage.image = UIImage(named: "logo")
                    let imageFile = otherUser[USER_AVATAR] as? PFFile
                    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                cell.avatarImage.image = UIImage(data:imageData)
                    }}})
                    
                    
                // userPointer != Current User
                } else {
                    cell.fullNameLabel.text = "\(userPointer[USER_FULLNAME]!)"
                    
                    // Get image
                    cell.avatarImage.image = UIImage(named: "logo")
                    let imageFile = userPointer[USER_AVATAR] as? PFFile
                    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                cell.avatarImage.image = UIImage(data:imageData)
                    }}})
                }
                
                
                // Get last Message
                cell.lastMessLabel.text = "\(chatsClass[CHATS_LAST_MESSAGE]!)"
                
                // Get Sender's name
                cell.senderLabel.text = "\(userPointer[USER_FULLNAME]!):"
                
                // Get Date
                let date = chatsClass.createdAt
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "MMM dd yyyy | hh:mm"
                cell.dateLabel.text = dateFormat.string(from: date!)
                
                
                // Assign a randolm color to the barView
                let randColor = Int(arc4random() % UInt32(colorsArray.count))
                cell.barView.backgroundColor = colorsArray[randColor]
 
            // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})
    }
    
    
    
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
}
    
    
    
// MARK: -  CELL HAS BEEN TAPPED -> CHAT WITH THE SELECTED CHAT
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var chatsClass = PFObject(className: CHATS_CLASS_NAME)
    chatsClass = chatsArray[(indexPath as NSIndexPath).row]
    
    // Get userPointer
    let userPointer = chatsClass[CHATS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground { (user, error) in
        
        let otherUser = chatsClass[CHATS_OTHER_USER] as! PFUser
        otherUser.fetchIfNeededInBackground(block: { (user2, error) in
            if error == nil {
                // Check if a user has blocked you
                let currentUser = PFUser.current()!
                let blockedUsers = otherUser[USER_HAS_BLOCKED] as! NSMutableArray
                if blockedUsers.contains(currentUser.objectId!) {
                    self.simpleAlert("\(otherUser[USER_FULLNAME]!) has blocked you. You can't send him/her any message!")
                
                
                } else {
                    let inboxVC = self.storyboard?.instantiateViewController(withIdentifier: "InboxVC") as! InboxVC
        
                    if userPointer.objectId == PFUser.current()!.objectId {
                        inboxVC.userObj = otherUser
                        GB.others = otherUser
                    } else {
                        inboxVC.userObj = userPointer
                        GB.others = userPointer
                    }
                
                    self.navigationController?.pushViewController(inboxVC, animated: true)
                }
                
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})

    }
    
}
    func createNewChatButt() {
        var cnt = 0
        for idx in 0...GB.userContacList.count-1{
            if GB.userContacList[idx].isAppInstall == true {
                cnt += 1
            }
        }
        let createNewChatVC = storyboard?.instantiateViewController(withIdentifier: "NewChat") as! NewChat
        navigationController?.pushViewController(createNewChatVC, animated: true)
    }
    
    
// MARK: - DELETE CHAT BY SWIPING THE CELL LEFT
func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
}
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCellEditingStyle.delete {

        var chatClass = PFObject(className: CHATS_CLASS_NAME)
        chatClass = chatsArray[(indexPath as NSIndexPath).row]
        
        chatClass.deleteInBackground {(success, error) -> Void in
            if error == nil {
                self.chatsArray.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }}
        
//        let sender = "\(PFUser.currentUser()!.objectId!)"
//        let receiver = "\(chatClass[CHATS_OTHER_USER])"
//        
//        let predicate1 = NSPredicate(format:"receiver = '\(sender)' AND sender = '\(receiver)'")
//        let query1 = PFQuery(className: INBOX_CLASS_NAME, predicate: predicate1)
//        query1.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
//            if error == nil {
//                for object in objects! {
//                    object.deleteEventually()
//                }
//            }
//        }
//        let predicate2 = NSPredicate(format:"sender = '\(receiver)' AND receiver = '\(sender)'")
//        let query2 = PFQuery(className: INBOX_CLASS_NAME, predicate: predicate2)
//        
//        query2.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
//            if error == nil {
//                for object in objects! {
//                    object.deleteEventually()
//                }
//            }
//        }
    }
}

}
