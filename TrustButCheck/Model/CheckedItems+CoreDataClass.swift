//
//  CheckedItems+CoreDataClass.swift
//  TrustButCheck
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Jesse Flores. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CheckedItems)
public class CheckedItems: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.instance.entityForName(entityName: "CheckedItems"), insertInto: CoreDataManager.instance.managedObjectContext)
    }
    
    private class func createNewFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CheckedItems")
        request.returnsObjectsAsFaults = false
        let sortDescriptorNum = NSSortDescriptor(key: "finish_date", ascending: true)
        request.sortDescriptors = [sortDescriptorNum]
        return request
    }
    
    public class func getItemByName(_ name:String) -> CheckedItems {
        let request = createNewFetchRequest()
        request.predicate = NSPredicate(format: "name = %ld", name)
        let result = try? CoreDataManager.instance.managedObjectContext.fetch(request) as! [NSManagedObject]
        return result?.first as! CheckedItems
    }
    
    public class func itemsCount() -> Int {
        let request = createNewFetchRequest()
        let result = try? CoreDataManager.instance.managedObjectContext.fetch(request)  as! [CheckedItems]
        return (result?.count)!
    }
    
    public class func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = createNewFetchRequest()
        let fetchedResultsCtrl = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsCtrl
    }
}
