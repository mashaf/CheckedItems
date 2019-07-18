//
//  NotificationController.swift
//  KidsSaveOcean
//
//  Created by Maria Soboleva on 6/24/19.
//  Copyright © 2019 Maria Soboleva. All rights reserved.
//

import UIKit
import UserNotifications

// highlight the run out items?

class NotificationController: NSObject {
    let notificationCheckItemId = "checkedItemsLocalNotificationId"
    
    private static var sharedNotificationController: NotificationController = {
        let notificationController = NotificationController()
        UNUserNotificationCenter.current().delegate = notificationController
        return notificationController
    }()
    
    class func shared() -> NotificationController {
        return sharedNotificationController
    }
    
    func requestAuthorization() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (success, error) in
            guard success == true, error == nil else {
                print(error!.localizedDescription)
                return
            }
            self.scheduleNotifications()
        }
    }
    
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break
            }
        }
    }

    private func scheduleNotifications() {
        
        clearScheduledNotifications()
        
        guard let notificationContextBody = getNotificationBody(),
            !notificationContextBody.isEmpty else {return}
        
        let content = UNMutableNotificationContent()
        content.title = "There some items are going to run out:\n"
        content.body = notificationContextBody
        content.sound = UNNotificationSound.default()
        content.badge = 1
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateHelper.getNotificationDateComponents(), repeats: false)
        let request = UNNotificationRequest(identifier: notificationCheckItemId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            guard error == nil else { return }
        }
    }
    
    private func getNotificationBody() -> String? {
        
        let runOutSoonItems = CheckedItems.getRunOutSoonItemsList()
        if runOutSoonItems.count == 0 { return nil }
        
        let notificationString = runOutSoonItems.reduce("") { (res, item) -> String in
            let difference = (item.finishDate as Date? ?? Date()).timeIntervalSince(Date())
            let restDays = round(difference/(60 * 60 * 24 ))
            return res + "\n\(item.itemName) is running out in \(restDays) days."
        }
        
        return notificationString
    }
    
    func clearScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationCheckItemId])
    }
}

extension NotificationController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}

