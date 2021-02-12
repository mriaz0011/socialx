//
//  ReportViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 27/01/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit
import WebKit

class ReportViewController: UIViewController, UIWebViewDelegate {
    
    //Outlets.
    @IBOutlet weak var reportWebView: WKWebView!
    @IBOutlet var reportSegmentControl: UISegmentedControl!
    @IBOutlet weak var reportHeadingLabel: UILabel!
    @IBOutlet weak var forwardReportButton: UIButton!
    @IBOutlet weak var backwardReportButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    //Variables.
    var selectedDateForReport: Date!
    var selectedSegmentControlValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Aspect fit for buttons.
        backButton.imageEdgeInsets.left = -55.0
        backButton.imageView!.contentMode = .scaleAspectFit
        
        //Changing height and font size of segmented control.
        //reportSegmentControl.frame.size.height = 22.0
        let attr = NSDictionary(object: UIFont(name: "Arial", size: 11.0)!, forKey: NSAttributedString.Key.font as NSCopying)
        UISegmentedControl.appearance().setTitleTextAttributes(attr as? [NSAttributedString.Key: Any], for: UIControl.State())

        //Method called to reload table when app running from background to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(ReportViewController.passcodeCheck(notification:)), name: NSNotification.Name(rawValue: "passcodeCheck"), object: nil)
        
        //Call to load view
        refreshingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    //Generating html page with images.
    func loadingHTMLReport(_ htmlString: String) {
        
        //For getting images from app itself to display images in UIWebView.
        let documentDirectoryURL =  try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        reportWebView.loadHTMLString(htmlString, baseURL: documentDirectoryURL)
        
        /*let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectoryURL: NSURL = urls.first! */
        //let path = NSBundle.mainBundle().bundlePath
        //let mainDirectoryURL: NSURL = NSURL.fileURLWithPath(path)
        //Loading html page in UIWebView.
        
    }
    
    func refreshingView() {
        
        //Setting defaults for segmented control and webview
        reportSegmentControl.selectedSegmentIndex = 0
        selectedSegmentControlValue = reportSegmentControl.selectedSegmentIndex
        //For showing daily report in webview
        selectedDateForReport = Date()
        let htmlReport = compilingDailyReport(date: selectedDateForReport)
        loadingHTMLReport(htmlReport)
        reportHeadingLabel.text = Date().asLongString()
        if selectedDateForReport.isEqualWithDay(Date()) {
            forwardReportButton.isEnabled = false
        }
    }
    
    //MARK:- Sub top panel
    @IBAction func backWardReportAction(sender: UIButton) {
        
        switch selectedSegmentControlValue {
        case 0:
            selectedDateForReport = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: selectedDateForReport, options: [])!
            let htmlReport = compilingDailyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asLongString()
            if selectedDateForReport.isEqualWithDay(Date()) {
                forwardReportButton.isEnabled = false
            } else {
                forwardReportButton.isEnabled = true
            }
            break
        case 1:
            selectedDateForReport = selectedDateForReport.getWeekFirstDate
            selectedDateForReport = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: selectedDateForReport, options: [])!
            let htmlReport = compilingWeeklyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asWeekNumberString()
            if selectedDateForReport.asWeekNumberString() == Date().asWeekNumberString() {
                forwardReportButton.isEnabled = false
            } else {
                forwardReportButton.isEnabled = true
            }
            break
        case 2:
            selectedDateForReport = selectedDateForReport.getMonthFirstDate
            selectedDateForReport = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: selectedDateForReport, options: [])!
            let htmlReport = compilingMonthlyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asStringMonth + " " + selectedDateForReport.asStringYear
            if (selectedDateForReport.asStringMonth + " " + selectedDateForReport.asStringYear) == (Date().asStringMonth + " " + Date().asStringYear) {
                forwardReportButton.isEnabled = false
            } else {
                forwardReportButton.isEnabled = true
            }
            break
        case 3:
            selectedDateForReport = (Calendar.current as NSCalendar).date(era: 1, year: (Calendar.current as NSCalendar).component(.year, from: selectedDateForReport), month: 1, day: -5, hour: 0, minute: 0, second: 0, nanosecond: 0)!
            let htmlReport = compilingYearlyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asStringYear
            if (selectedDateForReport.asStringYear) == (Date().asStringYear) {
                forwardReportButton.isEnabled = false
            } else {
                forwardReportButton.isEnabled = true
            }
            break
        case 4:
            break
        default:
            break
        }
    }
    
    @IBAction func forwardReportAction(sender: UIButton) {
        
        switch selectedSegmentControlValue {
        case 0:
            selectedDateForReport = (Calendar.current as NSCalendar).date(byAdding: .day, value: +1, to: selectedDateForReport, options: [])!
            let htmlReport = compilingDailyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asLongString()
            if selectedDateForReport.isEqualWithDay(Date()) {
                forwardReportButton.isEnabled = false
            } else {
                forwardReportButton.isEnabled = true
            }
            break
        case 1:
            selectedDateForReport = selectedDateForReport.getWeekLastDate
            selectedDateForReport = (Calendar.current as NSCalendar).date(byAdding: .day, value: +1, to: selectedDateForReport, options: [])!
            let htmlReport = compilingWeeklyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asWeekNumberString()
            if selectedDateForReport.asWeekNumberString() == Date().asWeekNumberString() {
                forwardReportButton.isEnabled = false
            } else {
                forwardReportButton.isEnabled = true
            }
            break
        case 2:
            selectedDateForReport = selectedDateForReport.getMonthLastDate
            selectedDateForReport = (Calendar.current as NSCalendar).date(byAdding: .day, value: +1, to: selectedDateForReport, options: [])!
            let htmlReport = compilingMonthlyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asStringMonth + " " + selectedDateForReport.asStringYear
            if (selectedDateForReport.asStringMonth + " " + selectedDateForReport.asStringYear) == (Date().asStringMonth + " " + Date().asStringYear) {
                forwardReportButton.isEnabled = false
            } else {
                forwardReportButton.isEnabled = true
            }
            break
        case 3:
            selectedDateForReport = (Calendar.current as NSCalendar).date(era: 1, year: (Calendar.current as NSCalendar).component(.year, from: selectedDateForReport), month: 12, day: 33, hour: 0, minute: 0, second: 0, nanosecond: 0)!
            let htmlReport = compilingYearlyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asStringYear
            if (selectedDateForReport.asStringYear) == (Date().asStringYear) {
                forwardReportButton.isEnabled = false
            } else {
                forwardReportButton.isEnabled = true
            }
            break
        case 4:
            break
        default:
            break
        }
    }
    
    //MARK:- All Time report methods.
    func partCompilationForAllTimeReport() -> String {
        
        var htmlTotalAllTimeYearsString: String = ""
        var reportContent: String = ""
        var totalTimeForGrandTotal: Int = 0
        var allTimeYearsTotalHTMLContent: String = ""
        allTimeYearsTotalHTMLContent = allTimeYearsTotalHTMLContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:40px;'><div style='float:left;display:block;width:100%;'><h3 style='margin-top:7px;font-size:14px;'><span style='text-align:center;font-weight: bold;'>Total Social Time Spent On Yearly Basis</span></h3></div></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Years</th><th>Total</th></tr></thead><tbody>"
        let yearsRowQuery = db.query(sql:"SELECT year_4digit, SUM(total_time) FROM report_details GROUP BY year_4digit")
        for indexA in 0 ..< yearsRowQuery.count {
            let rowData = yearsRowQuery[indexA]
            let year = rowData["year_4digit"] as! Int
            let sumTimeForReport = rowData["SUM(total_time)"] as! Int
            totalTimeForGrandTotal = totalTimeForGrandTotal + sumTimeForReport
            let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(sumTimeForReport)
            let sNoForReport = indexA + 1
            reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td>\(year)</td><td>\(sumTimeStringForReport)</td></tr>"
        }
        reportContent = reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
        let grandTotalString = CommonUtilities.secondsToHoursMinutesSeconds(totalTimeForGrandTotal)
        allTimeYearsTotalHTMLContent = allTimeYearsTotalHTMLContent + "<tr><td colspan='2'>Grand Total</td><td>\(grandTotalString)</td></tr>" + reportContent
        
        htmlTotalAllTimeYearsString = allTimeYearsTotalHTMLContent
        
        return htmlTotalAllTimeYearsString
    }
    
    func compilingAllTimeReport() -> String {
        
        var htmlWeeklyString: String = ""
        var reportContent: String = ""
        var totalTimeForGrandTotal: Int = 0
        var grandTotalHTMLContent: String = ""
        grandTotalHTMLContent = grandTotalHTMLContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:3px;'></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Site Name</th><th>Total</th></tr></thead><tbody>"
        let itemLinkQuery = db.query(sql: "SELECT item_name, item_image, item_link, SUM(total_time) FROM report_details GROUP BY item_name ORDER BY SUM(total_time) DESC")
        for indexA in 0 ..< itemLinkQuery.count {
            let rowData = itemLinkQuery[indexA]
            let itemNameForReport = rowData["item_name"] as! String
            let itemImageForReport = rowData["item_image"] as! String
            _ = rowData["item_link"] as! String
            let sumTimeForReport = rowData["SUM(total_time)"] as! Int
            totalTimeForGrandTotal = totalTimeForGrandTotal + sumTimeForReport
            let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(sumTimeForReport)
            let sNoForReport = indexA + 1
            //let grandTotalTime = String(CommonUtilities.secondsToHoursMinutesSeconds(sumTime))
            reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td><img src='\(itemImageForReport)' height='18' width='18'><br>\(itemNameForReport)</td><td>\(sumTimeStringForReport)</td></tr>"
        }
        let grandTotalString = CommonUtilities.secondsToHoursMinutesSeconds(totalTimeForGrandTotal)
        reportContent = grandTotalHTMLContent + "<tr><td colspan='2'>Grand Total</td><td>\(grandTotalString)</td></tr>" + reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
        
        reportContent = partCompilationForAllTimeReport() + reportContent
        
        if itemLinkQuery.count <= 0 {
            reportContent = "<div style='margin-top:300px;'><h1 style='font-family: Arial;'>No records to display.</h1></div>"
        }
        
        htmlWeeklyString = htmlWeeklyString + "<!DOCTYPE html><html><head><title>All Time Report</title><meta name='viewport' content='width=device-width, initial-scale=1'><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><link href='style.css' rel='stylesheet' type='text/css' media='all' /><link href='//fonts.googleapis.com/css?family=Cabin:400,400italic,500,500italic,600,600italic,700,700italic' rel='stylesheet' type='text/css'><link href='//fonts.googleapis.com/css?family=Cinzel:400,700,900' rel='stylesheet' type='text/css'></head><body><div class='main'>\(reportContent)</div></body></html>"
        
        return htmlWeeklyString
    }
    
    //MARK:- Yearly report methods.
    func partCompilationForYearlyReport(date: Date) -> String {
        
        var htmlTotalYearlyDaysString: String = ""
        var reportContent: String = ""
        let year = date.asStringYear
        let months: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        var totalTimeForGrandTotal: Int = 0
        var yearlyDaysTotalHTMLContent: String = ""
        yearlyDaysTotalHTMLContent = yearlyDaysTotalHTMLContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:40px;'><div style='float:left;display:block;width:100%;'><h3 style='margin-top:7px;font-size:14px;'><span style='text-align:center;font-weight: bold;'>Yearly Total Social Time Spent On Monthly Basis</span></h3></div></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Month</th><th>Total</th></tr></thead><tbody>"
        for indexA in 0 ..< months.count {
            let monthForQuery = months[indexA]
            let monthRowQuery = db.query(sql:"SELECT SUM(total_time) FROM report_details WHERE year_4digit='\(year)' AND month='\(monthForQuery)' GROUP BY month")
            if monthRowQuery.count <= 0 {
                let sNoForReport = indexA + 1
                let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(0)
                reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td>\(monthForQuery)</td><td>\(sumTimeStringForReport)</td></tr>"
            } else {
                let rowData = monthRowQuery[0]
                let sumTimeForReport = rowData["SUM(total_time)"] as! Int
                totalTimeForGrandTotal = totalTimeForGrandTotal + sumTimeForReport
                let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(sumTimeForReport)
                let sNoForReport = indexA + 1
                reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td>\(monthForQuery)</td><td>\(sumTimeStringForReport)</td></tr>"
            }
        }
        reportContent = reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
        let grandTotalString = CommonUtilities.secondsToHoursMinutesSeconds(totalTimeForGrandTotal)
        yearlyDaysTotalHTMLContent = yearlyDaysTotalHTMLContent + "<tr><td colspan='2'>Grand Total</td><td>\(grandTotalString)</td></tr>" + reportContent
        
        htmlTotalYearlyDaysString = yearlyDaysTotalHTMLContent
        
        return htmlTotalYearlyDaysString
    }
    
    func compilingYearlyReport(date: Date) -> String {
        
        var htmlWeeklyString: String = ""
        var reportContent: String = ""
        let selectedYearForReport = date.asStringYear
        var totalTimeForGrandTotal: Int = 0
        var grandTotalHTMLContent: String = ""
        grandTotalHTMLContent = grandTotalHTMLContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:3px;'></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Site Name</th><th>Total</th></tr></thead><tbody>"
        let itemLinkQuery = db.query(sql:"SELECT item_name, item_image, item_link, SUM(total_time) FROM report_details WHERE year_4digit='\(selectedYearForReport)' GROUP BY item_name ORDER BY SUM(total_time) DESC")
        for indexA in 0 ..< itemLinkQuery.count {
            let rowData = itemLinkQuery[indexA]
            let itemNameForReport = rowData["item_name"] as! String
            let itemImageForReport = rowData["item_image"] as! String
            _ = rowData["item_link"] as! String
            let sumTimeForReport = rowData["SUM(total_time)"] as! Int
            totalTimeForGrandTotal = totalTimeForGrandTotal + sumTimeForReport
            let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(sumTimeForReport)
            let sNoForReport = indexA + 1
            //let grandTotalTime = String(CommonUtilities.secondsToHoursMinutesSeconds(sumTime))
            reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td><img src='\(itemImageForReport)' height='18' width='18'><br>\(itemNameForReport)</td><td>\(sumTimeStringForReport)</td></tr>"
        }
        let grandTotalString = CommonUtilities.secondsToHoursMinutesSeconds(totalTimeForGrandTotal)
        reportContent = grandTotalHTMLContent + "<tr><td colspan='2'>Grand Total</td><td>\(grandTotalString)</td></tr>" + reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
        
        reportContent = partCompilationForYearlyReport(date: date) + reportContent
        
        if itemLinkQuery.count <= 0 {
            reportContent = "<div style='margin-top:300px;'><h1 style='font-family: Arial;'>No records to display.</h1></div>"
        }
        
        htmlWeeklyString = htmlWeeklyString + "<!DOCTYPE html><html><head><title>\(date)</title><meta name='viewport' content='width=device-width, initial-scale=1'><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><link href='style.css' rel='stylesheet' type='text/css' media='all' /><link href='//fonts.googleapis.com/css?family=Cabin:400,400italic,500,500italic,600,600italic,700,700italic' rel='stylesheet' type='text/css'><link href='//fonts.googleapis.com/css?family=Cinzel:400,700,900' rel='stylesheet' type='text/css'></head><body><div class='main'>\(reportContent)</div></body></html>"
        
        return htmlWeeklyString
    }
    
    //MARK:- Monthly report methods.
    func partCompilationForMonthlyReport(date: Date) -> String {
        
        var htmlTotalMonthlyDaysString: String = ""
        var reportContent: String = ""
        let monthlyDayDate = date.getMonthFirstDate
        var totalTimeForGrandTotal: Int = 0
        var monthlyDaysTotalHTMLContent: String = ""
        monthlyDaysTotalHTMLContent = monthlyDaysTotalHTMLContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:40px;'><div style='float:left;display:block;width:100%;'><h3 style='margin-top:7px;font-size:14px;'><span style='text-align:center;font-weight: bold;'>Monthly Total Social Time Spent On Daily Basis</span></h3></div></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Date</th><th>Total</th></tr></thead><tbody>"
        for var indexA in 0 ..< 31 {
            let monthlyDay = monthlyDayDate.addDays(indexA)
            let monthDayDateForQuery = monthlyDay.asStringDate()
            let dateRowQuery = db.query(sql:"SELECT SUM(total_time) FROM report_details WHERE date_8digit='\(monthDayDateForQuery)' GROUP BY date_8digit")
            if dateRowQuery.count <= 0 {
                let sNoForReport = indexA + 1
                let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(0)
                reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td>\(monthDayDateForQuery)</td><td>\(sumTimeStringForReport)</td></tr>"
            } else {
                let rowData = dateRowQuery[0]
                let sumTimeForReport = rowData["SUM(total_time)"] as! Int
                totalTimeForGrandTotal = totalTimeForGrandTotal + sumTimeForReport
                let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(sumTimeForReport)
                let sNoForReport = indexA + 1
                reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td>\(monthDayDateForQuery)</td><td>\(sumTimeStringForReport)</td></tr>"
            }
            if monthlyDay == date.getMonthLastDate {
                indexA = 31
            }
        }
        reportContent = reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
        let grandTotalString = CommonUtilities.secondsToHoursMinutesSeconds(totalTimeForGrandTotal)
        monthlyDaysTotalHTMLContent = monthlyDaysTotalHTMLContent + "<tr><td colspan='2'>Grand Total</td><td>\(grandTotalString)</td></tr>" + reportContent
        
        /*if checkingRows.count <= 0 {
        weeklyDaysTotalHTMLContent = ""
        }*/
        
        htmlTotalMonthlyDaysString = monthlyDaysTotalHTMLContent
        
        return htmlTotalMonthlyDaysString
    }
    
    func compilingMonthlyReport(date: Date) -> String {
        
        var htmlWeeklyString: String = ""
        var reportContent: String = ""
        let selectedMonthForReport = date.asStringMonth
        let selectedYearForReport = date.asStringYear
        var totalTimeForGrandTotal: Int = 0
        let startDate = date.getMonthFirstDateString
        let endDate = date.getMonthLastDateString
        var grandTotalHTMLContent: String = ""
        grandTotalHTMLContent = grandTotalHTMLContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:40px;'><div style='float:left;display:block;width:100%;'><h3 style='margin-top:7px;font-size:15px;'><span style='font-weight: bold;'>Start Date: </span>\(startDate)&nbsp;&nbsp;&nbsp;&nbsp;<span style='font-weight: bold;'>End Date: </span>\(endDate)</h3></div></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Site Name</th><th>Total</th></tr></thead><tbody>"
        let itemLinkQuery = db.query(sql:"SELECT item_name, item_image, item_link, SUM(total_time) FROM report_details WHERE month='\(selectedMonthForReport)' AND year_4digit='\(selectedYearForReport)' GROUP BY item_name ORDER BY SUM(total_time) DESC")
        for indexA in 0 ..< itemLinkQuery.count {
            let rowData = itemLinkQuery[indexA]
            let itemNameForReport = rowData["item_name"] as! String
            let itemImageForReport = rowData["item_image"] as! String
            _ = rowData["item_link"] as! String
            let sumTimeForReport = rowData["SUM(total_time)"] as! Int
            totalTimeForGrandTotal = totalTimeForGrandTotal + sumTimeForReport
            let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(sumTimeForReport)
            let sNoForReport = indexA + 1
            //let grandTotalTime = String(CommonUtilities.secondsToHoursMinutesSeconds(sumTime))
            reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td><img src='\(itemImageForReport)' height='18' width='18'><br>\(itemNameForReport)</td><td>\(sumTimeStringForReport)</td></tr>"
        }
        let grandTotalString = CommonUtilities.secondsToHoursMinutesSeconds(totalTimeForGrandTotal)
        reportContent = grandTotalHTMLContent + "<tr><td colspan='2'>Grand Total</td><td>\(grandTotalString)</td></tr>" + reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
        
        reportContent = partCompilationForMonthlyReport(date: date) + reportContent
        
        if itemLinkQuery.count <= 0 {
            reportContent = "<div style='margin-top:300px;'><h1 style='font-family: Arial;'>No records to display.</h1></div>"
        }
        
        htmlWeeklyString = htmlWeeklyString + "<!DOCTYPE html><html><head><title>\(date)</title><meta name='viewport' content='width=device-width, initial-scale=1'><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><link href='style.css' rel='stylesheet' type='text/css' media='all' /><link href='//fonts.googleapis.com/css?family=Cabin:400,400italic,500,500italic,600,600italic,700,700italic' rel='stylesheet' type='text/css'><link href='//fonts.googleapis.com/css?family=Cinzel:400,700,900' rel='stylesheet' type='text/css'></head><body><div class='main'>\(reportContent)</div></body></html>"
        
        return htmlWeeklyString
    }
    
    //MARK:- Weekly report methods.
    func partCompilationForWeeklyReport(date: Date) -> String {
        
        var htmlTotalWeeklyDaysString: String = ""
        var reportContent: String = ""
        let weeklyDayDate = date.getWeekFirstDate
        var totalTimeForGrandTotal: Int = 0
        var weeklyDaysTotalHTMLContent: String = ""
        weeklyDaysTotalHTMLContent = weeklyDaysTotalHTMLContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:40px;'><div style='float:left;display:block;width:100%;'><h3 style='margin-top:7px;font-size:14px;'><span style='text-align:center;font-weight: bold;'>Weekly Total Social Time Spent On Daily Basis</span></h3></div></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Day</th><th>Total</th></tr></thead><tbody>"
        for indexA in 0 ..< 7  {
            let weeklyDay = weeklyDayDate.addDays(indexA)
            let weekDayDateForQuery = weeklyDay.asLongString()
            let dayRowQuery = db.query(sql:"SELECT SUM(total_time) FROM report_details WHERE date_string='\(weekDayDateForQuery)' GROUP BY date_string")
            if dayRowQuery.count <= 0 {
                let sNoForReport = indexA + 1
                let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(0)
                reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td>\(weekDayDateForQuery)</td><td>\(sumTimeStringForReport)</td></tr>"
            } else {
                let rowData = dayRowQuery[0]
                let sumTimeForReport = rowData["SUM(total_time)"] as! Int
                totalTimeForGrandTotal = totalTimeForGrandTotal + sumTimeForReport
                let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(sumTimeForReport)
                let sNoForReport = indexA + 1
                reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td>\(weekDayDateForQuery)</td><td>\(sumTimeStringForReport)</td></tr>"
            }
        }
        reportContent = reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
        let grandTotalString = CommonUtilities.secondsToHoursMinutesSeconds(totalTimeForGrandTotal)
        weeklyDaysTotalHTMLContent = weeklyDaysTotalHTMLContent + "<tr><td colspan='2'>Grand Total</td><td>\(grandTotalString)</td></tr>" + reportContent
        
        /*if checkingRows.count <= 0 {
            weeklyDaysTotalHTMLContent = ""
        }*/
        
        htmlTotalWeeklyDaysString = weeklyDaysTotalHTMLContent
        
        return htmlTotalWeeklyDaysString
    }
    
    func compilingWeeklyReport(date: Date) -> String {
        
        var htmlWeeklyString: String = ""
        var reportContent: String = ""
        let selectedWeekForReport = date.asStringWeek
        var totalTimeForGrandTotal: Int = 0
        let startDate = date.getWeekFirstDateString
        let endDate = date.getWeekLastDateString
        var grandTotalHTMLContent: String = ""
        grandTotalHTMLContent = grandTotalHTMLContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:40px;'><div style='float:left;display:block;width:100%;'><h3 style='margin-top:7px;font-size:14px;'><span style='font-weight: bold;'>Start Date: </span>\(startDate)&nbsp;&nbsp;&nbsp;&nbsp;<span style='font-weight: bold;'>End Date: </span>\(endDate)</h3></div></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Site Name</th><th>Total</th></tr></thead><tbody>"
        let itemLinkQuery = db.query(sql:"SELECT item_name, item_image, item_link, SUM(total_time) FROM report_details WHERE week_no='\(selectedWeekForReport)' GROUP BY item_name ORDER BY SUM(total_time) DESC")
        for indexA in 0 ..< itemLinkQuery.count  {
            let rowData = itemLinkQuery[indexA]
            let itemNameForReport = rowData["item_name"] as! String
            let itemImageForReport = rowData["item_image"] as! String
            _ = rowData["item_link"] as! String
            let sumTimeForReport = rowData["SUM(total_time)"] as! Int
            totalTimeForGrandTotal = totalTimeForGrandTotal + sumTimeForReport
            let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(sumTimeForReport)
            let sNoForReport = indexA + 1
            //let grandTotalTime = String(CommonUtilities.secondsToHoursMinutesSeconds(sumTime))
            reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td><img src='\(itemImageForReport)' height='18' width='18'><br>\(itemNameForReport)</td><td>\(sumTimeStringForReport)</td></tr>"
        }
        let grandTotalString = CommonUtilities.secondsToHoursMinutesSeconds(totalTimeForGrandTotal)
        reportContent = grandTotalHTMLContent + "<tr><td colspan='2'>Grand Total</td><td>\(grandTotalString)</td></tr>" + reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
        
        reportContent = partCompilationForWeeklyReport(date: date) + reportContent
        
        if itemLinkQuery.count <= 0 {
            reportContent = "<div style='margin-top:300px;'><h1 style='font-family: Arial;'>No records to display.</h1></div>"
        }
        
        htmlWeeklyString = htmlWeeklyString + "<!DOCTYPE html><html><head><title>\(date)</title><meta name='viewport' content='width=device-width, initial-scale=1'><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><link href='style.css' rel='stylesheet' type='text/css' media='all' /><link href='//fonts.googleapis.com/css?family=Cabin:400,400italic,500,500italic,600,600italic,700,700italic' rel='stylesheet' type='text/css'><link href='//fonts.googleapis.com/css?family=Cinzel:400,700,900' rel='stylesheet' type='text/css'></head><body><div class='main'>\(reportContent)</div></body></html>"
        
        return htmlWeeklyString
    }
    
    
    
    //MARK:- Daily report methods.
    func partCompilationForDailyReport(date: Date) -> String {
        
        var htmlTotalDailyString: String = ""
        var reportContent: String = ""
        let selectedDateForReport = date.asLongString()
        var totalTimeForGrandTotal: Int = 0
        var grandTotalHTMLContent: String = ""
        grandTotalHTMLContent = grandTotalHTMLContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:40px;'><div style='float:left;display:block;width:0%;margin-right:0%;'></div><div style='float:left;display:block;width:100%;'><h3 style='margin-top:7px;font-size:15px;'>Daily Total Social Time Spent</h3></div></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Site Name</th><th>Total</th></tr></thead><tbody>"
        let itemLinkQuery = db.query(sql:"SELECT item_name, item_image, item_link, SUM(total_time) FROM report_details WHERE date_string='\(selectedDateForReport)' GROUP BY item_name ORDER BY SUM(total_time) DESC")
        for indexA in 0 ..< itemLinkQuery.count {
            let rowData = itemLinkQuery[indexA]
            let itemNameForReport = rowData["item_name"] as! String
            let itemImageForReport = rowData["item_image"] as! String
            _ = rowData["item_link"] as! String
            let sumTimeForReport = rowData["SUM(total_time)"] as! Int
            totalTimeForGrandTotal = totalTimeForGrandTotal + sumTimeForReport
            let sumTimeStringForReport = CommonUtilities.secondsToHoursMinutesSeconds(sumTimeForReport)
            let sNoForReport = indexA + 1
            //let grandTotalTime = String(CommonUtilities.secondsToHoursMinutesSeconds(sumTime))
            reportContent = reportContent + "<tr><td>\(sNoForReport)</td><td><img src='\(itemImageForReport)' height='18' width='18'><br>\(itemNameForReport)</td><td>\(sumTimeStringForReport)</td></tr>"
        }
        reportContent = reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
        let grandTotalString = CommonUtilities.secondsToHoursMinutesSeconds(totalTimeForGrandTotal)
        grandTotalHTMLContent = grandTotalHTMLContent + "<tr><td colspan='2'>Grand Total</td><td>\(grandTotalString)</td></tr>" + reportContent
        
        if itemLinkQuery.count <= 0 {
            grandTotalHTMLContent = ""
        }
        
        htmlTotalDailyString = grandTotalHTMLContent
        
        return htmlTotalDailyString
    }
    
    func compilingDailyReport(date: Date) -> String {

        var htmlDailyString: String = ""
        var reportContent: String = ""
        let selectedDateForReport = date.asLongString()
        //let todaysDateAsString: String = NSDate().asLongString()
        //let todaysDateAsString: String = "Monday, 01, February 2016"
        let itemLinkQuery = db.query(sql: "SELECT item_link, item_image, SUM(total_time) FROM report_details WHERE date_string='\(selectedDateForReport)' GROUP BY item_link")
        for indexA in 0 ..< itemLinkQuery.count {
            let rowData = itemLinkQuery[indexA]
            let itemImage = rowData["item_image"] as! String
            let sumTime = rowData["SUM(total_time)"] as! Int
            let grandTotalTime = String(CommonUtilities.secondsToHoursMinutesSeconds(sumTime))
            let itemLink = rowData["item_link"] as! String
            
            reportContent = reportContent + "<div class='main-grid'><div style='border-bottom: 1px dotted #999;height:40px;'><div style='float:left;display:block;width:12%;margin-right:03%;'><img src='\(itemImage)' height='35' width='35'></div><div style='float:left;display:block;width:85%;'><h3 style='margin-top:7px;font-size:15px;'>Site: \(itemLink)</h3></div></div><div class='clear'> </div><table><thead><tr><th>#</th><th>Start Time</th><th>End Time</th><th>Total</th></tr></thead><tbody><tr><td colspan='3'>Grand Total</td><td>\(grandTotalTime)</td></tr><tr><td colspan='4' style='text-align:center'>Detailed Description Of Social Time Spent</td></tr>"
            let dailyReportQuery = db.query(sql: "SELECT * FROM report_details WHERE item_link='\(itemLink)' AND date_string='\(selectedDateForReport)' ORDER BY total_time DESC")
            for indexB in 0 ..< dailyReportQuery.count {
                let rowDataB = dailyReportQuery[indexB]
                var sNo = rowDataB["s_no"] as! Int
                sNo = indexB + 1
                let startTimeString = rowDataB["start_time"] as! String
                let endTimeString = rowDataB["end_time"] as! String
                let totalTime = rowDataB["total_time"] as! Int
                let totalTimeString = CommonUtilities.secondsToHoursMinutesSeconds(totalTime)
                reportContent = reportContent + "<tr><td>\(sNo)</td><td>\(startTimeString)</td><td>\(endTimeString)</td><td>\(totalTimeString)</td></tr>"
            }
            reportContent = reportContent + "</tbody></table><div class='clear'> </div></div><div style='height: 20px; width:100%'></div>"
            //<tfoot><tr><th colspan='3'>Grand Total</th><th>\(grandTotalTime)</th></tr></tfoot>
        }
        
        reportContent = partCompilationForDailyReport(date: date) + reportContent
        
        if itemLinkQuery.count <= 0 {
            reportContent = "<div style='margin-top:300px;'><h1 style='font-family: Arial;'>No records to display.</h1></div>"
        }

        htmlDailyString = htmlDailyString + "<!DOCTYPE html><html><head><title>\(date)</title><meta name='viewport' content='width=device-width, initial-scale=1'><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><link href='style.css' rel='stylesheet' type='text/css' media='all' /><link href='//fonts.googleapis.com/css?family=Cabin:400,400italic,500,500italic,600,600italic,700,700italic' rel='stylesheet' type='text/css'><link href='//fonts.googleapis.com/css?family=Cinzel:400,700,900' rel='stylesheet' type='text/css'></head><body><div class='main'>\(reportContent)</div></body></html>"
        
        return htmlDailyString
    }
    
    //MARK:- Top panel.
    @IBAction func goingBackAction(sender: UIButton) {
        
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func deleteRecordsAction(sender: UIButton) {
        print(selectedDateForReport.asStringDate())
        switch selectedSegmentControlValue {
        case 0:
            let selectedStringDate = selectedDateForReport.asStringDate()
            let alertVC = UIAlertController(title: "Warning!", message: "It will delete your selected day report", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                { action -> Void in
                    //..
                })
            alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                _ = db.execute(sql: "DELETE FROM report_details WHERE date_8digit='\(selectedStringDate)'")
                self.loadSelectedReport(segmentNumber: self.selectedSegmentControlValue)
                })
            present(alertVC, animated: true, completion: nil)
            break
        case 1:
            let selectedWeek = selectedDateForReport.asStringWeek
            let alertVC = UIAlertController(title: "Warning!", message: "It will delete your selected week report", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                { action -> Void in
                    //..
                })
            alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                _ = db.execute(sql: "DELETE FROM report_details WHERE week_no='\(selectedWeek)'")
                self.loadSelectedReport(segmentNumber: self.selectedSegmentControlValue)
                })
            present(alertVC, animated: true, completion: nil)
            break
        case 2:
            let selectedMonth = selectedDateForReport.asStringMonth
            let selectedYear = selectedDateForReport.asStringYear
            let alertVC = UIAlertController(title: "Warning!", message: "It will delete your selected month report", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                { action -> Void in
                    //..
                })
            alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                    _ = db.execute(sql: "DELETE FROM report_details WHERE month='\(selectedMonth)' AND year_4digit='\(selectedYear)'")
                self.loadSelectedReport(segmentNumber: self.selectedSegmentControlValue)
                })
            present(alertVC, animated: true, completion: nil)
            break
        case 3:
            let selectedYear = selectedDateForReport.asStringYear
            let alertVC = UIAlertController(title: "Warning!", message: "It will delete your selected year report", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                { action -> Void in
                    //..
                })
            alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                    _ = db.execute(sql: "DELETE FROM report_details WHERE year_4digit='\(selectedYear)'")
                self.loadSelectedReport(segmentNumber: self.selectedSegmentControlValue)
                })
            present(alertVC, animated: true, completion: nil)
            break
        case 4:
            let alertVC = UIAlertController(title: "Warning!", message: "It will delete 'All Time' report means all reports of this app will be deleted.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                { action -> Void in
                    //..
                })
            alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                    _ = db.execute(sql: "DELETE FROM report_details")
                self.loadSelectedReport(segmentNumber: self.selectedSegmentControlValue)
                })
            present(alertVC, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch reportSegmentControl.selectedSegmentIndex {
        case 0:
            selectedSegmentControlValue = reportSegmentControl.selectedSegmentIndex
            loadSelectedReport(segmentNumber: selectedSegmentControlValue)
            break
        case 1:
            selectedSegmentControlValue = reportSegmentControl.selectedSegmentIndex
            loadSelectedReport(segmentNumber: selectedSegmentControlValue)
            break
        case 2:
            selectedSegmentControlValue = reportSegmentControl.selectedSegmentIndex
            loadSelectedReport(segmentNumber: selectedSegmentControlValue)
            break
        case 3:
            selectedSegmentControlValue = reportSegmentControl.selectedSegmentIndex
            loadSelectedReport(segmentNumber: selectedSegmentControlValue)
            break
        case 4:
            selectedSegmentControlValue = reportSegmentControl.selectedSegmentIndex
            loadSelectedReport(segmentNumber: selectedSegmentControlValue)
            break
        default:
            break
        }
    }
    
    func loadSelectedReport(segmentNumber: Int) {
        
        switch (segmentNumber) {
        case 0:
            //For showing daily report in webview
            selectedDateForReport = Date()
            let htmlReport = compilingDailyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = Date().asLongString()
            //Showing buttons
            forwardReportButton.isHidden = false
            backwardReportButton.isHidden = false
            if selectedDateForReport.isEqualWithDay(Date()) {
                forwardReportButton.isEnabled = false
            }
            break
        case 1:
            //For showing weekly report in webview
            selectedDateForReport = Date()
            let htmlReport = compilingWeeklyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asWeekNumberString()
            //Showing buttons
            forwardReportButton.isHidden = false
            backwardReportButton.isHidden = false
            if selectedDateForReport.isEqualWithDay(selectedDateForReport) {
                forwardReportButton.isEnabled = false
            }
            break
        case 2:
            //For showing monthly report in webview
            selectedDateForReport = Date()
            let htmlReport = compilingMonthlyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asStringMonth + " " + selectedDateForReport.asStringYear
            //Showing buttons
            forwardReportButton.isHidden = false
            backwardReportButton.isHidden = false
            if selectedDateForReport.isEqualWithDay(selectedDateForReport) {
                forwardReportButton.isEnabled = false
            }
            break
        case 3:
            //For showing yearly report in webview
            selectedDateForReport = Date()
            let htmlReport = compilingYearlyReport(date: selectedDateForReport)
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = selectedDateForReport.asStringYear
            //Showing buttons
            forwardReportButton.isHidden = false
            backwardReportButton.isHidden = false
            if selectedDateForReport.isEqualWithDay(selectedDateForReport) {
                forwardReportButton.isEnabled = false
            }
            break
        case 4:
            //For showing all time report in webview
            let htmlReport = compilingAllTimeReport()
            loadingHTMLReport(htmlReport)
            reportHeadingLabel.text = "All Time"
            //Hiding buttons
            forwardReportButton.isHidden = true
            backwardReportButton.isHidden = true
            break
        default:
            break
        }
    }
}
