//
//  FavouritesTableViewCell.swift
//  socialx
//
//  Created by Muhammad Riaz on 13/05/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit

class FavouritesTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var siteImage: UIImageView!
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var siteUrlLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        siteImage.layer.cornerRadius = siteImage.frame.size.width/6
        siteImage.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
