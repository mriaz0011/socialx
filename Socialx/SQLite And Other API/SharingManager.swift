//
//  SharingManager.swift
//  socialx
//
//  Created by Muhammad Riaz on 06/04/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit

class SharingManager {
    
    //MARK:- Declare variables here.
    //For web view
    var itemName: String!
    var itemFormalURL: String!
    var itemImageName: String!
    var itemDomainNameOnly: String!
    var startTime: NSDate!
    var saveRecord: Bool = false
    var dontReloadSiteURL: Bool = false
    //For delete icon
    var selectedIconNumber: Int!
    //Timer
    var timer = Timer()
    var remainingTimeInSeconds: Int = 0
    //Screen restoration.
    var storyBoardID: String!
    //For tutorial content value
    var tutorialContent: String = ""
    //For holding contacts
    var contactsData: (rFullNames: [String], rEmails: [String], rSelectEmail:[Bool], rImagesData:[(Bool, UIImage, String, UIColor)])!
    //For adding site
    var urlAddressForAdd: String = ""
    //For share socialx screen skip button title
    var skipTOShareLaterValueForButtonTitle: String = "Skip"
    
    //Instance to access declared variables.
    static let sharedInstance = SharingManager()
    
}
