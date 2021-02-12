//
//  SiteWebViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 15/01/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit
import AVFoundation
import WebKit

class SiteWebViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, WKUIDelegate/*, WKNavigationDelegate*/ {
    
    //Refrencing outlets.
    @IBOutlet weak var statusBarDistance: NSLayoutConstraint!
    @IBOutlet weak var urlViewHeight: NSLayoutConstraint!
    @IBOutlet weak var navigationViewHeight: NSLayoutConstraint!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var urlAddressView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet var containerView : UIView!
    @IBOutlet weak var stopAndReloadButton: UIButton!
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var addUrlButton: UIButton!
    
    //Variables.
    var loadCompletedValue: Int = 0
    var siteWebView: WKWebView?
    var url: NSURL!
    var siteTitleForAlert: String = ""
    var viewedItemName: String = ""
    var audioPlayer = AVAudioPlayer()
    var navBarVisibility: Bool = false
    var lastScrollContentOffset: CGFloat = 0.0
    var loadingFinished: Bool = false
    var clockTimer = Timer()
    let screenSize: CGRect = UIScreen.main.bounds
    var deviceOrientation: String = "Portrait" //Landscape
    var addIconView:UIViewController = UIViewController()
    var targetWidthForPopupMenu: CGFloat = 0.0
    
    override func loadView() {
        super.loadView()
        
        self.siteWebView = WKWebView()
        containerView.addSubview(siteWebView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        addIconView = storyBoard.instantiateViewController(withIdentifier: "addingSiteScreen")
        
        //Textfield delegate.
        urlTextField.delegate = self
        
        siteWebView!.scrollView.isScrollEnabled = true
        siteWebView!.isUserInteractionEnabled = true
        //siteWebView!.navigationDelegate = self //This is to track load progress.
        siteWebView!.uiDelegate = self
        //To use scrollview methods and detecting scrollview scrolling.
        siteWebView!.scrollView.delegate = self
        siteWebView!.scrollView.bounces = false
        targetWidthForPopupMenu = screenSize.width
        navigationBar.layer.borderWidth = 0.3
        navigationBar.layer.borderColor = UIColor.gray.cgColor
        
        //Method called to reload table when app running from background to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(SiteWebViewController.passcodeCheck(notification:)), name: NSNotification.Name(rawValue: "passcodeCheck"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SiteWebViewController.viewDidAppear(_:)), name: NSNotification.Name(rawValue: "refreshingView"), object: nil)
        
        //Adding tap gesture to statusBarView.
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SiteWebViewController.setPageTop))
        tapGestureRecognizer.numberOfTapsRequired = 1
        statusBarView.addGestureRecognizer(tapGestureRecognizer)
        statusBarView.isUserInteractionEnabled = true
        
        siteWebView!.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        
        //Clock setting.
        clockLabel.text = Date().asStringTime
        clockTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(SiteWebViewController.updateClock), userInfo: nil, repeats: true)
        //Setting status bar to light.
        //preferredStatusBarStyle()
        //setNeedsStatusBarAppearanceUpdate()
        
        //Check Device
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //                    print("iPhone 5 or 5S or 5C")
                statusBarDistance.constant = 0
            case 1334:
                //                    print("iPhone 6/6S/7/8")
                statusBarDistance.constant = 0
            case 1920, 2208:
                //                    print("iPhone 6+/6S+/7+/8+")
                statusBarDistance.constant = 0
            default:
                print("Unknown")
                statusBarDistance.constant = 14
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        siteWebView!.frame.size.width = containerView.frame.width
        siteWebView!.frame.size.height = containerView.frame.height
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let todaysDate = Date().asStringDate()
        let dbDateQuery = db.query(sql:"SELECT value FROM settings WHERE key='timerDate'")
        let dbDate = dbDateQuery[0]["value"] as! String
        if dbDate != todaysDate {
            if General.timer.isValid {
                General.timer.invalidate()
            }
            General.remainingTimeInSeconds = 0
            General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
            SharingManager.sharedInstance.storyBoardID = "mainScreen"
            General.storageDefaults.setValue(SharingManager.sharedInstance.storyBoardID, forKey: "storyBoardID")
            super.dismiss(animated: false, completion: nil)
        } else {
            refreshingView()
        }
        //passcodeScreenValidationStatus()
        //print(SharingManager.sharedInstance.dontReloadSiteURL)
        shouldAutorotate()
    }
    
    //Making app portrait
    func shouldAutorotate() -> Bool {
        if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft ||
                UIDevice.current.orientation == UIDeviceOrientation.landscapeRight ||
                UIDevice.current.orientation == UIDeviceOrientation.unknown) {
            deviceOrientation = "Landscape"
            navigationBar.isHidden = false
            urlAddressView.isHidden = false
//            self.siteWebView!.frame = CGRect(x: 0.0, y: 30.0, width: (screenSize.height), height: (screenSize.width - 48))
            targetWidthForPopupMenu = screenSize.height
            return true;
        } else {
            deviceOrientation = "Portrait"
            navigationBar.isHidden = false
            urlAddressView.isHidden = false
            targetWidthForPopupMenu = screenSize.width
//            self.siteWebView!.frame = CGRect(x: 0.0, y: 30.0, width: screenSize.width, height: (screenSize.height - 48))
            return true;
        }
    }
    
    //To open _blank or new tab window in the same window. Also set siteWebView!.UIDelegate = self
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if ((navigationAction.targetFrame) == nil) {
            siteWebView?.load(navigationAction.request)
            //print(navigationAction)
        }
        return nil
    }
    
    //MARK:- Custom methods
    @objc func updateClock() {
        
        clockLabel.text = Date().asStringTime
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
                super.dismiss(animated: false, completion: nil)
                break
            default:
                break
            }
        } else {
            //super.dismiss(animated: false, completion: nil)
        }
    }
    
    func loadSelectedPage() {
        
        if SharingManager.sharedInstance.urlAddressForAdd == "" && SharingManager.sharedInstance.dontReloadSiteURL == false {
            
            urlTextField.text = SharingManager.sharedInstance.itemFormalURL
            //Loading website as selected.
            SharingManager.sharedInstance.itemDomainNameOnly = gettingDomainNameOnly(fullURL: SharingManager.sharedInstance.itemFormalURL)
            General.storageDefaults.setValue(SharingManager.sharedInstance.itemDomainNameOnly, forKey: "itemDomainNameOnly")
            url = NSURL(string: SharingManager.sharedInstance.itemFormalURL)
            let requestObj = NSURLRequest(url: url! as URL)
            siteWebView!.load(requestObj as URLRequest)
        }
    }
    
    func refreshingView() {
        
        //Load site page.
        loadSelectedPage()
        //Setting website name in status bar.
        itemNameLabel.text = SharingManager.sharedInstance.itemName
        //print("1: Assigned to label: " + itemName)
        
        if General.timer.isValid {
            //print("Already valid.")
        } else {
            let displayString: String  = (CommonUtilities.secondsToHoursMinutesSeconds(General.remainingTimeInSeconds)) + "-"
            remainingTimeLabel.text = displayString
            General.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SiteWebViewController.updateDisplay), userInfo: nil, repeats: true)
            //Setting start time here.
            General.startTime = Date()
            General.saveRecord = true
            //print(startTime)
        }
    }
    
    //Backward forward list.
    func backwardItemList() -> NSURL {

        var nsURL: NSURL = NSURL(string: "")!
        let list : WKBackForwardList = siteWebView!.backForwardList
        if (list.backItem != nil) {
            nsURL = list.backItem!.url as NSURL
            return nsURL
        }
        return nsURL
    }
    
    func forwardItemList() -> NSURL {
        
        var nsURL: NSURL = NSURL(string: "")!
        let list : WKBackForwardList = siteWebView!.backForwardList
        if (list.forwardItem != nil) {
            nsURL = list.forwardItem!.url as NSURL
            return nsURL
        }
        return nsURL
    }
    
    //For passcode check
    @objc func passcodeCheck(notification: NSNotification) {
        
        passcodeScreenValidationStatus()
        refreshingView()
        //super.dismiss(animated: false, completion: nil)
    }
    
    /*func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }*/
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView:  UIScrollView) {
        
        if scrollView.contentOffset.y < lastScrollContentOffset {
            urlViewHeight.constant = 30.0
            navigationViewHeight.constant = 32.0
            siteWebView!.frame.size.width = containerView.frame.width
            siteWebView!.frame.size.height = containerView.frame.height
            viewDidLayoutSubviews()
        } else if scrollView.contentOffset.y > lastScrollContentOffset {
            urlViewHeight.constant = 0.0
            navigationViewHeight.constant = 0.0
            siteWebView!.frame.size.width = containerView.frame.width
            siteWebView!.frame.size.height = containerView.frame.height
        } else if scrollView.contentOffset.y == lastScrollContentOffset {
            urlViewHeight.constant = 30.0
            navigationViewHeight.constant = 32.0
            siteWebView!.frame.size.width = containerView.frame.width
            siteWebView!.frame.size.height = containerView.frame.height
        }
        lastScrollContentOffset = scrollView.contentOffset.y
    }
    
    //MARK:- Time methods
    @objc func updateDisplay() {
        
        if General.remainingTimeInSeconds != 0 {
            let updatedRemainingTime: Int = General.remainingTimeInSeconds - 1
            let displayString: String  = (CommonUtilities.secondsToHoursMinutesSeconds(updatedRemainingTime)) + "-"
            General.remainingTimeInSeconds = updatedRemainingTime
            remainingTimeLabel.text = displayString
        } else {
            General.timer.invalidate()
            General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
            _ = db.execute(sql: "UPDATE settings SET value='true' WHERE key='dailySocialTimeUtilization'")
            let soundFileNameQuery = db.query(sql:"SELECT value FROM settings WHERE key='soundFileName'")
            let soundFileName: String = soundFileNameQuery[0]["value"] as! String
            let audioFilePath = Bundle.main.path(forResource: soundFileName, ofType:"mp3")
            let audioFileURL = NSURL(fileURLWithPath: audioFilePath!)
            audioPlayer = try! AVAudioPlayer(contentsOf: audioFileURL as URL)
            audioPlayer.play()
            reminderAlert()
        }
    }
    
    func reminderAlert() {
        
        let alertVC = UIAlertController(title: "Time's Up!", message: "You have spent your allocated socialx time for today. You can again enjoy socialx tomorrow.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            { action -> Void in
                if self.audioPlayer.currentTime > 0 {
                    //print(self.audioPlayer.currentTime)
                    self.audioPlayer.stop()
                } else {
                    self.audioPlayer.currentTime = 0
                }
                self.dismissView()
            })
        present(alertVC, animated: true, completion: nil)
    }
    
    //MARK:- Top panel methods.
    @IBAction func refreshAction(sender: UIButton) {
        
        if loadingFinished == false {
            siteWebView?.stopLoading()
            stopAndReloadButton.setImage(UIImage(named: "refresh-thin.png"), for: .normal)
            loadingLabel.isHidden = true
            loadingFinished = true
            siteWebView!.isHidden = false
        } else {
            siteWebView!.reload()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text == urlTextField.text && textField.text != "" {
            textField.resignFirstResponder()
            loadingTextFieldURL(urlString: textField.text!)
            //print("Load called.")
            return true
        }
        return false
    }
    
    func loadingTextFieldURL(urlString: String) {
        
        url = NSURL(string: RepeatMethods.makingFormalURL(urlString: urlString))
        let requestObj = NSURLRequest(url: url! as URL)
        siteWebView!.load(requestObj as URLRequest)
    }
    
    @IBAction func addURLAction(sender: UIButton) {
        
        //Calling to become first responder. This code also depend of two methods canBecomeFirstResponder and canPerformAction.
        becomeFirstResponder()
        //Setting position for popup menu.
        let targetPosition:CGRect = CGRect(x: self.view.frame.width - 10, y: 0, width: 100, height: 30)
        //Initiating menu and menu item.
        let menu = UIMenuController.shared
        let addIcon = UIMenuItem(title: "Add Icon", action: #selector(SiteWebViewController.addIconScreen))
        let addToFavourite = UIMenuItem(title: "Add to Favourites", action: #selector(SiteWebViewController.addToFavourites))
        let addToReadLater = UIMenuItem(title: "Add to Read Later", action: #selector(SiteWebViewController.addToReadLater))
        menu.menuItems = [addIcon, addToFavourite, addToReadLater]
        menu.showMenu(from: urlAddressView, rect: targetPosition)
    }
    
    
    
    //MARK:- Necessary methods for popup menu.
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        // You need to only return true for the actions you want, otherwise you get the whole range of
        //  iOS actions. You can see this by just removing the if statement here.
        if action == #selector(SiteWebViewController.addIconScreen) {
            return true
        } else if action == #selector(SiteWebViewController.addToFavourites) {
            return true
        } else if action == #selector(SiteWebViewController.addToReadLater) {
            return true
        }
        return false
    }
    
    @objc func addIconScreen() {
        
        //Pause timer and save record.
        if General.timer.isValid {
            General.timer.invalidate()
        }
        General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
        //Saving record in database.
        if General.saveRecord == true {
            if SharingManager.sharedInstance.itemDomainNameOnly != "about:blank" {
                RepeatMethods.recordSpentTime(mEndTime: Date(), mItemName: SharingManager.sharedInstance.itemName, mItemLink: SharingManager.sharedInstance.itemDomainNameOnly, mItemImageNme: SharingManager.sharedInstance.itemImageName)
            }
            General.saveRecord = false
        }
        //Preparing to show add screen.
        SharingManager.sharedInstance.urlAddressForAdd = urlTextField.text!
        present(addIconView, animated: false, completion: nil)
    }
    
    @objc func addToFavourites() {
        
        let checkItemNameQuery = db.query(sql:"SELECT * FROM item_details WHERE item_name='\(SharingManager.sharedInstance.itemName!)'")
        if checkItemNameQuery.count > 0 {
            let favouriteStatus = checkItemNameQuery[0]["favourite_status"] as! String
            if favouriteStatus == "NO" {
                _ = db.execute(sql: "UPDATE item_details SET favourite_status='YES' WHERE item_name='\(SharingManager.sharedInstance.itemName!)'")
                let alertVC = UIAlertController(title: "Favourites Status", message: "This site is added to your favourites list.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                    //Write code here.
                    })
                present(alertVC, animated: true, completion: nil)
            } else {
                let alertVC = UIAlertController(title: "Favourites Status", message: "This site is already in your favourites list.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                    //Write code here.
                    })
                present(alertVC, animated: true, completion: nil)
            }
        } else {
            var siteNameForAlert: String = ""
            var siteUrlAddressForAlert: String = ""
            let alertVC = UIAlertController(title: "Favourites List", message: "Please tap 'Add' to list this site in favourites.", preferredStyle: .alert)
            alertVC.addTextField(configurationHandler: {(textField1: UITextField!) in
                textField1.text = self.itemNameLabel.text
            })
            alertVC.addTextField(configurationHandler: {(textField2: UITextField!) in
                textField2.text = self.urlTextField.text
            })
            alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive)
            { action -> Void in
                //Write code here.
                })
            alertVC.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default)
            { action -> Void in
                siteNameForAlert = alertVC.textFields![0].text!
                siteUrlAddressForAlert = alertVC.textFields![1].text!
                let siteIconImage: UIImage = RepeatMethods.captureWebViewScreen(webView: self.siteWebView!)
                let siteIconImageName: String = RepeatMethods.savingImageLocally(selectedImage: siteIconImage)
                let totalRowsQuery = db.query(sql:"SELECT * FROM item_details")
                let siteLocationNo = totalRowsQuery.count
                _ = db.execute(sql: "INSERT INTO item_details (item_name, item_image, item_link, favourite_status, item_location_no, image_local_storage) VALUES ('\(siteNameForAlert)', '\(siteIconImageName)', '\(siteUrlAddressForAlert)', 'YES', '\(siteLocationNo)', 'true')")
                })
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    @objc func addToReadLater() {
        
        var siteUrlAddressForAlert: String = ""
        let siteAddedDate:String = Date().asMediumString()
        let alertVC = UIAlertController(title: "Read Later List", message: "Please tap 'Add' to list this site in read later.", preferredStyle: .alert)
        alertVC.addTextField(configurationHandler: {(textField1: UITextField!) in
            textField1.autocapitalizationType = UITextAutocapitalizationType.sentences
            textField1.text = self.siteTitleForAlert //""
        })
        alertVC.addTextField(configurationHandler: {(textField2: UITextField!) in
            textField2.text = self.urlTextField.text
            siteUrlAddressForAlert = textField2.text!
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive)
        { action -> Void in
            //Write code here.
            })
        alertVC.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default)
        { action -> Void in
            self.siteTitleForAlert = alertVC.textFields![0].text!
            siteUrlAddressForAlert = alertVC.textFields![1].text!
            _ = db.execute(sql: "INSERT INTO read_later_sites (site_title, site_url_address, site_added_date) VALUES (?, ?, ?)", parameters:[self.siteTitleForAlert, siteUrlAddressForAlert, siteAddedDate])
            })
        present(alertVC, animated: true, completion: nil)
    }
    
    //MARK:- Report writing methods.
    func gettingItemName(urlWithoutHTTPAndSubDomain: String) -> String {
        
        let domainNamesQuery = db.query(sql:"SELECT item_name, item_link FROM item_details")
        for indexA in 0 ..< domainNamesQuery.count {
            
            let lowercaseText = (domainNamesQuery[indexA]["item_link"] as! String).lowercased
            if lowercaseText().contains(urlWithoutHTTPAndSubDomain) {
                //print("String matched.")
                let gotItemName = domainNamesQuery[indexA]["item_name"] as! String
                //print(gotItemName)
                return gotItemName
            }
        }
        //print(urlWithoutHTTPAndSubDomain)
        return urlWithoutHTTPAndSubDomain
    }
    
    func updatingSiteNameAndWritingReprot(urlString: String) {
        
        if urlString != "" {
            
            let domainNameOnly = gettingDomainNameOnly(fullURL: urlString)
            //print("Domain name only" + domainNameOnly)
            let itemNameForCheck = gettingItemName(urlWithoutHTTPAndSubDomain: domainNameOnly)
            //print("Item Name: " + itemNameForCheck)
            if SharingManager.sharedInstance.itemName == itemNameForCheck {
                //Do nothing
                //print("Doing Nothing.")
            } else {
                //Saving record.
                if General.saveRecord == true {
                    if SharingManager.sharedInstance.itemDomainNameOnly != "about:blank" {
                        RepeatMethods.recordSpentTime(mEndTime: Date(), mItemName: SharingManager.sharedInstance.itemName, mItemLink: SharingManager.sharedInstance.itemDomainNameOnly, mItemImageNme: SharingManager.sharedInstance.itemImageName)
                    }
                    General.saveRecord = false
                }
                //preparing for new record to save.
                SharingManager.sharedInstance.itemName = itemNameForCheck
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemName, forKey: "itemName")
                SharingManager.sharedInstance.itemFormalURL = urlString
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemFormalURL, forKey: "itemFormalURL")
                
                SharingManager.sharedInstance.itemImageName = "Anonymous-Icon.png"
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemImageName, forKey: "itemImageName")
                
                SharingManager.sharedInstance.itemDomainNameOnly = domainNameOnly
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemDomainNameOnly, forKey: "itemDomainNameOnly")
                itemNameLabel.text = SharingManager.sharedInstance.itemName
                //print("2: Assigned to label: " + itemName)
                //print("Not match: " + itemName)
                General.startTime = Date()
                General.saveRecord = true
            }
        }
    }
    
    func gettingDomainNameOnly(fullURL: String) -> String {
        
        if fullURL != "" {
            //print("Full URL : " + fullURL)
            var urlWithoutSubDomain: String = ""
            var urlWithoutHttps: String = ""
            
            if fullURL.range(of: "http://") != nil {
                urlWithoutHttps = fullURL.replacingOccurrences(of: "http://", with: "")
            } else if fullURL.range(of: "https://") != nil {
                urlWithoutHttps = fullURL.replacingOccurrences(of: "https://", with: "")
            } else {
                urlWithoutHttps = fullURL
            }
            
            //print("Without https: " + urlWithoutHttps)
            //var domainNameArray = urlWithoutHttps.characters.split{$0 == "."}.map(String.init)
            var domainNameArray = urlWithoutHttps.components(separatedBy: ".")
            
            if domainNameArray[0] == "www" || domainNameArray[0] == "m" || domainNameArray[0] == "lm" || domainNameArray[0] == "mobile" {
                //print("Index 0: " + domainNameArray[0])
                domainNameArray[0] = ""
            }
            
            for indexA in 0 ..< domainNameArray.count {
                //print("For Loop :" + String(indexA))
                if domainNameArray[indexA] != "" {
                    if indexA < (domainNameArray.count - 1) {
                        urlWithoutSubDomain += domainNameArray[indexA] + "."
                        //urlWithoutSubDomain.addString(domainNameArray[indexA] + ".")
                        //print(domainNameArray[indexA] + ".")
                    } else {
                        urlWithoutSubDomain += domainNameArray[indexA]
                        //urlWithoutSubDomain.addString(domainNameArray[indexA])
                        //print(domainNameArray[indexA])
                    }
                }
                //print("In loop: " + String(indexA) + domainNameArray[indexA])
            }
            
            let domainNameOnlyArray = urlWithoutSubDomain.split{$0 == "/"}.map(String.init)
            
            if domainNameOnlyArray.count > 0 {
                //print("Domain Name only: " + domainNameOnlyArray[0])
                return domainNameOnlyArray[0]
            } else {
                //print("Joined url: " + urlWithoutSubDomain)
                return urlWithoutSubDomain
            }
        }
        return ""
    }
    
    //MARK:- Bottom panel methods.
    @IBAction func backwardAction(sender: UIButton) {
        
        if siteWebView!.canGoBack {
            siteWebView!.goBack()
            //let fullDomainName = backwardItemList().host!
            //updatingSiteNameAndWritingReprot(fullDomainName)
        }
    }
    
    @IBAction func forwardAction(sender: UIButton) {
        
        if siteWebView!.canGoForward {
            siteWebView!.goForward()
            //let fullDomainName = forwardItemList().host!
            //updatingSiteNameAndWritingReprot(fullDomainName)
        }
    }
    
    @IBAction func shareLinkAction(sender: UIButton) {
        
        let textToShare:String = "socialx is awesome! I am sharing the site using this app." //siteWebView!.title! //"socialx is awesome! I am sharing the site using this app."
        
        if let myWebsite = NSURL(string: urlTextField.text!) {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            //activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func exitAction(sender: UIButton) {
        
        //Making textfield URL empty.
        SharingManager.sharedInstance.urlAddressForAdd = ""
        //Loading html.
        let htmlString:String = "<html><body><div style='font-color:black;width:100%;height:100%;margin-top:50%;text-align:center;font-weight:bold;font:20px arial'>...</div></body></html>"
        siteWebView!.loadHTMLString(htmlString, baseURL: nil)
        dismissView()
    }
    
    func dismissView() {
        
        if General.timer.isValid {
            General.timer.invalidate()
        }
        General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
        //Saving record in database.
        if General.saveRecord == true {
            if SharingManager.sharedInstance.itemDomainNameOnly != "about:blank" {
                RepeatMethods.recordSpentTime(mEndTime: Date(), mItemName: SharingManager.sharedInstance.itemName, mItemLink: SharingManager.sharedInstance.itemDomainNameOnly, mItemImageNme: SharingManager.sharedInstance.itemImageName)
            }
            General.saveRecord = false
        }
        SharingManager.sharedInstance.storyBoardID = "mainScreen"
        General.storageDefaults.setValue(SharingManager.sharedInstance.storyBoardID, forKey: "storyBoardID")
        super.dismiss(animated: false, completion: nil)
    }
    
    /*
    @IBAction func idPasteAction(sender: UIButton) {
        
        let idQuery = db.query(sql:"SELECT * FROM item_details WHERE item_name='\(itemName)'")
        let idString = idQuery[0]["item_username"] as! String
        copyText(idString!)
        pasteText()
    }
    
    @IBAction func passwordPasteAction(sender: UIButton) {
        
        let passwordQuery = db.query(sql:"SELECT * FROM item_details WHERE item_name='\(itemName)'")
        let passwordString = passwordQuery[0]["item_password"] as! String
        copyText(passwordString!)
        pasteText()
    }
    
    // Function receives the text as argument for copying
    func copyText(textToCopy: String) {
        
        let pasteBoard    = UIPasteboard.generalPasteboard()
        if textToCopy == "" {
            pasteBoard.string = " "
        } else {
            pasteBoard.string = textToCopy // Set your text here
        }
    }
    
    // Function returns the copied string
    func pasteText() -> String {
        let pasteBoard    = UIPasteboard.generalPasteboard();
        print("Copied Text : \(pasteBoard.string)"); // It prints the copied text
        return pasteBoard.string!;
    }*/
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if SharingManager.sharedInstance.dontReloadSiteURL == false {
            if (keyPath == "loading") {
                if siteWebView!.estimatedProgress == 1.0 {
                    loadCompletedValue = 0
                    let loadedUrl = siteWebView!.url?.absoluteString as String?
                    if loadedUrl != "about:blank" {
                        urlTextField.text = loadedUrl
                        updatingSiteNameAndWritingReprot(urlString: loadedUrl!)
                    } else {
                        itemNameLabel.text = (siteWebView?.title)! as String
                    }
                    if itemNameLabel.text == "Loading ..." {
                        itemNameLabel.text = SharingManager.sharedInstance.itemName
                    }
                    siteTitleForAlert = (siteWebView?.title)! as String
                    stopAndReloadButton.setImage(UIImage(named: "refresh-thin.png"), for: .normal)
                    loadingLabel.isHidden = true
                    loadingFinished = true
                    siteWebView!.isHidden = false
                } else if siteWebView!.estimatedProgress == 0.1 {
                    loadCompletedValue = loadCompletedValue - 1
                    if loadCompletedValue == -1 {
                        urlTextField.text = siteWebView!.url?.absoluteString as String?
                        itemNameLabel.text = "Loading ..."
                    } else if loadCompletedValue == -2 {
                        let htmlString:String = "<html><head><title>Page is not available</title></head><body><div style='font-color:black;width:100%;height:100%;margin-top:50%;text-align:center;font-weight:bold;font:28px arial'>Page is not available.</div></body></html>"
                        siteWebView!.loadHTMLString(htmlString, baseURL: nil)
                    }
                    loadingFinished = false
                    stopAndReloadButton.setImage(UIImage(named: "stop-thin.png"), for: .normal)
                    //print(loadCompletedValue)
                } else {
                    //This section is not called.
                    //print("Not in progress.")
                }
            }
        } else {
            SharingManager.sharedInstance.dontReloadSiteURL = false
        }
    }
    
    @IBAction func goToTopAction(sender: UIButton) {
        
        setPageTop()
    }
    
    @objc func setPageTop() {
        
        siteWebView!.scrollView.setContentOffset(.zero, animated: true)
    }
    
    func hideNavBar() {
        
        /*if  navBarVisibility == true {
            navBarVisibility = false
            General.storageDefaults.setBool(navBarVisibility, forKey: "siteScreenNavBarVisibility")
            //navigationBar.isHidden = true
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.navigationBar.frame = CGRect(x: 0, y: -48, width: 414, height: 30)
                self.siteWebView!.frame = CGRect(0.0, 18.0, 414.0, 736.0)
            })
        } else {
            navBarVisibility = true
            General.storageDefaults.setBool(navBarVisibility, forKey: "siteScreenNavBarVisibility")
            //navigationBar.isHidden = false
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.navigationBar!.frame = CGRect(x: 0, y: 18, width: 414, height: 30)
                self.siteWebView!.frame = CGRect(0.0, 48.0, 414.0, 688.0)
            })
        }*/
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        
        if (( self.presentedViewController) != nil) {
            super.dismiss(animated: flag, completion: completion)
        }
    }
}
