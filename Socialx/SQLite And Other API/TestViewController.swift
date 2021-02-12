//
//  TestViewController.swift
//  socialx
//
//  Created by Muhammad Riaz on 08/04/2016.
//  Copyright © 2016 Muhammad Riaz. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width/9
        iconImageView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

