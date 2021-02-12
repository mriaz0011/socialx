//
//  SettingsViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 21/01/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit
import StoreKit
import Social
import MessageUI

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate {
    
    //Outlet references.
    @IBOutlet weak var settingsScroll: UIScrollView!
    @IBOutlet weak var passcodeOnButton: UIButton!
    @IBOutlet weak var passcodeChangeButton: UIButton!
    @IBOutlet weak var allocateTimeButton: UIButton!
    @IBOutlet weak var selectSoundButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    //For picker view
    @IBOutlet weak var pickerTitle0Label: UILabel!
    @IBOutlet weak var pickerTitle1Label: UILabel!
    @IBOutlet weak var pickerBg0Label: UILabel!
    @IBOutlet weak var pcikerBg1Label: UILabel!
    @IBOutlet weak var customPickerView: UIPickerView!
    @IBOutlet weak var pickerConainerView: UIView!
    //For labels to round corners.
//    @IBOutlet weak var box1Lable: UILabel!
    @IBOutlet weak var box2Lable: UILabel!
    @IBOutlet weak var box3Lable: UILabel!
    @IBOutlet weak var box4Lable: UILabel!
    @IBOutlet weak var box5Lable: UILabel!
    @IBOutlet weak var box6Lable: UILabel!
    
    //Variables.
    //Screen view
    var siteWebView:UIViewController = UIViewController()
    //Story board
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    var myMail: MFMailComposeViewController!
    var soundPickerValues = ["No Sound", "Alarm-1", "Alarm-2", "Alarm-3", "Alarm-clock", "Bell", "Buzz", "Pager"]
    var hoursPickerValues = ["0 Hour", "1 Hour", "2 Hour", "3 Hour", "4 Hour", "5 Hour", "6 Hour", "7 Hour", "8 Hour", "9 Hour", "10 Hour", "11 Hour", "12 Hour", "13 Hour", "14 Hour", "15 Hour", "16 Hour", "17 Hour", "18 Hour", "19 Hour", "20 Hour", "21 Hour", "22 Hour", "23 Hour", "24 Hour"]
    var minutesPickerValues = ["0 Minute", "01 Minute", "02 Minutes", "03 Minutes", "04 Minutes", "05 Minutes", "06 Minutes", "07 Minutes", "08 Minutes", "09 Minutes", "10 Minutes", "11 Minutes", "12 Minutes", "13 Minutes", "14 Minutes", "15 Minutes", "16 Minutes", "17 Minutes", "18 Minutes", "19 Minutes", "20 Minutes", "21 Minutes", "22 Minutes", "23 Minutes", "24 Minutes", "25 Minutes", "26 Minutes", "27 Minutes", "28 Minutes", "29 Minutes", "30 Minutes", "31 Minutes", "32 Minutes", "33 Minutes", "34 Minutes", "35 Minutes", "36 Minutes", "37 Minutes", "38 Minutes", "39 Minutes", "40 Minutes", "41 Minutes", "42 Minutes", "43 Minutes", "44 Minutes", "45 Minutes", "46 Minutes", "47 Minutes", "48 Minutes", "49 Minutes", "50 Minutes", "51 Minutes", "52 Minutes", "53 Minutes", "54 Minutes", "55 Minutes", "56 Minutes", "57 Minutes", "58 Minutes", "59 Minutes", "60 Minutes"]
    var selectedPicker: String = "allocateTime" //selectSound, allocateTime
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Aspect fit for buttons.
        backButton.imageEdgeInsets.left = -55.0
        backButton.imageView!.contentMode = .scaleAspectFit
        
        deviceBasedCustomisation()
        //Assigning storyboard ID.
        siteWebView = storyBoard.instantiateViewController(withIdentifier: "siteScreen")
        
//        let tap1 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.shareAction(sender:)))
//        box1Lable.isUserInteractionEnabled = true
//        box1Lable.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.rateApp(sender:)))
        box2Lable.isUserInteractionEnabled = true
        box2Lable.addGestureRecognizer(tap2)
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.selectSoundAction(sender:)))
        box3Lable.isUserInteractionEnabled = true
        box3Lable.addGestureRecognizer(tap3)
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.contactUs(sender:)))
        box4Lable.isUserInteractionEnabled = true
        box4Lable.addGestureRecognizer(tap4)
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.facebookLike(sender:)))
        box5Lable.isUserInteractionEnabled = true
        box5Lable.addGestureRecognizer(tap5)
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(SettingsViewController.twitterFollow(sender:)))
        box6Lable.isUserInteractionEnabled = true
        box6Lable.addGestureRecognizer(tap6)
        
        //Method called to reload table when app running from background to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.passcodeCheck(notification:)), name: NSNotification.Name(rawValue: "passcodeCheck"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //passcodeScreenValidationStatus()
        refreshingSettingsView()
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    //MARK:- Custom methods
    func deviceBasedCustomisation() {
        
        var deviceScreenWidth: CGFloat = 0.0
        var deviceScreenHeight: CGFloat = 0.0
        let screenSize: CGRect = UIScreen.main.bounds
        deviceScreenWidth = screenSize.width
        deviceScreenHeight = screenSize.height
        
        switch (deviceScreenHeight, deviceScreenWidth) {
        case (480.0, 320.0),(320.0, 480.0): //iPhone 4S
            settingsScroll.contentSize.height = 550
            break
        case (568.0, 320.0),(320.0, 568.0): //iPhone 5/5S
            settingsScroll.contentSize.height = 550
            break
        case (667.0, 375.0),(375.0, 667.0): //iPhone 6
            settingsScroll.contentSize.height = 550
            //For rounded corners.
//            box1Lable.rounded
            box2Lable.rounded
            box3Lable.rounded
            box4Lable.rounded
            box5Lable.rounded
            box6Lable.rounded
            break
        case (736.0, 414.0),(414.0, 736.0): //iPhone 6 Plus
            //For rounded corners.
//            box1Lable.rounded
            box2Lable.rounded
            box3Lable.rounded
            box4Lable.rounded
            box5Lable.rounded
            box6Lable.rounded
            break
        case (1024.0, 768.0),(768.0, 1024.0): //iPad Mini, iPad, iPad Air
            //For rounded corners.
//            box1Lable.rounded
            box2Lable.rounded
            box3Lable.rounded
            box4Lable.rounded
            box5Lable.rounded
            box6Lable.rounded
            break
        case (1366.0, 1024.0),(1024.0, 1366.0): //iPad Pro
            //For rounded corners.
//            box1Lable.rounded
            box2Lable.rounded
            box3Lable.rounded
            box4Lable.rounded
            box5Lable.rounded
            box6Lable.rounded
            break
        default:
            break
        }
    }
    
    func passcodeScreenValidationStatus() {
        
        let passcodeValidationQuery = db.query(sql:"SELECT value FROM settings WHERE key='passcodeValidation'")
        let passcodeValidation: String = passcodeValidationQuery[0]["value"] as! String
        let passcodeScreenValidationQuery = db.query(sql:"SELECT value FROM settings WHERE key='passcodeScreenValidationStatus'")
        let passcodeScreenValidation: String = passcodeScreenValidationQuery[0]["value"] as! String
        
        if passcodeValidation == "ON" {
            switch (passcodeScreenValidation) {
            case "Passcode Validated":
                //..
                break
            case "Validate Passcode":
                dismiss(animated: false, completion: nil)
                break
            default:
                break
            }
        } else {
            //dismiss(animated: false, completion: nil)
        }
    }
    
    //For passcode check
    @objc func passcodeCheck(notification: NSNotification) {
        
        passcodeScreenValidationStatus()
        //dismiss(animated: false, completion: nil)
    }
    
    func refreshingSettingsView() {
        
        pickerConainerView.isHidden = true
        
        //Changing button images
        let passcodeOnQuery = db.query(sql:"SELECT value FROM settings WHERE key='passcodeValidation'")
        let passcodeOn = passcodeOnQuery[0]["value"] as! String
        if passcodeOn == "OFF" {
            passcodeOnButton.setImage(UIImage(named: "restriction-inactive-filled.png"), for: .normal)
        } else {
            passcodeOnButton.setImage(UIImage(named: "restriction-filled.png"), for: .normal)
        }
        let changePasscodeQuery = db.query(sql:"SELECT value FROM settings WHERE key='passcode'")
        let changePasscode = changePasscodeQuery[0]["value"] as! String
        if changePasscode == "" {
            passcodeChangeButton.setImage(UIImage(named: "change-passcode-inactive-filled.png"), for: .normal)
        } else {
            passcodeChangeButton.setImage(UIImage(named: "change-passcode-filled.png"), for: .normal)
        }
        let selectSoundQuery = db.query(sql:"SELECT value FROM settings WHERE key='soundFileName'")
        let selectSound = selectSoundQuery[0]["value"] as! String
        if selectSound == "No Sound" {
            selectSoundButton.setImage(UIImage(named: "sound-inactive-filled.png"), for: .normal)
        } else {
            selectSoundButton.setImage(UIImage(named: "sound-filled.png"), for: .normal)
        }
        /*let allocateTimeQuery = db.query(sql:"SELECT value FROM settings WHERE key='dailySocialTime'")
        let allocateTime = allocateTimeQuery[0]["value"] as! String
        if allocateTime == "0" {
            allocateTimeButton.setImage(UIImage(named: "time-inactive-filled"), for: .normal)
        } else {
            allocateTimeButton.setImage(UIImage(named: "time-filled"), for: .normal)
        }*/
    }
    
    @IBAction func changePasscodeAction(sender: UIButton) {
        
        let passcodeQuery = db.query(sql:"SELECT value FROM settings WHERE key='passcode'")
        let passcode: String = passcodeQuery[0]["value"] as! String
        let userQuery = db.query(sql:"SELECT email_address FROM user_details WHERE s_no=1 ")
        let user: String = userQuery[0]["email_address"] as! String
        
        if passcode == "" && user == "" {
            let alertVC = UIAlertController(title: "Note", message: "Before changing passcode, please fill user details. Tap 'Continue' to proceed.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default)
                { action -> Void in
                    var userView:UIViewController = UIViewController()
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                userView = storyBoard.instantiateViewController(withIdentifier: "userScreen")
                    self.present(userView, animated: false, completion: nil)
                })
            alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default)
                { action -> Void in
                    
                })
            self.present(alertVC, animated: true, completion: nil)
        } else if passcode == "" && user != "" {
            let alertVC = UIAlertController(title: "Note", message: "Before changing passcode, please create passcode. Tap 'Continue' to proceed.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default)
                { action -> Void in
                    _ = db.execute(sql: "UPDATE settings SET value='ON' WHERE key='passcodeValidation'")
                    _ = db.execute(sql: "UPDATE settings SET value='Validate Passcode' WHERE key='passcodeScreenValidationStatus'")
                    _ = db.execute(sql: "UPDATE settings SET value='Create New Passcode' WHERE key='passcodeScreenEntryStatus'")
                    self.dismiss(animated: false, completion: nil)
                })
            alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default)
                { action -> Void in
                    //....
                })
            self.present(alertVC, animated: true, completion: nil)
        } else {
            _ = db.execute(sql: "UPDATE settings SET value='ON' WHERE key='passcodeValidation'")
            _ = db.execute(sql: "UPDATE settings SET value='Validate Passcode' WHERE key='passcodeScreenValidationStatus'")
            _ = db.execute(sql: "UPDATE settings SET value='Change Old Passcode' WHERE key='passcodeScreenEntryStatus'")
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func selectSoundAction(sender: UIButton) {
        
        let soundFileNameQuery = db.query(sql:"SELECT value FROM settings WHERE key='soundFileName'")
        let soundFileName = soundFileNameQuery[0]["value"] as! String
        pickerTitle0Label.isHidden = false
        pickerTitle1Label.isHidden = true
        pickerBg0Label.isHidden = false
        pcikerBg1Label.isHidden = false
        pcikerBg1Label.backgroundColor = CommonUtilities.webColor("#EFEFF4")
        pickerTitle0Label.text = "Alarms:"
        //pickerTitle1Label.text = "Minutes:"
        selectedPicker = "selectSound"
        customPickerView.reloadAllComponents()
        customPickerView.selectRow(soundPickerValues.firstIndex(of:soundFileName)!, inComponent: 0, animated: true)
        pickerConainerView.isHidden = false
    }
    
    @IBAction func allocateTimeAction(sender: UIButton) {
        
        let setHoursQuery = db.query(sql:"SELECT value FROM settings WHERE key='setHours'")
        let setHours = setHoursQuery[0]["value"] as! String
        let setMinutesQuery = db.query(sql:"SELECT value FROM settings WHERE key='setMinutes'")
        let setMinutes = setMinutesQuery[0]["value"] as! String
        pickerTitle0Label.isHidden = false
        pickerTitle1Label.isHidden = false
        pickerBg0Label.isHidden = false
        pcikerBg1Label.isHidden = false
        pcikerBg1Label.backgroundColor = CommonUtilities.webColor("#CBCBCB")
        pickerTitle0Label.text = "Hours:"
        pickerTitle1Label.text = "Minutes:"
        selectedPicker = "allocateTime"
        customPickerView.reloadAllComponents()
        customPickerView.selectRow(hoursPickerValues.firstIndex(of: setHours)!, inComponent: 0, animated: true)
        customPickerView.selectRow(minutesPickerValues.firstIndex(of: setMinutes)!, inComponent: 1, animated: true)
        pickerConainerView.isHidden = false
    }
    
    @IBAction func resetSettingsAction(sender: UIButton) {
        
        let userDetailsQuery = db.query(sql:"SELECT email_address FROM user_details WHERE s_no=1 ")
        let userDetails: String = userDetailsQuery[0]["email_address"] as! String
        if userDetails != "" {
            _ = db.execute(sql: "UPDATE settings SET value='Create New Passcode' WHERE key='passcodeScreenEntryStatus'")
        } else {
            _ = db.execute(sql: "UPDATE settings SET value='Add User Details' WHERE key='passcodeScreenEntryStatus'")
        }
        _ = db.execute(sql: "UPDATE settings SET value='Validate Passcode' WHERE key='passcodeScreenValidationStatus'")
        _ = db.execute(sql: "UPDATE settings SET value='OFF' WHERE key='passcodeValidation'")
        _ = db.execute(sql: "UPDATE settings SET value='' WHERE key='passcode'")
        _ = db.execute(sql: "UPDATE settings SET value='0' WHERE key='dailySocialTime'")
        _ = db.execute(sql: "UPDATE settings SET value='2016-01-21' WHERE key='timerDate'")
        _ = db.execute(sql: "UPDATE settings SET value='No Sound' WHERE key='soundFileName'")
        _ = db.execute(sql: "UPDATE settings SET value='0 Hour' WHERE key='setHours'")
        _ = db.execute(sql: "UPDATE settings SET value='0 Minute' WHERE key='setMinutes'")
        _ = db.execute(sql: "UPDATE settings SET value='0' WHERE key='setHoursInt'")
        _ = db.execute(sql: "UPDATE settings SET value='0' WHERE key='setMinutesInt'")
        //Refreshing settings view
        refreshingSettingsView()
        General.remainingTimeInSeconds = 0
        General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
    }
    
    @IBAction func shareAction(sender: UIButton) {
        
        let url = URL(string: "https://apps.apple.com/us/app/socialx/id1071615346")!
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//        present(vc, animated: true)
        
        //Apps to be excluded sharing to
        vc.excludedActivityTypes = [
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.addToReadingList
        ]
        // Check if user is on iPad and present popover
        if UIDevice.current.userInterfaceIdiom == .pad {
            if vc.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                vc.popoverPresentationController?.sourceView = self.view
                vc.popoverPresentationController?.sourceRect = sender.frame
            }
        }
        // Present share activityView on regular iPhone
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func faqAction(sender: UIButton) {
        
        var faqView:UIViewController = UIViewController()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        faqView = storyBoard.instantiateViewController(withIdentifier: "faqScreen")
        present(faqView, animated: false, completion: nil)
    }
    
    @IBAction func dismissViewAction(sender: UIButton) {
        
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func eraseIdPwAction(sender: UIButton) {
        
        let alertVC = UIAlertController(title: "Warning!", message: "It will delete your saved usernames and passwords.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
            { action -> Void in
                //..
            })
        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            { action -> Void in
                _ = db.execute(sql: "UPDATE item_details SET item_username='', item_password=''")
            })
        present(alertVC, animated: true, completion: nil)
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult,
                                                   error: NSError?){
        
        self.dismiss(animated: true, completion: nil)
        switch(result){
        case .sent:
            //println("Email sent")
            let alert = UIAlertController(title: "Report", message: "Your email sent.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        default:
            //println("Whoops")
            let alert = UIAlertController(title: "Alert", message: "Your email is not sent.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func contactUs(sender: UIButton) {
        
        if(MFMailComposeViewController.canSendMail()){
            myMail = MFMailComposeViewController()
            
            //myMail.mailComposeDelegate
            myMail.mailComposeDelegate = self
            // set the subject
            myMail.setSubject("Type Your Subject Here")
            
            //To recipients
            let toRecipients = ["infoappworld1@gmail.com"]
            myMail.setToRecipients(toRecipients)
            
            /*
             //CC recipients
             var ccRecipients = ["tzhang85@gatech.edu"]
             myMail.setCcRecipients(ccRecipients)
             
             //CC recipients
             var bccRecipients = ["tzhang85@gatech.edu"]
             myMail.setBccRecipients(ccRecipients)
             */
            
            //Add some text to the message body
            let sentfrom = "Type your message here"
            myMail.setMessageBody(sentfrom, isHTML: true)
            /*
             //Include an attachment
             var image = UIImage(named: "Gimme.png")
             var imageData = UIImageJPEGRepresentation(image, 1.0)
             
             myMail.addAttachmentData(imageData, mimeType: "image/jped", fileName:     "image")
             */
            
            //Display the view controller
            self.present(myMail, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "Your device cannot send emails", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func rateApp(sender: UIButton) {
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
            // Try any other 3rd party or manual method here.
            if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "id1071615346") {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func facebookLike(sender: UIButton) {
        
        SharingManager.sharedInstance.itemFormalURL = "https://www.facebook.com/sharer/sharer.php?u=http%3A//socialxapp.com/"
        present(siteWebView, animated: false, completion: nil)
        /*if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Hi, I am very delighted to tell my firends! I found an amazing app which make your time management for social websites. Please try this app you will definitely recommend to others. I recommend you to try it! Please visit http://socialx.appworld1.com")
            self.present(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }*/
    }
    
    @IBAction func twitterFollow(sender: UIButton) {
        
        SharingManager.sharedInstance.itemFormalURL = "https://twitter.com/share?url=http%3A//socialxapp.com/"
        present(siteWebView, animated: false, completion: nil)
        /*if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Hi, I am very delighted to tell my firends! I found an amazing app which make your time management for social websites. Please try this app you will definitely recommend to others. I recommend you to try it! Please visit http://socialx.appworld1.com")
            self.present(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }*/
    }
    
    //MARK:- Picker view functions.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        var pickerValues: Int = 0
        switch (selectedPicker) {
        case "selectSound":
            pickerValues = 1
            break
        case "allocateTime":
            pickerValues = 2
            break
        default:
            break
        }
        return pickerValues
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        var pickerValues: Int = 0
        switch (selectedPicker) {
        case "selectSound":
            pickerValues = soundPickerValues.count
            break
        case "allocateTime":
            if component == 0 {
                pickerValues = hoursPickerValues.count
                return pickerValues
            } else {
                pickerValues = minutesPickerValues.count
                return pickerValues
            }
            break
        default:
            break
        }
        return pickerValues
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var attributedString: NSAttributedString!
        let pickerValues = [String]()
        switch (selectedPicker) {
        case "selectSound":
            attributedString = NSAttributedString(string: soundPickerValues[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            return attributedString
            break
        case "allocateTime":
            if component == 0 {
                attributedString = NSAttributedString(string: hoursPickerValues[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
                return attributedString
            } else {
                attributedString = NSAttributedString(string: minutesPickerValues[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
                return attributedString
            }
            break
        default:
            break
        }
        attributedString = NSAttributedString(string: pickerValues[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch (selectedPicker) {
        case "selectSound":
            //For hour.
            let selectedSound = soundPickerValues[row]
            _ = db.execute(sql: "UPDATE settings SET value='\(selectedSound)' WHERE key='soundFileName'")
            if selectedSound != "No Sound" {
                selectSoundButton.setImage(UIImage(named: "sound-filled.png"), for: .normal)
            } else {
                selectSoundButton.setImage(UIImage(named: "sound-inactive-filled.png"), for: .normal)
            }
            //print(selectedSound)
            break
        case "allocateTime":
            if component == 0 {
                //For hour.
                let selectedHour = hoursPickerValues[row]
                let hourInInt: Int = row
                _ = db.execute(sql: "UPDATE settings SET value='\(selectedHour)' WHERE key='setHours'")
                _ = db.execute(sql: "UPDATE settings SET value='\(hourInInt)' WHERE key='setHoursInt'")
                //For minutes.
                let setMinutesIntQuery = db.query(sql:"SELECT value FROM settings WHERE key='setMinutesInt'")
                let setMinutesInt: Int = Int(setMinutesIntQuery[0]["value"] as! String)!
                //Calculation.
                let dailySocialTime:Int = ((hourInInt * 60) * 60) + (setMinutesInt * 60)
                _ = db.execute(sql: "UPDATE settings SET value='\(dailySocialTime)' WHERE key='dailySocialTime'")
                General.remainingTimeInSeconds = dailySocialTime
                General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
                //print(dailySocialTime)
                if dailySocialTime == 0 {
                    allocateTimeButton.setImage(UIImage(named: "time-inactive-filled"), for: .normal)
                } else {
                    allocateTimeButton.setImage(UIImage(named: "time-filled"), for: .normal)
                }
            } else {
                //For minutes
                let selectedMinutes = minutesPickerValues[row]
                let minutesInInt: Int = row
                _ = db.execute(sql: "UPDATE settings SET value='\(selectedMinutes)' WHERE key='setMinutes'")
                _ = db.execute(sql: "UPDATE settings SET value='\(minutesInInt)' WHERE key='setMinutesInt'")
                //For hours.
                let setHourIntQuery = db.query(sql:"SELECT value FROM settings WHERE key='setHoursInt'")
                let setHourInt: Int = Int(setHourIntQuery[0]["value"] as! String)!
                //Calculation.
                let dailySocialTime:Int = ((setHourInt * 60) * 60) + (minutesInInt * 60)
                _ = db.execute(sql: "UPDATE settings SET value='\(dailySocialTime)' WHERE key='dailySocialTime'")
                General.remainingTimeInSeconds = dailySocialTime
                General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
                //print(dailySocialTime)
                if dailySocialTime == 0 {
                    allocateTimeButton.setImage(UIImage(named: "time-inactive-filled"), for: .normal)
                } else {
                    allocateTimeButton.setImage(UIImage(named: "time-filled"), for: .normal)
                }
            }
            break
        default:
            break
        }
    }
    
    @IBAction func pickerViewDoneAction(sender: UIButton) {
        
        pickerConainerView.isHidden = true
    }
}

