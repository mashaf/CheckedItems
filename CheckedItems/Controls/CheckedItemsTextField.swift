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
    nilDataInput(textFieldName: String),
    wrongNumberFormat(textFieldName: String),
    wrongDateFormat(textFieldName: String),
    otherError(errorMessage: String)

    var localizedDescription: String {
        switch self {
        case .wrongNumberFormat(let textFieldName):
            return "Wrong number format. \"\(textFieldName)\" must be a number."
        case .wrongDateFormat(let textFieldName):
            return "Wrong date format. \"\(textFieldName)\" must be a date."
        case .nilDataInput(let textFieldName):
            return "You missed a text field. \"\(textFieldName)\" must be entered before adding."
        case .otherError(let errorMessage), .wrongDataInputFormat(let errorMessage):
            return errorMessage
        }
    }
}

class CheckedItemsTextField: UITextField {

    var errorTitleWorld: String?
    var errorEmptyFieldType: CheckedItemsTextFieldError? //Error?
    var datePicker: UIDatePicker?

    var dataFormat: CheckedItemsInputDataFormat = .text {
        didSet {
            setInputView()
        }
    }

    var textFieldName: String! {
        return checkString(placeholder) ? placeholder! : "this one"
    }

    // MARK: Setters
    func setValue(_ newValue: Any?) {

        var newString = ""

        switch dataFormat {
        case .date:
            let formatter = DateFormatter()
            formatter.dateFormat = dataFormat.rawValue
            guard let newDate = newValue as? Date else {
                fatalError("Wrong date format for \(String(describing: newValue))")
            }
            newString = formatter.string(from: newDate)

        case .number:
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            guard let newNumber = newValue as? CheckedItemAmountDataType else {
                fatalError("Wrong number format for \(String(describing: newValue))")
            }
            newString = formatter.string(from: NSNumber(value: newNumber)) ?? "0"

        default:
            guard let newNewString = newValue as? String else {
                fatalError("Wrong string format for \(String(describing: newValue))")
            }
            newString = newNewString
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

    // MARK: validation methods
    func checkInputValueAndNull() throws {
        if !checkString(text) {
            checkValueIs(success: false)
            becomeFirstResponder()
            throw CheckedItemsTextFieldError.nilDataInput(textFieldName: textFieldName)
        } else {
            try checkInputValue()
        }
    }

    func checkInputValue() throws {

        switch dataFormat {
        case .number:
            guard CheckedItemAmountDataType(text ?? "0") != nil else {
                checkValueIs(success: false)
                becomeFirstResponder()
                throw CheckedItemsTextFieldError.wrongNumberFormat(textFieldName: textFieldName)
            }
        case .date:
            guard DateHelper.getDateFrom(text!) != nil else {
                checkValueIs(success: false)
                becomeFirstResponder()
                throw CheckedItemsTextFieldError.wrongDateFormat(textFieldName: textFieldName)
            }
        default:
            break
        }
        
        checkValueIs(success: true)
        
    }

    func checkValueIs(success: Bool) {
       // do something if you need to
    }

    private func checkString(_ string: String?) -> Bool {
        guard let trimmedString = string?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) else {
            return false
        }
        return !trimmedString.isEmpty
    }
}
