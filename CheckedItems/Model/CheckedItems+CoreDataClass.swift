//
//  CheckedItems+CoreDataClass.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CheckedItems)
public class CheckedItems: NSManagedObject {

    private static var sharedCheckedItems: CheckedItems = {
        let checkedItems = CheckedItems()
        return checkedItems
    }()

    class func shared() -> CheckedItems {
        return sharedCheckedItems
    }

    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "CheckedItems"),
                  insertInto: CoreDataManager.instance.managedObjectContext)
    }

    private class func createNewFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CheckedItems")
        request.returnsObjectsAsFaults = false
        let sortDescriptorNum = NSSortDescriptor(key: "finishDate", ascending: true)
        request.sortDescriptors = [sortDescriptorNum]
        return request
    }

    public class func getItemByName(_ name: String) -> CheckedItems {
        let request = createNewFetchRequest()
        request.predicate = NSPredicate(format: "name = %ld", name)
        let result = try? CoreDataManager.instance.managedObjectContext.fetch(request)
        guard let item = result?.first as? CheckedItems else {
            fatalError("Wrong item's name: " + name)
        }
        return item
    }

    public class func itemsCount() -> Int {
        let request = createNewFetchRequest()
        guard let result = try? CoreDataManager.instance.managedObjectContext.fetch(request) as? [CheckedItems] else {
            fatalError("No items in entity")
        }
        return result!.count
    }

    public class func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = createNewFetchRequest()
        let managedObject = CoreDataManager.instance.managedObjectContext
        let fetchedResultsCtrl = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: managedObject,
                                                            sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsCtrl
    }
}
