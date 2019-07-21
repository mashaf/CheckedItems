//
//  AppDelegate.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let rootViewController = CheckedItems.allItems()?.count == 0 ? AddItemViewController.instantiate() : NavigationController.instantiate()
        window?.rootViewController = rootViewController
        
        NotificationController.shared().schedule()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        NotificationController.shared().scheduleFutureNotifications()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationController.shared().processNotification()
        completionHandler(UIBackgroundFetchResult.noData)
    }
}
