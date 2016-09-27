//
//  AllMedia.swift
//  Chatty
//
//  Created by ciast on 8/17/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit
import Parse
import MediaPlayer


// MARK: - CUSTOM WP CELL
class AMCell:UICollectionViewCell {
    /* Views */
    @IBOutlet var thumbImage: UIImageView!
    @IBOutlet var kindImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var viewButt: UIButton!
    
    var isVideo = Bool()
    var theVideoURL = URL()
}

class AllMedia: UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    AVAudioPlayerDelegate
{

    @IBOutlet var AMView: UICollectionView!
    
    var inboxArray = [PFObject]()
    var dataArray = [PFObject]()
    
    var moviePlayer:MPMoviePlayerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AMView.dataSource = self
        AMView.delegate = self
        
        self.title = "All Media"
        
        // Initialize a BACK BarButton Item
        let butt = UIButton(type: .custom)
        butt.adjustsImageWhenHighlighted = false
        butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        butt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        butt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
        
        // swipe right gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(Wallpapers.backToScreen(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // make query
        queryInbox()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func backToScreen(_ sender: UISwipeGestureRecognizer){
        self.backButton()
    }
    
    // MARK: - COLLECTION VIEW DELEGATES
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AMCell", for: indexPath) as! AMCell
        
        var inboxClass = PFObject(className: INBOX_CLASS_NAME)
        inboxClass = dataArray[(indexPath as NSIndexPath).row]
        
        // Get Date
        let date = inboxClass.createdAt
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM dd yyyy | hh:mm"
        cell.dateLabel.text = "\(dateFormat.string(from: date!)) "
        
        // Get Image
        if inboxClass[INBOX_IMAGE] != nil {
            // Get the image
            let imageFile = inboxClass[INBOX_IMAGE] as? PFFile
            imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.thumbImage.image = UIImage(data: imageData)
                        cell.thumbImage.layer.cornerRadius = 8
                    }
                }
            })
        }
        cell.isVideo = false
        cell.viewButt.tag = (indexPath as NSIndexPath).row
        cell.viewButt.frame.size.width = 150
        cell.viewButt.frame.size.height = 150
        cell.kindImage.image = UIImage(named: "previewImg")
        if inboxClass[INBOX_VIDEO] != nil {
            cell.isVideo = true
            let video = inboxClass[INBOX_VIDEO] as! PFFile
            let videoURL = URL(string: video.url!)!
            cell.theVideoURL = videoURL
            cell.kindImage.image = UIImage(named: "video")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2 - 20, height: 150)
    }

    func queryInbox() {
        self.showHUD("")
        let inboxId1 = "\(PFUser.current()!.objectId!)\(GB.others.objectId!)"
        let inboxId2 = "\(GB.others.objectId!)\(PFUser.current()!.objectId!)"
        let video = "[Video]"
        let picture = "[Picture]"
        
        let predicate = NSPredicate(format:"inboxID = '\(inboxId1)' OR inboxID = '\(inboxId2)' AND message = '\(video)' OR message = '\(picture)'")
        
        let query = PFQuery(className: INBOX_CLASS_NAME, predicate: predicate)
        query.order(byAscending: "createdAt")
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.inboxArray = objects!
                self.dataArray.removeAll()
                for idx in 0...self.inboxArray.count-1 {
                    var inboxC = PFObject(className: INBOX_CLASS_NAME)
                    inboxC = self.inboxArray[idx]
                    if inboxC[INBOX_MESSAGE] as! String == "[Picture]" || inboxC[INBOX_MESSAGE] as! String == "[Video]" {
                        self.dataArray.append(inboxC)
                    }
                }
                self.AMView.reloadData()
                self.hideHUD()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
            }}
    }
    
    @IBAction func viewButt(_ sender: AnyObject) {
        
        let butt = sender
        let indexP = IndexPath(row: butt.tag, section: 0)
        let cell = AMView.cellForItem(at: indexP) as! AMCell
        
        // Show the image preview
        if cell.isVideo == false {
            
            let prevVC = storyboard?.instantiateViewController(withIdentifier: "PreviewImage") as! PreviewImage
            if cell.thumbImage.image != nil {
                prevVC.prev_img = cell.thumbImage.image!
            }
            navigationController?.pushViewController(prevVC, animated: true)
            
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
    

}
