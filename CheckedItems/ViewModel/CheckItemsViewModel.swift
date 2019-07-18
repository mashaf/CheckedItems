//
//  CheckedItemsViewModel.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 4/15/19.
//  Copyright © 2019 Maria Soboleva. All rights reserved.
//

import UIKit

struct CheckedItemsViewModel {
    
    // placeholder for working with list of items
    
    static func deleteItem(_ item: CheckedItems) {
        CoreDataManager.instance.managedObjectContext.delete(item)
        CoreDataManager.instance.saveContext()
    }
}
