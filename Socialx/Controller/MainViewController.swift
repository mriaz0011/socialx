//
//  MainViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 27/12/2015.
//  Copyright © 2015 Muhammad Riaz. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UISearchBarDelegate {
    
    //MARK:- Outlet references.
    @IBOutlet weak var statusBarDistance: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var iconsSearchBar: UISearchBar!
    @IBOutlet weak var topPanel: UIView!
    //For status bar.
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var statusBarView: UIView!
    //For picker view.
    @IBOutlet weak var customPickerView: UIPickerView!
    @IBOutlet weak var pickerConainerView: UIView!
    
    //MARK:- Variables
    var clockTimer = Timer()
    //For collection view flow layout
    var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    //For device orientation.
    var deviceScreenWidth: CGFloat = 0.0
    var deviceScreenHeight: CGFloat = 0.0
    //For scrollview.
    var lastScrollContentOffset: CGFloat = 0.0
    //Icon shaking.
    var iconsShakingValue: String = "false"
    var searchBarActive: Bool = false
    //To hold database query result.
    var itemsData = [[String:Any]]()
    var settingsData = [[String:Any]]()
    //View variable
    var settingsView:UIViewController = UIViewController()
    var addingSiteView:UIViewController = UIViewController()
    var editingSiteView:UIViewController = UIViewController()
    var favouritesView:UIViewController = UIViewController()
    var readLaterView:UIViewController = UIViewController()
    var siteWebView:UIViewController = UIViewController()
    var passcodeView:UIViewController = UIViewController()
    var userView:UIViewController = UIViewController()
    var reportView:UIViewController = UIViewController()
    var tutorialViewView:UIViewController = UIViewController()
    let reuseIdentifier = "socialCell"
    var indexPathItem: Int!
    var destinationPathItem: Int!
    var destinationPathItemFromMethod: Int!
    //Shaking
    var iconImages = [UIImageView]()
    var iconDeleteButtons = [UIButton]()
    var iconViews = [UIView]()
    var emptyButton = UIButton()
    var emptyImage = UIImageView()
    var emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 90))
    var VisibleCell = [Bool]()
    var longPressedCell: NSIndexPath?
    var autoScrollCollectionView: Bool = false
    //Pagination
    var totalPages: Int!
    var cellQuantity: Int!
    var cellQuantityByDevice: Int!
    //Search bar
    var dataSourceForSearch = [String]()
    var dataSourceSearchedItemNames = [String]()    
    var topPanelSliding: Bool = false
    //Story board
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    //For picker view.
    var hoursPickerValues = ["0 Hour", "1 Hour", "2 Hour", "3 Hour", "4 Hour", "5 Hour", "6 Hour", "7 Hour", "8 Hour", "9 Hour", "10 Hour", "11 Hour", "12 Hour", "13 Hour", "14 Hour", "15 Hour", "16 Hour", "17 Hour", "18 Hour", "19 Hour", "20 Hour", "21 Hour", "22 Hour", "23 Hour", "24 Hour"]
    var minutesPickerValues = ["0 Minute", "01 Minute", "02 Minutes", "03 Minutes", "04 Minutes", "05 Minutes", "06 Minutes", "07 Minutes", "08 Minutes", "09 Minutes", "10 Minutes", "11 Minutes", "12 Minutes", "13 Minutes", "14 Minutes", "15 Minutes", "16 Minutes", "17 Minutes", "18 Minutes", "19 Minutes", "20 Minutes", "21 Minutes", "22 Minutes", "23 Minutes", "24 Minutes", "25 Minutes", "26 Minutes", "27 Minutes", "28 Minutes", "29 Minutes", "30 Minutes", "31 Minutes", "32 Minutes", "33 Minutes", "34 Minutes", "35 Minutes", "36 Minutes", "37 Minutes", "38 Minutes", "39 Minutes", "40 Minutes", "41 Minutes", "42 Minutes", "43 Minutes", "44 Minutes", "45 Minutes", "46 Minutes", "47 Minutes", "48 Minutes", "49 Minutes", "50 Minutes", "51 Minutes", "52 Minutes", "53 Minutes", "54 Minutes", "55 Minutes", "56 Minutes", "57 Minutes", "58 Minutes", "59 Minutes", "60 Minutes"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Assigning values for width and height of views
        let screenSize: CGRect = UIScreen.main.bounds
        deviceScreenWidth = screenSize.width
        deviceScreenHeight = screenSize.height
       
        addingSiteView = storyBoard.instantiateViewController(withIdentifier: "addingSiteScreen")
        siteWebView = storyBoard.instantiateViewController(withIdentifier: "siteScreen")
        editingSiteView = storyBoard.instantiateViewController(withIdentifier: "editingSiteScreen")
        favouritesView = storyBoard.instantiateViewController(withIdentifier: "favouritesScreen")
        readLaterView = storyBoard.instantiateViewController(withIdentifier: "readLaterScreen")
        settingsView = storyBoard.instantiateViewController(withIdentifier: "settingsScreen")
        reportView = storyBoard.instantiateViewController(withIdentifier: "reportScreen")
        tutorialViewView = storyBoard.instantiateViewController(withIdentifier: "tutorialScreen")
        
        //Search bar.
        iconsSearchBar.delegate = self
        
        //Setting status bar to light.
        /*preferredStatusBarStyle()
        setNeedsStatusBarAppearanceUpdate()*/
        
        //Method called to reload table when app running from background to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.viewDidAppear(_:)), name: NSNotification.Name(rawValue: "refreshingViewForMainScreen"), object: nil)
        
        /*NSNotificationCenter.defaultCenter().addObserverForName("statusBarTouched", object: nil, queue: nil) { event in
            //print("Status bar tapped.")
            self.setPageTop()
        }*/
        
        //Setting collectionview of scrolling speed.
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        //Collection view auto resizing.
//        collectionViewSizing()
        
        //For status bar.
        //Adding tap gesture to statusBarView.
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.setPageTop))
        tapGestureRecognizer.numberOfTapsRequired = 1
        statusBarView.addGestureRecognizer(tapGestureRecognizer)
        statusBarView.isUserInteractionEnabled = true
        //Clock setting.
        clockLabel.text = Date().asStringTime
        clockTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(SiteWebViewController.updateClock), userInfo: nil, repeats: true)
        
        //For battery level change.
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.batteryLevelDidChange(notification:)), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        batteryLabel.text = "Battery " + String(Int((UIDevice.current.batteryLevel * 100))) + "%"
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Making app portrait
    /*func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
                return false;
        }
        else {
            return true;
        }
    }*/
    
    override var prefersStatusBarHidden : Bool {
                
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UpdatingRemainingTimeLabel()
        refreshingCollectionView()
        passcodeScreenValidationStatus()
    }
    
    /*func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }*/
    
    func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
//        collectionViewSizing()
    }
    
    //MARK:- Custom methods
    func collectionViewSizing() {
        
        
        //Setting margins for UICollectionView
//        layout.minimumInteritemSpacing = 15 //Column spacing.
//        layout.minimumLineSpacing = 15 //Row spacing.
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //layout.scrollDirection = .Horizontal
        self.collectionView.collectionViewLayout = layout
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
        }
        if (General.storageDefaults.string(forKey:"iconsShakingKey") == "true") {
            StopShaking()
            //print("Removed animations.")
        }
    }
    
    @objc func setPageTop() {
        
        collectionView.setContentOffset(.zero, animated: true)
    }
    
    @objc func updateClock() {
        
        clockLabel.text = Date().asStringTime
    }
    
    func refreshingCollectionView() {
        
        pickerConainerView.isHidden = true
        
        //Running query.
        itemsData = db.query(sql:"SELECT * FROM item_details ORDER BY item_location_no ASC")
        var tmpIconImages = [UIImageView]()
        var tmpIconDeleteButtons = [UIButton]()
        var tmpIconViews = [UIView]()
        var tmpDataSourceForSearch = [String]()
        for indexA in 0 ..< itemsData.count  {
            tmpIconDeleteButtons.append(emptyButton)
            tmpIconImages.append(emptyImage)
            tmpIconViews.append(emptyView)
            tmpDataSourceForSearch.append(itemsData[indexA]["item_name"] as! String)
        }
        iconImages = tmpIconImages
        iconDeleteButtons = tmpIconDeleteButtons
        iconViews = tmpIconViews
        dataSourceForSearch = tmpDataSourceForSearch
        
        collectionView.reloadData()
    }
    
    //For passcode check
    func passcodeCheck(notification: NSNotification) {
        
        passcodeScreenValidationStatus()
        if iconsShakingValue == "true" {
            StopShaking()
        }
    }
    
    func UpdatingRemainingTimeLabel() {
        
        //Table queries for conditional statements check.
        let todaysDate = Date().asStringDate()
        let dbDateQuery = db.query(sql:"SELECT value FROM settings WHERE key='timerDate'")
        let dbDate = dbDateQuery[0]["value"] as! String
        //Updating settings table values for new day.
        if dbDate != todaysDate {
            //Updating records in settings table.
            _ = db.execute(sql: "UPDATE settings SET value='\(todaysDate)' WHERE key='timerDate'")
            _ = db.execute(sql: "UPDATE settings SET value='false' WHERE key='dailySocialTimeUtilization'")
            _ = db.execute(sql: "UPDATE settings SET value='true' WHERE key='timerSettingMessageDisplay'")
        }
        let setTimerMessageQuery = db.query(sql:"SELECT value FROM settings WHERE key='timerSettingMessageDisplay'")
        let setTimerMessageValue = setTimerMessageQuery[0]["value"] as! String
        
        //For remaining time label in main screen top corner.
        if setTimerMessageValue == "true" {
            //Updating remaining time label on main screen top corner if timer is not started yet.
            let dbTimeQuery = db.query(sql:"SELECT value FROM settings WHERE key='dailySocialTime'")
            let dbTime = dbTimeQuery[0]["value"] as! String
            General.remainingTimeInSeconds = Int(dbTime)!
            General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
            //Assigning time to label.
            let remainingTimeString: String  = (CommonUtilities.secondsToHoursMinutesSeconds(General.remainingTimeInSeconds)) + "-"
            remainingTimeLabel.text = remainingTimeString
        } else {
            let remainingTimeString: String  = (CommonUtilities.secondsToHoursMinutesSeconds(General.remainingTimeInSeconds)) + "-"
            remainingTimeLabel.text = remainingTimeString
        }
    }
    
    
    //MARK:- Alert functions
    func alertForSetSocialTime() {
        
        let alertVC = UIAlertController(title: "Note", message: "You have already set socialx time for today. Your changes will effect tomorrow.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { action -> Void in
            //Code.
            })
        present(alertVC, animated: true, completion: nil)
    }
    
    func alertForFinishedSocialTime() {
        
        let alertVC = UIAlertController(title: "Reminder!", message: "You have already spent your allocated socialx time for today. You can again enjoy socialx tomorrow.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            { action -> Void in
                //Code.
            })
        present(alertVC, animated: true, completion: nil)
    }
    
    func alertForSettingTimerFirst() {
        
        let alertVC = UIAlertController(title: "Set Timer", message: "Please set timer first to control your time for socialx.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "SET", style: UIAlertAction.Style.default)
        { action -> Void in
            //Timer button method calling.
            self.allocateTimeAction(sender: nil)
            })
        present(alertVC, animated: true, completion: nil)
    }
    
    func alertForConfirmingTodaysSocialTime() {
        
        //For daily social time value
        let dbTimeQuery = db.query(sql:"SELECT value FROM settings WHERE key='dailySocialTime'")
        let dbTime = dbTimeQuery[0]["value"] as! String
        let timeInSpecificFormat = CommonUtilities.secondsToHoursMinutesSeconds(Int(dbTime)!)
        let messageContent = "You have set '\(timeInSpecificFormat)' for today. To change it tap reset otherwise tap OK to continue with set time for today."
        let alertVC = UIAlertController(title: "Your Set Time", message: messageContent, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { action -> Void in
            //Setting General.remainingTimeInSeconds from settings table for today once only everyday.
            let dbTimeQuery = db.query(sql:"SELECT value FROM settings WHERE key='dailySocialTime'")
            let dbTime = dbTimeQuery[0]["value"] as! String
            General.remainingTimeInSeconds = Int(dbTime)!
            General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
            //Assigning time to label.
            let remainingTimeString: String  = (CommonUtilities.secondsToHoursMinutesSeconds(General.remainingTimeInSeconds)) + "-"
            self.remainingTimeLabel.text = remainingTimeString
            //Code for not showing this alert message again.
            _ = db.execute(sql: "UPDATE settings SET value='false' WHERE key='timerSettingMessageDisplay'")
            //Going to site screen.
            SharingManager.sharedInstance.storyBoardID = "siteScreen"
            General.storageDefaults.setValue(SharingManager.sharedInstance.storyBoardID, forKey: "storyBoardID")
            self.present(self.siteWebView, animated: false, completion: nil)
            })
        alertVC.addAction(UIAlertAction(title: "RESET", style: UIAlertAction.Style.cancel)
        { action -> Void in
            //Timer button method calling.
            self.allocateTimeAction(sender: nil)
            })
        present(alertVC, animated: true, completion: nil)
    }
    
    func hideTopPanel() {
        
        if  topPanelSliding == true {
            topPanelSliding = false
            //Sliding top panel.
            UIView.animate(withDuration: 0.0, animations: { () -> Void in
                //self.topPanel.frame = CGRect(x: 0, y: -48, width: 414, height: 30)
                //self.collectionView.frame = CGRect(0.0, 18.0, 414.0, 670.0)
                //Setting margins for UICollectionView
                /*self.layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                self.layout.minimumInteritemSpacing = 22
                self.layout.minimumLineSpacing = 22
                self.collectionView.collectionViewLayout = self.layout*/
            })
        } else {
            topPanelSliding = true
            //Sliding top panel.
            UIView.animate(withDuration: 0.0, animations: { () -> Void in
                //self.topPanel.frame = CGRect(x: 0, y: 18, width: 414, height: 30)
                //self.collectionView.frame = CGRect(0.0, 48.0, 414.0, 640.0)
                //Setting margins for UICollectionView
                /*self.layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                self.layout.minimumInteritemSpacing = 15
                self.layout.minimumLineSpacing = 17
                self.collectionView.collectionViewLayout = self.layout*/
            })
        }
    }
    
    /*func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let leftRightInsets: CGFloat = 30
        return UIEdgeInsetsMake(30, leftRightInsets, 30, leftRightInsets)
    }*/
    func scrollViewDidScroll(_ scrollView:  UIScrollView) {
        
        if scrollView.contentOffset.y > lastScrollContentOffset {
            topPanelSliding = true
            hideTopPanel()
        } else if scrollView.contentOffset.y < lastScrollContentOffset || scrollView.contentOffset.y == lastScrollContentOffset {
            topPanelSliding = false
            hideTopPanel()
        } else if scrollView.contentOffset.y == lastScrollContentOffset {
            topPanelSliding = true
            hideTopPanel()
        }
        lastScrollContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        /* if scrollView.contentOffset.y == 0 {
        scrollView.scrollRectToVisible(CGRect(x: 2304.0, y: 0.0, width: 768, height: 365), animated: false)
        } */
        autoScrollCollectionView = false
        /*for var indexA = 0; indexA < totalPages ; ++indexA {
            //For horizontal scrolling
            //let setScrollView: CGFloat = CGFloat(indexA) * 392.0
            //For vertical scrolling
            let setScrollView: CGFloat = CGFloat(indexA) * 617.0
            print(setScrollView)
            if setScrollView == scrollView.contentOffset.x {
                iconsPageControl.currentPage = indexA
            }
        }*/
    }
    
    //For battery level notification.
    @objc func batteryLevelDidChange(notification: NSNotification) {
        
        batteryLabel.text = "Battery " + String(Int((UIDevice.current.batteryLevel * 100))) + "%"
    }
    
    //MARK:- Search bar methods.
    func filterContentForSearchText(searchText:String){
        
        //dataSourceForSearch.keys.filter
        let lowerCaseSearchText = searchText.lowercased()
        dataSourceSearchedItemNames = dataSourceForSearch.filter({ (text:String) -> Bool in
            let lowerCaseDataSource = text.lowercased()
            return lowerCaseDataSource.contains(lowerCaseSearchText)
            })
        //dataSourceShortNameForSearchResult = dataSourceShortName.filter({ (text:String) -> Bool in
            //return text.contains(searchText)
        //})
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // user did type something, check our datasource for text that looks the same
        if searchText.count > 0 {
            // search and reload data source
            searchBarActive = true
            self.filterContentForSearchText(searchText:searchText)
            self.collectionView.reloadData()
        } else {
            // if text lenght == 0
            // we will consider the searchbar is not active
            searchBarActive = false
            self.collectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self .cancelSearching()
        self.collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // we used here to set self.searchBarActive = YES
        // but we'll not do that any more... it made problems
        // it's better to set self.searchBarActive = YES when user typed something
        //self.iconsSearchBar.showsCancelButton = true
        StopShaking()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        searchBarActive = false
    }
    
    func cancelSearching(){
        searchBarActive = false
        self.iconsSearchBar.resignFirstResponder()
        self.iconsSearchBar.text = ""
    }
    
    //MARK:- Top panel methods.
    @IBAction func favouritesListAction(sender: UIButton) {
        
        if iconsShakingValue == "true" {
            StopShaking()
            SharingManager.sharedInstance.storyBoardID = "favouritesScreen"
            self.present(favouritesView, animated: false, completion: nil)
        } else {
            SharingManager.sharedInstance.storyBoardID = "favouritesScreen"
            self.present(favouritesView, animated: false, completion: nil)
        }
    }
    
    @IBAction func readLaterListAction(sender: UIButton) {
        
        if iconsShakingValue == "true" {
            StopShaking()
            SharingManager.sharedInstance.storyBoardID = "readLaterScreen"
            self.present(readLaterView, animated: false, completion: nil)
        } else {
            SharingManager.sharedInstance.storyBoardID = "readLaterScreen"
            self.present(readLaterView, animated: false, completion: nil)
        }
    }
    
    @IBAction func addingSiteAction(sender: UIButton) {
        
        if iconsShakingValue == "true" {
            StopShaking()
            self.present(addingSiteView, animated: false, completion: nil)
        } else {
            self.present(addingSiteView, animated: false, completion: nil)
        }
    }
    
    @IBAction func userDetailsAction(sender: UIButton) {
        
        if iconsShakingValue == "true" {
            StopShaking()
            self.present(userView, animated: false, completion: nil)
        } else {
            self.present(userView, animated: false, completion: nil)
        }
    }
    
    //MARK:- Bottom panel methods.
    @IBAction func homeAction(sender: UIButton) {
        
        if iconsShakingValue == "true" {
            StopShaking()
        } else {
            topPanelSliding = true
            collectionView.setContentOffset(.zero, animated: true)
        }
    }
    
    @IBAction func settingsScreenAction(sender: UIButton) {
        
        if iconsShakingValue == "true" {
            StopShaking()
            self.present(settingsView, animated: false, completion: nil)
        } else {
            self.present(settingsView, animated: false, completion: nil)
        }
    }
    
    @IBAction func reportScreenAction(sender: UIButton) {
        
        if iconsShakingValue == "true" {
            StopShaking()
            self.present(reportView, animated: false, completion: nil)
        } else {
            self.present(reportView, animated: false, completion: nil)
        }
    }
    
    @IBAction func tutorialAction(sender: UIButton) {
        
        if iconsShakingValue == "true" {
            StopShaking()
            self.present(tutorialViewView, animated: false, completion: nil)
        } else {
            self.present(tutorialViewView, animated: false, completion: nil)
        }
    }
    
    @IBAction func allocateTimeAction(sender: UIButton?) {
        
        let setHoursQuery = db.query(sql:"SELECT value FROM settings WHERE key='setHours'")
        let setHours = setHoursQuery[0]["value"] as! String
        let setMinutesQuery = db.query(sql:"SELECT value FROM settings WHERE key='setMinutes'")
        let setMinutes = setMinutesQuery[0]["value"] as! String
        customPickerView.reloadAllComponents()
        customPickerView.selectRow(hoursPickerValues.firstIndex(of: setHours)!, inComponent: 0, animated: true)
        customPickerView.selectRow(minutesPickerValues.firstIndex(of: setMinutes)!, inComponent: 1, animated: true)
        pickerConainerView.isHidden = false
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK:- Collection view methods.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //return items.count
        if (searchBarActive) {
            cellQuantity = dataSourceSearchedItemNames.count;
        } else {
//            let expectedPages: Double = (Double(itemsData.count)/Double(cellQuantityByDevice))
//            let totalPagesForCollectionView = ceil(expectedPages)
//            cellQuantity = Int(totalPagesForCollectionView) * cellQuantityByDevice
            cellQuantity = itemsData.count
            //print(cellQuantity)
        }
        
        return cellQuantity
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidthAndHeight: CGSize = CGSize(width: 70, height: 90)
        
        return cellWidthAndHeight
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! SocialCollectionViewCell
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MainViewController.handleLongGesture(gesture:)))
        longPress.minimumPressDuration = 0.3
        
        cell.isHidden = false
        cell.addGestureRecognizer(longPress)
        cell.deleteButton.tag = indexPath.item
        cell.deleteCellDelegate = self
        
        if indexPath.item < itemsData.count {
            
            if (searchBarActive) {
                cell.searchBarActive = true
                SharingManager.sharedInstance.itemName = dataSourceSearchedItemNames[indexPath.item]
//                cell.selectedIconLocationNumber = indexPath.item
                let rowQuery = db.query(sql:"SELECT * FROM item_details WHERE item_name='\( SharingManager.sharedInstance.itemName!)'")
                let rowInData =  rowQuery[0]
                let imageName = rowInData["item_image"] as! String //dataSourceForImageName[indexPath.item]
                let imageLocalStorage = rowInData["image_local_storage"] as! String
                if imageLocalStorage == "true" {
                    cell.iconImage.image = RepeatMethods.getImageFromLocalStorage(imageName:imageName)
                } else {
                    cell.iconImage.image = UIImage(named: imageName)
                }
                iconImages[indexPath.item] = cell.iconImage
                cell.iconLabel.text = rowInData["item_name"] as! String //dataSourceForLabelName[indexPath.item]
                iconDeleteButtons[indexPath.item] = cell.deleteButton
                iconViews[indexPath.item] = cell.iconView
            } else {
                cell.searchBarActive = false
                let rowInData =  itemsData[indexPath.item]
                SharingManager.sharedInstance.itemName = rowInData["item_name"] as! String
//                cell.selectedIconLocationNumber = indexPath.item
                let imageName = rowInData["item_image"] as! String //dataSourceForImageName[indexPath.item]
                //Getting image from local storage.
                cell.iconImage.image = RepeatMethods.getImageFromLocalStorage(imageName:imageName)
                
                iconImages[indexPath.item] = cell.iconImage
                cell.iconLabel.text = rowInData["item_name"] as! String //dataSourceForLabelName[indexPath.item]
                iconDeleteButtons[indexPath.item] = cell.deleteButton
                iconViews[indexPath.item] = cell.iconView
                
                //Applying or removing shaking animation.
                iconDeleteButtons[indexPath.item].isHidden = true
                iconViews[indexPath.item].layer.removeAllAnimations()
                if iconsShakingValue == "true" {
                    let vibrateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                    vibrateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    vibrateAnimation.fromValue =  M_PI / 96 //0.07
                    vibrateAnimation.toValue = -(M_PI / 96) //-0.07
                    vibrateAnimation.autoreverses = true
                    vibrateAnimation.duration = 0.1
                    vibrateAnimation.repeatCount = FLT_MAX
                    iconDeleteButtons[indexPath.item].isHidden = false
                    iconViews[indexPath.item].layer.add(vibrateAnimation, forKey: "kVibrateAnimation")
                } else {
                    iconDeleteButtons[indexPath.item].isHidden = true
                    iconViews[indexPath.item].layer.removeAllAnimations()
                }
            }
        } else {
            cell.removeGestureRecognizer(longPress)
            cell.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        destinationPathItemFromMethod = destinationIndexPath.item
        //print("Move Method " + String(destinationPathItemFromMethod))
        let numberForComparison: Int = Int(itemsData.count) - 1
        if destinationIndexPath.item > numberForComparison {
            collectionView.reloadData()
        } else {
            let tmpHold = dataSourceForSearch.remove(at: sourceIndexPath.item)
            dataSourceForSearch.insert(tmpHold, at: destinationIndexPath.item)
            //Loop to update item location number.
            for indexA in 0 ..< dataSourceForSearch.count  {
                let itemName = dataSourceForSearch[indexA]
                _ = db.execute(sql: "UPDATE item_details SET item_location_no='\(indexA)' WHERE item_name='\(itemName)'")
            }
            itemsData = (db.query(sql:"SELECT * FROM item_details ORDER BY item_location_no ASC"))
            //collectionView.reloadData() //If get bugs work, remove this line.
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Did select working")
        // handle tap events
        if indexPath.item < itemsData.count {
            if (searchBarActive) {
                //Assigning values to default storage.
                SharingManager.sharedInstance.itemName = dataSourceSearchedItemNames[indexPath.item]
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemName, forKey: "itemName")
                let rowQuery = db.query(sql:"SELECT * FROM item_details WHERE item_name='\(SharingManager.sharedInstance.itemName!)'")
                let rowInData =  rowQuery[0]
                SharingManager.sharedInstance.itemImageName = rowInData["item_image"] as! String
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemImageName, forKey: "itemImageName")
                SharingManager.sharedInstance.itemFormalURL = rowInData["item_link"] as! String
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemFormalURL, forKey: "itemFormalURL")
            } else {
                //Assigning values to default storage.
                let rowInData =  itemsData[indexPath.item]
                SharingManager.sharedInstance.itemName = rowInData["item_name"] as! String //dataSourceForImageName[indexPath.item]
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemName, forKey: "itemName")
                SharingManager.sharedInstance.itemImageName = rowInData["item_image"] as! String
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemImageName, forKey: "itemImageName")
                SharingManager.sharedInstance.itemFormalURL = rowInData["item_link"] as! String
                General.storageDefaults.setValue(SharingManager.sharedInstance.itemFormalURL, forKey: "itemFormalURL")
            }
            if iconsShakingValue == "true" {
                
                StopShaking()
                present(editingSiteView, animated: false, completion: nil)
            } else {
                //For daily social time utilization value
                let dailyTimeUtilizationQuery = db.query(sql:"SELECT value FROM settings WHERE key='dailySocialTimeUtilization'")
                let dailyTimeUtilization = dailyTimeUtilizationQuery[0]["value"] as! String
                //For set time reminder value
                let setTimerMessageQuery = db.query(sql:"SELECT value FROM settings WHERE key='timerSettingMessageDisplay'")
                let setTimerMessageValue = setTimerMessageQuery[0]["value"] as! String
                
                if dailyTimeUtilization == "false" && setTimerMessageValue == "false" {
                    //Going to site screen.
                    SharingManager.sharedInstance.storyBoardID = "siteScreen"
                    General.storageDefaults.setValue(SharingManager.sharedInstance.storyBoardID, forKey: "storyBoardID")
                    present(siteWebView, animated: false, completion: nil)
                } else {
                    //For daily social time value
                    let dbTimeQuery = db.query(sql:"SELECT value FROM settings WHERE key='dailySocialTime'")
                    let dbTime = dbTimeQuery[0]["value"] as! String
                    
                    if Int(dbTime)! == 0 {
                        //Calling alert to show message to set timer.
                        alertForSettingTimerFirst()
                    } else if Int(dbTime)! != 0 && dailyTimeUtilization == "false" && setTimerMessageValue == "true" {
                        //Reminder mmessage for first time to show set timer
                        //Calling alert to confirm social time for today
                        alertForConfirmingTodaysSocialTime()
                    } else if Int(dbTime)! != 0 && dailyTimeUtilization == "true" {
                        let todaysDate = Date().asStringDate()
                        let dbDateQuery = db.query(sql:"SELECT value FROM settings WHERE key='timerDate'")
                        let dbDate = dbDateQuery[0]["value"] as! String
                        if dbDate == todaysDate {
                            //Calling alert for reminding of finished social time for today.
                            alertForFinishedSocialTime()
                        } else {
                            //Updating records in settings table.
                            _ = db.execute(sql: "UPDATE settings SET value='\(todaysDate)' WHERE key='timerDate'")
                            _ = db.execute(sql: "UPDATE settings SET value='false' WHERE key='dailySocialTimeUtilization'")
                            _ = db.execute(sql: "UPDATE settings SET value='true' WHERE key='timerSettingMessageDisplay'")
                            //Calling alert to confirm social time for today
                            alertForConfirmingTodaysSocialTime()
                        }
                    }
                }
            } //Second if
        } else {
            //...
        }
    }
    
    //MARK:- Long press and drag and drop.
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        if (searchBarActive) {
            //...
        } else {
            if iconsShakingValue == "true" {
                
            } else {
                shakingIcons()
            }
            switch(gesture.state) {
            case UIGestureRecognizerState.began:
                //Checking for indexPath in collection view.
                guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                    break
                }
                indexPathItem = selectedIndexPath.item
                collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            case UIGestureRecognizerState.changed:
                //Checking for indexPath in collection view.
                guard let movedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                    break
                }
                destinationPathItem = movedIndexPath.item
                //collectionView.updateInteractiveMovementTargetPosition(gesture.locationInView(gesture.view!))
                collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: self.collectionView))
                //print(destinationPathItem)
            case UIGestureRecognizerState.ended:
                collectionView.endInteractiveMovement()
                /*//print(destinationPathItem)
                let numberForComparison: Int = Int(itemsData.count) - 1
                if destinationPathItem > numberForComparison {
                    print("Cancel tapped.")
                    collectionView.cancelInteractiveMovement()
                    //_ = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "getActualMoved", userInfo: nil, repeats: false)
                } else {
                    print("Moved tapped.")
                    collectionView.endInteractiveMovement()
                    //_ = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "getActualMoved", userInfo: nil, repeats: false)
                }
                //collectionView.endInteractiveMovement()
                /*//Loop to update item location number.
                for var indexA = 0; indexA < dataSourceForSearch.count ; ++indexA {
                let itemName = dataSourceForSearch[indexA]
                _ = db.execute(sql: "UPDATE item_details SET item_location_no='\(indexA)' WHERE item_name='\(itemName)'")
                }
                //Updating itemsData variable.
                itemsData = db.query(sql:"SELECT * FROM item_details ORDER BY item_location_no ASC")
                //collectionView.reloadData()*/*/
            default:
                collectionView.cancelInteractiveMovement()
            }
        }
    }
    
    func shakingIcons() {
        
        iconsShakingValue = "true"
        General.storageDefaults.setValue(iconsShakingValue, forKey: "iconsShakingKey")
        
        for indexA in 0 ..< itemsData.count  {
            let vibrateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            vibrateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            vibrateAnimation.fromValue =  M_PI / 96 //0.07
            vibrateAnimation.toValue = -(M_PI / 96) //-0.07
            vibrateAnimation.autoreverses = true
            vibrateAnimation.duration = 0.1
            vibrateAnimation.repeatCount = FLT_MAX
            iconDeleteButtons[indexA].isHidden = false
            iconViews[indexA].layer.add(vibrateAnimation, forKey: "kVibrateAnimation")
        }
    }
    
    func StopShaking() {
        
        iconsShakingValue = "false"
        General.storageDefaults.setValue(iconsShakingValue, forKey: "iconsShakingKey")
        
        for indexA in 0 ..< itemsData.count  {
            iconDeleteButtons[indexA].isHidden = true
            iconViews[indexA].layer.removeAllAnimations() //.removeAnimationForKey("kVibrateAnimation")
        }
    }
}

extension MainViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: Picker view methods for allocate time.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        var pickerValues: Int = 0
        if component == 0 {
            pickerValues = hoursPickerValues.count
            return pickerValues
        } else {
            pickerValues = minutesPickerValues.count
            return pickerValues
        }
        
        return pickerValues
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var attributedString: NSAttributedString!
        if component == 0 {
            attributedString = NSAttributedString(string: hoursPickerValues[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            return attributedString
        } else {
            attributedString = NSAttributedString(string: minutesPickerValues[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            return attributedString
        }
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
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
            //Updating remaining time label if needed.
            UpdatingRemainingTimeLabel()
            /*General.remainingTimeInSeconds = dailySocialTime
            General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
            //Assigning time to label.
            let remainingTimeString: String  = (CommonUtilities.secondsToHoursMinutesSeconds(General.remainingTimeInSeconds)) + "-"
            remainingTimeLabel.text = remainingTimeString */
            //print(dailySocialTime)
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
            //Updating remaining time label if needed.
            UpdatingRemainingTimeLabel()
            /*General.remainingTimeInSeconds = dailySocialTime
            General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
            //Assigning time to label.
            let remainingTimeString: String  = (CommonUtilities.secondsToHoursMinutesSeconds(General.remainingTimeInSeconds)) + "-"
            remainingTimeLabel.text = remainingTimeString*/
            //print(dailySocialTime)
        }
    }
    
    @IBAction func pickerViewDoneAction(sender: UIButton) {
        
        //For remaining time label in main screen top corner.
        let setTimerMessageQuery = db.query(sql:"SELECT value FROM settings WHERE key='timerSettingMessageDisplay'")
        let setTimerMessageValue = setTimerMessageQuery[0]["value"] as! String
        
        if setTimerMessageValue == "false" {
            alertForSetSocialTime()
        }
        pickerConainerView.isHidden = true
    }
}

extension MainViewController: MainViewCellDelegate {
    
    func deleteCellPressButton(_ tag: Int) {
        print(tag)
        print("Delete Action")
        iconImages.remove(at: tag)
        iconDeleteButtons.remove(at: tag)
        iconViews.remove(at: tag)
        let iconName = dataSourceForSearch.remove(at: tag)
        _ = db.execute(sql: "DELETE FROM item_details WHERE item_name='\(iconName)'")
        //Loop to update item location number.
        for indexA in 0 ..< dataSourceForSearch.count  {
            let itemName = dataSourceForSearch[indexA]
            _ = db.execute(sql: "UPDATE item_details SET item_location_no='\(indexA)' WHERE item_name='\(itemName)'")
        }
        refreshingCollectionView()
    }
}
