/* ------------------------------------------
 
 
 Copyright © 2016 Sevenstar Infotech.
 All rights reserved.
 
 ------------------------------------------*/

import UIKit
import Parse
import AudioToolbox
import MessageUI
import Contacts
import ContactsUI


// MARK: - CUSTOM NICKNAME CELL
class UserCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
}


// MARK: - USERS CONTROLLER
class UsersList: UIViewController,
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
MFMailComposeViewControllerDelegate, CNContactPickerDelegate, MFMessageComposeViewControllerDelegate
{
    
    /* Views */
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let refreshControl = UIRefreshControl()
    
    var refreshTimer = Timer()
    
//    var contacts = [CNContact]()
//    let store = CNContactStore()
//    
//    var user_contact = UserContact()
//    
//    /* Variables */
//    var usersArray = [PFObject]()
//    var userContacList = [UserContact]()
    
    var userContacList = [UserContact]()
    
override func viewWillAppear(_ animated: Bool) {
    if PFUser.current() == nil {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        present(loginVC, animated: true, completion: nil)
    }
    queryContacts("")
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Set logo on NavigationBar
    //navigationItem.titleView = UIImageView(image: UIImage(named: "logoNavBar"))

    
    // Init a refresh Control
    refreshControl.tintColor = deepPurple
    refreshControl.addTarget(self, action: #selector(refreshTB), for: .valueChanged)
    usersTableView.addSubview(refreshControl)
    
    usersTableView.backgroundColor = UIColor.clear
    
    // Timer to automatically check messages in the Inbox
    refreshTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.refreshTB), userInfo: nil, repeats: true)
}

    
// MARK: - QUERY USERS
func queryContacts(_ text:String ) {
    //showHUD("")
    self.userContacList.removeAll()
    if text == "" {
        self.userContacList = GB.userContacList
    }
    else{
        for idx in 0...GB.userContacList.count - 1 {
            var user_contact = UserContact()
            user_contact = GB.userContacList[idx]
            if user_contact.fullName.contains(text) {
                self.userContacList.append(user_contact)
                continue
            }
        }
    }
    self.usersTableView.reloadData()
    //self.hideHUD()
}
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
        return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.userContacList.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
//
//    var userClass = PFUser(className: USER_CLASS_NAME)
////    userClass = usersArray[indexPath.row] as! PFUser
////     //Get data
////    cell.fullnameLabel.text = "\(userClass[USER_FULLNAME]!)"
////    cell.statusLabel.text = "\(userClass[USER_STATUS]!)".stringByReplacingOccurrencesOfString("Chatty", withString: "Murphy Chat")
////    
////    // Get avatar
////    let imageFile = userClass[USER_AVATAR] as? PFFile
////    imageFile?.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
////        if error == nil {
////            if let imageData = imageData {
////                cell.avatarImage.image = UIImage(data:imageData)
////    }}})
////    cell.avatarImage.layer.cornerRadius = cell.avatarImage.bounds.size.width/2
////
////    
////    // Show online/offline User
////    if userClass[USER_IS_ONLINE] as! Bool == true {
////        cell.avatarImage.layer.borderColor = colorsArray[2].CGColor
////        cell.avatarImage.layer.borderWidth = 3
////    } else {
////        cell.avatarImage.layer.borderColor = UIColor.blackColor().CGColor
////        cell.avatarImage.layer.borderWidth = 3
////    }
//
////    print("++++++++\(indexPath.row
//    var isInstallApp = false
//    let contact = contacts[indexPath.row] as CNContact
//    
//    var numberArray = [String]()
//    for number in contact.phoneNumbers {
//        let phoneNumber = number.value as! CNPhoneNumber
//        numberArray.append(phoneNumber.stringValue)
//    }
//    if usersArray.count != 0{
//        for index in 0...usersArray.count-1{
//            userClass = usersArray[index] as! PFUser
//            if numberArray.contains(userClass[USER_PHONE_NUMBER] as! String) {
//                cell.statusLabel.text = "\(userClass[USER_STATUS]!)".stringByReplacingOccurrencesOfString("Chatty", withString: "Murphy Chat")
//                cell.fullnameLabel.text = "\(userClass[USER_FULLNAME])"
//                // Get avatar
////                let imageFile = userClass[USER_AVATAR] as? PFFile
////                imageFile?.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
////                    if error == nil {
////                        if let imageData = imageData {
////                            cell.avatarImage.image = UIImage(data:imageData)
////                        }
////                    }})
////                cell.avatarImage.layer.cornerRadius = cell.avatarImage.bounds.size.width/2
////                // Show online/offline User
////                if userClass[USER_IS_ONLINE] as! Bool == true {
////                    cell.avatarImage.layer.borderColor = colorsArray[2].CGColor
////                    cell.avatarImage.layer.borderWidth = 3
////                } else {
////                    cell.avatarImage.layer.borderColor = UIColor.blackColor().CGColor
////                    cell.avatarImage.layer.borderWidth = 3
////                }
//                isInstallApp = true
//                break
//            }
//            
//        }
//    }
//    if (isInstallApp == false) {
//        cell.fullnameLabel.text = "\(contact.givenName) \(contact.familyName)"
//        cell.statusLabel.text = numberArray[0]
//        if contact.imageData != nil {
////            cell.avatarImage.image = UIImage(data: contact.imageData!)
////            cell.avatarImage.layer.cornerRadius = cell.avatarImage.bounds.size.width/2
//        }
//    }
//    cell.backgroundColor = UIColor.clearColor()
    cell.fullnameLabel.text = self.userContacList[(indexPath as NSIndexPath).row].fullName
    if self.userContacList[(indexPath as NSIndexPath).row].isAppInstall == true{
        cell.statusLabel.text = self.userContacList[(indexPath as NSIndexPath).row].status
    }
    else{
        cell.statusLabel.text = self.userContacList[(indexPath as NSIndexPath).row].phoneNumber
    }
    return cell
}
//func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//    return 80
//}
    
    
// MARK: -  CELL HAS BEEN TAPPED
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    var user_contact = UserContact()
    user_contact = self.userContacList[(indexPath as NSIndexPath).row]
    if user_contact.isAppInstall == true {
        var aUser = PFUser(className: USER_CLASS_NAME)
        let currentUser = PFUser.current()!
        for idx in 0...GB.usersArray.count - 1 {
            aUser = GB.usersArray[idx] as! PFUser
            if aUser[USER_FULLNAME] as! String == user_contact.fullName {
                GB.others = aUser
                break
            }
        }
        let blockedUsers = currentUser[USER_HAS_BLOCKED] as! NSMutableArray
        if blockedUsers.contains(aUser.objectId!) {
            simpleAlert("\(aUser[USER_FULLNAME]!) has blocked you. You can't send him/her any message!")
        } else {
            let inboxVC = storyboard?.instantiateViewController(withIdentifier: "InboxVC") as! InboxVC
            inboxVC.userObj = aUser
            navigationController?.pushViewController(inboxVC, animated: true)
        }
        
    }
    else{
                //    let mailComposeViewController = configuredMailComposeViewController(numberArray[0])
                //    if MFMailComposeViewController.canSendMail() {
                //        self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                //    }
                //    else {
                //        self.simpleAlert("Sorry, Your device could not send e-mail. Please check e-mail configuration and try again!")
                //    }
        
        if( self.canSendText() ){
            let messageComposeVC = self.configuredMessageComposeViewController(user_contact.phoneNumber!)
            present(messageComposeVC, animated: true, completion: nil)
        }
        else{
            self.simpleAlert("Sorry, Your device could not send e-mail. Please check e-mail configuration and try again!")
        }

    }
    
//    var isAppInstalled = false;
//    let cellStatusText = cell.statusLabel.text
//    let cellFullNameText = cell.fullnameLabel.text
//    if ((cellStatusText?.containsString(APP_NAME)) != nil){
//            var aUser = PFUser(className: USER_CLASS_NAME)
//            for userArrayIdx in 0 ... usersArray.count-1{
//                aUser = usersArray[userArrayIdx] as! PFUser
//                if ((cellFullNameText?.compare(aUser[APP_NAME] as! String)) != nil){
//                    isAppInstalled = true
//                    break
//                }
//            }
//        if isAppInstalled{
//            // Check if a user has blocked you
//            let currentUser = PFUser.currentUser()!
//            let blockedUsers = aUser[USER_HAS_BLOCKED] as! NSMutableArray
//            if blockedUsers.containsObject(currentUser.objectId!) {
//                simpleAlert("\(aUser[USER_FULLNAME]!) has blocked you. You can't send him/her any message!")
//            } else {
//                let inboxVC = storyboard?.instantiateViewControllerWithIdentifier("InboxVC") as! InboxVC
//                inboxVC.userObj = aUser
//                navigationController?.pushViewController(inboxVC, animated: true)
//            }
//        }
//        
//    }
//    else{
    
//        let contact = contacts[indexPath.row] as CNContact
//        var numberArray = [String]()
//        for number in contact.phoneNumbers {
//            let phoneNumber = number.value as! CNPhoneNumber
//            numberArray.append(phoneNumber.stringValue)
//        }
//        //    let mailComposeViewController = configuredMailComposeViewController(numberArray[0])
//        //    if MFMailComposeViewController.canSendMail() {
//        //        self.presentViewController(mailComposeViewController, animated: true, completion: nil)
//        //    }
//        //    else {
//        //        self.simpleAlert("Sorry, Your device could not send e-mail. Please check e-mail configuration and try again!")
//        //    }
//        
//        if( self.canSendText() ){
//            let messageComposeVC = self.configuredMessageComposeViewController(numberArray[0])
//            presentViewController(messageComposeVC, animated: true, completion: nil)
//        }
//        else{
//            self.simpleAlert("Sorry, Your device could not send e-mail. Please check e-mail configuration and try again!")
//        }
    
    //}
    
}
    // send email from phone
    func configuredMailComposeViewController(_ contact:String) -> MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["\(contact)"])
        mailComposerVC.setSubject("Welcome")
        mailComposerVC.setMessageBody("Please add me as a contact", isHTML: true)
        return mailComposerVC
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // send message
    func canSendText()->Bool{
        return MFMessageComposeViewController.canSendText()
    }
    //Configure and return a MFMessageComposeViewCotroller instance
    func configuredMessageComposeViewController(_ contact: String )->MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = ["\(contact)"]
        messageComposeVC.body = "Check out \(APP_NAME) for your smartphone. Download it today from http://test.com/"
        return messageComposeVC
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - DELETE CHAT BY SWIPING THE CELL LEFT
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            //remove phone contact
            let req = CNSaveRequest()
            let mutableContact = GB.contacts[(indexPath as NSIndexPath).row].mutableCopy() as! CNMutableContact
            req.delete(mutableContact)
            
            do{
                try GB.store.execute(req)
                self.userContacList.remove(at: (indexPath as NSIndexPath).row)
                //remove global data
                GB.userContacList.remove(at: (indexPath as NSIndexPath).row)
                GB.contacts.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
            catch let e {
                print( "Error" )
            }
            
            
            
        }
    }

//func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//    
//    // Get this User
//    var userToBlock = PFUser(className: USER_CLASS_NAME)
//    userToBlock = self.usersArray[indexPath.row] as! PFUser
//
//    
//    // Set block Action Title to perform Block/Unblock actions
//    let currentUser = PFUser.currentUser()!
//    let blockedUsers = currentUser[USER_HAS_BLOCKED] as! NSMutableArray
//    var blockActionTitle = ""
//    if blockedUsers.containsObject(userToBlock.objectId!) {
//        blockActionTitle = "Unblock"
//    } else {
//        blockActionTitle = "Block"
//    }
//    
//    
//    
//    // BLOCK USER ACTION -----------------------------------------------------------------
//    let blockAction = UITableViewRowAction(style: .Default, title: blockActionTitle , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
//      
//        // UNBLOCK USER
//        if blockedUsers.containsObject(userToBlock.objectId!) {
//            blockedUsers.removeObject(userToBlock.objectId!)
//            currentUser[USER_HAS_BLOCKED] = blockedUsers
//            currentUser.saveInBackgroundWithBlock({ (succ, error) in
//                if error == nil {
//                    self.simpleAlert("You've unblocked this user!")
//                    self.usersTableView.reloadData()
//                }
//            })
//            
//            
//        // BLOCK USER
//        } else {
//            blockedUsers.addObject(userToBlock.objectId!)
//            currentUser[USER_HAS_BLOCKED] = blockedUsers
//            currentUser.saveInBackgroundWithBlock({ (succ, error) in
//                if error == nil {
//                    self.simpleAlert("You've blocked this user. He/she will no longer be able to send you messages.")
//                    self.usersTableView.reloadData()
//                }
//            })
//        }
//            
//        
//    })
//    
//    // Set colors of the actions
//    blockAction.backgroundColor = deepPurple
//    
//return [blockAction]
//}

    
// MARK: - SEARCH BAR DELEGATES
func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
    
func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //queryUsers(searchBar.text!.lowercaseString)
        //srchContactName(searchBar.text!.lowercaseString)
        queryContacts(searchBar.text!.lowercased())
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        //srchContactName("")
        //queryUsers("")
        queryContacts("")
    }
    
func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
}

@IBAction func AddContactButt(_ sender: AnyObject) {
    let contactVC = storyboard?.instantiateViewController(withIdentifier: "Contact") as! Contact
    navigationController?.pushViewController(contactVC, animated: true)
}
// MARK: - LOGOUT BUTTON
@IBAction func logoutButt(_ sender: AnyObject) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to logout?",
        preferredStyle: UIAlertControllerStyle.alert)
        
    let ok = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        self.showHUD("Logging out...")
            
        let currentUser = PFUser.current()!
        currentUser[USER_IS_ONLINE] = false
            
        currentUser.saveInBackground(block: { (success, error) -> Void in
            if error == nil {
                print("offline")
                    
                PFUser.logOutInBackground { (error) -> Void in
                    if error == nil {
                        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                        self.present(loginVC, animated: true, completion: nil)
                    }
                    self.hideHUD()
                }}
        })
    
    })
        
        
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
        
    alert.addAction(ok); alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
//    func srchContactName(srchName:String){
//        if srchName == "" {
//            self.contacts = findContacts()
//        }
//        else{
//            let predicate = CNContact.predicateForContactsMatchingName("\(srchName)")
//            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
//                               CNContactImageDataKey,
//                               CNContactPhoneNumbersKey]
//            
//            do{
//                self.contacts = try store.unifiedContactsMatchingPredicate(
//                    predicate, keysToFetch: keysToFetch)
//                
//            } catch let err{
//                print(err)
//            }
//        }
//        self.usersTableView.reloadData()
//    }
    
// MARK: - REFRESH TABLEVIEW
func refreshTB() {
    print("call refreshTB")
    if refreshControl.isRefreshing {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = "Last update: \(formatter.string(from: date))"
        let attrsDictionary = NSDictionary(object: deepPurple, forKey: NSForegroundColorAttributeName as NSCopying)
        
        let attributedTitle = NSAttributedString(string: title, attributes: attrsDictionary as? [String : AnyObject])
        refreshControl.attributedTitle = attributedTitle
        refreshControl.endRefreshing()
    }
        
    searchBar.text = ""
    searchBar.showsCancelButton = false
    searchBar.resignFirstResponder()
    
    
    // Call query
    //queryUsers("")
    queryContacts("")
}
}





