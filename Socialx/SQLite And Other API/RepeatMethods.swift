//
//  RepeatMethods.swift
//  socialx
//
//  Created by Muhammad Riaz on 01/02/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//
import Foundation
import UIKit
import WebKit

@objc class RepeatMethods: NSObject {
    
    class func recordSpentTime(mEndTime: Date, mItemName: String, mItemLink: String, mItemImageNme: String) {
        
        //var itemImage: String = "Anonymous-Icon.png"
        let imageLocalStorage: String = "false"
        
        let date8Digit = Date().asStringDate()
        let dateLongString = Date().asLongString()
        let year4Digit = Date().asStringYear
        let weekNumber = Date().asStringWeek
        let monthFull = Date().asStringMonth
        let totalSpentTimeInSeconds = Int(mEndTime.timeIntervalSince(General.startTime as Date))
        let startTimeFull = General.startTime.asStringTimeFull
        let endTimeFull = mEndTime.asStringTimeFull
        
        _ = db.execute(sql: "INSERT INTO report_details (item_name, item_link, item_image, image_local_storage, date_8digit, date_string, year_4digit, week_no, month, start_time, end_time, total_time) VALUES ('\(mItemName)', '\(mItemLink)', '\(mItemImageNme)', '\(imageLocalStorage)', '\(date8Digit)', '\(dateLongString)', '\(year4Digit)', '\(weekNumber)', '\(monthFull)', '\(startTimeFull)', '\(endTimeFull)', '\(totalSpentTimeInSeconds)')")
    }
    
    //Email validation.
    class func isValidEmail(testStr:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluate(with: testStr)
        
        return result
        
    }
    
    class func makingFormalURL(urlString: String) -> String {
        
        if urlString != "" {
            var urlWithHTTPS: String = ""
            if urlString.range(of: "http://") != nil {
                urlWithHTTPS = urlString
            } else if urlString.range(of: "https://") != nil {
                urlWithHTTPS = urlString
            } else {
                urlWithHTTPS = "http://" + urlString
            }
            return urlWithHTTPS
        }
        return ""
    }
    
    class func captureWebViewScreen(webView: WKWebView) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: webView.frame.size.width, height: webView.frame.size.height ))
        webView.drawHierarchy(in: webView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //Saving image in local storage.
    @objc class func savingImageLocally(selectedImage: UIImage) -> String {
        
        //let circularImage = selectedImage.circle
        let fileName = "image_\(NSDate.timeIntervalSinceReferenceDate).png"
        //let keyName = "img_\(NSDate.timeIntervalSinceReferenceDate())"
        let imageData = selectedImage.pngData()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let imagePath = paths.stringByAppendingPathComponent(fileName)
        
        do {
            try imageData!.write(to: URL(fileURLWithPath: imagePath), options: .atomic)
            print(fileName)
        } catch {
            print(error)
            print("Image not saved.")
        }
        return fileName
    }
    
    //Getting image from local storage.
    class func getImageFromLocalStorage(imageName: String) -> UIImage {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let fullPath = paths.stringByAppendingPathComponent(imageName)
        
        if(!fullPath.isEmpty){
            let image = UIImage(contentsOfFile: fullPath)
            if(image != nil){
                return image!;
            }
        }
        return UIImage(named: "Google-Plus-Icon-demo.png")!
    }
    
    //Deleting existing local files.
    class func deletingImageLocally(imageName: String) {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let getImagePath = paths.stringByAppendingPathComponent(imageName)
        
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: getImagePath)) {
            do {
                try fileManager.removeItem(atPath: getImagePath)
                print("File deleted.")
            } catch {
                print("File exist but not deleted.")
            }
        } else {
            print("No file to delete.")
        }
    }
    
    class func selectedCropImageBoundry(boundryValue: String) -> String {
                
        return boundryValue
    }
}
