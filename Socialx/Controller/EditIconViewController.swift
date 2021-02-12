//
//  EditIconViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 11/05/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit
import WebKit

class EditIconViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, WKUIDelegate, WKNavigationDelegate {
    
    //Outlet reference.
    @IBOutlet weak var siteNameInputValue: UITextField!
    @IBOutlet weak var siteLinkInputValue: UITextField!
    @IBOutlet weak var siteLinkInputValueForLargeWeb: UITextField!
    @IBOutlet weak var siteImageSelectedDisplay: UIImageView!
    @IBOutlet weak var siteImageSelectionButton: UIButton!
    @IBOutlet weak var iconSelectionButton: UIButton!
    @IBOutlet weak var gallerySelectionButton: UIButton!
    @IBOutlet weak var cameraSelectionButton: UIButton!
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
    var loadCompletedValue: Int = 0
    var editWebView: WKWebView?
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
    var loadInputs: Bool = true //By default true
    var siteimageLocalStorageValue: String!
    var siteFavouriteStatus: String!
    var deviceImageActive: Bool = false
    var dataSource = [String : String]()
    var dataSourceSearchedResults = [String]()
    var siteLocationNo: Int!
    var siteImageName: String = "None"
    var dbLocalSiteImageName: String = ""
    var dbSiteImageName: String = ""
    
    override func loadView() {
        super.loadView()
        
        editWebView = WKWebView(frame: webContainerView.bounds, configuration: WKWebViewConfiguration())
        editWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webContainerView.addSubview(editWebView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Makng focus view tap able and assigning action.
        let tapGestureForFocusView = UITapGestureRecognizer(target: self, action: #selector(EditIconViewController.resizingWebContainer(gesture:)))
        tapGestureForFocusView.numberOfTapsRequired = 1
        focusView.addGestureRecognizer(tapGestureForFocusView)
        let rightGestureForFocusView = UISwipeGestureRecognizer(target: self, action: #selector(EditIconViewController.resizingWebContainer(gesture:)))
        rightGestureForFocusView.direction = .right
        focusView.addGestureRecognizer(rightGestureForFocusView)
        let leftGestureForFocusView = UISwipeGestureRecognizer(target: self, action: #selector(EditIconViewController.resizingWebContainer(gesture:)))
        leftGestureForFocusView.direction = .left
        focusView.addGestureRecognizer(leftGestureForFocusView)
        let upGestureForFocusView = UISwipeGestureRecognizer(target: self, action: #selector(EditIconViewController.resizingWebContainer(gesture:)))
        upGestureForFocusView.direction = .up
        focusView.addGestureRecognizer(upGestureForFocusView)
        let downGestureForFocusView = UISwipeGestureRecognizer(target: self, action: #selector(EditIconViewController.resizingWebContainer(gesture:)))
        downGestureForFocusView.direction = .down
        focusView.addGestureRecognizer(downGestureForFocusView)
        focusView.isUserInteractionEnabled = true
        
        //Aspect fit for buttons.
        cancelButton.imageEdgeInsets.right = -55.0
        cancelButton.imageView!.contentMode = .scaleAspectFit
        doneButton.imageEdgeInsets.left = -55.0
        doneButton.imageView!.contentMode = .scaleAspectFit
        
        //For webView.
        editWebView!.scrollView.isScrollEnabled = true
        editWebView!.isUserInteractionEnabled = true
        editWebView!.navigationDelegate = self //This is to track load progress.
        editWebView!.uiDelegate = self
        //To use scrollview methods and detecting scrollview scrolling.
        editWebView!.scrollView.delegate = self
        editWebView!.scrollView.bounces = false
        //Observer for webView.
        editWebView!.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        
        siteImageSelectedDisplay.layer.cornerRadius = siteImageSelectedDisplay.frame.size.width/6
        siteImageSelectedDisplay.clipsToBounds = true
        
        //Hiding outlets.
//        urlView.isHidden = true
        siteImagePickUpView.isHidden = true
        doneButton.isEnabled = false
        siteImageSelectionButton.rounded
        //Recognizing tap outside textfileds to dismiss the keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditIconViewController.DismissKeyboard))
        dismissView.addGestureRecognizer(tap)
        //Assign delegation for text fields.
        siteNameInputValue.delegate = self
        siteNameInputValue.addTarget(self, action: #selector(EditIconViewController.textFieldDidChange(textField:)), for: .editingChanged)
        siteLinkInputValue.delegate = self
        siteLinkInputValueForLargeWeb.delegate = self
        
        for indexA in 0 ..< Icons.fileName.count  {
            let key: String = Icons.name[indexA]
            //print(key)
            let value: String = Icons.fileName[indexA]
            //print(value)
            dataSource[key] = value
        }
        
        let siteNamesData = db.query(sql:"SELECT item_name FROM item_details")
        for indexA in 0 ..< siteNamesData.count  {
            let lowercaseText = (siteNamesData[indexA]["item_name"] as! String).lowercased()
            if SharingManager.sharedInstance.itemName.lowercased() != lowercaseText {
                siteNames[lowercaseText] = lowercaseText
            }
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        siteImageCollectionView.collectionViewLayout = layout
        
        //Method called to reload table when app running from background to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(EditIconViewController.passcodeCheck(notification:)), name: NSNotification.Name(rawValue: "passcodeCheck"), object: nil)
        //To get the keyboard height.
        NotificationCenter.default.addObserver(self, selector: #selector(EditIconViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditIconViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Hiding or unhiding views
//        urlView.isHidden = true
        siteImagePickUpView.isHidden = true
        focusView.isHidden = false
        //Designating frame location and size.
//        webContainerView.frame = CGRect(x: 0.0, y: focusView.frame.origin.y, width: focusView.frame.size.width, height: focusView.frame.size.height)
//        editWebView!.frame = CGRect(x: 0.0, y: 0.0, width: webContainerView.frame.size.width, height: webContainerView.frame.size.height)
        siteImageCollectionView.frame = CGRect(x: 0.0, y: 44.0, width: siteImagePickUpView.frame.size.width, height: (siteImagePickUpView.frame.size.height - 44.0))
        
        if loadInputs == true {
            loadInputValues()
        }
        
        let check = General.storageDefaults.string(forKey:"check")
        if "true" == check {
            General.storageDefaults.set("false", forKey: "check")
            siteImageName = General.storageDefaults.string(forKey:"croppedImageName")!
            siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName: siteImageName)
            siteImageSelectionButton.setTitle("Reset", for: .normal)
            deviceImageActive = true
            General.storageDefaults.set("None", forKey: "croppedImageName")
            //print("This condition called.")
            siteNameInputValue.becomeFirstResponder()
        }
        
        if siteLinkInputValue.text == "" {
            url = NSURL (string: "http://www.google.com")
            let requestObj = NSURLRequest(url: url! as URL)
            editWebView!.load(requestObj as URLRequest)
        } else {
            url = NSURL (string: siteLinkInputValue.text!)
            let requestObj = NSURLRequest(url: url! as URL)
            editWebView!.load(requestObj as URLRequest)
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
        editWebView!.frame = CGRect(x: 0.0, y: 0.0, width: webContainerView.frame.size.width, height: webContainerView.frame.size.height)
    }
    
    @IBAction func doneBrowsingAction(sender: UIButton) {
        
//        urlView.isHidden = true
        focusView.isHidden = false
        webContainerViewHeightEnable = false
        //Designating frame location and size.
        webContainerView.frame = CGRect(x: 0.0, y: focusView.frame.origin.y, width: focusView.frame.size.width, height: focusView.frame.size.height)
        editWebView!.frame = CGRect(x: 0.0, y: 0.0, width: webContainerView.frame.size.width, height: webContainerView.frame.size.height)
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
    
    func loadInputValues() {
        
        siteImageSelectionButton.setTitle("Select", for: .normal)
        let siteQuery = db.query(sql:"SELECT * FROM item_details WHERE item_name='\(SharingManager.sharedInstance.itemName!)'")
        let siteDetails = siteQuery[0]
        //Filling text fields with values.
        if siteNameInputValue.text == "" {
            doneButton.isEnabled = true
            siteNameInputValue.textColor = UIColor.black
            siteNameInputValue.text = siteDetails["item_name"] as! String
            alertLabel.text = "Please type unique name for site icon."
            alertLabel.textColor = UIColor.darkGray
        }
        if siteLinkInputValue.text == "" {
            siteLinkInputValue.text = siteDetails["item_link"] as! String
            siteLinkInputValueForLargeWeb.text = siteDetails["item_link"] as! String
        }
        siteimageLocalStorageValue = siteDetails["image_local_storage"] as! String
        if siteimageLocalStorageValue == "true" {
            dbLocalSiteImageName = siteDetails["item_image"] as! String
            siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName:dbLocalSiteImageName)
        } else {
            dbSiteImageName = siteDetails["item_image"] as! String
            siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName:dbSiteImageName)
        }
        siteFavouriteStatus = siteDetails["favourite_status"] as! String
        siteLocationNo = siteDetails["item_location_no"] as! Int
        //Reseting search bar
        self.cancelSearching()
        //Enabling buttons
        iconSelectionButton.isEnabled = true
        //Hiding view
        siteImagePickUpView.isHidden = true
    }
    
    //For passcode check
    @objc func passcodeCheck(notification: NSNotification) {
        
        passcodeScreenValidationStatus()
        //dismiss(animated: false, completion: nil)
    }
    
    func resetingEditView() {
        
        deviceImageActive = false
        siteImageName = "None"
        loadInputs = true
        
        siteImageSelectionButton.setTitle("Select", for: .normal)
        //Filling text fields with values.
        siteNameInputValue.text = ""
        siteNameInputValue.textColor = UIColor.black
        siteLinkInputValue.text = ""
        siteLinkInputValueForLargeWeb.text = ""
        siteimageLocalStorageValue = ""
        dbLocalSiteImageName = ""
        siteImageSelectedDisplay.image = UIImage(named: "Google-Plus-Icon-demo.png")
        dbSiteImageName = ""
        siteLocationNo = 0
        //Reseting search bar
        self.cancelSearching()
        //Enabling buttons
        iconSelectionButton.isEnabled = true
        //Hiding view
        siteImagePickUpView.isHidden = true
        collectionViewHeightEnable = false
    }
    
    //MARK:- Top panel button actions.
    @IBAction func dismissViewAction(sender: UIButton) {
        
        if deviceImageActive {
            RepeatMethods.deletingImageLocally(imageName: siteImageName)
        } else {
        }
        //Set loadInputValues check.
        resetingEditView()
        dismiss(animated: false, completion: nil)
    }
    
    @objc func DismissKeyboard(){
        //Dismissing key board.
        view.endEditing(true)
    }
    
    @IBAction func siteEditionAction(sender: UIButton) {
        
        var imageLocalStorage: String = "false"
        if deviceImageActive {
            imageLocalStorage = "true"
        } else {
            imageLocalStorage = siteimageLocalStorageValue
        }
        //Deleting local stored image and assigning to siteImageName.
        if siteImageName != "None" {
            if dbLocalSiteImageName == "" {
                
            } else if dbLocalSiteImageName != siteImageName {
                RepeatMethods.deletingImageLocally(imageName: dbLocalSiteImageName)
            }
        } else if siteImageName == "None" {
            if dbLocalSiteImageName != "" {
                siteImageName = dbLocalSiteImageName
            } else {
                siteImageName = dbSiteImageName
            }
        }
        if siteImageName != "None" && siteNameInputValue.text != "" {
            
            _ = db.execute(sql: "UPDATE item_details SET item_name='\(siteNameInputValue.text!)', item_image='\(siteImageName)', item_link='\(siteLinkInputValue.text!)', favourite_status='\(siteFavouriteStatus!)', image_local_storage='\(imageLocalStorage)' WHERE item_location_no='\(siteLocationNo!)'")
            //Displaying alert.
            let alertVC = UIAlertController(title: "Site Editing", message: "Site updated successfully.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            { action -> Void in
                self.resetingEditView()
                self.dismiss(animated: false, completion: nil)
                })
            present(alertVC, animated: true, completion: nil)
            
        } else {
            let alertVC = UIAlertController(title: "Empty Input", message: "Please type site name and pick site image at least.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
            alertVC.addAction(okAction)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        let typedSiteName = siteNameInputValue.text!.lowercased()
        let siteName = siteNames[typedSiteName]
        
        if (siteName == typedSiteName) {
            siteNameInputValue.text = ""
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
        
        if (textField == siteLinkInputValue || textField.text == siteLinkInputValueForLargeWeb.text) && textField.text != "" {
            textField.resignFirstResponder()
            siteLinkInputValue.text = textField.text
            siteLinkInputValueForLargeWeb.text = textField.text
            loadingTextFieldURL(urlString: siteLinkInputValue.text!)
            //print("Load called.")
            return true
        } else if textField.text == siteNameInputValue.text {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    func loadingTextFieldURL(urlString: String) {
        
        url = NSURL(string: RepeatMethods.makingFormalURL(urlString: urlString))
        let requestObj = NSURLRequest(url: url! as URL)
        editWebView!.load(requestObj as URLRequest)
    }
    
    //MARK:- Height adjustments for webContainerView and collectionView when keyboard is visible.
    @objc func keyboardWillShow(notification:NSNotification) {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        if collectionViewHeightEnable == true {
            siteImageCollectionView.frame.size.height = siteImageCollectionView.frame.size.height - keyboardHeight
        }
        if webContainerViewHeightEnable == true {
            webContainerView.frame.size.height = webContainerView.frame.size.height - keyboardHeight
            editWebView?.frame.size.height = webContainerView.frame.size.height
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        
        if collectionViewHeightEnable == true {
            siteImageCollectionView.frame.size.height = siteImagePickUpView.frame.size.height - 44.0
        }
        if webContainerViewHeightEnable == true {
            webContainerView.frame.size.height = dismissView.frame.size.height - urlView.frame.size.height
            editWebView?.frame.size.height = webContainerView.frame.size.height
        }
    }
    
    //MARK:- Collection view methods.
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidthAndHeight: CGSize = CGSize(width: 45, height: 45)
        
        return cellWidthAndHeight
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = siteImageCollectionView.dequeueReusableCell(withReuseIdentifier: "siteImage", for: indexPath)
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
                siteIconImage.image = RepeatMethods.getImageFromLocalStorage(imageName:imageName!)
            }
        } else {
            let imageName = Icons.fileName[indexPath.item]
            siteIconImage.image = RepeatMethods.getImageFromLocalStorage(imageName:imageName)
        }
        cell.addSubview(siteIconImage)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //deviceImageActive = false
        if (dataSourceSearchedResults.count > 0) {
            let itemName = dataSourceSearchedResults[indexPath.item]
            if dataSource.count > 0 {
                let imageName = dataSource[itemName]
                siteImageName = imageName!
                siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName:imageName!)
            }
        } else {
            let imageName = Icons.fileName[indexPath.item]
            siteImageName = imageName
            siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName:imageName)
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
    
    //MARK: methods for after getting or taking photo
    //Selecting image from device photo library.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.dismiss(animated: false) { () -> Void in
            let cropViewController: ImageCropViewController = ImageCropViewController(image: image)
            //controller.delegate = self
            cropViewController.blurredBackground = true
            cropViewController.cropImageBoundryValue = "Circle" //Square, Circle
            self.present(cropViewController, animated: false, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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
        
        siteImageSelectionButton.setTitle("Done", for: .normal)
        resetSelectedImage()
        //Set loadInputValues condition.
        loadInputs = false
        //Disabling and enabling buttons.
        iconSelectionButton.isEnabled = true
        //Visible view
        siteImagePickUpView.isHidden = true
        //Opening camera.
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            noCamera()
            siteImageSelectionButton.setTitle("Select", for: .normal)
        }
    }
    
    @IBAction func galleryImageAction(sender: UIButton) {
        
        siteImageSelectionButton.setTitle("Done", for: .normal)
        resetSelectedImage()
        //Set loadInputValues condition.
        loadInputs = false
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
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func iconImageAction(sender: UIButton) {
        
        siteImageSelectionButton.setTitle("Done", for: .normal)
        resetSelectedImage()
        iconImageSelectionScreen()
    }
    
    @IBAction func captureWebViewScreenAction(sender: UIButton) {
        
        //Set loadInputValues condition.
        loadInputs = false
        //Deleting local image
        resetSelectedImage()
        //Disabling and enabling buttons.
        iconSelectionButton.isEnabled = true
        //Visible view
        siteImagePickUpView.isHidden = true
        //Open editing screen.
        let image: UIImage = RepeatMethods.captureWebViewScreen(webView: editWebView!)
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
        //Visible view
        siteImagePickUpView.isHidden = false
        siteImagePickUpView.isHidden = false
        //siteImageCameraViewActive = true
        collectionViewHeightEnable = true
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
            if dbLocalSiteImageName != "" {
                siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName: dbLocalSiteImageName)
            } else {
                siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName: dbSiteImageName)
            }
        } else {
            siteImageName = "None"
            if dbLocalSiteImageName != "" {
                siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName: dbLocalSiteImageName)
            } else {
                siteImageSelectedDisplay.image = RepeatMethods.getImageFromLocalStorage(imageName: dbSiteImageName)
            }
        }
    }
    
    //MARK:- WKWebView methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "loading" {
            if editWebView!.estimatedProgress == 1 {
                loadCompletedValue = 0
                let loadedUrl = editWebView!.url?.absoluteString as String?
                if loadedUrl != "about:blank" {
                    siteLinkInputValue.text = loadedUrl
                    siteLinkInputValueForLargeWeb.text = loadedUrl 
                    if loadedUrl!.lowercased().range(of: "google") != nil {
                        editWebView?.becomeFirstResponder()
                    } else {
                        siteNameInputValue.becomeFirstResponder()
                    }
                }
                //print(loadCompletedValue)
            } else {
                loadCompletedValue = loadCompletedValue - 1
                if loadCompletedValue == -2 {
                    let htmlString:String = "<html><body><div style='font-color:black;width:100%;height:100%;margin-top:50%;text-align:center;font-weight:bold;font:28px arial'>Page not found.</div></body></html>"
                    editWebView!.loadHTMLString(htmlString, baseURL: nil)
                }
                //print(loadCompletedValue)
            }
        }
    }
}
