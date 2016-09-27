/* ------------------------------------------
 
 
 Copyright © 2016 Sevenstar Infotech.
 All rights reserved.
 
 ------------------------------------------*/


import UIKit
import Parse



class Profile: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var statusTxt: UITextField!
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    self.edgesForExtendedLayout = UIRectEdge()
    
    
    // Initialize a SAVE BarButton Item
    let butt = UIButton(type: UIButtonType.custom)
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "saveButt"), for: UIControlState())
    butt.addTarget(self, action: #selector(saveProfileButt), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)

    // Initialize a BACK BarButton Item
    let backButt = UIButton(type: UIButtonType.custom)
    backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    backButt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
    backButt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)

    
    // Layout setup
    avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
    self.title = "PROFILE"
    
    
    // Show user details
    let CurrentUser = PFUser.current()!
    statusTxt.text = "\(CurrentUser[USER_STATUS]!)".replacingOccurrences(of: "Chatty", with: "Murphy Chat")
    fullNameTxt.text = "\(CurrentUser[USER_FULLNAME]!)"
    emailTxt.text = "\(CurrentUser[USER_EMAIL]!)"

    let imageFile = CurrentUser[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.avatarImage.image = UIImage(data:imageData)
    }}})
    

    
}

    
    
// MARK: -  CHANGE AVATAR BUTTON
@IBAction func changeAvatarButt(_ sender: AnyObject) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Select source",
        preferredStyle: .alert)
    
    let camera = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    let library = UIAlertAction(title: "Choose an Image", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
    
    alert.addAction(camera)
    alert.addAction(library)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)

}
// ImagePicker delegate
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    avatarImage.image = image
    dismiss(animated: true, completion: nil)
}
    
    
    
    
    
 
// MARK: - SAVE PROFILE BUTTON
func saveProfileButt() {
    showHUD("Saving...")
    
    let userToUpdate = PFUser.current()!
    userToUpdate[USER_FULLNAME] = fullNameTxt.text!
    userToUpdate[USER_EMAIL] = emailTxt.text!
    userToUpdate[USER_STATUS] = statusTxt.text!
    
    // Save Avatar Image (if exists)
    if avatarImage.image != nil {
        let imageData = UIImageJPEGRepresentation(avatarImage.image!, 0.5)
        let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
        userToUpdate[USER_AVATAR] = imageFile
    }
    
    // Saving block
    userToUpdate.saveInBackground { (success, error) -> Void in
        if error == nil {
            self.hideHUD()
            self.simpleAlert("Your Profile has been updated!")
            self.navigationController?.popViewController(animated: true)
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
        }}
}
    
    
    
    
// MARK: - TEXTFIELD DELEGATE
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == statusTxt   { fullNameTxt.becomeFirstResponder() }
    if textField == fullNameTxt { emailTxt.becomeFirstResponder()    }
    if textField == emailTxt    { emailTxt.resignFirstResponder()    }
    
return true
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismisskeyb(_ sender: UITapGestureRecognizer) {
    fullNameTxt.resignFirstResponder()
    statusTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
}
    
    
    
    
// MARK: - BACK BUTTON
func backButton() {
    navigationController?.popViewController(animated: true)
}

    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
