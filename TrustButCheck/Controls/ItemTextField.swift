//
//  ItemTextField.swift
//  TrustButCheck
//
//  Created by Maria Soboleva on 4/12/19.
//  Copyright © 2019 Jesse Flores. All rights reserved.
//

import UIKit

private let kItemTextFieldHeight:CGFloat = 40 //48

enum inputDataFormat: String {
    case text,
    percent,
    currency,
    currencyAndZero,
    shortDate = "M/dd",
    longDate = "MM/dd/yy",
    currencyName,
    number
}

enum ItemTextFieldError: Error {
    case wrongDataInputFormat(errorMessage:String),
    nilDataInput(fieldName:String),
    wrongNumberFormat(fieldName:String),
    wrongDateFormat(fieldName:String),
    wrongCurrencyName(fieldName:String),
    otherError(errorMessage:String)
}

enum errorMessageDetailed: Error {
    
    case other(errorMessage: String),
    wrongNumberFormat(textFieldName: String),
    wrongDateFormat(textFieldName: String),
    fieldMissed(textFieldName: String),
    promoFieldMissed(textFieldName: String)
    
    var localizedDescription: String {
        switch self {
        case .wrongNumberFormat(let textFieldName):
            return "Wrong number format. \"\(textFieldName)\" must be a number."
        case .wrongDateFormat(let textFieldName):
            return "Wrong date format. \"\(textFieldName)\" must be a date."
        case .fieldMissed(let textFieldName):
            return "You missed a text field. \"\(textFieldName)\" must be entered before adding."
        case .promoFieldMissed(let textFieldName):
            return "You missed a text field. \"\(textFieldName)\" must be entered before adding. If you don't want to use this field. Press on the toggle to remove this section."
        case .other(let errorMessage):
            return errorMessage
        }
    }
}

class ItemTextField: UITextField {
    
    //@IBOutlet var checkSignView:UIImageView! = UIImageView(image: #imageLiteral(resourceName: "checkSign"))
    
    var dataFormat:inputDataFormat = .text {
        didSet {
            setInputView()
        }
    }
    
    var errorTitleWorld:String?
    var errorEmptyFieldType:Error?
    
    var datePicker: UIDatePicker?
    
    var textFieldName:String! {
        get {
            return (placeholder != nil && (placeholder?.count)! > 0) ? placeholder! : "this one"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //clipsToBounds = true
        //layer.cornerRadius = kConrnerRadius * screenDimensionCorrectionFactor
        //backgroundColor = .labelBGGray
        //textColor = .darkBlue
        //font = UIFont(name: "DIN-Regular", size: 17)
        
        //layer.borderWidth = 2.0
        //layer.borderColor = UIColor.labelBGGray.cgColor
        //borderStyle = .roundedRect
        
        //let height:CGFloat = kItemTextFieldHeight //* screenDimensionCorrectionFactor
        //heightAnchor.constraint(equalToConstant: height).isActive = true
        
        //addSubview(checkSignView)
        
        //checkValueIs(ok: false)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let height:CGFloat = kItemTextFieldHeight// * screenDimensionCorrectionFactor
        let heightOfCheckSign = height/3
        //checkSignView.frame = CGRect(x: bounds.width - 30, y:(height - heightOfCheckSign)/2, width: heightOfCheckSign, height: heightOfCheckSign)
    }
    
    // MARK: Setters
    func setValue(_ newValue: Any?) {
        
        var newString = ""
        
        switch dataFormat {
        case .percent, .currency, .currencyAndZero:
            let formatter = NumberFormatter()
            formatter.numberStyle = dataFormat == .percent ? .percent : .decimal //.currency ////// no ????
            newString = formatter.string(from: NSNumber(value: newValue as! Double))!
        case .longDate, .shortDate:
            let formatter = DateFormatter()
            formatter.dateFormat = dataFormat.rawValue
            newString = formatter.string(from: newValue as! Date)
        //case .currencyName:
        case .number:
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            newString = formatter.string(from: NSNumber(value: newValue as! Int))!
        default:
            newString = newValue as! String
        }
        text = newString
    }
    
    /// keyboard with predefined type or UIDatePicker ?
    func setInputView() {
        switch dataFormat {
        case .currency, .percent, .currencyAndZero, .number:
            keyboardType = .decimalPad
        case .shortDate, .longDate:
            inputView = datePicker
        default:
            keyboardType = .default
        }
    }
    
    //MARK: validation methods
    func checkInputValueAndNull() throws -> (Any?) {
        if text == nil || (text?.count)! <= 0 {
            checkValueIs(ok: false)
            becomeFirstResponder()
            let fieldName:String = placeholder != nil && (placeholder?.count)! != 0 ? placeholder! : "Unknown"
            throw ItemTextFieldError.nilDataInput(fieldName: fieldName)
        } else {
            return try checkInputValue()
        }
    }
    
    func checkInputValue() throws -> (Any?) {
        
        if text == nil || (text?.count)! <= 0 {
            return nil
        }
        
        switch dataFormat {
        case .number:
            let f = Int(text ?? "0")
            checkValueIs(ok: true)
            return f
        case .percent, .currencyAndZero:
            let f = extractDoubleValue()
            checkValueIs(ok: true)
            return f
        case .currency:
            let f = extractDoubleValue()
            if  f == 0 {
                checkValueIs(ok: false)
                becomeFirstResponder()
                let fieldName:String = placeholder != nil && (placeholder?.count)! != 0 ? placeholder! : "Unknown"
                throw ItemTextFieldError.wrongNumberFormat(fieldName: fieldName)
            } else {
                checkValueIs(ok: true)
                return f
            }
        case .shortDate, .longDate:
            let d = checkDate()
            if  d == nil {
                checkValueIs(ok: false)
                becomeFirstResponder()
                let fieldName:String = placeholder != nil && (placeholder?.count)! != 0 ? placeholder! : "Unknown"
                throw ItemTextFieldError.wrongDateFormat(fieldName: fieldName)
            } else {
                checkValueIs(ok: true)
                return d
            }
        default:
            checkValueIs(ok: true)
            return text
        }
        
    }
    
    // Get Double from text value
    func extractDoubleValue() -> Double! {
        
        if text == nil { return 0 }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal //dataFormat == .percent ? .percent : .currency ////// no ????
        var nsString = text! as NSString
        
        nsString = nsString.replacingOccurrences(of: " ", with: "") as NSString
        nsString = nsString.replacingOccurrences(of: formatter.currencyCode, with: "") as NSString
        nsString = nsString.replacingOccurrences(of: formatter.currencySymbol, with: "") as NSString
        nsString = nsString.replacingOccurrences(of: formatter.groupingSeparator, with: "") as NSString
        nsString = nsString.replacingOccurrences(of: formatter.percentSymbol, with: "") as NSString
        
        let result = (formatter.number(from: nsString as String) ??  0) as! Double
        return result
    }
    
    func checkDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dataFormat.rawValue
        return dateFormatter.date(from: text!)
    }
    
    func checkValueIs(ok:Bool) {
       // checkSignView.alpha = ok ? 1 : 0
    }
}
