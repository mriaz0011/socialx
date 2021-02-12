//
//  SocialCollectionViewCell.swift
//  socialx
//
//  Created by Muhammad Riaz on 27/12/2015.
//  Copyright © 2015 Muhammad Riaz. All rights reserved.
//

import UIKit


protocol MainViewCellDelegate : class {
    
    func deleteCellPressButton(_ tag: Int)
}

class SocialCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var baseBackgroundColor : UIColor?
    var searchBarActive: Bool = false
    
    var deleteCellDelegate: MainViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImage.layer.borderWidth = 1
        iconImage.layer.borderColor = CommonUtilities.webColor("F9AC18").cgColor //UIColor.whiteColor().CGColor
        iconImage.layer.cornerRadius = iconImage.frame.size.width/6
        iconImage.clipsToBounds = true
    }
    
    @IBAction func deleteButtonAction(sender: UIButton) {
        
        print(sender.tag)
        deleteCellDelegate?.deleteCellPressButton(sender.tag)
    }
    
    
    
    /*var dragging : Bool = false {
    
        didSet {
            if dragging == true {
                if (searchBarActive) {
                    
                } else {
                    iconImage.layer.masksToBounds = false
                    iconImage.layer.cornerRadius = 0.0
                    iconImage.layer.shadowOffset = CGSizeMake(-4.0, 0)
                    iconImage.layer.shadowRadius = 1.25
                    iconImage.layer.shadowOpacity = 0.6
                    iconImage.layer.shadowColor = UIColor.yellowColor().CGColor
                    //self.baseBackgroundColor = self.backgroundColor
                    //self.backgroundColor = UIColor.red
                }
            } else {
                iconImage.layer.shadowColor = UIColor.clearColor().CGColor
            }
        }
    }*/
    
}
