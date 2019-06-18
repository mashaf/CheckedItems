//
//  CheckedItemsViewModel.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 4/15/19.
//  Copyright © 2019 Maria Soboleva. All rights reserved.
//

import UIKit

struct CheckedItemsViewModel {

    var dailyAmount: String
    var itemName: String
    var startAmount: String
    var startDate: String
    var finishDate: String
    var restAmount: String
    var spentAmount: String
    var image: UIImage
    
    //init(item:CheckedItems) {
    //    return self
    //}
    
    static func deleteCheckedItem(_ item: CheckedItems) {
        CoreDataManager.instance.managedObjectContext.delete(item)
        CoreDataManager.instance.saveContext()
    }
    
}
