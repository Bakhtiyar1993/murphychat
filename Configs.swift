

import Foundation
import UIKit
import AVFoundation




// IMPORTANT: Replace the red string below with the new name you'll give to this app.

    //let APP_NAME = "Murphy Chat"
let APP_NAME = "Murphy Chat"


// IMPORTANT: Replace the red keys below with the ones you'll get from your own App on http://back4app.com
//let PARSE_APP_KEY = "b5vJ7toaFtnTzgreV3YhevbzY7Ys8HTG8cIpduNi"
//let PARSE_CLIENT_KEY = "WFA1hzyJPdG0v5NTXFS18nAQnpywh4vNrFCIFmEZ"
    //let PARSE_APP_KEY = "OUGiALUjPObCxb0baOM9epSWaP0bX1vUQTTSlBBE"
    //let PARSE_CLIENT_KEY = "IQsacYFOYB5Rzj85hUMYdts6W3q2owtwSJetfMNZ"

let PARSE_APP_KEY = "nLPzwHBPzNV4i8DBHrDLPEfmg6cXieSKIoVdJrRI"
let PARSE_CLIENT_KEY = "o8bXT3kUj4eSDnkxtUA1RH04Kxd3aZFO0EuzfbmS"

// IMPORTANT: replace the email address below with the one you'll dedicate to users to report abusive people
let REPORT_EMAIL_ADDRESS = "report@mydomain.com"


// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE UNIT ID YOU'VE GOT BY REGISTERING YOUR APP IN http://apps.admob.com
let ADMOB_BANNER_UNIT_ID = "ca-app-pub-9733347540588953/6145924825"


// REPLACE THE RED STRING BELOW WITH THE LINK TO YOUR OWN APP ON THE ITUNES APP SORE (You can get it from iTunes Connect)
let APPSTORE_LINK = "https://itunes.apple.com/"


// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE APP ID YOU CAN GRAB FROM YOUR OneSignal DASHBOARD -> App Settings
let ONESIGNAL_APP_ID = "0c58fc03-7427-4949-83bb-5bc690ec54f6"


// SET THE AMOUNT OF WALLPAPERS YOU'LL STORE INTO CHAT WALLPAPERS FOLDER (in Assets.xcassets)
let WALLPAPERS_AMOUNT = 10


// YOU CAN CHANGE THE VALUE OF THE MAX. DURATION OF A RECORDING (PLEASE NOTE THAT HIGHER VALUES MAY AFFET THE LOADING TIME OF POSTS)
let RECORD_MAX_DURATION:TimeInterval = 20


// MAIN PURPLE COLOR, you can edit the RGB values below to change color
let deepPurple = UIColor(red: 74.0/255.0, green: 65.0/255.0, blue: 135.0/255.0, alpha: 1.0)


// Array of colors
let colorsArray = [
    UIColor(red: 237.0/255.0, green: 85.0/255.0, blue: 100.0/255.0, alpha: 1.0),
    UIColor(red: 250.0/255.0, green: 110.0/255.0, blue: 82.0/255.0, alpha: 1.0),
    UIColor(red: 255.0/255.0, green: 207.0/255.0, blue: 85.0/255.0, alpha: 1.0),
    UIColor(red: 160.0/255.0, green: 212.0/255.0, blue: 104.0/255.0, alpha: 1.0),
    UIColor(red: 72.0/255.0, green: 207.0/255.0, blue: 174.0/255.0, alpha: 1.0),
    UIColor(red: 172.0/255.0, green: 146.0/255.0, blue: 237.0/255.0, alpha: 1.0),
    UIColor(red: 236.0/255.0, green: 136.0/255.0, blue: 192.0/255.0, alpha: 1.0),
    UIColor(red: 218.0/255.0, green: 69.0/255.0, blue: 83.0/255.0, alpha: 1.0),
    UIColor(red: 204.0/255.0, green: 208.0/255.0, blue: 217.0/255.0, alpha: 1.0),
    UIColor(red: 198.0/255.0, green: 156.0/255.0, blue: 109.0/255.0, alpha: 1.0),
]







// HUD View extension
let hudView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
let label = UILabel()
let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
extension UIViewController {
    func showHUD(_ message:String) {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = deepPurple
        hudView.alpha = 0.9
        hudView.layer.cornerRadius = 8
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
        
        label.frame = CGRect(x: 0, y: 90, width: 120, height: 20)
        label.font = UIFont(name: "Titillium-Semibold", size: 16)
        label.text = message
        label.textAlignment = .center
        label.textColor = UIColor.white
        hudView.addSubview(label)
    }
    
    func hideHUD() {
        hudView.removeFromSuperview()
        label.removeFromSuperview()
    }
    
    func simpleAlert(_ mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }
}


/****** DO NOT EDIT THE CODE BELOW! *****/
let USER_CLASS_NAME = "_User"
let USER_USERNAME = "username"
let USER_PASSWORD = "password"
let USER_EMAIL = "email"
let USER_FULLNAME = "fullName"
let USER_FULLNAME_LOWERCASE = "fullNameLowercase"
let USER_PHONE_NUMBER = "phone"
let USER_AVATAR = "avatar"
let USER_IS_ONLINE = "isOnline"
let USER_PUSH_ID = "pushID"
let USER_STATUS = "status"
let USER_HAS_BLOCKED = "hasBlocked"


let INBOX_CLASS_NAME = "Inbox"
let INBOX_SENDER = "sender"
let INBOX_SENDER_NAME = "senderName"
let INBOX_RECEIVER = "receiver"
let INBOX_RECEIVER_NAME = "receiverName"
let INBOX_INBOX_ID = "inboxID"
let INBOX_MESSAGE = "message"
let INBOX_IMAGE = "image"
let INBOX_VIDEO = "video"
let INBOX_AUDIO = "audio"
let INBOX_READ = "read"


let CHATS_CLASS_NAME = "Chats"
let CHATS_LAST_MESSAGE = "lastMessage"
let CHATS_USER_POINTER = "userPointer"
let CHATS_OTHER_USER = "otherUser"
let CHATS_ID = "chatID"

let FAVORITES_CLASS_NAME = "Favorites"
let FAVORITES_MESSAGE_POINTER = "messagePointer"
let FAVORITES_USER_POINTER = "userPointer"

let BLOCKED_CLASS_NAME = "Blocked"
let BLOCKED_A_USER = "aUser"
let BLOCKED_HAS_BLOCKED = "hasBlocked"


let STATIS_CLASS_NAME = "Statistic"
let STATIS_USER = "user"
let STATIS_SEND_MESSAGE_COUNT = "messageSend"
let STATIS_RECEIVE_MESSAGE_COUNT = "messageReceive"
let STATIS_SEND_IMG_COUNT = "imgSend"
let STATIS_RECEIVE_IMG_COUNT = "imgReceive"
let STATIS_SEND_VIDEO_COUNT = "videoSend"
let STATIS_RECEIVE_VIDEO_COUNT = "videoReceive"
let STATIS_SEND_AUDIO_COUNT = "audioSend"
let STATIS_RECEIVE_AUDIO_COUNT = "audioReceive"



let DEFAULTS = UserDefaults.standard
var wallpaperName = DEFAULTS.string(forKey: "wallpaperName")




// MARK: - METHOD TO CREATE A THUMBNAIL OF YOUR VIDEO
func createVideoThumbnail(_ url:URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    var time = asset.duration
    time.value = min(time.value, 2)
    do { let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: imageRef)
    } catch let error as NSError {
        print("Image generation failed with error \(error)")
        return nil
    }
}

