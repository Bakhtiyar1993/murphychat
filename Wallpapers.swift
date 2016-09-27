/* ------------------------------------------
 
 
 Copyright © 2016 Sevenstar Infotech.
 All rights reserved.
 
 ------------------------------------------*/


import UIKit



// MARK: - CUSTOM WP CELL
class WPCell:UICollectionViewCell {
    /* Views */
    @IBOutlet weak var wpImage: UIImageView!
}






// MARK: _ WALLPAPER CONTROLLER
class Wallpapers: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
{

    /* Views */
    @IBOutlet weak var wpCollView: UICollectionView!
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    self.title = "WALLPAPERS"
    
    
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
}

func backButton() {
    navigationController?.popViewController(animated: true)
}

    
    
    
// MARK: - COLLECTION VIEW DELEGATES
func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}
    
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return WALLPAPERS_AMOUNT
}
    
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WPCell", for: indexPath) as! WPCell
        
        cell.wpImage.image = UIImage(named: "wp\((indexPath as NSIndexPath).row)")
        
    return cell
}
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/2 - 20, height: 200)
}
    
// TAP ON A CELL -> SELECT THE WALLPAPER
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    wallpaperName = "wp\((indexPath as NSIndexPath).row)"
    DEFAULTS.set(wallpaperName, forKey: "wallpaperName")
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
