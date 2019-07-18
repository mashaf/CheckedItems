//
//  CheckItemViewModel.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 5/9/19.
//  Copyright © 2019 Maria Soboleva. All rights reserved.
//

import UIKit

struct CheckItemViewModel {
    
    var dailyAmount: String? {
        didSet(newValue) {
            item.dailyAmount = CheckedItemAmountDataType(newValue ?? "0")!
        }
    }
    var itemName: String? {
        didSet(newValue) {
            item.itemName = newValue!
        }
    }
    var startAmount: String? {
        didSet(newValue) {
            item.startAmount = CheckedItemAmountDataType(newValue ?? "0")!
        }
    }
    var startDate: String? {
        didSet(newValue) {
            item.startDate = DateHelper.getDateFrom(newValue!)
        }
    }
    var finishDate: String? {
        didSet(newValue) {
            item.finishDate = DateHelper.getDateFrom(newValue!)
        }
    }
    var restAmount: String?
    var spentAmount: String?
    var image: UIImage? {
        didSet(newValue) {
            item.image = newValue != nil ? UIImagePNGRepresentation(newValue!) as NSData? : nil
        }
    }
    var item: CheckedItems {
        didSet(newValue) {
            
        }
    }

    init() {
        self.init(item: CheckedItems())
    }
    
    init(item: CheckedItems) {
        
        self.item = item
        
        self.dailyAmount = String(self.item.dailyAmount)
        self.itemName    = self.item.itemName
        self.startAmount = String(self.item.startAmount)
        
        self.startDate  = DateHelper.getStringFrom(self.item.startDate ?? NSDate())
        self.finishDate = DateHelper.getStringFrom(self.item.finishDate ?? NSDate())
        
        self.restAmount = String(self.item.restAmount)
        self.spentAmount = String(self.item.spentAmount)
        
        if self.item.image != nil {
            guard let imageFromData = UIImage(data: self.item.image! as Data) else {
                fatalError() //fatalError("Wrong image format for item \(self.item.itemName)")
            }
            self.image = imageFromData
        } else {
            self.image = #imageLiteral(resourceName: "camera")
        }
    }
    
    func saveVerifiedValues(name: String, dailyAmount: String, startAmount: String, startDate: String, image: UIImage?, boxCount: String?) {
        
        item.itemName = name
        item.dailyAmount = CheckedItemAmountDataType(dailyAmount) ?? 0
        
        item.startAmount = getItemsAmount(boxCount: boxCount, amountPerBox: startAmount)
        
        item.startDate = DateHelper.getDateFrom(startDate) as NSDate?
        
        let daysNumber = item.startAmount / item.dailyAmount
        item.finishDate = DateHelper.getDateFor(item.startDate!, since: daysNumber) as NSDate?
        
        if image != nil {
            item.image = UIImagePNGRepresentation(image!) as NSData?
        }
        
        CoreDataManager.instance.saveContext()
        
    }
    
    func addVerifiedValuesToItem(amount: String, boxCount: String?) {
        
        item.startAmount +=  getItemsAmount(boxCount: boxCount, amountPerBox: amount)
        
        let daysNumber = item.startAmount / item.dailyAmount
        item.finishDate = DateHelper.getDateFor(item.startDate!, since: daysNumber) as NSDate?
        
        CoreDataManager.instance.saveContext()
    }
    
    private func getItemsAmount(boxCount: String?, amountPerBox: String?) -> CheckedItemAmountDataType {
        
        let boxCountNum: CheckedItemAmountDataType = CheckedItemAmountDataType(boxCount ?? "1") ?? 1
        let amountPerBoxNum: CheckedItemAmountDataType = CheckedItemAmountDataType(amountPerBox ?? "0") ?? 0
        return boxCountNum * amountPerBoxNum
        
    }
}
