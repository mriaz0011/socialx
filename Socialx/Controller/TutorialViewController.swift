//
//  TutorialViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 23/03/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    //Outlet
    @IBOutlet weak var tutorialScrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    //To make round.
    @IBOutlet weak var box1: UILabel!
    @IBOutlet weak var box2: UILabel!
    @IBOutlet weak var box3: UILabel!
    @IBOutlet weak var box4: UILabel!
    @IBOutlet weak var box5: UILabel!
    @IBOutlet weak var box6: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Aspect fit for buttons.
        backButton.imageEdgeInsets.left = -55.0
        backButton.imageView!.contentMode = .scaleAspectFit
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(TutorialViewController.homeScreenTutorialAction))
        box1.isUserInteractionEnabled = true
        box1.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(TutorialViewController.addScreenTutorialAction))
        box2.isUserInteractionEnabled = true
        box2.addGestureRecognizer(tap2)
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(TutorialViewController.editScreenTutorialAction))
        box3.isUserInteractionEnabled = true
        box3.addGestureRecognizer(tap3)
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(TutorialViewController.timerScreenTutorialAction))
        box4.isUserInteractionEnabled = true
        box4.addGestureRecognizer(tap4)
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(TutorialViewController.reportScreenTutorialAction))
        box5.isUserInteractionEnabled = true
        box5.addGestureRecognizer(tap5)
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(TutorialViewController.browsingScreenTutorialAction))
        box6.isUserInteractionEnabled = true
        box6.addGestureRecognizer(tap6)
        
        deviceBasedCustomisation()
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func deviceBasedCustomisation() {
        
        var deviceScreenWidth: CGFloat = 0.0
        var deviceScreenHeight: CGFloat = 0.0
        let screenSize: CGRect = UIScreen.main.bounds
        deviceScreenWidth = screenSize.width
        deviceScreenHeight = screenSize.height
        
        switch (deviceScreenHeight, deviceScreenWidth) {
        case (480.0, 320.0),(320.0, 480.0): //iPhone 4S
            //tutorialScrollView.contentSize.height = 550
            break
        case (568.0, 320.0),(320.0, 568.0): //iPhone 5/5S
            //tutorialScrollView.contentSize.height = 550
            break
        case (667.0, 375.0),(375.0, 667.0): //iPhone 6
            //tutorialScrollView.contentSize.height = 550
            //For rounded corners.
            box1.rounded
            box2.rounded
            box3.rounded
            box4.rounded
            box5.rounded
            box6.rounded
            break
        case (736.0, 414.0),(414.0, 736.0): //iPhone 6 Plus
            //For rounded corners.
            box1.rounded
            box2.rounded
            box3.rounded
            box4.rounded
            box5.rounded
            box6.rounded
            break
        case (1024.0, 768.0),(768.0, 1024.0): //iPad Mini, iPad, iPad Air
            //For rounded corners.
            box1.rounded
            box2.rounded
            box3.rounded
            box4.rounded
            box5.rounded
            box6.rounded
            break
        case (1366.0, 1024.0),(1024.0, 1366.0): //iPad Pro
            //For rounded corners.
            box1.rounded
            box2.rounded
            box3.rounded
            box4.rounded
            box5.rounded
            box6.rounded
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
    
    @IBAction func back(sender: UIButton) {
        //println("Play image tapped.")
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func homeScreenTutorialAction(sender: UIButton) {
        
        SharingManager.sharedInstance.tutorialContent = "Home screen features"
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var aboutUsView: UIViewController = UIViewController()
        aboutUsView = storyBoard.instantiateViewController(withIdentifier:"tutorialOneScreen")
        present(aboutUsView, animated: false, completion: nil)
    }
    
    @IBAction func addScreenTutorialAction(sender: UIButton) {
        
        SharingManager.sharedInstance.tutorialContent = "Add icon details"
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var aboutUsView: UIViewController = UIViewController()
        aboutUsView = storyBoard.instantiateViewController(withIdentifier:"tutorialOneScreen")
        present(aboutUsView, animated: false, completion: nil)
    }
    
    @IBAction func editScreenTutorialAction(sender: UIButton) {
        
        SharingManager.sharedInstance.tutorialContent = "Edit icon details"
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var aboutUsView: UIViewController = UIViewController()
        aboutUsView = storyBoard.instantiateViewController(withIdentifier:"tutorialOneScreen")
        present(aboutUsView, animated: false, completion: nil)
    }
    
    @IBAction func timerScreenTutorialAction(sender: UIButton) {
        
        SharingManager.sharedInstance.tutorialContent = "Setting timer"
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var aboutUsView: UIViewController = UIViewController()
        aboutUsView = storyBoard.instantiateViewController(withIdentifier:"tutorialOneScreen")
        present(aboutUsView, animated: false, completion: nil)
    }
    
    @IBAction func reportScreenTutorialAction(sender: UIButton) {
        
        SharingManager.sharedInstance.tutorialContent = "Viewing reports"
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var aboutUsView: UIViewController = UIViewController()
        aboutUsView = storyBoard.instantiateViewController(withIdentifier:"tutorialOneScreen")
        present(aboutUsView, animated: false, completion: nil)
    }
    
    @IBAction func browsingScreenTutorialAction(sender: UIButton) {
        
        SharingManager.sharedInstance.tutorialContent = "Surfing social media sites"
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var aboutUsView: UIViewController = UIViewController()
        aboutUsView = storyBoard.instantiateViewController(withIdentifier:"tutorialOneScreen")
        present(aboutUsView, animated: false, completion: nil)
    }
}
