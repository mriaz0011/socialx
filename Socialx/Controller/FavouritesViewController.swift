//
//  FavouritesViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 13/05/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets.
    @IBOutlet weak var favouriteTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    //variables.
    var indexArray = ["test1", "test1", "test1"]
    var favouritesData = [[String:Any]]()
    var siteWebView:UIViewController = UIViewController()
    //Story board
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Aspect fit for buttons.
        backButton.imageEdgeInsets.left = -55.0
        backButton.imageView!.contentMode = .scaleAspectFit
        
        siteWebView = storyBoard.instantiateViewController(withIdentifier: "siteScreen")
        
        //Registering with UITABLEVIEWCELL class.
        favouriteTableView.delegate = self
        favouriteTableView.dataSource = self
        favouriteTableView.backgroundColor = nil
        favouriteTableView.tableFooterView = UIView(frame: .zero) //Hiding blank cells.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        favouritesData = db.query(sql:"SELECT * FROM item_details WHERE favourite_status='YES' ORDER BY item_location_no ASC")
        favouriteTableView.reloadData()
        if SharingManager.sharedInstance.storyBoardID == "mainScreen" {
            dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func back(sender: UIButton) {
        
        SharingManager.sharedInstance.storyBoardID = "mainScreen"
        General.storageDefaults.setValue(SharingManager.sharedInstance.storyBoardID, forKey: "storyBoardID")
        dismiss(animated: false, completion: nil)
    }
    
    func reminderAlert() {
        
        let alertVC = UIAlertController(title: "Reminder!", message: "You have already spent your allocated time.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { action -> Void in
            //Code.
            })
        alertVC.addAction(UIAlertAction(title: "RESET", style: UIAlertAction.Style.default)
        { action -> Void in
            //Resetting timer.
            let dailySocialTimeQuery = db.query(sql:"SELECT value FROM settings WHERE key='dailySocialTime'")
            let dailySocialTime: Int = Int(dailySocialTimeQuery[0]["value"] as! String)!
            General.remainingTimeInSeconds = dailySocialTime
            General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
            })
        present(alertVC, animated: true, completion: nil)
    }
    
    //MARK:- Table View Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favouritesData.count
    }
    
    //This function for cell separator settings.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var totalCellHeight: CGFloat!
        totalCellHeight = 55
        
        return totalCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouritesCell") as! FavouritesTableViewCell
        
        let rowInData =  favouritesData[indexPath.row]
        let siteImageName = rowInData["item_image"] as! String
        print(indexPath.row)
        cell.siteImage.image = RepeatMethods.getImageFromLocalStorage(imageName:siteImageName)
        cell.siteNameLabel.text = rowInData["item_name"] as! String
        cell.siteUrlLabel.text = rowInData["item_link"] as! String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dbTimeQuery = db.query(sql:"SELECT value FROM settings WHERE key='dailySocialTime'")
        let dbTime = dbTimeQuery[0]["value"] as! String
        
        let rowInData =  favouritesData[indexPath.row]
        SharingManager.sharedInstance.itemName = rowInData["item_name"] as! String //dataSourceForImageName[indexPath.item]
        General.storageDefaults.setValue(SharingManager.sharedInstance.itemName, forKey: "itemName")
        SharingManager.sharedInstance.itemImageName = rowInData["item_image"] as! String
        General.storageDefaults.setValue(SharingManager.sharedInstance.itemImageName, forKey: "itemImageName")
        SharingManager.sharedInstance.itemFormalURL = rowInData["item_link"] as! String
        General.storageDefaults.setValue(SharingManager.sharedInstance.itemFormalURL, forKey: "itemFormalURL")
        
        if Int(dbTime)! == 0 {
            SharingManager.sharedInstance.storyBoardID = "siteScreen"
            General.storageDefaults.setValue(SharingManager.sharedInstance.storyBoardID, forKey: "storyBoardID")
            present(siteWebView, animated: false, completion: nil)
        } else {
            //print(General.remainingTimeInSeconds)
            if General.remainingTimeInSeconds == 0 {
                let todaysDate = Date().asStringDate()
                let dbDateQuery = db.query(sql:"SELECT value FROM settings WHERE key='timerDate'")
                let dbDate = dbDateQuery[0]["value"] as! String
                if dbDate == todaysDate {
                    reminderAlert()
                } else {
                    let dbTimeQuery = db.query(sql:"SELECT value FROM settings WHERE key='dailySocialTime'")
                    let dbTime = dbTimeQuery[0]["value"] as! String
                    General.remainingTimeInSeconds = Int(dbTime)!
                    General.storageDefaults.set(General.remainingTimeInSeconds, forKey: "General.remainingTimeInSeconds")
                    _ = db.execute(sql: "UPDATE settings SET value='\(todaysDate)' WHERE key='timerDate'")
                    SharingManager.sharedInstance.storyBoardID = "siteScreen"
                    General.storageDefaults.setValue(SharingManager.sharedInstance.storyBoardID, forKey: "storyBoardID")
                    present(siteWebView, animated: false, completion: nil)
                }
            } else {
                SharingManager.sharedInstance.storyBoardID = "siteScreen"
                General.storageDefaults.setValue(SharingManager.sharedInstance.storyBoardID, forKey: "storyBoardID")
                present(siteWebView, animated: false, completion: nil)
            }
        }
    }
    
    //To enable editing row in table view
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            let rowInData = favouritesData[indexPath.row]
            let sNo = rowInData["s_no"] as! Int
            _ = db.execute(sql: "UPDATE item_details SET favourite_status='NO' WHERE s_no ='\(sNo)'")
            favouritesData.remove(at: indexPath.row)
            favouriteTableView.deleteRows(at: [indexPath], with: .fade)
            favouriteTableView.reloadData()
        }
    }
}
