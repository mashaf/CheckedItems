//
//  NotificationProtocol.swift
//  KidsSaveOcean
//
//  Created by Maria Soboleva on 6/26/19.
//  Copyright © 2019 KidsSaveOcean. All rights reserved.
//

import UIKit

protocol NotificationProtocol {
    
    func clearNotifications() 
}

extension NotificationProtocol {
    
    func clearNotifications() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
