//
//  CheckedItemsViewModel.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 4/15/19.
//  Copyright © 2019 Jesse Flores. All rights reserved.
//

import UIKit

class CheckedItemsViewModel {

    static func deleteCheckedItem(_ item: CheckedItems) {
        CoreDataManager.instance.managedObjectContext.delete(item)
        CoreDataManager.instance.saveContext()
    }
}
