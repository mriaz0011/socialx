//
//  AddIconViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 10/05/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit
import WebKit

class AddIconViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    
    //Outlet reference.
    @IBOutlet weak var siteNameInputValue: UITextField!
    @IBOutlet weak var siteLinkInputValue: UITextField!
    @IBOutlet weak var siteLinkInputValueForLargeWeb: UITextField!
    @IBOutlet weak var siteImageSelectedDisplay: UIImageView!
    @IBOutlet weak var siteImageSelectionButton: UIButton!
    @IBOutlet weak var iconSelectionButton: UIButton!
    @IBOutlet weak var gallerySelectionButton: UIButton!
    @IBOutlet weak var cameraSelectionButton: UIButton!
    @IBOutlet weak var doneBrowsingButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var siteImageSearchBar: UISearchBar!
    @IBOutlet weak var siteImageCollectionView: UICollectionView!
    @IBOutlet var focusView : UIView!
    @IBOutlet weak var siteImagePickUpView: UIView!
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var webContainerView: UIView! = nil
    @IBOutlet weak var dismissView: UIView!
    
    //Variables.
    //For website
    var layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var loadCompletedValue: Int = 0
    var addWebView: WKWebView?
    var url: NSURL!
    //Resizing frame when keyboard shows.
    var keyboardHeight: CGFloat!
    var collectionViewHeightEnable: Bool = false
    var webContainerViewHeightEnable: Bool = false
    //Creating instance for image picker controller
    let imagePicker = UIImagePickerController()
    //var cameraImageFileName: String = "None"
    var siteNames = [String : String]()
    //var siteImageCollectionViewActive: Bool = false
    var deviceImageActive: Bool = false
    var dataSource = [String : String]()
    var dataSourceSearchedResults = [String]()
    var siteLocationNo: Int!
    var defaultSiteImageName: String = "Google-Plus-Icon-demo.png"
    var siteImageName: String = "None"
    
    //MARK:- Override class methods //Update
    override func loadView() {
        super.loadView()
        
        addWebView = WKWebView(frame: webContainerView.bounds, configuration: WKWebViewConfiguration())
        addWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webContainerView.addSubview(addWebView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Makng focus view tap able and assigning action. //Update
        let tapGestureForFocusView = UITapGestureRecognizer(target: self, action: #selector(AddIconViewController.resizingWebContainer(gesture:)))
        tapGestureForFocusView.numberOfTapsRequired = 1
        focusView.addGestureRecognizer(tapGestureForFocusView)
        let rightGestureForFocusView = UISwipeGestureRecognizer(target: self, action: #selector(AddIconViewController.resizingWebContainer(gesture:)))
        rightGestureForFocusView.direction = .right
        focusView.addGestureRecognizer(rightGestureForFocusView)
        let leftGestureForFocusView = UISwipeGestureRecognizer(target: self, action: #selector(AddIconViewController.resizingWebContainer(gesture:)))
        leftGestureForFocusView.direction = .left
        focusView.addGestureRecognizer(leftGestureForFocusView)
        let upGestureForFocusView = UISwipeGestureRecognizer(target: self, action: #selector(AddIconViewController.resizingWebContainer(gesture:)))
        upGestureForFocusView.direction = .up
        focusView.addGestureRecognizer(upGestureForFocusView)
        let downGestureForFocusView = UISwipeGestureRecognizer(target: self, action: #selector(AddIconViewController.resizingWebContainer(gesture:)))
        downGestureForFocusView.direction = .down
//        focusView.addGestureRecognizer(downGestureForFocusView)
//        focusView.isUserInteractionEnabled = true
        
        //Aspect fit for buttons.
        cancelButton.imageEdgeInsets.right = -55.0
        cancelButton.imageView!.contentMode = .scaleAspectFit
        doneButton.imageEdgeInsets.left = -55.0
        doneButton.imageView!.contentMode = .scaleAspectFit
        
        siteImageCollectionView.delegate = self
        siteImageCollectionView.dataSource = self
        siteImageCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        siteImageCollectionView.collectionViewLayout = layout
        siteImageCollectionView.isUserInteractionEnabled = true
        
        //For webView.
        addWebView!.scrollView.isScrollEnabled = true
        addWebView!.isUserInteractionEnabled = true
        addWebView!.navigationDelegate = self //This is to track load progress.
        addWebView!.uiDelegate = self
        //To use scrollview methods and detecting scrollview scrolling.
        addWebView!.scrollView.delegate = self
        addWebView!.scrollView.bounces = false
        //Observer for webView.
        addWebView!.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        
        siteImageSelectedDisplay.layer.cornerRadius = siteImageSelectedDisplay.frame.size.width/6
        siteImageSelectedDisplay.clipsToBounds = true
        
        //Hiding outlets.
//        urlView.isHidden = true
        siteImagePickUpView.isHidden = true
        doneButton.isEnabled = false
        siteImageSelectionButton.rounded
//        doneBrowsingButton.rounded
        //Recognizing tap outside textfileds to dismiss the keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddIconViewController.DismissKeyboard))
//        dismissView.addGestureRecognizer(tap)
        //Assign delegation for text fields.
        siteNameInputValue.delegate = self
        siteNameInputValue.addTarget(self, action: #selector(AddIconViewController.textFieldDidChange(textField:)), for: .editingChanged)
        siteLinkInputValue.delegate = self
        siteLinkInputValueForLargeWeb.delegate = self
        
        for indexA in 0 ..< Icons.fileName.count  {
            let key: String = Icons.name[indexA]
            //print(key)
            let value: String = Icons.fileName[indexA]
            //print(value)
            dataSource[key] = value
        }
        
        let siteNamesData = db.query(sql: "SELECT item_name FROM item_details")
        for indexA in 0 ..< siteNamesData.count  {
            let lowercaseText = (siteNamesData[indexA]["item_name"] as! String).lowercased()
            siteNames[lowercaseText] = lowercaseText
            //print(lowercaseText)
        }
        
        //Method called to reload table when app running from background to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(AddIconViewController.passcodeCheck(notification:)), name: NSNotification.Name(rawValue: "passcodeCheck"), object: nil)
        //To get the keyboard height.
        NotificationCenter.default.addObserver(self, selector: #selector(AddIconViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddIconViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Hiding or unhiding views
//        urlView.isHidden = true
        siteImagePickUpView.isHidden = true
        focusView.isHidden = false
        //Designating frame location and size. //Update and relocate.
        webContainerView.frame = CGRect(x: 0.0, y: focusView.frame.origin.y, width: focusView.frame.size.width, height: focusView.frame.size.height)
        addWebView!.frame = CGRect(x: 0.0, y: 0.0, width: webContainerView.frame.size.width, height: webContainerView.frame.size.height)
//        siteImageCollectionView.frame = CGRect(x: 0.0, y: 44.0, width: siteImagePickUpView.frame.size.width, height: (siteImagePickUpView.frame.size.height - 44.0))
        
        let check = General.storageDefaults.string(forKey: "check")
        if "true" == check {
            General.storageDefaults.set("false", forKey: "check")
            siteImageName = General.storageDefaults.string(forKey:"croppedImageName")!
            siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName: siteImageName)
            siteImageSelectionButton.setTitle("Reset", for: .normal)
            deviceImageActive = true
            General.storageDefaults.set("None", forKey: "croppedImageName")
            siteNameInputValue.becomeFirstResponder()
            //print("This condition called.")
        }
        
        if siteLinkInputValue.text == "" && SharingManager.sharedInstance.urlAddressForAdd == "" {
            url = NSURL (string: "http://www.google.com")
            let requestObj = NSURLRequest(url: url! as URL)
            addWebView!.load(requestObj as URLRequest)
        } else if SharingManager.sharedInstance.urlAddressForAdd != "" {
            siteLinkInputValue.text = SharingManager.sharedInstance.urlAddressForAdd
            siteLinkInputValueForLargeWeb.text = SharingManager.sharedInstance.urlAddressForAdd  //Update
            url = NSURL (string: siteLinkInputValue.text!)
            let requestObj = NSURLRequest(url: url! as URL)
            addWebView!.load(requestObj as URLRequest)
        } else if check != "true" && SharingManager.sharedInstance.urlAddressForAdd == "" { //Update
            refreshingInputValues()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //passcodeScreenValidationStatus()
    }
    
    override func viewDidLayoutSubviews() {
        
        
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
    @objc func resizingWebContainer(gesture: UIGestureRecognizer) {
        
//        urlView.isHidden = false
        focusView.isHidden = true
        webContainerViewHeightEnable = true
        //Designating frame location and size.
        webContainerView.frame = CGRect(x: 0.0, y: urlView.frame.size.height, width: dismissView.frame.size.width, height: (dismissView.frame.size.height - urlView.frame.size.height))
        addWebView!.frame = CGRect(x: 0.0, y: 0.0, width: webContainerView.frame.size.width, height: webContainerView.frame.size.height)
    }
    
    @IBAction func doneBrowsingAction(sender: UIButton) { //Update
        
        urlView.isHidden = true
        focusView.isHidden = false
        webContainerViewHeightEnable = false
        //Designating frame location and size.
        webContainerView.frame = CGRect(x: 0.0, y: focusView.frame.origin.y, width: focusView.frame.size.width, height: focusView.frame.size.height)
        addWebView!.frame = CGRect(x: 0.0, y: 0.0, width: webContainerView.frame.size.width, height: webContainerView.frame.size.height)
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
    
    func refreshingInputValues() { //Update relocate
        
        deviceImageActive = false
        siteImageName = "None"
        
        siteImageSelectionButton.setTitle("Select", for: .normal)
        //Making text fields empty.
        siteNameInputValue.text = ""
        siteLinkInputValue.text = ""
        siteLinkInputValueForLargeWeb.text = ""
        siteImageSelectedDisplay.image = UIImage(named: "Google-Plus-Icon-demo.png")
        //Reseting search bar
        self.cancelSearching()
        alertLabel.text = "Please type unique name for site icon."
        alertLabel.textColor = UIColor.darkGray
        //Enabling buttons
        iconSelectionButton.isEnabled = true
        gallerySelectionButton.isEnabled = true
        cameraSelectionButton.isEnabled = true
        //Hiding view
        siteImagePickUpView.isHidden = true
        //collectionViewHeight = 0.0 //Update
        collectionViewHeightEnable = false
        //Reseting webView
        url = NSURL (string: "http://www.google.com")
        let requestObj = NSURLRequest(url: url! as URL)
        addWebView!.load(requestObj as URLRequest)
    }
    
    //MARK:- Top panel button actions.
    @IBAction func dismissViewAction(sender: UIButton) {
        
        SharingManager.sharedInstance.dontReloadSiteURL = true
        if deviceImageActive {
            RepeatMethods.deletingImageLocally(imageName: siteImageName)
            deviceImageActive = false
        } else {
        }
        refreshingInputValues()
        dismiss(animated: false, completion: nil)
    }
    
    //For passcode check
    @objc func passcodeCheck(notification: NSNotification) {
        
        passcodeScreenValidationStatus()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func siteAdditionAction(sender: UIButton) {
        
        var imageLocalStorage: String = "false"
        if deviceImageActive {
            imageLocalStorage = "true"
        } else {
            imageLocalStorage = "false"
        }
        if siteImageName != "None" && siteNameInputValue.text != "" {
            let totalRowsQuery = db.query(sql:"SELECT * FROM item_details ORDER BY item_location_no ASC")
            siteLocationNo = totalRowsQuery.count
            let dataEntry = db.execute(sql: "INSERT INTO item_details (item_name, item_image, item_link, favourite_status, item_location_no, image_local_storage) VALUES ('\(siteNameInputValue.text!)', '\(siteImageName)', '\(siteLinkInputValue.text!)', 'NO', '\(siteLocationNo!)', '\(imageLocalStorage)')")
            if dataEntry > 0 {
                let alertVC = UIAlertController(title: "Site Addition", message: "Site added successfully.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                { action -> Void in
                    self.refreshingInputValues()
                    self.dismiss(animated: false, completion: nil)
                    })
                present(alertVC, animated: true, completion: nil)
            }
        } else {
            let alertVC = UIAlertController(title: "Empty Input", message: "Please type site name and pick site image at least.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    @objc func DismissKeyboard(){
        //Dismissing key board.
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        let typedSiteName = siteNameInputValue.text!.lowercased()
        //print(siteNameInputValue)
        let siteName = siteNames[typedSiteName]
        
        if (siteName == typedSiteName) {
            siteNameInputValue.textColor = UIColor.red
            alertLabel.text = "This site name is already exist. Please type different name."
            alertLabel.textColor = UIColor.red
            doneButton.isEnabled = false
        } else {
            siteNameInputValue.textColor = UIColor.black
            alertLabel.text = "Please type unique name for site icon."
            alertLabel.textColor = UIColor.darkGray
            doneButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField.text == siteLinkInputValue.text || textField.text == siteLinkInputValueForLargeWeb.text) && textField.text != "" { //Update
            textField.resignFirstResponder()
            siteLinkInputValue.text = textField.text //Update
            siteLinkInputValueForLargeWeb.text = textField.text //Update
            loadingTextFieldURL(urlString: textField.text!)
            //print("Load called.")
            return true
        } else if textField.text == siteNameInputValue.text {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    func loadingTextFieldURL(urlString: String) {
        
        //print(urlString)
        url = NSURL(string: RepeatMethods.makingFormalURL(urlString: urlString))
        let requestObj = NSURLRequest(url: url! as URL)
        addWebView!.load(requestObj as URLRequest)
    }
    
    
    //MARK:- Height adjustments for webContainerView and collectionView when keyboard is visible.
    @objc func keyboardWillShow(notification:NSNotification) {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        if collectionViewHeightEnable == true {
            siteImageCollectionView.frame.size.height = siteImageCollectionView.frame.size.height - keyboardHeight //Update
        }
        if webContainerViewHeightEnable == true { //Update
            webContainerView.frame.size.height = webContainerView.frame.size.height - keyboardHeight
            addWebView?.frame.size.height = webContainerView.frame.size.height
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        
        if collectionViewHeightEnable == true {
            siteImageCollectionView.frame.size.height = siteImagePickUpView.frame.size.height - 44.0
        }
        if webContainerViewHeightEnable == true { //Update
            webContainerView.frame.size.height = dismissView.frame.size.height - urlView.frame.size.height
            addWebView?.frame.size.height = webContainerView.frame.size.height
        }
    }
}
    //MARK:- Collection view methods.
extension AddIconViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var cellQuantity: Int!
        if (dataSourceSearchedResults.count > 0) {
            cellQuantity = dataSourceSearchedResults.count
        } else {
            cellQuantity = Icons.fileName.count
        }
        
        return cellQuantity
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let cellWidthAndHeight: CGSize = CGSize(width: 45, height: 45)
//        
//        return cellWidthAndHeight
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = siteImageCollectionView.dequeueReusableCell(withReuseIdentifier: "siteImage", for: indexPath) as! AddIconCollectionViewCell
        var siteIconImage: UIImageView!
        siteIconImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        siteIconImage.layer.cornerRadius = siteIconImage.frame.size.width/6
        siteIconImage.clipsToBounds = true
        
        //print(indexPath.item)
        if (dataSourceSearchedResults.count > 0) {
            let itemName = dataSourceSearchedResults[indexPath.item]
            if dataSource.count > 0 {
                let imageName = dataSource[itemName]
                //print(imageName)
                siteIconImage.image = UIImage(named: imageName!)
            }
        } else {
            let imageName = Icons.fileName[indexPath.item]
            siteIconImage.image = UIImage(named: imageName)
        }
        cell.addSubview(siteIconImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Did select tapped")
        
        deviceImageActive = false
        if (dataSourceSearchedResults.count > 0) {
            let itemName = dataSourceSearchedResults[indexPath.item]
            if dataSource.count > 0 {
                let imageName = dataSource[itemName]
                siteImageName = imageName!
                siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName: imageName!)
            }
        } else {
            let imageName = Icons.fileName[indexPath.item]
            siteImageName = imageName
            siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName: imageName)
        }
    }
    
    //MARK:- Search bar methods.
    func filterContentForSearchText(searchText:String){
        
        //dataSourceForSearch.keys.filter
        let lowerCaseSearchText = searchText.lowercased()
        dataSourceSearchedResults = Icons.name.filter({ (text:String) -> Bool in
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
            self.filterContentForSearchText(searchText: searchText)
            self.siteImageCollectionView.reloadData()
        } else {
            // if text lenght == 0
            // we will consider the searchbar is not active
            self.siteImageCollectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.cancelSearching()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // we used here to set self.searchBarActive = YES
        // but we'll not do that any more... it made problems
        // it's better to set self.searchBarActive = YES when user typed something
        //self.iconsSearchBar.showsCancelButton = true
        self.siteImageSearchBar!.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        self.siteImageSearchBar!.setShowsCancelButton(false, animated: false)
    }
    
    func cancelSearching(){
        self.siteImageSearchBar.resignFirstResponder()
        self.siteImageSearchBar.text = ""
        let emptyArray = [String]()
        dataSourceSearchedResults = emptyArray
        self.siteImageCollectionView.reloadData()
    }
    
    //MARK: Methods for after getting or taking photo
    //Selecting image from device photo library.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.dismiss(animated: false) { () -> Void in
            let cropViewController: ImageCropViewController = ImageCropViewController(image: image)
            //controller.delegate = self
            cropViewController.blurredBackground = true
            cropViewController.cropImageBoundryValue = "Circle" //Square, Circle
            cropViewController.modalPresentationStyle = .fullScreen
            self.present(cropViewController, animated: false, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        doneOrCancelImageSelection()
        siteImageSelectionButton.setTitle("Select", for: .normal)
        
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { action -> Void in
            self.doneOrCancelImageSelection()
            })
        present(alertVC, animated: true, completion: nil)
    }
    
    func savingSquareImageLocally(selectedImage: UIImage) -> String {
        
        let squareImage = selectedImage.rounded
        let fileName = "image_\(NSDate.timeIntervalSinceReferenceDate).png"
        //let keyName = "img_\(NSDate.timeIntervalSinceReferenceDate())"
        let imageData = squareImage!.pngData()
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
    
    //MARK:- Icon selection buttons.
    @IBAction func cameraImageAction(sender: UIButton) {
        
        //Deleting local image
        resetSelectedImage()
        //Disabling and enabling buttons.
        iconSelectionButton.isEnabled = true
        //Visible view
        siteImagePickUpView.isHidden = true
        //Opening camera.
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            noCamera()
            siteImageSelectionButton.setTitle("Select", for: .normal)
        }
    }
    
    @IBAction func galleryImageAction(sender: UIButton) {
        
        //Deleting local image
        resetSelectedImage()
        //Disabling and enabling buttons.
        iconSelectionButton.isEnabled = true
        //Visible view
        siteImagePickUpView.isHidden = true
        //Opening gallery
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.delegate = self
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func iconImageAction(sender: UIButton) {
        
        siteImageSelectionButton.setTitle("Done", for: .normal)
        resetSelectedImage()
        iconImageSelectionScreen()
    }
    
    @IBAction func captureWebViewScreenAction(sender: UIButton) {
        
        //Deleting local image
        resetSelectedImage()
        //Disabling and enabling buttons.
        iconSelectionButton.isEnabled = true
        //Visible view
        siteImagePickUpView.isHidden = true
        //Open editing screen.
        let image: UIImage = RepeatMethods.captureWebViewScreen(webView: addWebView!)
        let cropViewController: ImageCropViewController = ImageCropViewController(image: image)
        //controller.delegate = self
        cropViewController.blurredBackground = true
        cropViewController.cropImageBoundryValue = "Circle" //Square, Circle
        cropViewController.modalPresentationStyle = .fullScreen
        self.present(cropViewController, animated: false, completion: nil)
    }
    
    //MARK:- Icon buttons manipulation.
    func iconImageSelectionScreen() {
        
        DismissKeyboard()
        //Disabling and enabling buttons.
        iconSelectionButton.isEnabled = false
        cameraSelectionButton.isEnabled = true
        gallerySelectionButton.isEnabled = true
        //Visible view
        siteImagePickUpView.isHidden = false
        //siteImageCameraViewActive = true
        collectionViewHeightEnable = true //Update
    }
    
    @IBAction func imageSelectionDoneAction(sender: UIButton) {
        
        let doneButtonTitle: String = siteImageSelectionButton.titleLabel!.text!
        switch (doneButtonTitle) {
        case "Select":
            siteImageSelectionButton.setTitle("Done", for: .normal)
            iconImageSelectionScreen()
            break
        case "Done":
            doneOrCancelImageSelection()
            if siteImageName == "None" {
                siteImageSelectionButton.setTitle("Select", for: .normal)
            } else {
                siteImageSelectionButton.setTitle("Reset", for: .normal)
            }
            if collectionViewHeightEnable == true {
                DismissKeyboard()
                collectionViewHeightEnable = false
            }
            siteNameInputValue.becomeFirstResponder()
            break
        case "Reset":
            doneOrCancelImageSelection()
            resetSelectedImage()
            siteImageSelectionButton.setTitle("Select", for: .normal)
            break
        default:
            break
        }
    }
    
    func doneOrCancelImageSelection() {
        
        //Enabling buttons
        iconSelectionButton.isEnabled = true
        //Hiding view
        siteImagePickUpView.isHidden = true
    }
    
    func resetSelectedImage() {
        
        if deviceImageActive {
            RepeatMethods.deletingImageLocally(imageName: siteImageName)
            deviceImageActive = false
            siteImageName = "None"
            siteImageSelectedDisplay.image = UIImage(named: "Google-Plus-Icon-demo.png")
        } else {
            siteImageName = "None"
            siteImageSelectedDisplay.image = UIImage(named: "Google-Plus-Icon-demo.png")
        }
    }
    
    //MARK:- WKWebView methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        //Not really need to write code here.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "loading" {
            if addWebView!.estimatedProgress == 1 {
                loadCompletedValue = 0
                let loadedUrl = addWebView!.url?.absoluteString as String?
                if loadedUrl != "about:blank" {
                    siteLinkInputValue.text = loadedUrl
                    siteLinkInputValueForLargeWeb.text = loadedUrl //Update
                    if loadedUrl?.lowercased().range(of: "google") != nil {
                        addWebView?.becomeFirstResponder()
                    } else {
                        siteNameInputValue.becomeFirstResponder()
                    }
                }
                //print(loadCompletedValue)
            } else {
                loadCompletedValue = loadCompletedValue - 1
                if loadCompletedValue == -2 {
                    let htmlString:String = "<html><body><div style='font-color:black;width:100%;height:100%;margin-top:50%;text-align:center;font-weight:bold;font:28px arial'>Page not found.</div></body></html>"
                    addWebView!.loadHTMLString(htmlString, baseURL: nil)
                }
                //print(loadCompletedValue)
            }
        }
    }
}
