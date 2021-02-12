//
//  TutorialOneViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 24/03/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit

class TutorialOneViewController: UIViewController, UIScrollViewDelegate {
    
    //Outlets.
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tutorialImageView: UIImageView!
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    //Variables
    var pageControlNumber = 0
    var numberOfImages: Int = 0
    var descriptionTexts = [String]()
    var nameOfImages = [String]()
    var nameOfTapImages = [String]()
    var tapXPosition = [CGFloat]()
    var tapYPosition = [CGFloat]()
    var tapWidth = [CGFloat]()
    var tapHeight = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Aspect fit for buttons.
        cancelButton.imageEdgeInsets.right = -55.0
        cancelButton.imageView!.contentMode = .scaleAspectFit
        
        //Adjusting font size.
        descriptionLabel.adjustsFontSizeToFitWidth = true
        
        //Swipe gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(TutorialOneViewController.respondToSwipeGesture(sender:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.tutorialImageView.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(TutorialOneViewController.respondToSwipeGesture(sender:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.tutorialImageView.addGestureRecognizer(swipeLeft)
        //Swipe gesture for going back to previous screen.
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(TutorialOneViewController.respondToSwipeGesture(sender:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.tutorialImageView.addGestureRecognizer(swipeDown)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Preparing for tutorial content.
        switch (SharingManager.sharedInstance.tutorialContent) {
        case "Home screen features":
            screenTitleLabel.text = "Home screen features"
            numberOfImages = 13
            descriptionTexts = ["Single tap on the highlighted icon to see your socialx account details.", "Single tap on the highlighted icon to see your favourites list.", "Single tap on the highlighted icon to see your read later list.", "Single tap on the highlighted icon to add social media site on socialx home screen.", "To start browsing a specific social media site, single tap on its icon to open it in another screen.", "Press and hold social media icon to enable editing options.", "On this screen you have two options, delete the icon from home screen OR edit the icon and its details. Single tap on the icon without touching delete option for editing the icon and its details.", "For deleting the icon and its details, single tap on the gray circle with cross mark. It will delete the icon from home screen.", "Single tap on the highlighted icon to allocate specific time to get notified when the time is up. Once you set the timer, it displays on the top right corner in blue text.", "Single tap on the highlighted icon to view report of your spent time on soical media sites.", "Single tap on the highlighted icon to stop shaking icons and single tap on the highlighted icon also sets icons' list scroll to the top.", "Single tap on the highlighted icon to open tutorial screen.", "Single tap on the highlighted icon to open settings screen."]
            nameOfImages = ["home_screen_features_1.png", "home_screen_features_2.png", "home_screen_features_3.png", "home_screen_features_4.png", "home_screen_features_5.png", "home_screen_features_6.png", "home_screen_features_7.png", "home_screen_features_8.png", "home_screen_features_9", "home_screen_features_10.png", "home_screen_features_11.png", "home_screen_features_12.png", "home_screen_features_13.png"]
            //Set initial data.
            pageControl.numberOfPages = numberOfImages
            tutorialImageView.image = UIImage(named: nameOfImages[pageControlNumber])
            descriptionLabel.text = descriptionTexts[pageControlNumber]
            pageControl.currentPage = 0
            break
        case "Add icon details":
            screenTitleLabel.text = "Add icon details"
            numberOfImages = 15
            descriptionTexts = [
                "Single tap on the highlighted icon to add social media site on socialx home screen.",
                "Just type the website address in the 'URL' text field & tap the go button. Or single tap anywhere on the website to maximize it and search for the website you are looking for.",
                "Type the name you are looking for and search it with google OR just type website address in 'URL' text field and tap the 'Go' button.",
                "Tap on your desired website name in google searched results. It will open the website.",
                "Now tap on 'Done' button to close maximized view of the website.",
                "Tap on the 'snap shot' button to take snap of the website and crop it for selecting website logo.",
                "Select particular area by moving the dots for cropping the image. Once you finish selecting area for website logo, tap on 'Preview' button to get an idea.",
                "Tap on 'Done' button to crop the image and go back to 'Adding Site' screen.",
                "Now type a short name for your site in highlighted area. Name should be unique.",
                "All done, tap on 'Yes Sign' button to save your site details.",
                "Your details are saved. Tap on 'OK' button for going back to main screen.",
                "Press and hold an icon to enbale moving its position.",
                "Once icons start shaking, keep pressing and holding particular icon, of which you want to change the position and drag it to desired location and unhold the icon.",
                "You moved your icon. To go back to normal screen mode, tap on highlighted icon. It will stop shaking icon and hide icon deletion button as well.",
                "Now you can see the home screen is back to its normal view. You have successfully added the icon!"
            ]
            nameOfImages = ["home_screen_features_4.png", "add_icon_details_2.png", "add_icon_details_3.png", "add_icon_details_4.png", "add_icon_details_5.png", "add_icon_details_6.png", "add_icon_details_7.png", "add_icon_details_8.png", "add_icon_details_9.png", "add_icon_details_10.png", "add_icon_details_11.png", "add_icon_details_12.png", "add_icon_details_13.png", "add_icon_details_14.png", "add_icon_details_15.png"]
            //Set initial data.
            pageControl.numberOfPages = numberOfImages
            tutorialImageView.image = UIImage(named: nameOfImages[pageControlNumber])
            descriptionLabel.text = descriptionTexts[pageControlNumber]
            pageControl.currentPage = 0
            break
        case "Edit icon details":
            screenTitleLabel.text = "Edit icon details"
            numberOfImages = 4
            descriptionTexts = ["Press and hold social media icon to enable editing options.", "On this screen you have two options, delete the icon from home screen OR edit the icon and its details. Single tap on the icon without touching delete option for editing the icon and its details.", "Single tap on the highlighted icon for selecting built-in icons.", "Single tap on the highlighted text for changing the site name of social media. Rest of the things are similar to add icon details."]
            nameOfImages = ["home_screen_features_6.png", "home_screen_features_7.png", "edit_icon_details_3.png", "edit_icon_details_4.png"]
            //Set initial data.
            pageControl.numberOfPages = numberOfImages
            tutorialImageView.image = UIImage(named: nameOfImages[pageControlNumber])
            descriptionLabel.text = descriptionTexts[pageControlNumber]
            pageControl.currentPage = 0
            break
        case "Setting timer":
            screenTitleLabel.text = "Setting timer"
            numberOfImages = 3
            descriptionTexts = ["Single tap on the highlighted icon to allocate daily social media time. The timer is displayed on the top right corner in blue color. Once you have consumed your allocated social media time, socialx app will be inaccessible until the next day.", "Swipe down OR swipe up for scrolling minutes values. The same applies to hours.", "Single tap on the 'Done' button to set allocated time and hide the timer."]
            nameOfImages = ["home_screen_features_9.png", "setting_timer_2.png", "setting_timer_3.png"]
            //Set initial data.
            pageControl.numberOfPages = numberOfImages
            tutorialImageView.image = UIImage(named: nameOfImages[pageControlNumber])
            descriptionLabel.text = descriptionTexts[pageControlNumber]
            pageControl.currentPage = 0
            break
        case "Viewing reports":
            screenTitleLabel.text = "Viewing reports"
            numberOfImages = 3
            descriptionTexts = ["Single tap on the highlighted icon to view report of your spent time on soical media sites.", "By default, 'Daily' report is selected to view daily spent time on social media sites. You can view other four types of reports by just taping on their names.", "Deleting the history of social media sites you have visited is quite easy. It depends on which type of reports data you want to delete. Just tap on REPORT TYPE NAME, like 'Daily' and tap delete button."]
            nameOfImages = ["home_screen_features_10.png", "viewing_reports_2.png", "viewing_reports_3.png"]
            //Set initial data.
            pageControl.numberOfPages = numberOfImages
            tutorialImageView.image = UIImage(named: nameOfImages[pageControlNumber])
            descriptionLabel.text = descriptionTexts[pageControlNumber]
            pageControl.currentPage = 0
            break
        case "Surfing social media sites":
            screenTitleLabel.text = "Surfing social media sites"
            numberOfImages = 2
            descriptionTexts = ["Single tap on the social media icon to open social media site in another screen.", "To return to the main screen, tap on 'Home' button."]
            nameOfImages = ["home_screen_features_5.png", "surfing_social_media_sites_2.png"]
            //Set initial data.
            pageControl.numberOfPages = numberOfImages
            tutorialImageView.image = UIImage(named: nameOfImages[pageControlNumber])
            descriptionLabel.text = descriptionTexts[pageControlNumber]
            pageControl.currentPage = 0
            break
        default:
            break
        }
    }
    
    //Making app portrait
    func shouldAutorotate() -> Bool {
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
                UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
                UIDevice.current.orientation == UIDeviceOrientation.unknown) {
            return false;
        }
        else {
            return true;
        }
    }
    
    @objc func respondToSwipeGesture(sender: UIGestureRecognizer) {
        
        if let swipeGesture = sender as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                if pageControlNumber >= 1 && pageControlNumber < numberOfImages {
                    pageControlNumber -= 1
                    //print(pageControlNumber)
                    tutorialImageView.image = UIImage(named: nameOfImages[pageControlNumber])
                    descriptionLabel.text = descriptionTexts[pageControlNumber]
                    pageControl.currentPage = pageControlNumber
                }
            case UISwipeGestureRecognizer.Direction.left:
                if pageControlNumber >= 0 && pageControlNumber < (numberOfImages - 1) {
                    pageControlNumber += 1
                    //print(pageControlNumber)
                    tutorialImageView.image = UIImage(named: nameOfImages[pageControlNumber])
                    descriptionLabel.text = descriptionTexts[pageControlNumber]
                    pageControl.currentPage = pageControlNumber
                }
            case UISwipeGestureRecognizer.Direction.down:
                dismiss(animated: false, completion: nil)
                break
            default:
                break
            }
        } else {
            print("Gesture not working")
        }
    }
    
    @IBAction func back(sender: UIButton) {
        //println("Play image tapped.")
        dismiss(animated: false, completion: nil)
    }
}
