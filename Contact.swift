//
//  Contact.swift
//  Chatty
//
//  Created by ciast on 8/5/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class Contact: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate
{

    
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var fullNameTxt: UITextField!
    @IBOutlet var mobileTxt: UITextField!
    @IBOutlet var contactImage: UIImageView!
    @IBOutlet var containerScrollView: UIScrollView!
    
    let contactStore = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge()
        
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 700)
        // Initialize a SAVE BarButton Item
        let butt = UIButton(type: UIButtonType.custom)
        butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        butt.setBackgroundImage(UIImage(named: "saveButt"), for: UIControlState())
        butt.addTarget(self, action: #selector(saveContactButt), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
        
        // Initialize a BACK BarButton Item
        let backButt = UIButton(type: UIButtonType.custom)
        backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        backButt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
        
        
        // Layout setup
        contactImage.layer.cornerRadius = contactImage.bounds.size.width/2
        self.title = "NEW CONTACT"
        
        
        //Init textfields
        mobileTxt.text = ""
        fullNameTxt.text = ""
        emailTxt.text = ""
        
        // swipe right gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(Contact.backToScreen(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - SAVE PROFILE BUTTON
    func saveContactButt() {
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            createContact()
        case .notDetermined:
            contactStore.requestAccess(for: .contacts){
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
        
        if fullNameTxt.text! == "" || mobileTxt.text! == "" {
            self.simpleAlert("Pleae input all data!")
        }
        else {
            showHUD("Saving...")
            mutableContact.givenName = fullNameTxt.text!
            
            mutableContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value:
                CNPhoneNumber(stringValue: mobileTxt.text!))]
            mutableContact.emailAddresses = [ CNLabeledValue(label: CNLabelHome, value: emailTxt.text! ) ]
            
            // Save Contact Image (if exists)
            if contactImage.image != nil {
                let imageData = UIImageJPEGRepresentation(contactImage.image!, 0.5)
                mutableContact.imageData = imageData
            }
            
            saveContactRequest.add(mutableContact, toContainerWithIdentifier: nil)
            do{
                try contactStore.execute(saveContactRequest)
                
                let user_contact = UserContact()
                user_contact.fullName = fullNameTxt.text!
                user_contact.phoneNumber = mobileTxt.text!
                user_contact.isAppInstall = false
                // add global data
                GB.userContacList.append(user_contact)
                // add global contact
                GB.contacts.append(mutableContact)
                GB.queryUsers()
                self.hideHUD()
                self.simpleAlert("New Contact has been saved!")
                self.navigationController?.popViewController(animated: true)
                
            }catch let error{
                self.simpleAlert("\(error)")
                self.hideHUD()
            }
        }
    }
    
    // MARK: - BACK BUTTON
    func backButton() {
        navigationController?.popViewController(animated: true)
    }
    func backToScreen(_ sender: UISwipeGestureRecognizer){
        self.backButton()
    }
    @IBAction func contactImageBtn(_ sender: AnyObject) {
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
        contactImage.image = image
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TAP TO DISMISS KEYBOARD
    @IBAction func tapToDismisskeyb(_ sender: UITapGestureRecognizer) {
        fullNameTxt.resignFirstResponder()
        mobileTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
    }
}
