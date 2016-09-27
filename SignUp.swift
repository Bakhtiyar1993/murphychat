

import UIKit
import Parse


class SignUp: UIViewController,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet var phoneNumber: UITextField!
    

    
override func viewDidLoad() {
        super.viewDidLoad()
        
    // Setup layout views
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 550)
    
    // SET COLOR OF PLACEHOLDERS
    let color = UIColor.white
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "choose a username", attributes: [NSForegroundColorAttributeName: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "choose a password", attributes: [NSForegroundColorAttributeName: color])
    emailTxt.attributedPlaceholder = NSAttributedString(string: "type your email address", attributes: [NSForegroundColorAttributeName: color])
    fullNameTxt.attributedPlaceholder = NSAttributedString(string: "type your full name", attributes: [NSForegroundColorAttributeName: color])
    phoneNumber.attributedPlaceholder = NSAttributedString(string: "type your phone number", attributes: [NSForegroundColorAttributeName: color])
}
    
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
   dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    fullNameTxt.resignFirstResponder()
    phoneNumber.resignFirstResponder()
}
    
    
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(_ sender: AnyObject) {
    dismissKeyboard()
    showHUD("Signing up...")

    if fullNameTxt.text != "" || passwordTxt.text != "" || usernameTxt.text != "" ||
    emailTxt.text != "" || phoneNumber.text != ""{
    
        let userForSignUp = PFUser()
        userForSignUp.username = usernameTxt.text!.lowercased()
        userForSignUp.email = emailTxt.text!
        userForSignUp.password = passwordTxt.text!
        userForSignUp[USER_FULLNAME] = fullNameTxt.text!
        userForSignUp[USER_FULLNAME_LOWERCASE] = fullNameTxt.text!.lowercased()
        userForSignUp[USER_IS_ONLINE] = true
        userForSignUp[USER_STATUS] = "Hi there, I'm on \(APP_NAME)!"
        userForSignUp[USER_PHONE_NUMBER] = phoneNumber.text!
        let hasBlocked = [String]()
        userForSignUp[USER_HAS_BLOCKED] = hasBlocked
    
        let oneSignal = OneSignal.defaultClient()
        oneSignal?.idsAvailable({ (pushID, pushToken) -> Void in
            print("PushID at Sign Up: \(pushID)")
            userForSignUp[USER_PUSH_ID] = pushID
        })
    
        
        userForSignUp.signUpInBackground { (succeeded, error) -> Void in
            if error == nil {
                self.dismiss(animated: false, completion: nil)
                self.hideHUD()
        
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
        
        
        
        
    // CAN'T SIGN UP -> EMPTY FILED(S)
    } else {
        simpleAlert("You must fill all the fields to Sign Up!")
        hideHUD()
    }
}
    
    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt {  passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder() }
    if textField == emailTxt    {  fullNameTxt.becomeFirstResponder() }
    if textField == fullNameTxt { fullNameTxt.becomeFirstResponder() }
    if textField == phoneNumber {
        dismissKeyboard()
        signupButt(self)
    }
    
return true
}
    
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
}
    
    

    
// MARK: - TERMS OF USE BUTTON
@IBAction func touButt(_ sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
    present(touVC, animated: true, completion: nil)
}
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
