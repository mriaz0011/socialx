//
//  AppDelegate.swift
//  socialx
//
//  Created by Muhammad Riaz on 26/01/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit

//Creating instance of database class.
let db = SQLiteDB.sharedInstance

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Preventing screen lock.
        UIApplication.shared.isIdleTimerDisabled = true
        
        
        //First time writing keys in defaults.
        if let keysInitializationCheck = General.storageDefaults.string(forKey: "keysInitializationForVersion1.1Build1") { //Put new key
            print(keysInitializationCheck)
            SharingManager.sharedInstance.itemName = General.storageDefaults.string(forKey: "itemName")
            SharingManager.sharedInstance.itemFormalURL = General.storageDefaults.string(forKey: "itemFormalURL")
            SharingManager.sharedInstance.itemImageName = General.storageDefaults.string(forKey: "itemImageName")
            SharingManager.sharedInstance.itemDomainNameOnly = General.storageDefaults.string(forKey: "itemDomainNameOnly")
            General.remainingTimeInSeconds = General.storageDefaults.integer(forKey: "General.remainingTimeInSeconds")
            SharingManager.sharedInstance.storyBoardID = General.storageDefaults.string(forKey: "storyBoardID")
        } else {
            //Condition to remove old keys.
            if (General.storageDefaults.string(forKey: "keysInitializationForVersion1Build59") != nil) { //Put old key
                //Deleting stored storage defaults values first.
                UserDefaults.standard.removeObject(forKey: "keysInitializationForVersion1Build59") //Put old key
                //For old database for key: keysInitializationForVersion1Build59
                _ = db.execute(sql: "INSERT INTO settings (key, value) VALUES ('dailySocialTimeUtilization', 'true')")
                _ = db.execute(sql: "INSERT INTO settings (key, value) VALUES ('timerSettingMessageDisplay', 'true')")
                //Now initializing new keys.
                General.storageDefaults.setValue("Default keys initiated already.", forKey: "keysInitializationForVersion1.1Build1") //Put new key
                //Assign values to variables.
                SharingManager.sharedInstance.itemName = General.storageDefaults.string(forKey: "itemName")
                SharingManager.sharedInstance.itemFormalURL = General.storageDefaults.string(forKey: "itemFormalURL")
                SharingManager.sharedInstance.itemImageName = General.storageDefaults.string(forKey: "itemImageName")
                SharingManager.sharedInstance.itemDomainNameOnly = General.storageDefaults.string(forKey: "itemDomainNameOnly")
                General.remainingTimeInSeconds = General.storageDefaults.integer(forKey: "General.remainingTimeInSeconds")
                SharingManager.sharedInstance.storyBoardID = General.storageDefaults.string(forKey: "storyBoardID")
                print("Old keys removed. New keys initiated.")
            } else {
                
                //Initializing new keys.
                General.storageDefaults.setValue("Default keys initiated already.", forKey: "keysInitializationForVersion1.1Build1") //Put new key
                General.storageDefaults.setValue("Facebook", forKey: "itemName")
                General.storageDefaults.setValue("http://www.facebook.com", forKey: "itemFormalURL")
                General.storageDefaults.setValue("Facebook-Icon.png", forKey: "itemImageName")
                
                General.storageDefaults.setValue("facebook.com", forKey: "itemDomainNameOnly")
                General.storageDefaults.set(0, forKey: "General.remainingTimeInSeconds")
                General.storageDefaults.setValue("mainScreen", forKey: "storyBoardID")
                //Assign values to variables.
                SharingManager.sharedInstance.itemName = General.storageDefaults.string(forKey: "itemName")
                SharingManager.sharedInstance.itemFormalURL = General.storageDefaults.string(forKey: "itemFormalURL")
                SharingManager.sharedInstance.itemImageName = General.storageDefaults.string(forKey: "itemImageName")
                SharingManager.sharedInstance.itemDomainNameOnly = General.storageDefaults.string(forKey: "itemDomainNameOnly")
                General.remainingTimeInSeconds = General.storageDefaults.integer(forKey: "General.remainingTimeInSeconds")
                SharingManager.sharedInstance.storyBoardID = General.storageDefaults.string(forKey: "storyBoardID")
                
                _ = db.execute(sql: "UPDATE user_details SET email_address='user@demo.com', first_name='FirstName', last_name='LastName', age='18', verification_code='000000', email_verification_date='000000' WHERE s_no=1 ")
                _ = db.execute(sql: "UPDATE user_details SET profile_photo_name='profile_picture.png' WHERE s_no=1 ")
                _ = db.execute(sql: "UPDATE user_details SET email_verification_date='done' WHERE email_address='user@demo.com'")
                General.storageDefaults.set("true", forKey: "check")
                General.storageDefaults.set("None", forKey: "croppedImageName")
                print("Old keys doesn't exist. New keys initiated.")
            }
            //For copying local files if needed.
            copyingFilesAndDeletingThemFromMainBundle()
            /*//For second or later version/build
             deletingFilesFromMainBundle()*/
            
            //Copying new database from app's main bundle to app's document directory and remove from app's main bundle and remove old database file from app's document if exist.
            handlingDatabaseForNewVersion()
        }
        //print(NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys.count)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        passcodeScreenValidationStatus()
        
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
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        General.remainingTimeInSeconds = General.storageDefaults.integer(forKey: "General.remainingTimeInSeconds")
        if SharingManager.sharedInstance.storyBoardID == "siteScreen" {
            SharingManager.sharedInstance.dontReloadSiteURL = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshingView"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshingViewForMainScreen"), object: nil)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "passcodeCheck"), object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let events = event!.allTouches
        let touch = events!.first
        let location = touch!.location(in: self.window)
        let statusBarFrame = UIApplication.shared.statusBarFrame
        if statusBarFrame.contains(location) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "statusBarTouched"), object: nil)
        }
    }
    
    func passcodeScreenValidationStatus() {
        
        let passcodeValidationQuery = db.query(sql: "SELECT value FROM settings WHERE key='passcodeValidation'")
        let passcodeValidation: String = passcodeValidationQuery[0]["value"] as! String
        let passcodeScreenValidationQuery = db.query(sql: "SELECT value FROM settings WHERE key='passcodeScreenValidationStatus'")
        let passcodeScreenValidation: String = passcodeScreenValidationQuery[0]["value"] as! String
        
        if passcodeValidation == "ON" {
            switch (passcodeScreenValidation) {
            case "Passcode Validated":
                _ = db.execute(sql: "UPDATE settings SET value='Validate Passcode' WHERE key='passcodeScreenValidationStatus'")
                break
            case "Validate Passcode":
                //..
                break
            default:
                break
            }
        }
    }
    
    //This function will be placed and utilized when first build/version is published. For second or later version/build it is not required.
    func copyingFilesAndDeletingThemFromMainBundle() {
        
        var iconFileNames = ["Google-Search-Icon.png", "Google-News-Icon.png", "8tracks-Icon.png", "9gag-Icon.png", "51-Icon.png", "500px-Icon.png", "About.me-Icon.png", "Aim-App-Icon.png", "Aim-Icon.png", "Amazon-Icon.png", "Andrioid-Icon.png", "Answers-Icon.png", "Aol-Icon.png", "Apple-Icon.png", "Apple-Play-Store-Icon.png", "Arto-Icon.png", "Ask-Icon.png", "Ask.Fm-Icon.png", "Aws-Icon.png", "Baidu-Icon.png", "Basecamp-Icon.png", "Bebo-Icon.png", "Behance-Icon.png", "Bing-Icon.png", "Blinklist-Icon.png", "Blip-Icon.png", "Blogger-Icon.png", "Bloglovin-Icon.png", "Blogmark-Icon.png", "Break-Icon.png", "Buddypress-Icon.png", "BuzzFeed-Icon.png", "Buzznet-Icon.png", "Carbonmade-Icon.png", "Cargo-Collection-Icon.png", "CitySearch-Icon.png", "Coroflot-Icon.png", "Creative-market-Icon.png", "Dailymotion-Icon.png", "Delicious-Icon.png", "Designfloat-Icon.png", "Deviantart-Icon.png", "Digg-icon.png", "Diigo-Icon.png", "Disqus-Icon.png", "Dribbble-Icon.png", "Dropbox-Icon.png", "Dropr-Icon.png", "Dzone-Icon.png", "Ebay-Icon.png", "Edmodo-Icon.png", "Elance-Icon.png", "Email-Icon.png", "Enveto-Icon.png", "Etsy-Icon.png", "Eventbright-Icon.png", "Eventful-Icon.png", "Evernote-Icon.png", "Facebook-Icon.png", "Facetime-Icon.png", "Fc2-Icon.png", "Flickr-Icon.png", "Flipagram-Icon.png", "Flipboard-Icon.png", "Fotolog-Icon.png", "Foursquare-Icon.png", "Frendster-Icon.png", "Friendfeed-Icon.png", "Gamespot-Icon.png", "Github-Icon.png", "Goodreads-Icon.png", "Google-Drive-Icon.png", "Google-Playstore-Icon.png", "Google-Plus-Icon.png", "Gravatar-Icon.png", "Grooveshark-Icon.png", "Hi5-Icon.png", "HTML3-Icon.png", "HTML5-Icon.png", "Hulu-Icon.png", "Icq-Icon.png", "IGN-Icon.png", "iheart-Icon.png", "iHeartRadio-Icon.png", "IMDb-Icon.png", "Imgur-Icon.png", "IMVU-Icon.png", "Indiegogo-Icon.png", "Instagram-Icon.png", "Instapaper-Icon.png", "iTunes-Icon.png", "Kaixin-Icon.png", "kakaotalk-Icon.png", "Keek-Icon.png", "Kickstarter-Icon.png", "Kik-Icon.png", "Klout-Icon.png", "Kongregate-Icon.png", "Lastfm-Icon.png", "Line-Icon.png", "Linkedin-Icon.png", "Livejournal-Icon.png", "Livestream-Icon.png", "Mashable-Icon.png", "Mediafire-Icon.png", "Meetup-Icon.png", "Meneame-Icon.png", "Menuism-Icon.png", "Metacafe-Icon.png", "Myspace-Icon.png", "Netflix-Icon.png", "Netvibes-Icon.png", "Newsvine-Icon.png", "Ning-Icon.png", "Odnoklassniki-Ok-Icon.png", "ooVoo-Icon.png", "Pandora-Icon.png", "Path-Icon.png", "Paypal-Icon.png", "Periscope-Icon.png", "Pheed-Icon.png", "Photobucket-Icon.png", "PictureTrail-Icon.png", "Pinterest-Icon.png", "Plaxo-Icon.png", "PlayStation-Icon.png", "Plurk-Icon.png", "Polyvore-Icon.png", "QQ-Icon.png", "Quora-Icon.png", "Qzone-Icon.png", "Rakuten-Icon.png", "Rdio-Icon.png", "Redbubble-Icon.png", "Reddit-Icon.png", "Renren-Icon.png", "Reverbnation-Icon.png", "Rhapsody-Icon.png", "RSS-Icon.png", "Rutube-Icon.png", "Share-Icon.png", "Shazam-Icon.png", "Shots-Icon.png", "Shutterstock-Icon.png", "Sina-Icon.png", "Skyp-Qik-Icon.png", "Skype-Icon.png", "Slash-Dot-Icon.png", "Slideshare-Icon.png", "Smugmug-Icon.png", "Snapchat-Icon.png", "Society-Icon.png", "Sound-Cloud.png", "Specificfeeds-Icon.png", "Spotify-Icon.png", "Spring-me-Icon.png", "Squarespace-Icon.png", "Storie-Icon.png", "Stumbleupon-Icon.png", "Tagged-Icon.png", "Tango-Icon.png", "Taobao-icon.png", "Tapatalk-Icon.png", "Technorati-Icon.png", "TED-Icon.png", "ThisNext-Icon.png", "Tidal-Icon.png", "Topix-Icon.png", "Tout-Icon.png", "Travbuddy-Icon.png", "Tripadvisor-Icon.png", "Tudou-Icon.png", "Tuenti-Icon.png", "Tumblr-Icon.png", "Twitch-Icon.png", "Twitter-Icon.png", "Twylah-Icon.png", "Uber-Icon.png", "Urbanspoon-Icon.png", "Ustream-Icon.png", "Veoh-Icon.png", "Vessel-Icon.png", "Vevo-Icon.png", "Viber-Icon.png", "Viddlr-Icon.png", "Vimeo-Icon.png", "Vine-Icon.png", "VK-Icon.png", "Website-Icon.png", "Weheartit-Icon.png", "Weibo-Icon.png", "Whatsapp-Icon.png", "Whattpad-Icon.png", "Whisper-Icon.png", "Windows-Store-Icon.png", "Wix-Icon.png", "Wordpress-Icon.png", "Xango-Icon.png", "XBox-Icon.png", "Xing-Icon.png", "Yahoo-Icon.png", "Yelp-Icon.png", "Yonder-Icon.png", "Youku-Icon.png", "YouNow-Icon.png", "Youtube-Icon.png", "Zazzle-Icon.png", "style.css", "Anonymous-Icon.png", "profile_picture.png"]
        
        let fileManager = FileManager.default
        let mainPath = Bundle.main.bundlePath
        //let mainDirectoryURL: NSURL = NSURL.fileURLWithPath(path)
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        for indexA in 0 ..< iconFileNames.count  {
            let getImagePathForMainPath = mainPath.stringByAppendingPathComponent(iconFileNames[indexA])
            let setImagePathForDocumentPath = documentPath.stringByAppendingPathComponent(iconFileNames[indexA])
            
            //Copying image from main to app's document directory.
            if !(fileManager.fileExists(atPath: setImagePathForDocumentPath)) {
                try! fileManager.copyItem(atPath: getImagePathForMainPath, toPath: setImagePathForDocumentPath)
            }
        }
    }
    
    func handlingDatabaseForNewVersion() {
        
        let fileManager = FileManager.default
        //let mainPath = NSBundle.mainBundle().bundlePath
        //let mainDirectoryURL: NSURL = NSURL.fileURLWithPath(path)
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        //let databaseFileForAppDoc = documentPath.stringByAppendingPathComponent(DATABASE_NAME)
        //let databaseFileInAppMain = mainPath.stringByAppendingPathComponent(DATABASE_NAME)
        
        /*//For new database file.
         if fileManager.fileExistsAtPath(databaseFileForAppDoc) {
         //Remove from app's main.
         try! fileManager.removeItemAtPath(databaseFileInAppMain)
         } else {
         //Copying new file in app's doc.
         try! fileManager.copyItemAtPath(databaseFileInAppMain, toPath: databaseFileForAppDoc)
         print("New database file is copied in app's document.")
         //Then remove from app's main.
         //try! fileManager.removeItemAtPath(databaseFileInAppMain)
         }*/
        
        //For existing old version/build file.
        let oldDatabaseFileInAppDoc = documentPath.stringByAppendingPathComponent("socialex-v-1-build46.sqlite")
        if fileManager.fileExists(atPath: oldDatabaseFileInAppDoc) {
            try! fileManager.removeItem(atPath: oldDatabaseFileInAppDoc)
            print("Old database file is removed.")
        } else {
            print("Old database file is not found.")
        }
    }
    
    //This function will be placed and utilized when second or later build/version is published. For first version/build it is not required.
    func deletingFilesFromMainBundle() {
        
        let fileManager = FileManager.default
        let mainPath = Bundle.main.bundlePath
        
        for indexA in 0 ..< Icons.fileName.count  {
            let getImagePathForMainPath = mainPath.stringByAppendingPathComponent(Icons.fileName[indexA])
            //Deleting image from main
            print(Icons.fileName[indexA])
            try! fileManager.removeItem(atPath: getImagePathForMainPath)
        }
        
        
    }
}


