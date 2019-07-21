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
// add background scheduling

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
            self.schedule()
        }
    }
    
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.clearScheduledNotifications()
                guard let items = CheckedItems.getRunOutSoonItemsList() else { break }
                self.scheduleNotifications(for: items, on: nil)
            default:
                break
            }
        }
    }
    
    func scheduleFutureNotifications() {
        guard let allItems = CheckedItems.allItems() else { return }
        for item in allItems {
            guard let finishDate = item.finishDate as Date? else { continue }
            let dateNotification = Calendar.current.date(byAdding: .day, value: -10, to: finishDate)
            scheduleNotifications(for: [item], on: dateNotification)
        }
    }
    
    func clearScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationCheckItemId])
    }
    
    func processNotification() {
        clearScheduledNotifications()
        removeDeliveredNotification()
    }

    // MARK: Private methods
    private func scheduleNotifications(for items: [CheckedItems], on date: Date?) {
        
        let date = DateHelper.getNotificationDateComponents(for: date)
        
        guard let notificationContextBody = getNotificationBody(for: items),
            !notificationContextBody.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "There some items are going to run out:\n"
        content.body = notificationContextBody
        content.sound = UNNotificationSound.default()
        content.badge = 1
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        let request = UNNotificationRequest(identifier: notificationCheckItemId, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            guard error == nil else { return }
        }
    }
    
    private func getNotificationBody(for items: [CheckedItems]) -> String? {
        
        let notificationString = items.reduce("") { (res, item) -> String in
            let difference = (item.finishDate as Date? ?? Date()).timeIntervalSince(Date())
            let restDays = round(difference/(60 * 60 * 24 ))
            return res + "\n\(item.itemName) is running out in \(restDays) days."
        }
        
        return notificationString
    }

    private func removeDeliveredNotification() {
         UNUserNotificationCenter.current().removeAllDeliveredNotifications()
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

