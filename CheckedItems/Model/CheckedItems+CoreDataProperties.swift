//
//  CheckedItems+CoreDataProperties.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//
//

import Foundation
import CoreData

public typealias checkedItemAmountDataType = Int16

extension CheckedItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CheckedItems> {
        return NSFetchRequest<CheckedItems>(entityName: "CheckedItems")
    }

    @NSManaged public var daily_amount: checkedItemAmountDataType
    @NSManaged public var item_name: String?
    @NSManaged public var start_amount: checkedItemAmountDataType
    @NSManaged public var start_date: NSDate?
    @NSManaged public var finish_date: NSDate?
    @NSManaged public var image: NSData?

    var rest_amount: checkedItemAmountDataType {
        get{
            return start_amount - daily_amount * getSpentDays()
        }
    }
    
    var spent_amount: checkedItemAmountDataType {
        get{
            return daily_amount * getSpentDays()
        }
    }

    private func getSpentDays() -> checkedItemAmountDataType {
        let date = Date()
        let difference = date.timeIntervalSince(start_date! as Date)
        return checkedItemAmountDataType(difference/(60 * 60 * 24 ))
    }
}
