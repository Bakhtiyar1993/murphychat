/* ------------------------------------------
 
 
 Copyright © 2016 Sevenstar Infotech.
 All rights reserved.
 
 ------------------------------------------*/


import UIKit
import Parse
import MessageUI


class Settings: UIViewController,
MFMailComposeViewControllerDelegate
{

    /* Views */
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var scrollView: UIScrollView!
    
    
    
 
override func viewDidAppear(_ animated: Bool) {

    // Get Current User's data
    let CurrentUser = PFUser.current()!
        
    fullnameLabel.text = "\(CurrentUser[USER_FULLNAME]!)"
    statusLabel.text = "\(CurrentUser[USER_STATUS]!)".replacingOccurrences(of: "Chatty", with: "Murphy Chat")
        
    let imageFile = CurrentUser[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
        if error == nil {
        if let imageData = imageData {
            self.avatarImage.image = UIImage(data:imageData)
    }}})
    avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
    
    scrollView.contentSize.height = 400
}
    
    
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set currentUser online
    let currentUser = PFUser.current()!
    currentUser[USER_IS_ONLINE] = true
    currentUser.saveInBackground()
    print("online!")
    
}


    
    
// MARK: - SHOW ACCOUNT BUTTON
@IBAction func accountButt(_ sender: AnyObject) {
    let pVC = storyboard?.instantiateViewController(withIdentifier: "Profile") as! Profile
    navigationController?.pushViewController(pVC, animated: true)
}
    
    
    
// MARK: - CHOOSE WALLPAPER BUTTON
@IBAction func chooseWPbutt(_ sender: AnyObject) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Wallpapers") as! Wallpapers
    navigationController?.pushViewController(aVC, animated: true)
}

// MARK: - OPEN FAVORITES BUTTON
@IBAction func showFavoritesButt(_ sender: AnyObject) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "Favorites") as! Favorites
    navigationController?.pushViewController(aVC, animated: true)
}
    
   
    
// MARK: - TERMS OF USE BUTTON
@IBAction func touButt(_ sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
    present(touVC, animated: true, completion: nil)
}
    
    
   
    
// MARK: - TELL A FRIEND BUTTON
@IBAction func tellAfriendButt(_ sender: AnyObject) {
    
    let messageStr  = "Hi there, let's chat on \(APP_NAME) | download it from the iTunes App Store: \(APPSTORE_LINK)"
    let img = UIImage(named: "logo")!
    let shareItems = [messageStr, img] as [Any]
    
    let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        // iPad
        let popOver = UIPopoverController(contentViewController: activityViewController)
        popOver.present(from: CGRect.zero, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    } else {
        // iPhone
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - DISPLAY STATISTIC BUTTON

    @IBAction func statisticButt(_ sender: AnyObject) {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Statistic") as! Statistic
        navigationController?.pushViewController(aVC, animated: true)
    }
// MARK: - LOGOUT BUTTON
@IBAction func logoutButt(_ sender: AnyObject) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to logout?",
        preferredStyle: UIAlertControllerStyle.alert)
        
    let ok = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        self.showHUD("")
            
        let currentUser = PFUser.current()!
        currentUser[USER_IS_ONLINE] = false
            
        currentUser.saveInBackground(block: { (success, error) -> Void in
            if error == nil {
                print("offline")
                    
                PFUser.logOutInBackground { (error) -> Void in
                    if error == nil {
                        // Show the Login screen
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
    
    
    
    

    
    
    
    

  
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
