//
//  ReadLaterTableViewCell.swift
//  socialx
//
//  Created by Muhammad Riaz on 15/05/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit

class ReadLaterTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var siteTitleLabel: UILabel!
    @IBOutlet weak var siteUrlLabel: UILabel!
    @IBOutlet weak var siteAddedDateLabel: UILabel!    
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        siteAddedDateLabel.layer.cornerRadius = siteAddedDateLabel.frame.size.width/6
        siteAddedDateLabel.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
