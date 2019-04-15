//
//  CheckedItemsLayoutConstraint.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 4/15/19.
//  Copyright © 2019 Maria Soboleva. All rights reserved.
//

import UIKit

let screenScaleFactor:CGFloat = UIScreen.main.bounds.height < 667 ? 2/3 : 1

class CheckedItemsLayoutConstraint: NSLayoutConstraint {
    
    override var constant: CGFloat {
        set {
            super.constant *= screenScaleFactor
        }
        get {
            return super.constant*screenScaleFactor
        }
    }
}
