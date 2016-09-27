/* ------------------------------------------
 
 
 Copyright © 2016 Sevenstar Infotech.
 All rights reserved.
 
 ------------------------------------------*/


import UIKit
import Contacts
import ContactsUI


class NewContact: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var mobileTxt: UITextField!
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    let contactStore = CNContactStore()
    
    
override func viewDidLoad() {
        super.viewDidLoad()

//    self.edgesForExtendedLayout = .None
//    
//    
//    // Initialize a SAVE BarButton Item
//    let butt = UIButton(type: UIButtonType.Custom)
//    butt.frame = CGRectMake(0, 0, 44, 44)
//    butt.setBackgroundImage(UIImage(named: "saveButt"), forState: .Normal)
//    butt.addTarget(self, action: #selector(saveContactButt), forControlEvents: .TouchUpInside)
//    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
//
//    // Initialize a BACK BarButton Item
//    let backButt = UIButton(type: UIButtonType.Custom)
//    backButt.frame = CGRectMake(0, 0, 44, 44)
//    backButt.setBackgroundImage(UIImage(named: "backButt"), forState: .Normal)
//    backButt.addTarget(self, action: #selector(backButton), forControlEvents: .TouchUpInside)
//    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
//
//    
//    // Layout setup
//    avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
//    self.title = "NEW CONTACT"
//    
//    
//    // Initial Contact info
//    mobileTxt.text = "";
//    emailTxt.text = "";
//    fullNameTxt.text = "";
}

    
    
// MARK: -  CHANGE AVATAR BUTTON
@IBAction func changeAvatarButt(sender: AnyObject) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Select source",
        preferredStyle: .Alert)
    
    let camera = UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    })
    
    let library = UIAlertAction(title: "Choose an Image", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    })
    
    
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in })
    
    alert.addAction(camera)
    alert.addAction(library)
    alert.addAction(cancel)
    presentViewController(alert, animated: true, completion: nil)

}
// ImagePicker delegate
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
    avatarImage.image = image
    dismissViewControllerAnimated(true, completion: nil)
}
 
// MARK: - SAVE CONTACT BUTTON
func saveContactButt() {
    showHUD("Saving...")
    
    switch CNContactStore.authorizationStatusForEntityType(.Contacts) {
    case .Authorized:
        createContact()
    case .NotDetermined:
        contactStore.requestAccessForEntityType(.Contacts){
            succeeded, err in guard err == nil && succeeded else{
                return
            }
            self.createContact()
        }
    default:
        print("Not handled")
    }
    
    
}
    
func createContact(){
    
    let saveContactRequest = CNSaveRequest()
    let mutableContact = CNMutableContact()
    mutableContact.givenName = fullNameTxt.text!
    
    mutableContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value:
        CNPhoneNumber(stringValue: mobileTxt.text!))]
    mutableContact.emailAddresses = [ CNLabeledValue(label: CNLabelWork, value: emailTxt.text! ) ]
    
    // Save Avatar Image (if exists)
    if avatarImage.image != nil {
        let imageData = UIImageJPEGRepresentation(avatarImage.image!, 0.5)
        mutableContact.imageData = imageData
    }
    
    saveContactRequest.addContact(mutableContact, toContainerWithIdentifier: nil)
    do{
        try contactStore.executeSaveRequest(saveContactRequest)
        self.hideHUD()
        self.simpleAlert("New Contact has been saved!")
        self.navigationController?.popViewControllerAnimated(true)
        
    }catch let error{
        self.simpleAlert("\(error)")
        self.hideHUD()
    }
    
}

    
    
// MARK: - TEXTFIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == mobileTxt   { fullNameTxt.becomeFirstResponder() }
    if textField == fullNameTxt { emailTxt.becomeFirstResponder()    }
    if textField == emailTxt    { emailTxt.resignFirstResponder()    }
    
return true
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismisskeyb(sender: UITapGestureRecognizer) {
    fullNameTxt.resignFirstResponder()
    mobileTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
}
    
    
    
    
// MARK: - BACK BUTTON
func backButton() {
    navigationController?.popViewControllerAnimated(true)
}

    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
