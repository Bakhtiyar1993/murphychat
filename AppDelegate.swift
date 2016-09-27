

import UIKit
import Parse
import Contacts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    
    // Init Parse
    let configuration = ParseClientConfiguration {
        $0.applicationId = PARSE_APP_KEY
        $0.clientKey = PARSE_CLIENT_KEY
        $0.server = "https://parseapi.back4app.com"
    }
    Parse.initialize(with: configuration)

    
    
    // FOR PUSH NOTIFICATIONS WITH ONE SIGNAL SERVICE http://onesignal.com
    _ = OneSignal(launchOptions: launchOptions, appId: ONESIGNAL_APP_ID, handleNotification: nil)
    OneSignal.defaultClient().enable(inAppAlertNotification: true)
    
    GB.contacts = self.findContacts()
    self.getContactList()
    GB.queryUsers()
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            self.contacts = self.findContacts()
//            self.getContactList()
//            dispatch_async(dispatch_get_main_queue()) {
//                self.queryUsers()
//            }
//        }

    
    return true
}
    func getContactList(){
        for idx in 0...GB.contacts.count-1{
            let user_contact = UserContact()
            let contact = GB.contacts[idx] as CNContact
            var numberArray = [String]()
            for number in contact.phoneNumbers {
                let phoneNumber = number.value 
                numberArray.append(phoneNumber.stringValue)
            }
            if numberArray.count != 0 {
                user_contact.phoneNumber = numberArray[0]
            }
            else {
                user_contact.phoneNumber = ""
            }
            
            user_contact.fullName = "\(contact.givenName) \(contact.familyName)"
            user_contact.isAppInstall = false
            GB.userContacList.append(user_contact)
        }
    }
    
    func findContacts() -> [CNContact] {
        //let store = CNContactStore()
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactImageDataKey,
                           CNContactPhoneNumbersKey] as [Any]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        
        var contacts = [CNContact]()
        
        do {
            try GB.store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                contacts.append(contact)
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        return contacts
    }
        
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if PFUser.current() != nil {
            let currentUser = PFUser.current()!
            currentUser[USER_IS_ONLINE] = false
            currentUser.saveInBackground()
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    
    
// MARK: - SET USER OFFLINE
func applicationWillTerminate(_ application: UIApplication) {
    
    if PFUser.current() != nil {
        let currentUser = PFUser.current()!
        currentUser[USER_IS_ONLINE] = false
        currentUser.saveInBackground()
    }
}
}

