//
//  UIViewController+Extensions.swift
//  DailyTaskManager
//
//  Created by Maria Soboleva on 7/25/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {

    func setHidingKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
