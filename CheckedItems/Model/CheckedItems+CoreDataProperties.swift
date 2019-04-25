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

public typealias CheckedItemAmountDataType = Int16

extension CheckedItems {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CheckedItems> {
        return NSFetchRequest<CheckedItems>(entityName: "CheckedItems")
    }

    @NSManaged public var dailyAmount: CheckedItemAmountDataType
    @NSManaged public var itemName: String?
    @NSManaged public var startAmount: CheckedItemAmountDataType
    @NSManaged public var startDate: NSDate?
    @NSManaged public var finishDate: NSDate?
    @NSManaged public var image: NSData?

    var restAmount: CheckedItemAmountDataType {
        return startAmount - dailyAmount * getSpentDays()
    }

    var spentAmount: CheckedItemAmountDataType {
        return dailyAmount * getSpentDays()
    }

    private func getSpentDays() -> CheckedItemAmountDataType {
        let date = Date()
        let difference = date.timeIntervalSince(startDate! as Date)
        return CheckedItemAmountDataType(difference/(60 * 60 * 24 ))
    }
}
