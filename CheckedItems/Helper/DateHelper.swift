//
//  DateHelper.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 5/9/19.
//  Copyright © 2019 Maria Soboleva. All rights reserved.
//

import UIKit

class DateHelper {

    static let dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = CheckedItemsInputDataFormat.date.rawValue
        return formatter
    }()
    
    static func getDateFrom(_ text: String) -> NSDate? { /// TO DO may by wrap it to NSDate?
        return dateFormatter.date(from: text) as NSDate?
    }
    
    static func getStringFrom(_ date: NSDate) -> String? {
        return dateFormatter.string(from: date as Date)
    }
    
    static func getDateFor(_ date: NSDate, since days: CheckedItemAmountDataType) -> NSDate? {
        var components = DateComponents()
        components.day = Int(days)
        return Calendar.current.date(byAdding: components, to: date as Date) as NSDate?
    }
    
    static func getNotificationDateComponents() -> DateComponents {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)//15 //TODO check if the date.hour > 15 (if user restart app later)
        let minute = calendar.component(.minute, from: date) + 1 // 00
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return DateComponents(calendar: Calendar.current, year: year, month: month, day: day, hour: hour, minute: minute)
    }
}
