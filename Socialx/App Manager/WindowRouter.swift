//
//  WindowRouter.swift
//  Knotive
//
//  Created by Muhammad Riaz on 01/01/2021.
//

import UIKit
import LocalAuthentication

struct WindowRouter {
    
    private var window: UIWindow?? {
        return UIApplication.shared.delegate?.window
    }
    
    private func clear(_ window: UIWindow??) {
        window??.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func showMainApp() {
        
        clear(window)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window??.rootViewController = vc
    }
}
