//
//  PreviewImage.swift
//  Chatty
//
//  Created by ciast on 8/17/16.
//  Copyright © 2016 FV iMAGINATION. All rights reserved.
//

import UIKit

class PreviewImage: UIViewController {

    @IBOutlet var prevImage: UIImageView!
    var prev_img = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize a BACK BarButton Item
        let backButt = UIButton(type: UIButtonType.custom)
        backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        backButt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
        
        self.title = "Preview"
        
        // set Image
        prevImage.image = prev_img
        
        // swipe right gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(Contact.backToScreen(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
