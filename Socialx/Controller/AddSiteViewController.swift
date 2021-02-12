//
//  AddSiteViewController.swift
//  Socialx
//
//  Created by Muhammad Riaz on 12/01/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit
//import MobileCoreServices

class AddSiteViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //Outlet reference.
    @IBOutlet weak var siteNameInputValue: UITextField!
    @IBOutlet weak var siteLinkInputValue: UITextField!
    @IBOutlet weak var siteUsernameInputValue: UITextField!
    @IBOutlet weak var sitePasswordInputValue: UITextField!
    @IBOutlet weak var siteImageSelectedDisplay: UIImageView!
    @IBOutlet weak var siteImageSelectionButton: UIButton!
    @IBOutlet weak var iconSelectionButton: UIButton!
    @IBOutlet weak var gallerySelectionButton: UIButton!
    @IBOutlet weak var cameraSelectionButton: UIButton!
    @IBOutlet weak var siteImagePickUpView: UIView!
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet weak var siteImageSearchBar: UISearchBar!
    @IBOutlet weak var siteImageCollectionView: UICollectionView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    //Variables.
    var keyboardHeight: CGFloat!
    var collectionViewHeight: CGFloat = 0.0
    var collectionViewHeightEnable: Bool = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SharingManager.sharedInstance.urlAddressForAdd != "" {
            siteLinkInputValue.text = SharingManager.sharedInstance.urlAddressForAdd
        }
        
        siteImageSelectedDisplay.layer.cornerRadius = siteImageSelectedDisplay.frame.size.width/6
        siteImageSelectedDisplay.clipsToBounds = true
        
        //Hiding outlets.
        siteImagePickUpView.isHidden = true
        textFieldsView.isHidden = false
        alertLabel.isHidden = true
        doneButton.isEnabled = false
        siteImageSelectionButton.rounded
        //Recognizing tap outside textfileds to dismiss the keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddSiteViewController.DismissKeyboard))
        dismissView.addGestureRecognizer(tap)
        //Assign delegation for text fields.
        siteNameInputValue.delegate = self
        siteNameInputValue.addTarget(self, action: #selector(AddSiteViewController.textFieldDidChange(textField:)), for: .editingChanged)
        
        for indexA in 0 ..< Icons.fileName.count {
            let key: String = Icons.name[indexA]
            //print(key)
            let value: String = Icons.fileName[indexA]
            //print(value)
            dataSource[key] = value
        }
        
        let siteNamesData = db.query(sql: "SELECT item_name FROM item_details")
        for indexA in 0 ..< siteNamesData.count {
            let lowercaseText = (siteNamesData[indexA]["item_name"] as! String).lowercased()
            siteNames[lowercaseText] = lowercaseText
            //print(lowercaseText)
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        siteImageCollectionView.collectionViewLayout = layout
        
        //Method called to reload table when app running from background to foreground.
        NotificationCenter.default.addObserver(self, selector: #selector(AddSiteViewController.passcodeCheck(notification:)), name: NSNotification.Name(rawValue: "passcodeCheck"), object: nil)
        //To get the keyboard height.
        NotificationCenter.default.addObserver(self, selector: #selector(AddSiteViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddSiteViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let check = General.storageDefaults.string(forKey: "check")
        if "true" == check {
            General.storageDefaults.set("false", forKey: "check")
            siteImageName = General.storageDefaults.string(forKey: "croppedImageName")!
            siteImageSelectedDisplay.image = getImageFromLocalStorage(imageName: siteImageName)
            siteImageSelectionButton.setTitle("Reset", for: .normal)
            deviceImageActive = true
            General.storageDefaults.set("None", forKey: "croppedImageName")
            print("This condition called.")
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
    
    //MARK:- Top panel button actions.
    @IBAction func dismissViewAction(sender: UIButton) {
        
        if deviceImageActive {
            deletingImageLocally(imageName: siteImageName)
            deviceImageActive = false
        } else {
        }
        refreshingInputValues()
        dismiss(animated: false, completion: nil)
    }
    
    func refreshingInputValues() {
        
        deviceImageActive = false
        siteImageName = "None"
        
        siteImageSelectionButton.setTitle("Select", for: .normal)
        //Making text fields empty.
        siteNameInputValue.text = ""
        siteLinkInputValue.text = ""
        siteImageSelectedDisplay.image = UIImage(named: "Google-Plus-Icon-demo.png")
        //Reseting search bar
        self.cancelSearching()
        alertLabel.isHidden = true
        //Enabling buttons
        iconSelectionButton.isEnabled = true
        gallerySelectionButton.isEnabled = true
        cameraSelectionButton.isEnabled = true
        //Hiding view
        siteImagePickUpView.isHidden = true
        textFieldsView.isHidden = false
        collectionViewHeight = 0.0
        collectionViewHeightEnable = false
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
            let dataEntry = db.execute(sql: "INSERT INTO item_details (item_name, item_image, item_link, item_username, item_password, item_location_no, image_local_storage) VALUES ('\(siteNameInputValue.text!)', '\(siteImageName)', '\(siteLinkInputValue.text!)', '', '', '\(siteLocationNo!)', '\(imageLocalStorage)')")
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
            alertLabel.isHidden = false
            doneButton.isEnabled = false
        } else {
            siteNameInputValue.textColor = UIColor.black
            alertLabel.isHidden = true
            doneButton.isEnabled = true
        }
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        if collectionViewHeightEnable == true {
            siteImageCollectionView.frame.size.height = collectionViewHeight - keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        
        if collectionViewHeightEnable == true {
            siteImageCollectionView.frame.size.height = collectionViewHeight
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
        
        deviceImageActive = false
        if (dataSourceSearchedResults.count > 0) {
            let itemName = dataSourceSearchedResults[indexPath.item]
            if dataSource.count > 0 {
                let imageName = dataSource[itemName]
                siteImageName = imageName!
                siteImageSelectedDisplay.image = getImageFromLocalStorage(imageName: imageName!)
            }
        } else {
            let imageName = Icons.fileName[indexPath.item]
            siteImageName = imageName
            siteImageSelectedDisplay.image = getImageFromLocalStorage(imageName: imageName)
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
    
    //Getting image from local storage.
    func getImageFromLocalStorage(imageName: String) -> UIImage {
        
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
    
    //Saving image in local storage.
    func savingImageLocally(selectedImage: UIImage) -> String {
        
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
    
    //Deleting existing local files.
    func deletingImageLocally(imageName: String) {
        
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
    
    @IBAction func cameraImageAction(sender: UIButton) {
        
        siteImageSelectionButton.setTitle("Done", for: .normal)
        resetSelectedImage()
        //Disabling and enabling buttons.
        cameraSelectionButton.isEnabled = false
        iconSelectionButton.isEnabled = true
        gallerySelectionButton.isEnabled = true
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
        
        siteImageSelectionButton.setTitle("Done", for: .normal)
        resetSelectedImage()
        //Disabling and enabling buttons.
        gallerySelectionButton.isEnabled = false
        iconSelectionButton.isEnabled = true
        cameraSelectionButton.isEnabled = true
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
    
    func iconImageSelectionScreen() {

        DismissKeyboard()
        //Disabling and enabling buttons.
        iconSelectionButton.isEnabled = false
        cameraSelectionButton.isEnabled = true
        gallerySelectionButton.isEnabled = true
        //Visible view
        textFieldsView.isHidden = true
        siteImagePickUpView.isHidden = false
        //siteImageCameraViewActive = true
        if collectionViewHeight == 0.0 {
            collectionViewHeightEnable = true
            collectionViewHeight = siteImageCollectionView.frame.height
        }
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
        gallerySelectionButton.isEnabled = true
        cameraSelectionButton.isEnabled = true
        //Hiding view
        siteImagePickUpView.isHidden = true
        textFieldsView.isHidden = false
    }
    
    func resetSelectedImage() {
        
        if deviceImageActive {
            deletingImageLocally(imageName: siteImageName)
            deviceImageActive = false
            siteImageName = "None"
            siteImageSelectedDisplay.image = UIImage(named: "Google-Plus-Icon-demo.png")
        } else {
            siteImageName = "None"
            siteImageSelectedDisplay.image = UIImage(named: "Google-Plus-Icon-demo.png")
        }
    }
}

