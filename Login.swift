


import UIKit
import Parse
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class Login: UIViewController,
UITextFieldDelegate,
UIAlertViewDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    
   
    
    
override func viewWillAppear(_ animated: Bool) {
    if PFUser.current() != nil {
        //dismissViewControllerAnimated(false, completion: nil)
    }
}
override func viewDidLoad() {
        super.viewDidLoad()
        
    // Setup layouts
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 600)
    
    // SET COLOR OF PLACEHOLDERS
    let color = UIColor.lightGray
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "type your nickname", attributes: [NSForegroundColorAttributeName: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "type your password", attributes: [NSForegroundColorAttributeName: color])
}
    
   
// MARK: - LOGIN BUTTON
@IBAction func loginButt(_ sender: AnyObject) {
    dismissKeyboard()
    showHUD("Signing in...")
    
    PFUser.logInWithUsername(inBackground: usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
        // Login successfull
        if user != nil {
            let currentUser = PFUser.current()!
            currentUser[USER_IS_ONLINE] = true
            currentUser.saveInBackground()
            
            self.dismiss(animated: true, completion: nil)
            self.hideHUD()
            GB.queryUsers()
        // Login failed. Try again or SignUp
        } else {
            let alert = UIAlertView(title: APP_NAME,
                message: "\(error!.localizedDescription)",
                delegate: self,
                cancelButtonTitle: "Retry",
                otherButtonTitles: "Sign Up")
            alert.show()
            self.hideHUD()
    }}
}
    func isValidEmail(_ testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
// AlertView delegate
func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    if alertView.buttonTitle(at: buttonIndex) == "Sign Up" {
        signupButt(self)
    }
    else if alertView.buttonTitle(at: buttonIndex) == "Reset" {
        if alertView.textField(at: 0)?.text?.characters.count>0
        {
            alertView.textField(at: 0)?.resignFirstResponder()

            if self.isValidEmail((alertView.textField(at: 0)?.text)!)==true
            {
                showHUD("")
                PFUser.requestPasswordResetForEmail(inBackground: (alertView.textField(at: 0)?.text)!) { (success, error) in
                    if error != nil {
                        let alert = UIAlertView(title: APP_NAME,
                                                message: "\(error!.localizedDescription)",
                                                delegate: nil,
                                                cancelButtonTitle: nil,
                                                otherButtonTitles: "Ok")
                        alert.show()
                        self.hideHUD()
                    } else {
                        let alert = UIAlertView(title: APP_NAME,
                                                message: "Password reset successfully",
                                                delegate: nil,
                                                cancelButtonTitle: nil,
                                                otherButtonTitles: "Ok")
                        alert.show()
                        self.hideHUD()
                    }
                }
                
            }
            else
            {
                let alert = UIAlertView(title: APP_NAME,
                                        message: "Please enter valid email",
                                        delegate: self,
                                        cancelButtonTitle: "Cancel",
                                        otherButtonTitles: "Reset")
                alert.tag=400
                alert.alertViewStyle=UIAlertViewStyle.plainTextInput
                alert.show()
            }
            
            
        }
        else
        {
            let alert = UIAlertView(title: APP_NAME,
                                    message: "Please enter email",
                                    delegate: self,
                                    cancelButtonTitle: "Cancel",
                                    otherButtonTitles: "Reset")
            alert.tag=400
            alert.alertViewStyle=UIAlertViewStyle.plainTextInput
            alert.show()
        }
    }
}
    
    
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(_ sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
    signupVC.modalTransitionStyle = .crossDissolve
    present(signupVC, animated: true, completion: nil)
}
    
    @IBAction func forgotButt(_ sender: AnyObject) {
        dismissKeyboard()
        
        let alert = UIAlertView(title: APP_NAME,
                                message: "Please enter email",
                                delegate: self,
                                cancelButtonTitle: "Cancel",
                                otherButtonTitles: "Reset")
        alert.tag=400
        alert.alertViewStyle=UIAlertViewStyle.plainTextInput
        alert.show()
    }
   
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt  {
        loginButt(self)
        passwordTxt.resignFirstResponder()
    }
    
return true
}
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
