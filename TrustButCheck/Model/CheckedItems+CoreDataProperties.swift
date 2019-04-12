//
//  CheckedItems+CoreDataProperties.swift
//  TrustButCheck
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Jesse Flores. All rights reserved.
//
//

import Foundation
import CoreData


extension CheckedItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CheckedItems> {
        return NSFetchRequest<CheckedItems>(entityName: "CheckedItems")
    }

    @NSManaged public var daily_amount: Int16
    @NSManaged public var item_name: String?
    @NSManaged public var start_amount: Int16
    @NSManaged public var start_date: NSDate?
    @NSManaged public var finish_date: NSDate?

    var rest_amount: Int16 {
        get{
            return start_amount - daily_amount * getSpendedDays()
        }
    }
    
    var spend_amount: Int16 {
        get{
            return daily_amount * getSpendedDays()
        }
    }

    private func getSpendedDays() -> Int16 {
        let date = Date()
        let difference = date.timeIntervalSince(start_date! as Date)
        return Int16(difference/(60 * 60 * 24 ))
    }
}
