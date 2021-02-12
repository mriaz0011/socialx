//
//  CommonUtilities.swift
//  socialx
//
//  Created by Muhammad Riaz on 18/01/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit

class CommonUtilities: NSObject {
    
    class func webColor(_ hexString: String) -> UIColor { //CommonUtilities.webColor("#c195fd")
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    class func secondsToHoursMinutesSeconds (_ timeInSeconds: Int) -> String {
        
        let hours = timeInSeconds/3600
        let minutes = (timeInSeconds % 3600) / 60
        let seconds = (timeInSeconds % 3600) % 60
        let timeAsString = NSString(format:"%02d:%02d:%02d", hours, minutes, seconds)
        return timeAsString as String
    }
    
    class func numbersWithoutDecimal(_ numbersWithDecimal: CGFloat) -> CGFloat {
        
        let cleanValue: String = String(format: "%.0f", numbersWithDecimal)
        let numbers:CGFloat = CGFloat(Double(cleanValue)!)
        
        return numbers
    }
}

//MARK:- UIImage
extension UIImage {
    var rounded: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/9
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

//MARK:- UIButton
extension UIButton {
    var rounded: UIButton? {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        return self
    }
    var circle: UIButton? {
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.layer.masksToBounds = true
        return self
    }
}

//MARK:- UILabel
extension UILabel {
    
    var rounded: UILabel? {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        return self
    }
    
    var circle: UILabel? {
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.layer.masksToBounds = true
        return self
    }
    
    func border(_ thickness: Int, color: UIColor, corner: Int) {
        
        layer.borderColor = color.cgColor
        layer.borderWidth = CGFloat(thickness)
        layer.cornerRadius = CGFloat(corner)
    }
}

extension CALayer {  //Label.layer.addBorder(UIRectEdge.Top, color: UIColor.greenColor(),  0.5)
    
    func addTopBorder(_ color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: thickness)
        border.backgroundColor = color.cgColor
        self.addSublayer(border)
    }
    
    func addBottomBorder(_ color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
        border.backgroundColor = color.cgColor
        self.addSublayer(border)
    }
    
    func addLeftBorder(_ color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
        border.backgroundColor = color.cgColor
        self.addSublayer(border)
    }
    
    func addBorder(_ color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        border.frame = CGRect(x: thickness, y: thickness, width: thickness, height: thickness)
        //CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
        border.backgroundColor = color.cgColor
        self.addSublayer(border)
    }
    
    func makeCircle() {
        
        let border = CALayer()
        border.cornerRadius = 20
        self.addSublayer(border)
    }
}

//MARK:- UITextField
extension UITextField {
    
    func border(_ thickness: Int, color: UIColor, corner: Int) {
        
        layer.borderColor = color.cgColor
        layer.borderWidth = CGFloat(thickness)
        layer.cornerRadius = CGFloat(corner)
    }
    
    func makeCircle() {
        
        layer.cornerRadius = frame.size.width/2
    }
}

//MARK:- NSDate
extension Date
{
    
    var asStringMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    var asStringTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: self)
    }
    
    var asStringTimeFull: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        return dateFormatter.string(from: self)
    }
    
    var asStringYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }
    
    var asStringWeek: String {
        let iso8601 =  Calendar(identifier: Calendar.Identifier.iso8601)
        let dateComponent = (iso8601 as NSCalendar).components([.weekOfYear, .day, .month, .year], from:self)
        let weekNumber = String(describing: dateComponent.weekOfYear!)
        return weekNumber
    }
    
    var getWeekFirstDateString: String {
        let iso8601 =  Calendar(identifier: Calendar.Identifier.iso8601)
        let date = iso8601.date(from: (iso8601 as NSCalendar).components([.yearForWeekOfYear, .weekOfYear], from: self))!
        return date.asStringDate()
    }
    
    var getWeekFirstDate: Date {
        let iso8601 =  Calendar(identifier: Calendar.Identifier.iso8601)
        let date = iso8601.date(from: (iso8601 as NSCalendar).components([.yearForWeekOfYear, .weekOfYear], from: self))!
        return date
    }
    
    var getWeekLastDateString: String {
        let iso8601 =  Calendar(identifier: Calendar.Identifier.iso8601)
        let date = iso8601.date(from: (iso8601 as NSCalendar).components([.yearForWeekOfYear, .weekOfYear], from: self))!
        let lastDate = date.addDays(6)
        return lastDate.asStringDate()
    }
    
    var getWeekLastDate: Date {
        let iso8601 =  Calendar(identifier: Calendar.Identifier.iso8601)
        let date = iso8601.date(from: (iso8601 as NSCalendar).components([.yearForWeekOfYear, .weekOfYear], from: self))!
        let lastDate = date.addDays(6)
        return lastDate
    }
    
    var getMonthFirstDateString: String {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month], from: self)
        let firstDate = calendar.date(from: components)!
        return firstDate.asStringDate()
    }
    
    var getMonthFirstDate: Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month], from: self)
        let firstDate = calendar.date(from: components)!
        return firstDate
    }
    
    var getMonthLastDateString: String {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        let firstDate = self.getMonthFirstDate
        let lastDate = (calendar as NSCalendar).date(byAdding: components, to: firstDate, options: [])!
        return lastDate.asStringDate()
    }
    
    var getMonthLastDate: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        let firstDate = self.getMonthFirstDate
        let lastDate = (calendar as NSCalendar).date(byAdding: components, to: firstDate, options: [])!
        return lastDate
    }
    
    func asWeekNumberString() -> String { //Week 1, March 2016
        
        var currentWeekNumber: String!
        //Getting week.
        let weekNumber: String = self.asStringWeek
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ", MMMM YYYY"
        let currentDate: String = dateFormatter.string(from: self)
        currentWeekNumber = "Week \(weekNumber)\(currentDate)"
        
        return currentWeekNumber
    }
    
    func asLongString() -> String { //Wednesday, 27 January 2016
        
        var longDateForToday: String!
        //Getting date.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM YYYY"
        let currentDate: String = dateFormatter.string(from: self)
        longDateForToday = currentDate
        
        return longDateForToday
    }
    
    func asMediumString() -> String { //27 January 2016
        
        var longDateForToday: String!
        //Getting date.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY"
        let currentDate: String = dateFormatter.string(from: self)
        longDateForToday = currentDate
        
        return longDateForToday
    }
    
    func asStringDate() -> String { //2016-01-27
        
        var dateForToday: String!
        //Getting date.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let currentDate: String = dateFormatter.string(from: self)
        dateForToday = currentDate
        
        return dateForToday
    }
    
    func isEqualWithDay(_ dateToCompare : Date) -> Bool {
        //Declare Variables
        var isEqual = false
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let currentDay: String = dateFormatter.string(from: self)
        let compareDay: String = dateFormatter.string(from: dateToCompare)
        
        //Compare Values
        if currentDay == compareDay {
            isEqual = true
        }
        
        //Return Result
        return isEqual
    }
    
    func isGreaterThanDate(_ dateToCompare : Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(_ dateToCompare : Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    
    func isEqualWithDate(_ dateToCompare : Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame
        {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addMonths(_ monthsToAdd : Int) -> Date {
        let components = DateComponents()
        (components as NSDateComponents).setValue(monthsToAdd, forComponent: NSCalendar.Unit.month)
        let dateWithMonthsAdded : Date = (Calendar.current as NSCalendar).date(byAdding: components, to: self.addingTimeInterval(0), options: NSCalendar.Options(rawValue: 0))!
        
        //Return Result
        return dateWithMonthsAdded
    }
    
    func addWeeks(_ weeksToAdd : Int) -> Date {
        let secondsInDays : TimeInterval = Double(weeksToAdd*7) * 60 * 60 * 24
        let dateWithWeeksAdded : Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithWeeksAdded
    }
    
    func addDays(_ daysToAdd : Int) -> Date {
        let secondsInDays : TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    
    func addHours(_ hoursToAdd : Int) -> Date {
        let secondsInHours : TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    func addMinutes(_ minutesToAdd : Int) -> Date {
        let secondsInMinutes : TimeInterval = Double(minutesToAdd) * 60
        let dateWithMinutesAdded : Date = self.addingTimeInterval(secondsInMinutes)
        
        //Return Result
        return dateWithMinutesAdded
    }
}
