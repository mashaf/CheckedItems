//
//  CheckedItemsTextField.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 4/12/19.
//  Copyright © 2019 Maria Soboleva. All rights reserved.
//

import UIKit

enum CheckedItemsInputDataFormat: String {
    case text,
    date = "MM/dd/yy",
    number
}

enum CheckedItemsTextFieldError: Error {
    case wrongDataInputFormat(errorMessage: String),
    nilDataInput(fieldName: String),
    wrongNumberFormat(fieldName: String),
    wrongDateFormat(fieldName: String),
    otherError(errorMessage: String)
}

enum CheckedItemsErrorMessageDetailed: Error {
    
    case other(errorMessage: String),
    wrongNumberFormat(textFieldName: String),
    wrongDateFormat(textFieldName: String),
    fieldMissed(textFieldName: String)
    
    var localizedDescription: String {
        switch self {
        case .wrongNumberFormat(let textFieldName):
            return "Wrong number format. \"\(textFieldName)\" must be a number."
        case .wrongDateFormat(let textFieldName):
            return "Wrong date format. \"\(textFieldName)\" must be a date."
        case .fieldMissed(let textFieldName):
            return "You missed a text field. \"\(textFieldName)\" must be entered before adding."
        case .other(let errorMessage):
            return errorMessage
        }
    }
}

class CheckedItemsTextField: UITextField {
    
    var errorTitleWorld: String?
    var errorEmptyFieldType: Error?
    var datePicker: UIDatePicker?
    
    var dataFormat:CheckedItemsInputDataFormat = .text {
        didSet {
            setInputView()
        }
    }
    
    var textFieldName:String! {
        get {
            return checkString(placeholder) ? placeholder! : "this one"
        }
    }

    // MARK: Setters
    func setValue(_ newValue: Any?) {
        
        var newString = ""
        
        switch dataFormat {
         case .date:
            let formatter = DateFormatter()
            formatter.dateFormat = dataFormat.rawValue
            newString = formatter.string(from: newValue as! Date)
            
        case .number:
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            newString = formatter.string(from: NSNumber(value: newValue as! checkedItemAmountDataType))!
            
        default:
            newString = newValue as! String
        }
        
        text = newString
    }
    
    /// keyboard with predefined type or UIDatePicker
    func setInputView() {
        
        switch dataFormat {
        case .number:
            keyboardType = .decimalPad
        case .date:
            inputView = datePicker
        default:
            keyboardType = .default
        }
        
    }
    
    //MARK: validation methods
    func checkInputValueAndNull() throws -> (Any?) {
        if !checkString(text) {
            checkValueIs(ok: false)
            becomeFirstResponder()
            throw CheckedItemsTextFieldError.nilDataInput(fieldName: textFieldName)
        } else {
            return try checkInputValue()
        }
    }
    
    
    func checkInputValue() throws -> (Any?) {
        
        switch dataFormat {
        case .number:
            let f = Int(text ?? "0")
            if f == nil {
                checkValueIs(ok: false)
                becomeFirstResponder()
                throw CheckedItemsTextFieldError.wrongNumberFormat(fieldName: textFieldName)
            } else {
                checkValueIs(ok: true)
                return f
            }
        case .date:
            let d = checkDate()
            if  d == nil {
                checkValueIs(ok: false)
                becomeFirstResponder()
                throw CheckedItemsTextFieldError.wrongDateFormat(fieldName: textFieldName)
            } else {
                checkValueIs(ok: true)
                return d
            }
        default:
            checkValueIs(ok: true)
            return text
        }
    }
    
    func checkDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dataFormat.rawValue
        return dateFormatter.date(from: text!)
    }
    
    func checkValueIs(ok:Bool) {
       // do something if you need to
    }
    
    private func checkString(_ string: String?) -> Bool {
        guard let trimmedString = string?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) else {
            return false
        }
        return trimmedString.count != 0
    }
}
