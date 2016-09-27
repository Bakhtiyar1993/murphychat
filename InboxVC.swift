/* ------------------------------------------
 
 
 Copyright © 2016 Sevenstar Infotech.
 All rights reserved.
 
 ------------------------------------------*/


import UIKit
import Parse
import MessageUI
import AudioToolbox
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import AVFoundation



// MARK: - CUSTOM INBOX CELLS
class InboxCell: UITableViewCell
{
    /* Views */
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var imageVideoButt: UIButton!
    @IBOutlet weak var playOutlet: UIButton!
    @IBOutlet var deliveryLabel: UILabel!
    
    var theImage = UIImage()
    var theVideoURL = URL()
    var hasVideo = Bool()
    var hasAudio = Bool()
}


class InboxCell2: UITableViewCell
{
    /* Views */
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTxtView: UITextView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var imageVideoButt: UIButton!
    @IBOutlet weak var playOutlet: UIButton!

    var theImage = UIImage()
    var theVideoURL = URL()
    var hasVideo = Bool()
    var hasAudio = Bool()
}


// MARK: - INBOX CONTROLLER
class InboxVC: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UITextViewDelegate,
MFMailComposeViewControllerDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
AVAudioRecorderDelegate,
AVAudioPlayerDelegate
{

    /* Views */
    @IBOutlet weak var inboxTableView: UITableView!
    @IBOutlet weak var fakeView: UIView!
    @IBOutlet weak var fakeTxt: UITextField!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var wallpaperImage: UIImageView!
    
    @IBOutlet var lastloginInfoLabel: UILabel!
    
    let messageTxt = UITextView()
    var moviePlayer:MPMoviePlayerController?

    var recorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?

    @IBOutlet weak var recordingLabel: UILabel!
    
    var circularProgress: KYCircularProgress!
    var progress = 0
    var messTimer = Timer()

    var sendButt = UIButton()
    
    
    /* Variables */
    var userObj = PFUser()
    var inboxArray = [PFObject]()
    var chatsArray = [PFObject]()
    var cellHeight = CGFloat()
    var refreshTimer = Timer()
    var destroyTimer = Timer()
    var lastMessageStr = ""
    var imageToSend:UIImage?
    var videoToSendURL:URL?
    var audioData:Data?
    var messageIsPlaying = false
    
override func viewDidAppear(_ animated: Bool) {
    queryInbox()
}
override func viewDidLoad() {
        super.viewDidLoad()
    
    messageIsPlaying = false
    
    // Initial setup
    self.edgesForExtendedLayout = UIRectEdge()
    lastMessageStr = ""
    
    self.title = "\(userObj[USER_FULLNAME]!)"
    
    // Get Date
    let date = userObj.updatedAt
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "MMM dd yyyy | hh:mm"
    self.lastloginInfoLabel.text = "Last login  \(dateFormat.string(from: date!))"
    
    previewView.frame.origin.y = view.frame.size.height
    recordingLabel.frame.origin.y = view.frame.size.height
    if wallpaperName != nil { wallpaperImage.image = UIImage(named: wallpaperName!) }
    
    // Call query
    queryInbox()
    
    // Initialize a BACK BarButton Item
    let butt = UIButton(type: .custom)
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
    butt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
    
    // Initialize a USER BarButton Item
    let userButt = UIButton(type: .custom)
    userButt.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    
    userButt.setBackgroundImage(UIImage(named: "logo"), for: UIControlState())
    let imageFile = userObj[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                userButt.setBackgroundImage(UIImage(data:imageData), for: UIControlState())
    }}})
    
    userButt.clipsToBounds = true
    userButt.layer.cornerRadius = userButt.bounds.size.width/2
//    userButt.addTarget(self, action: #selector(userButton), forControlEvents: .TouchUpInside)
    userButt.addTarget(self, action: #selector( showContactInfo ), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: userButt)

    // INIT A KEYBOARD TOOLBAR ----------------------------------------------------------------------------
    let toolbar = UIView(frame: CGRect(x: 0, y: view.frame.size.height+44, width: view.frame.size.width, height: 60))
    toolbar.backgroundColor = deepPurple
    
    // Message Txt
    messageTxt.frame = CGRect(x: 8, y: 2, width: toolbar.frame.size.width - 100, height: 58)
    messageTxt.delegate = self
    messageTxt.font = UIFont(name: "Titillium-Light", size: 16)
    messageTxt.textColor = UIColor.white
    messageTxt.keyboardAppearance = .dark
    messageTxt.autocorrectionType = .default
    messageTxt.autocapitalizationType = .none
    messageTxt.spellCheckingType = .default
    messageTxt.backgroundColor = UIColor.clear
    toolbar.addSubview(messageTxt)
    
    // Send button
    sendButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 60, y: 0, width: 44, height: 44))
    sendButt.titleLabel?.textColor = UIColor.white
    sendButt.setBackgroundImage(UIImage(named: "sendButt"), for: UIControlState())
    sendButt.addTarget(self, action: #selector(sendButton), for: UIControlEvents.touchUpInside)
    sendButt.showsTouchWhenHighlighted = true
    sendButt.isEnabled = false
    toolbar.addSubview(sendButt)
    
    // Hide keyboard button
    let hideKBButt = UIButton(frame: CGRect(x: sendButt.frame.origin.x - 48, y: 0, width: 44, height: 44))
    hideKBButt.titleLabel?.textColor = UIColor.white
    hideKBButt.setBackgroundImage(UIImage(named: "hideKBButt"), for: UIControlState())
    hideKBButt.addTarget(self, action: #selector(dismissKeyboard), for: UIControlEvents.touchUpInside)
    hideKBButt.showsTouchWhenHighlighted = true
    toolbar.addSubview(hideKBButt)
    
    fakeTxt.inputAccessoryView = toolbar
    fakeTxt.delegate = self
    
    //------------------------------------------------------------------------------------------------------------
    
    // Timer to automatically check messages in the Inbox
    refreshTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(queryInbox), userInfo: nil, repeats: true)
    
    // Add observer to dismiss MediaPlayer on Done button
    NotificationCenter.default.addObserver(self, selector: #selector(dismissMoviePlayer(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)

    // Call method
    prepareRecorder()
    
    // swipe right gesture
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(InboxVC.backToScreen(_:)))
    let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(InboxVC.hideImagePreview(_:)))
    swipeRight.direction = .right
    swipeDown.direction = .down
    self.view.addGestureRecognizer(swipeRight)
    self.view.addGestureRecognizer(swipeDown)
}
    
    
    
// MARK: - QUERY MESSAGES FROM YOUR INBOX
func queryInbox() {    
    let inboxId1 = "\(PFUser.current()!.objectId!)\(userObj.objectId!)"
    let inboxId2 = "\(userObj.objectId!)\(PFUser.current()!.objectId!)"
    
    let predicate = NSPredicate(format:"inboxID = '\(inboxId1)' OR inboxID = '\(inboxId2)'")
    let query = PFQuery(className: INBOX_CLASS_NAME, predicate: predicate)
    query.order(byAscending: "createdAt")
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.inboxArray = objects!
            self.inboxTableView.reloadData()
            if self.inboxArray.count != 0 {
                Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.scrollTableViewToBottom), userInfo: nil, repeats: false)
            }
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
    if( self.inboxArray.count > 0 ) {
        for idx in 0...self.inboxArray.count-1{
            var inboxC = PFObject(className: INBOX_CLASS_NAME)
            inboxC = self.inboxArray[idx]
            if inboxId2 == inboxC[INBOX_INBOX_ID] as! String && inboxC[INBOX_READ] as! Bool == false {
                inboxC[INBOX_READ] = true
                // Saving block
                inboxC.saveInBackground { (success, error) -> Void in
                    if error == nil {
                        print("update read field success!")
                    } else {
                        print("update read field fail!")
                    }}
            }
        }
    }
}
    
    
    
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return inboxArray.count
}
    
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    var inboxC = PFObject(className: INBOX_CLASS_NAME)
    inboxC = inboxArray[(indexPath as NSIndexPath).row]
    
    // Fetch Inbox if needed
    var inboxClass = PFObject(className: INBOX_CLASS_NAME)
    var userPointer = PFUser()
    inboxC.fetchIfNeededInBackground { (object, error) in
        if error == nil {
            inboxClass = object!
            userPointer = inboxC[INBOX_SENDER] as! PFUser
            do { userPointer = try userPointer.fetchIfNeeded() } catch {}
    }}
    
    
    
    
            
    // CELL WITH MESSAGE FROM CURRENT USER ------------------------------------------------------
    if userPointer.objectId == PFUser.current()!.objectId {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! InboxCell
        
        // Default layout
        cell.backgroundColor = UIColor.clear
        cell.imageVideoButt.isHidden = true

        
        // Get Fullname
        cell.nicknameLabel.text = "\(userPointer[USER_FULLNAME]!)"
        
        // Get avatar
        let imageFile = userPointer[USER_AVATAR] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.avatarImage.image = UIImage(data:imageData)
        }}})
        cell.avatarImage.layer.cornerRadius = cell.avatarImage.bounds.size.width/2
        
        
        // Get message
        cell.messageTxtView.text = "\(inboxClass[INBOX_MESSAGE]!)"
        cell.messageTxtView.sizeToFit()
        cell.messageTxtView.frame.origin.x = 77
        cell.messageTxtView.frame.size.width = cell.frame.size.width - 87
        cell.messageTxtView.layer.cornerRadius = 5
        
        // Reset cellHeight
        self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + 15
        
        // Get Date
        let date = inboxClass.createdAt
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM dd yyyy | hh:mm"
        
        cell.deliveryLabel.textColor = UIColor.black
        if inboxClass[INBOX_READ]! as! Bool == false {
            cell.deliveryLabel.text = "✓"
        }
        else {
            cell.deliveryLabel.text = "✓✓"
            cell.deliveryLabel.textColor = UIColor.blue
        }
        
        cell.dateLabel.text = "\(dateFormat.string(from: date!)) "
        // THIS MESSAGE HAS AUDIO ---------------------
        if inboxClass[INBOX_AUDIO] != nil {
            cell.messageTxtView.frame.size.height = 0
            cell.playOutlet.tag = (indexPath as NSIndexPath).row
            cell.playOutlet.isHidden = false
        } else {
            cell.playOutlet.isHidden = true
        }
        cell.playOutlet.layer.cornerRadius = 8

        
        // THIS MESSAGE HAS MEDIA -------------------
        if inboxClass[INBOX_IMAGE] != nil {
            cell.playOutlet.isHidden = true
             cell.imageVideoButt.imageView!.contentMode = .scaleAspectFill
            
            // Check if there's a video
            if inboxClass[INBOX_VIDEO] != nil { cell.hasVideo = true
            } else { cell.hasVideo = false }
            
            cell.messageTxtView.frame.size.height = 0
            
            cell.imageVideoButt.tag = (indexPath as NSIndexPath).row
            cell.imageVideoButt.frame.size.width = 180
            cell.imageVideoButt.frame.size.height = 180
            cell.imageVideoButt.layer.cornerRadius = 8
            cell.imageVideoButt.isHidden = false
            
            // Get video's URL
            if cell.hasVideo == true {
                let video = inboxClass[INBOX_VIDEO] as! PFFile
                let videoURL = URL(string: video.url!)!
                cell.theVideoURL = videoURL
                print("\nVIDEO IN CELL 1: \(cell.theVideoURL)\n")
                cell.imageVideoButt.layer.borderColor = deepPurple.cgColor
                cell.imageVideoButt.layer.borderWidth = 2
            }
            
            
            // Get the image
            let imageFile = inboxClass[INBOX_IMAGE] as? PFFile
            imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.imageVideoButt.setImage(UIImage(data: imageData), for: UIControlState())
                        if cell.hasVideo == false { cell.theImage = UIImage(data: imageData)! }
            }}})
            
            // Reset cellHeight
            self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + cell.imageVideoButt.frame.size.height + 40
            
        }
        return cell
    // CELL WITH MESSAGE FROM OTHER USER ------------------------------------------------------
    } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell2", for: indexPath) as! InboxCell2
        
        // Default layout
        cell.backgroundColor = UIColor.clear
        cell.imageVideoButt.isHidden = true
        
        
        // Get fullName
        cell.nicknameLabel.text = "\(userPointer[USER_FULLNAME]!)"
        
        // Get avatar
        let imageFile = userPointer[USER_AVATAR] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.avatarImage.image = UIImage(data:imageData)
        }}})
        cell.avatarImage.layer.cornerRadius = cell.avatarImage.bounds.size.width/2
        
        
        // Get message
        cell.messageTxtView.text = "\(inboxClass[INBOX_MESSAGE]!)"
        cell.messageTxtView.sizeToFit()
        cell.messageTxtView.frame.origin.x = 8
        cell.messageTxtView.frame.size.width = cell.frame.size.width - 87
        cell.messageTxtView.layer.cornerRadius = 5

        // Reset cellheight
        self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + 15
        
        
        // Get Date
        let date = inboxClass.createdAt
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM dd yyyy | hh:mm"
        cell.dateLabel.text = dateFormat.string(from: date!)
        
        
        
        // THIS MESSAGE HAS AUDIO ---------------------
        if inboxClass[INBOX_AUDIO] != nil {
            cell.messageTxtView.frame.size.height = 0
            cell.playOutlet.tag = (indexPath as NSIndexPath).row
            cell.playOutlet.isHidden = false
        } else {
            cell.playOutlet.isHidden = true
        }
        cell.playOutlet.layer.cornerRadius = 8
        
        
        
        
        // THIS MESSAGE HAS MEDIA -------------------
        if inboxClass[INBOX_IMAGE] != nil {
            cell.playOutlet.isHidden = true
            cell.imageVideoButt.imageView!.contentMode = .scaleAspectFill
            
            // Check is there's a video
            if inboxClass[INBOX_VIDEO] != nil { cell.hasVideo = true
            } else { cell.hasVideo = false }
            
            cell.messageTxtView.frame.size.height = 0
            
            cell.imageVideoButt.tag = (indexPath as NSIndexPath).row
            cell.imageVideoButt.frame.size.width = 180
            cell.imageVideoButt.frame.size.height = 180
            cell.imageVideoButt.layer.cornerRadius = 8
            cell.imageVideoButt.isHidden = false
            
            
            // Get video's URL
            if cell.hasVideo == true {
                let video = inboxClass[INBOX_VIDEO] as! PFFile
                let videoURL = URL(string: video.url!)!
                cell.theVideoURL = videoURL
                print("\nVIDEO IN CELL 2: \(cell.theVideoURL)\n")
                cell.imageVideoButt.layer.borderColor = deepPurple.cgColor
                cell.imageVideoButt.layer.borderWidth = 2
            }
            
            
            // Get the image
            let imageFile = inboxClass[INBOX_IMAGE] as? PFFile
            imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.imageVideoButt.setImage(UIImage(data: imageData), for: UIControlState())
                        if cell.hasVideo == false { cell.theImage = UIImage(data: imageData)! }
            }}})
            
            
            // Reset cellHeight
            self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + cell.imageVideoButt.frame.size.height + 40
        }
        return cell
    
        
    }
}
    

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight
}

   
    
    
// MARK: - EDIT ACTIONS ON SWIPE ON A CELL
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
}
    
func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    var favoriteAction:UITableViewRowAction!
    var reportAction:UITableViewRowAction!
    var removeAction:UITableViewRowAction!
    
    
    // Get the message of this row
    var message = PFObject(className: INBOX_CLASS_NAME)
    message = self.inboxArray[(indexPath as NSIndexPath).row]
    
    // Get UserPointer
    let userPointer = message[INBOX_SENDER] as! PFUser
    userPointer.fetchIfNeededInBackground { (user, error) in
        if error == nil {
            // FAVORITE MESSAGE -----------------------------------------------------------------
            favoriteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Favorite" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
                
                // Favorite this message
                let favClass = PFObject(className: FAVORITES_CLASS_NAME)
                let currentUser = PFUser.current()
                favClass[FAVORITES_USER_POINTER] = currentUser
                favClass[FAVORITES_MESSAGE_POINTER] = message
                
                // Saving block
                favClass.saveInBackground { (success, error) -> Void in
                    if error == nil { self.simpleAlert("You've added this message to your Favorites!")
                    } else { self.simpleAlert("\(error!.localizedDescription)")
                    }}
                
            })
            
            
            
            // REPORT MESSAGE -----------------------------------------------------------------
            reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Forward" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
//                let mailComposer = MFMailComposeViewController()
//                mailComposer.mailComposeDelegate = self
//                mailComposer.setToRecipients([REPORT_EMAIL_ADDRESS])
//                mailComposer.setSubject("Reporting abusive User on \(APP_NAME)")
//                mailComposer.setMessageBody("Hello,<br>I'm reporting this Message: <strong>\(message[INBOX_MESSAGE]!)</strong><br>with ID:<strong>\(message.objectId!)</strong><br>by User: <strong>\(userPointer[USER_FULLNAME]!)</strong><br><br>because it has offensive and inappropriate content.<br><br>Thanks,<br>Regards.", isHTML: true)
//                
//                if MFMailComposeViewController.canSendMail() {
//                    self.presentViewController(mailComposer, animated: true, completion: nil)
//                } else {
//                    self.simpleAlert("Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.")
//                }
                let shareItems = [message[INBOX_MESSAGE]]
                
                let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    // iPad
                    let popOver = UIPopoverController(contentViewController: activityViewController)
                    popOver.present(from: CGRect.zero, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
                } else {
                    // iPhone
                    self.present(activityViewController, animated: true, completion: nil)
                }
                
            })
            removeAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
                
                let selectedObject:PFObject = self.inboxArray[indexPath.row] as PFObject
                selectedObject.deleteInBackground()
                self.inboxArray.remove(at: indexPath.row)
                self.inboxTableView.reloadData()
            })
            
            // Set colors of the actions
            favoriteAction.backgroundColor = colorsArray[4]
            reportAction.backgroundColor = deepPurple
            removeAction.backgroundColor = UIColor.red

        // error
        } else { self.simpleAlert("\(error!.localizedDescription)")
    }}
    
    
return [removeAction, favoriteAction, reportAction]
}
    
// Email delegate
func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        var outputMessage = ""
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            outputMessage = "Mail cancelled"
        case MFMailComposeResult.saved.rawValue:
            outputMessage = "Mail saved"
        case MFMailComposeResult.sent.rawValue:
            outputMessage = "Mail sent"
        case MFMailComposeResult.failed.rawValue:
            outputMessage = "Something went wrong with sending Mail, try again later."
        default: break }
    
    simpleAlert(outputMessage)
    dismiss(animated: false, completion: nil)
}

    
// MARK: - SCROLL TABLEVIEW TO BOTTOM
func scrollTableViewToBottom() {
    inboxTableView.scrollToRow(at: IndexPath(row: self.inboxArray.count-1, section: 0), at: .bottom, animated: true)
}
    
// MARK: - PLAY AUDIO MESSAGE BUTTON
@IBAction func playButt(_ sender: AnyObject) {
    if !messageIsPlaying {
        let button = sender as! UIButton
        
        // Setup circular progress
        circularProgress = KYCircularProgress(frame: CGRect(x: 0, y: 0, width: button.frame.size.width, height: button.frame.size.height))
        circularProgress.colors = [0xffffff, 0xffffff, 0xffffff, 0xffffff]
        circularProgress.lineWidth = 2
        circularProgress.progressChangedClosure({ (progress: Double, circularView: KYCircularProgress) in })
        button.addSubview(circularProgress)
        button.sendSubview(toBack: circularProgress)
            
        var inboxClass = PFObject(className: INBOX_CLASS_NAME)
        inboxClass = inboxArray[button.tag]
            
        let audioFile = inboxClass[INBOX_AUDIO] as? PFFile
        audioFile?.getDataInBackground { (audioData, error) -> Void in
            if error == nil {
                self.audioPlayer = try? AVAudioPlayer(data: audioData!)
                self.audioPlayer?.delegate = self
                print("\nAUDIO MESSAGE DURATION: \(self.audioPlayer!.duration)\n")
                self.audioPlayer?.play()
                self.messageIsPlaying = true
                    
                // Start timer (shows the progress of the message while playing)
                self.progress = 0
                let calcTime = self.audioPlayer!.duration * 0.004
                self.messTimer = Timer.scheduledTimer(timeInterval: calcTime, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        }}
            
    } // end IF to prevent tapping on an audio message multiple times
        
}
   
    
// MARK: - UPDATE TIMER
func updateTimer() {
        progress = progress + 1
        let normalizedProgress = Double(progress) / 255.0
        circularProgress.progress = normalizedProgress
        
        // Timer ends
        if normalizedProgress >= 1.01 {  messTimer.invalidate()  }
    }
    
func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    audioPlayer = nil
    messTimer.invalidate()
    circularProgress.removeFromSuperview()
    messageIsPlaying = false
}
// MARK: - CHAT IMAGE/VIDEO BUTTON | INBOX CELL 1
@IBAction func imageVideoButt(_ sender: UIButton) {
    let butt = sender
    let indexP = IndexPath(row: butt.tag, section: 0)
    let cell = inboxTableView.cellForRow(at: indexP) as! InboxCell
    
    // Show the image preview
    if cell.hasVideo == false {
        previewImage.image = cell.theImage
        showImagePreview()
    
        
    // Play a Video
    } else {
        var url = cell.theVideoURL
        
        // Save video locally (so the app can play it)
        let videoData = try? Data(contentsOf: url)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let destinationPath = URL(fileURLWithPath: documentsPath).appendingPathComponent("video.mov", isDirectory: false)
        FileManager.default.createFile(atPath: destinationPath.path!, contents:videoData, attributes:nil)
        url = destinationPath
        print("VIDEO URL: \(url)")
        
        // Init moviePlayer
        moviePlayer = MPMoviePlayerController(contentURL: url)
        if let player = moviePlayer {
            player.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
            player.view.sizeToFit()
            player.scalingMode = .aspectFit
            player.isFullscreen = true
            player.controlStyle = .fullscreen
            player.movieSourceType = .file
            player.repeatMode = .none
            player.play()
            view.addSubview(player.view)
        }
    }
}
  

   
// MARK: - CHAT IMAGE/VIDEO BUTTON | INBOX CELL 2
@IBAction func imageVideoButt2(_ sender: UIButton) {
    let butt = sender
    let indexP = IndexPath(row: butt.tag, section: 0)
    let cell = inboxTableView.cellForRow(at: indexP) as! InboxCell2
        
    // Show the image preview
    if cell.hasVideo == false {
        previewImage.image = cell.theImage
        showImagePreview()
            
            
    // Play a Video
    } else {
        var url = cell.theVideoURL
            
        // Save video locally (so the app can play it)
        let videoData = try? Data(contentsOf: url)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let destinationPath = URL(fileURLWithPath: documentsPath).appendingPathComponent("video.mov", isDirectory: false)
        FileManager.default.createFile(atPath: destinationPath.path!, contents:videoData, attributes:nil)
        url = destinationPath
        print("VIDEO URL: \(url)")
            
        // Init moviePlayer
        moviePlayer = MPMoviePlayerController(contentURL: url)
        if let player = moviePlayer {
            player.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
            player.view.sizeToFit()
            player.scalingMode = .aspectFit
            player.isFullscreen = true
            player.controlStyle = .fullscreen
            player.movieSourceType = .file
            player.repeatMode = .none
            player.play()
            view.addSubview(player.view)
        }
    }
}
  
    
    
    
    
// MARK: - DISMISS MOVIE PLAYER NOTIFICATIONS
func dismissMoviePlayer(_ note: Notification) {
    let reason = (note as NSNotification).userInfo?[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]
    if (MPMovieFinishReason(rawValue: reason as! Int) == MPMovieFinishReason.userExited) {
        moviePlayer!.view.removeFromSuperview()
    }
}

    
    
    
    
// MARK: - SHOW/HIDE IMAGE PREVIEW
func showImagePreview() {
    messageTxt.resignFirstResponder()
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
        self.previewView.frame.origin.y = 0
    }, completion: { (finished: Bool) in })
}
func hideImagePreview(_ sender: UISwipeGestureRecognizer) {
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
        self.previewView.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in })
}
    
// MARK: - DISMISS KEYBOARD
func dismissKeyboard() {
    messageTxt.resignFirstResponder()
    messageTxt.text = ""
    fakeTxt.resignFirstResponder()
    fakeTxt.text = "type your message"
    sendButt.isEnabled = false
}
    
    
    
// MARK: - TEXT FIELD DELEGATES
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == fakeTxt {
        messageTxt.text = ""
        messageTxt.becomeFirstResponder()
        sendButt.isEnabled = true
    }
    
return true
}
func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField == fakeTxt {
        messageTxt.text = ""
        messageTxt.becomeFirstResponder()
    }
    
return true
}
    

    
    
    

    
// MARK: - SEND IMAGE OR VIDEO BUTTON
@IBAction func sendImageButt(_ sender: AnyObject) {
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
    
    
    let videoCamera = UIAlertAction(title: "Take a Video", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
        	imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [String(kUTTypeMovie)]
            imagePicker.delegate = self
            imagePicker.videoMaximumDuration = RECORD_MAX_DURATION
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    let videoLibrary = UIAlertAction(title: "Choose a Video", style: UIAlertActionStyle.default, handler: { (action) -> Void in
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [String(kUTTypeMovie)]
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
    
    alert.addAction(camera)
    alert.addAction(library)
    alert.addAction(videoCamera)
    alert.addAction(videoLibrary)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    

    
// MARK: - IMAGE PICKER DELEGATE (VIDEOS AND IMAGES)
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

    let mediaType = info[UIImagePickerControllerMediaType] as! String
    
    
    // mediaType is IMAGE
    if mediaType == kUTTypeImage as String {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageToSend = image
        
        /*
        UIImageWriteToSavedPhotosAlbum(imageToSend!, nil, nil, nil)
        simpleAlert("Your image has been saved into Photo library!")
        */
        
    // mediaType is VIDEO
    } else if mediaType == kUTTypeMovie as String {
        let videoPath = info[UIImagePickerControllerMediaURL] as! URL
        videoToSendURL = videoPath

        /*
        // Save video in the photo library
        ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(videoToSendURL, completionBlock: { (url, error) in
            if error == nil {
                self.simpleAlert("Your video has been saved in ther Photo Library!")
            }
        })
         */

    }
    
    dismiss(animated: true, completion: nil)
    sendButton()
}
    
    
    
    
    


    
// MARK: - START/STOP RECORDING AN AUDIO MESSAGE
@IBAction func recordAudioMessButt(_ sender: AnyObject) {
    let butt = sender as! UIButton
    
    // Recording...
    if !recorder!.isRecording {
        recorder!.record(forDuration: RECORD_MAX_DURATION)
        recordingLabel.frame.origin.y = view.frame.size.height - 120
        butt.setBackgroundImage(UIImage(named: "recordingIcon"), for: UIControlState())
        
    // Stop recording and Send audio message
    } else {
        recorder!.stop()
        butt.setBackgroundImage(UIImage(named: "micButt"), for: UIControlState())
        
        // Check NSData out of the recorded audio
        audioData = try! Data(contentsOf: recorder!.url)
        print("AUDIO DATA: \(audioData!.count)\nRECORDER URL: \(recorder!.url)")
        
        // Get recorded file's length in seconds
        let audioAsset = AVURLAsset(url: recorder!.url, options: nil)
        let audioDuration: CMTime = audioAsset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        print("AUDIO DURATION: \(audioDurationSeconds)")
        
        recordingLabel.frame.origin.y = view.frame.size.height
        
        // Send audio message
        sendButton()
    }
}



    
// MARK: - PREPARE THE AUDIO RECORDER
func prepareRecorder() {
    let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let recordingName = "sound.caf"
    let pathArray = [dirPath, recordingName]
    let filePath = URL.fileURL(withPathComponents: pathArray)
    let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                              AVEncoderBitRateKey: 16,
                              AVNumberOfChannelsKey: 2,
                              AVSampleRateKey: 44100.0] as [String : Any]
    print(filePath)
        
    let session = AVAudioSession.sharedInstance()
    do { try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        recorder = try AVAudioRecorder(url: filePath!, settings: recordSettings as! [String : AnyObject])
    } catch _ {  print("Error") }
        
    recorder!.delegate = self
    recorder!.isMeteringEnabled = true
    recorder!.prepareToRecord()
}
    
    
    
    
    
    
    
    
// MARK: - SEND MESSAGE BUTTON ----------------------------------------------------------------------
func sendButton() {
    let inboxClass = PFObject(className: INBOX_CLASS_NAME)
    let currentUser = PFUser.current()!
    
    let blockedUsers = currentUser[USER_HAS_BLOCKED] as! NSMutableArray
    
    // UNBLOCK USER
    if blockedUsers.contains(GB.others.objectId!) {
        self.simpleAlert("You've blocked this user. He/she will no longer be able to send you messages.")
    }
    else {
        // Save Message to Inbox Class
        inboxClass[INBOX_SENDER] = currentUser
        inboxClass[INBOX_RECEIVER] = userObj
        inboxClass[INBOX_SENDER_NAME] = currentUser.objectId
        inboxClass[INBOX_RECEIVER_NAME] = userObj.objectId
        
        inboxClass[INBOX_INBOX_ID] = "\(currentUser.objectId!)\(userObj.objectId!)"
        
        inboxClass[INBOX_MESSAGE] = messageTxt.text
        lastMessageStr = messageTxt.text
        inboxClass[INBOX_READ] = false
        
        
        // SEND AUDIO (if it exists)
        if audioData != nil {
            showHUD("Sending...")
            let audioFile = PFFile(name: "sound.mp3", data: audioData!)
            inboxClass[INBOX_AUDIO] = audioFile
            
            inboxClass[INBOX_MESSAGE] = "[Audio]"
            lastMessageStr = "[Audio]"
        }
        
        // SEND AN IMAGE (if it exists)
        if imageToSend != nil {
            showHUD("Sending...")
            
            let imageData = UIImageJPEGRepresentation(imageToSend!, 0.5)
            let imageFile = PFFile(name:"image.jpg", data:imageData!)
            inboxClass[INBOX_IMAGE] = imageFile
            
            inboxClass[INBOX_MESSAGE] = "[Picture]"
            lastMessageStr = "[Picture]"
        }
        
        
        
        // SEND A VIDEO (if it exists)
        if videoToSendURL != nil {
            showHUD("Sending...")
            
            // Make thumbnail
            var videoThumbnail = UIImage()
            videoThumbnail = createVideoThumbnail(videoToSendURL!)!
            let imageData = UIImageJPEGRepresentation(videoThumbnail, 0.2)
            let imageFile = PFFile(name:"videoThumb.jpg", data:imageData!)
            inboxClass[INBOX_IMAGE] = imageFile
            
            let videoData = try! Data(contentsOf: videoToSendURL!)
            let videoFile = PFFile(name:"video.mov", data:videoData)
            inboxClass[INBOX_VIDEO] = videoFile
            
            inboxClass[INBOX_MESSAGE] = "[Video]"
            lastMessageStr = "[Video]"
        }
        
        
        
        // Saving block
        inboxClass.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.messageTxt.resignFirstResponder()
                self.fakeTxt.resignFirstResponder()
                
                // Call save LastMessage
                self.saveLastMessageInChats()
                
                // Add message to the array (it's temporary, before a new query gets automatically called)
                self.inboxArray.append(inboxClass)
                self.inboxTableView.reloadData()
                self.scrollTableViewToBottom()
                
                // Reset variables
                self.imageToSend = nil
                self.videoToSendURL = nil
                self.audioData = nil
                self.hideHUD()
                
                
                // Send Push notification
                if self.userObj[USER_PUSH_ID] != nil {
                    let oneSignal = OneSignal.defaultClient()
                    oneSignal?.postNotification(["contents": ["en": "\(PFUser.current()!.username!):\n\(self.lastMessageStr)"], "include_player_ids": ["\(self.userObj[USER_PUSH_ID]!)"]])
                    print("\nPUSH SENT TO: \(self.userObj.username!)\n")
                }
                
                
                // error on saving
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}

    }
    
    
}
  
    
    
// MARK: - SAVE LAST MESSAGE IN CHATS CLASS
func saveLastMessageInChats() {
    let currentUser = PFUser.current()!

    let inboxId1 = "\(PFUser.current()!.objectId!)\(userObj.objectId!)"
    let inboxId2 = "\(userObj.objectId!)\(PFUser.current()!.objectId!)"
    
    let predicate = NSPredicate(format:"\(CHATS_ID) = '\(inboxId1)'  OR  \(CHATS_ID) = '\(inboxId2)' ")
    let query = PFQuery(className: CHATS_CLASS_NAME, predicate: predicate)
    
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.chatsArray = objects!

            var chatsClass = PFObject(className: CHATS_CLASS_NAME)

            if self.chatsArray.count != 0 {
                chatsClass = self.chatsArray[0]
            }
            
            // print("CHATS ARRAY: \(self.chatsArray)\n")
            
            // Update Last message
            chatsClass[CHATS_LAST_MESSAGE] = self.lastMessageStr
            chatsClass[CHATS_USER_POINTER] = currentUser
            chatsClass[CHATS_OTHER_USER] = self.userObj
            chatsClass[CHATS_ID] = "\(currentUser.objectId!)\(self.userObj.objectId!)"
            
            // Saving block
            chatsClass.saveInBackground { (success, error) -> Void in
                if error == nil { print("LAST MESS SAVED: \(self.lastMessageStr)\n")
                } else { self.simpleAlert("\(error!.localizedDescription)")
            }}
         
            
            
        // error in query
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }}
}
// MARK: - USER BUTTON
func userButton() {
    
    // Get image
    let imageFile = userObj[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
        if error == nil {
            if let imageData = imageData {
                self.previewImage.image = UIImage(data:imageData)
                self.showImagePreview()
    }}})
    
}
    func showContactInfo(){
        let contactInfoVC = storyboard?.instantiateViewController(withIdentifier: "ContactInfo") as! ContactInfo
        navigationController?.pushViewController(contactInfoVC, animated: true)
    }
    
func backToScreen(_ sender: UISwipeGestureRecognizer){
    self.backButton()
}
    
// MARK: - BACK BUTTON
func backButton() {
    refreshTimer.invalidate()
    navigationController?.popViewController(animated: true)
}
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


