//
//  General.swift
//  Socialx
//
//  Created by Muhammad Riaz on 31/01/2021.
//

import Foundation

struct General {
    
    static let storageDefaults = UserDefaults.standard
    //Creating instance of database class.
    static let db = SQLiteDB.sharedInstance
    //For web view
    static var startTime: Date!
    static var saveRecord: Bool = false
    //Timer
    static var timer = Timer()
    static var remainingTimeInSeconds: Int = 0
}
