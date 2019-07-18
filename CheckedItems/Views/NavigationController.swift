//
//  NavigationController.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 6/20/19.
//  Copyright © 2019 Jesse Flores. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController, Instantiatable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleNotification), name: NSNotification.Name.UIApplicationSignificantTimeChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleNotification), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
    }
    
    @objc private func scheduleNotification() {
        NotificationController.shared().schedule()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
