//
//  GB.swift
//  Chatty
//
//  Created by ciast on 8/11/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse
import Contacts
class UserContact{
    var fullName: String!
    var status: String?
    var avatar: UIImage?
    var isAppInstall: Bool!
    var phoneNumber: String?
    var objectId: String? 
}

class GB{
    static var userContacList = [UserContact]()
    static var usersArray = [PFObject]()
    static var appUserArray = [PFObject]()
    static var others = PFUser(className: USER_CLASS_NAME)
    static var contacts = [CNContact]()
    static let store = CNContactStore()
    static let isNeedChatReload = false
    // MARK: - QUERY USERS
    static func queryUsers() {
        if let currentUser = PFUser.current() {
            // Set currentUser online
            
            currentUser[USER_IS_ONLINE] = true
            currentUser.saveInBackground()
            print("online!")
            let query = PFUser.query()!
            query.whereKey(USER_USERNAME, notEqualTo: PFUser.current()!.username!)
            query.order(byDescending: "createdAt")
            query.findObjectsInBackground { (users, error)-> Void in
                if error == nil {
                    GB.usersArray = users!
                    var userClass = PFUser(className: USER_CLASS_NAME)
                    var contactClass = UserContact()
                    if GB.usersArray.count != 0 {
                        for contactAryIdx in 0...GB.userContacList.count-1{
                            contactClass = GB.userContacList[contactAryIdx]
                            for userAryIdx in 0...GB.usersArray.count-1 {
                                userClass = GB.usersArray[userAryIdx] as! PFUser
                                let phoneNumber = "\(userClass[USER_PHONE_NUMBER]!)"
                                if contactClass.phoneNumber == phoneNumber {
                                    GB.userContacList[contactAryIdx].isAppInstall = true;
                                    GB.userContacList[contactAryIdx].fullName = "\(userClass[USER_FULLNAME]!)"
                                    GB.userContacList[contactAryIdx].status = "\(userClass[USER_STATUS]!)"
                                    // append app use list
                                    GB.appUserArray.append(userClass)
                                }
                            }
                        }
                        
                    }
                } else {
                    print("\(error!.localizedDescription)")
                }}
        }
        
    }
    

}
