/* ------------------------------------------
 
 
 Copyright © 2016 Sevenstar Infotech.
 All rights reserved.
 
 ------------------------------------------*/


import UIKit
import Parse
import AudioToolbox
import MediaPlayer
import AVFoundation



class Favorites: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
AVAudioPlayerDelegate
{

    /* Views */
    @IBOutlet weak var favTableView: UITableView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImage: UIImageView!

    var moviePlayer:MPMoviePlayerController?
    var audioPlayer : AVAudioPlayer?
    
    var circularProgress: KYCircularProgress!
    var progress = 0
    var messTimer = Timer()
    var messageIsPlaying = false
    
    
    
    /* Variables */
    var favArray = [PFObject]()
    var cellHeight = CGFloat()
    
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Initial setup
    self.title = "FAVORITES"
    self.edgesForExtendedLayout = UIRectEdge()
    previewView.frame.origin.y = view.frame.size.height
    favTableView.backgroundColor = UIColor.clear
    
    
    // Initialize a BACK BarButton Item
    let butt = UIButton(type: UIButtonType.custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
    butt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)

    
    // Add observer to dismiss MediaPlayer on Done button
    NotificationCenter.default.addObserver(self, selector: #selector(dismissMoviePlayer(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
    
    
    // Call query
    queryFavorites()
    
    // swipe right gesture
    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(Favorites.backToScreen(_:)))
    swipeRight.direction = .right
    self.view.addGestureRecognizer(swipeRight)
    
}

    
    
  
// MARK: - QUERY FAVORITES
func queryFavorites() {
    showHUD("")
    
    let query = PFQuery(className: FAVORITES_CLASS_NAME)
    query.whereKey(FAVORITES_USER_POINTER, equalTo: PFUser.current()!)
    query.order(byDescending: "CreatedAt")
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.favArray = objects!
            self.favTableView.reloadData()
            self.hideHUD()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
  
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return favArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! InboxCell
    
    var favClass = PFObject(className: FAVORITES_CLASS_NAME)
    favClass = favArray[(indexPath as NSIndexPath).row]
    
    
    // Get Message Pointer
    var messPointer = favClass[FAVORITES_MESSAGE_POINTER] as! PFObject
    do { messPointer = try  messPointer.fetchIfNeeded() } catch { }
    
    // Get userPointer
    var userPointer = messPointer[INBOX_SENDER] as! PFUser
    do { userPointer = try userPointer.fetchIfNeeded() } catch { }
    
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
    cell.messageTxtView.text = "\(messPointer[INBOX_MESSAGE]!)"
    cell.messageTxtView.sizeToFit()
    cell.messageTxtView.frame.origin.x = 77
    cell.messageTxtView.frame.size.width = cell.frame.size.width - 87
    cell.messageTxtView.layer.cornerRadius = 5
                
    // Reset cellHeight
    self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + 15
                
    // Get Date
    let date = messPointer.createdAt
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "MMM dd yyyy | hh:mm"
    cell.dateLabel.text = dateFormat.string(from: date!)
                
                
                
    // THIS MESSAGE HAS AUDIO ---------------------
    if messPointer[INBOX_AUDIO] != nil {
        cell.messageTxtView.frame.size.height = 0
        cell.playOutlet.tag = (indexPath as NSIndexPath).row
        cell.playOutlet.isHidden = false
    } else {
        cell.playOutlet.isHidden = true
    }
    cell.playOutlet.layer.cornerRadius = 8
                
                
                
                
    // THIS MESSAGE HAS MEDIA -------------------
    if messPointer[INBOX_IMAGE] != nil {
        cell.playOutlet.isHidden = true
        cell.imageVideoButt.imageView!.contentMode = .scaleAspectFill
                    
        // Check if there's a video
        if messPointer[INBOX_VIDEO] != nil { cell.hasVideo = true
        } else { cell.hasVideo = false }
                    
        cell.messageTxtView.frame.size.height = 0
        
        cell.imageVideoButt.tag = (indexPath as NSIndexPath).row
        cell.imageVideoButt.frame.size.width = 180
        cell.imageVideoButt.frame.size.height = 180
        cell.imageVideoButt.layer.cornerRadius = 8
        cell.imageVideoButt.isHidden = false
                    
        // Get video's URL
        if cell.hasVideo == true {
            let video = messPointer[INBOX_VIDEO] as! PFFile
            let videoURL = URL(string: video.url!)!
            cell.theVideoURL = videoURL
            print("\nVIDEO IN CELL 1: \(cell.theVideoURL)\n")
            cell.imageVideoButt.layer.borderColor = deepPurple.cgColor
            cell.imageVideoButt.layer.borderWidth = 2
        }
                    
                    
        // Get the image
        let imageFile = messPointer[INBOX_IMAGE] as? PFFile
        imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.imageVideoButt.setImage(UIImage(data: imageData), for: UIControlState())
                    if cell.hasVideo == false { cell.theImage = UIImage(data: imageData)! }
        }}})
                    
        // Reset cellHeight
        self.cellHeight = cell.messageTxtView.frame.origin.y + cell.messageTxtView.frame.size.height + cell.imageVideoButt.frame.size.height + 80
    }

    
return cell
}
 
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight
}
    
    

    
    
// MARK: - DELETE FAVORITE BY SWIPING THE CELL LEFT
func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
}
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            var favClass = PFObject(className: FAVORITES_CLASS_NAME)
            favClass = favArray[0]
            
            favClass.deleteInBackground {(success, error) -> Void in
                if error == nil {
                    self.favArray.remove(at: (indexPath as NSIndexPath).row)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
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
            
        // Get Audio message
        var favClass = PFObject(className: FAVORITES_CLASS_NAME)
        favClass = favArray[button.tag]
        let messPointer = favClass[FAVORITES_MESSAGE_POINTER] as! PFObject
        messPointer.fetchIfNeededInBackground(block: { (mess, error) in
            if error == nil {
                let audioFile = messPointer[INBOX_AUDIO] as? PFFile
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
                
            // error
            } else { self.simpleAlert("\(error!.localizedDescription)")
        }})
        
       
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
    

    
    
    
    
    
    
   
// MARK: - CHAT IMAGE/VIDEO BUTTON
@IBAction func imageVideoButt(_ sender: UIButton) {
    let butt = sender
    let indexP = IndexPath(row: butt.tag, section: 0)
    let cell = favTableView.cellForRow(at: indexP) as! InboxCell
        
    // Show the image preview
    if cell.hasVideo == false {
        previewImage.image = cell.theImage
        showImagePreview()
            
            
    // Play a Video
    } else {
        var url = cell.theVideoURL
            
        // Save video locally (so the app can play it)
        let videoData = try? Data(contentsOf: url as URL)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let destinationPath = URL(fileURLWithPath: documentsPath).appendingPathComponent("video.mov", isDirectory: false)
        FileManager.default.createFile(atPath: destinationPath.path, contents:videoData, attributes:nil)
        url = destinationPath
        print("VIDEO URL: \(url)")
            
        // Init moviePlayer
        moviePlayer = MPMoviePlayerController(contentURL: url as URL!)
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
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
        self.previewView.frame.origin.y = 0
    }, completion: { (finished: Bool) in })
}
func hideImagePreview() {
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
        self.previewView.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in })
}

    
    
// MARK: - SWIPE TO CLOSE IMAGE PREVIEW
@IBAction func swipeToClose(_ sender: UISwipeGestureRecognizer) {
    hideImagePreview()
}
    
    
    
  
 
// MARK: - BACK BUTTON
func backButton() {
    navigationController?.popViewController(animated: true)
}
    
func backToScreen(_ sender: UISwipeGestureRecognizer){
    self.backButton()
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
