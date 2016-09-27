//
//  Statistic.swift
//  Chatty
//
//  Created by ciast on 8/6/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

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


class Statistic: UIViewController, UITextFieldDelegate {


    
    @IBOutlet var sendMessCountTxt: UITextField!
    @IBOutlet var recMessCountTxt: UITextField!
    @IBOutlet var sendMediaCountTxt: UITextField!
    @IBOutlet var recMediaCountTxt: UITextField!
    
    /*Variables*/
    var retArray = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        // Initialize a BACK BarButton Item
        let backButt = UIButton(type: UIButtonType.custom)
        backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        backButt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
        
        // Layout setup
        self.title = "Statistic"
        
        //Init Variable
        sendMessCountTxt.isUserInteractionEnabled = false
        recMessCountTxt.isUserInteractionEnabled = false
        sendMediaCountTxt.isUserInteractionEnabled = false
        recMediaCountTxt.isUserInteractionEnabled = false
        
        initValue()
        
        //Get Statistic Info
        getStatisticInfo()
        
        // swipe right gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(Statistic.backToScreen(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
    }
    func initValue() {
        sendMessCountTxt.text = "0"
        recMessCountTxt.text = "0"
        sendMediaCountTxt.text = "0"
        recMediaCountTxt.text = "0"
    }
    func getStatisticInfo(){
        
        var sendMesssageCnt = 0;
        var receiverMesssageCnt = 0;
        var sendMediaCnt = 0;
        var receiveMediaCnt = 0;
        
        let receive = "\(PFUser.current()!.objectId!)"
        let send = "\(PFUser.current()!.objectId!)"
        
        let predicate = NSPredicate(format:"receiverName = '\(receive)' OR senderName = '\(send)'")

        let query = PFQuery(className: INBOX_CLASS_NAME, predicate: predicate)
        
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.retArray.removeAll()
                self.retArray = objects!
                let cnt = self.retArray.count - 1
                var inboxRow = PFObject(className: INBOX_CLASS_NAME)
                for i in 0 ... cnt{
                    inboxRow = self.retArray[i]
                    if( inboxRow[INBOX_SENDER_NAME] as! String == send && inboxRow[INBOX_MESSAGE] as! String != "[Video]" && inboxRow[INBOX_MESSAGE] as! String != "[Audio]" && inboxRow[INBOX_MESSAGE] as! String != "[Picture]" ){
                        sendMesssageCnt += 1;
                        continue
                    }
                    if( inboxRow[INBOX_RECEIVER_NAME] as! String == receive && inboxRow[INBOX_MESSAGE] as! String != "[Video]" && inboxRow[INBOX_MESSAGE] as! String != "[Audio]" && inboxRow[INBOX_MESSAGE] as! String != "[Picture]" ){
                        receiverMesssageCnt += 1;
                        continue
                    }
                    if( inboxRow[INBOX_SENDER_NAME] as! String == send && inboxRow[INBOX_MESSAGE] as! String == "[Video]" || inboxRow[INBOX_MESSAGE] as! String == "[Audio]" || inboxRow[INBOX_MESSAGE] as! String == "[Picture]" ){
                        sendMediaCnt += 1;
                        continue
                    }
                    if( inboxRow[INBOX_RECEIVER_NAME] as! String == receive && inboxRow[INBOX_MESSAGE] as! String == "[Video]" || inboxRow[INBOX_MESSAGE] as! String == "[Audio]" || inboxRow[INBOX_MESSAGE] as! String == "[Picture]" ){
                        receiveMediaCnt += 1;
                        continue
                    }
                }
                self.sendMessCountTxt.text = String( sendMesssageCnt )
                self.recMessCountTxt.text = String( receiverMesssageCnt )
                self.sendMediaCountTxt.text = String( sendMediaCnt )
                self.recMediaCountTxt.text = String( receiveMediaCnt )
                
            } else {
                print("error")
            }}
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - BACK BUTTON
    func backButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func backToScreen(_ sender: UISwipeGestureRecognizer){
        self.backButton()
    }
    
    @IBAction func resetButton(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: APP_NAME,
                                      message: "Are you sure you want to reset statistic?",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "Reset", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            self.showHUD("")
            
            let objectId = "\(PFUser.current()!.objectId!)"
            
            let predicate = NSPredicate(format:"senderName = '\(objectId)' OR receiverName = '\(objectId)'")
            let query = PFQuery(className: INBOX_CLASS_NAME, predicate: predicate)
            query.findObjectsInBackground { (objects, error)-> Void in
                if error == nil {
                    if objects?.count > 0 {
                        for object in objects! {
                            object.deleteEventually()
                            self.initValue()
                        }
                    }
                    self.hideHUD()
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                }}
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in })
        
        alert.addAction(ok); alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
