//
//  AddItemViewController.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameLabel: CheckedItemsTextField!
    @IBOutlet weak var dailyAmountLabel: CheckedItemsTextField!
    @IBOutlet weak var startAmountLabel: CheckedItemsTextField!
    @IBOutlet weak var startDateLabel: CheckedItemsTextField!
    @IBOutlet weak var imageButton: UIButton!
    
    var dateFormatter = { () -> DateFormatter in
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        return df
    }()
    
    let datePicker = UIDatePicker()
    var activeField: UITextField?
    var item:CheckedItems?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setHidingKeyboardWhenTappedAround()
        scrollView.delegate = self
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)
        
        nameLabel.dataFormat = .text
        nameLabel.delegate = self
        
        dailyAmountLabel.dataFormat = .number
        dailyAmountLabel.delegate = self
        
        startAmountLabel.dataFormat = .number
        startAmountLabel.delegate = self
        
        startDateLabel.dataFormat = .date
        startDateLabel.delegate = self
        startDateLabel.inputView = datePicker
        
        if item != nil {
            nameLabel.text = item?.item_name
            dailyAmountLabel.text = String(describing: item?.daily_amount ?? 0)
            startAmountLabel.text = String(describing: item?.start_amount ?? 0)
            startDateLabel.text = dateFormatter.string(from: (item?.start_date)! as Date)
        } else {
            startDateLabel.text = dateFormatter.string(from: Date())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(aNotification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(aNotification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @IBAction func saveItem(_ sender: Any) {
        do {
            
            try setVerifiedValues()
            closeWindow()
            
        } catch CheckedItemsTextFieldError.wrongNumberFormat(let fieldName) {
            
            becomeFirstResponder()
            showErrorMessageExtended(.wrongNumberFormat(textFieldName: fieldName))
            
        } catch CheckedItemsTextFieldError.wrongDateFormat(let fieldName) {
            
            becomeFirstResponder()
            showErrorMessageExtended(.wrongDateFormat(textFieldName: fieldName))
            
        } catch CheckedItemsTextFieldError.nilDataInput(let fieldName) {
            
            becomeFirstResponder()
            
            let predefinedErrorType = (activeField as! CheckedItemsTextField).errorEmptyFieldType
            let missedErrorType:CheckedItemsErrorMessageDetailed = (predefinedErrorType != nil) ? predefinedErrorType! as! CheckedItemsErrorMessageDetailed : CheckedItemsErrorMessageDetailed.fieldMissed(textFieldName: fieldName)
            showErrorMessageExtended(missedErrorType)
            
        } catch CheckedItemsTextFieldError.wrongDataInputFormat(let errorMessage) {
            
            becomeFirstResponder()
            showErrorMessage(errorMessage)
            return
        } catch CheckedItemsTextFieldError.otherError(let errorMessage) {
            showErrorMessage(errorMessage)
            return
        } catch let error as NSError {
            showErrorMessage("Update data error : \(error) \(error.userInfo)")
            return
        }
    }
    
    // MARK: add/update data
    private func setVerifiedValues() throws -> () {
        
        let name = try nameLabel.checkInputValueAndNull() as! String
        let dailyAmount = try dailyAmountLabel.checkInputValueAndNull() as! Int
        let startAmount = try startAmountLabel.checkInputValueAndNull() as! Int
        let startDate   = try startDateLabel.checkInputValueAndNull() as! Date
        
        let daysNumber = startAmount / dailyAmount
        var components = DateComponents()
        components.day = Int(daysNumber)
        let finish_date = Calendar.current.date(byAdding: components, to: startDate as Date)! as NSDate
        
        if item == nil {
            item = CheckedItems()
        }
        item!.item_name = name
        item!.daily_amount = checkedItemAmountDataType(dailyAmount)
        item!.start_amount = checkedItemAmountDataType(startAmount)
        item!.start_date = startDate as NSDate
        item!.finish_date = finish_date
        
        CoreDataManager.instance.saveContext()
        closeWindow()
    }
    
    @IBAction func imageButtonAction(_ sender: Any) {
        print("AAAa")
    }
    
    func setActive(_ textField: CheckedItemsTextField?) {
        activeField = textField
    }
    
    @objc func updateDateField(sender: Any) {
         (activeField as! CheckedItemsTextField).setValue(datePicker.date)
    }
    
    // MARK: keyboard methods
    @objc func keyboardWillHide(aNotification: NSNotification) {
        scrollViewTo(0)
        scrollView.isScrollEnabled = false
    }
    
    @objc func keyboardWillShow(aNotification: NSNotification) {
        
        let y: CGFloat = 100 /// TODO
        scrollViewTo(y)
        scrollView.isScrollEnabled = true
    }
    
    func scrollViewTo(_ y: CGFloat) {
        
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height + y)
        let offset  = CGPoint(x:0, y:y)
        if (y != 0) { //&&
            //!view.bounds.contains(CGRect(x:activeField!.frame.origin.x, y:activeField!.frame.origin.y - y, width:activeField!.frame.width, height: activeField!.frame.height)) {
            //scrollView.setContentOffset(CGPoint(x: 0, y: activeField!.frame.origin.y), animated: true)
            scrollView.setContentOffset(offset, animated: true)
        } else {
            scrollView.setContentOffset(offset, animated: true)
        }
        
    }
    
    // TODO remake error messages to struct
    // MARK: UIAlert methods
    private func showErrorMessage(_ errMessage: String) {
        showErrorMessageExtended(.other(errorMessage: errMessage))
    }
    
    private func showErrorMessageExtended(_ errorMessage: CheckedItemsErrorMessageDetailed) {
        
        let title = "Something wrong:"
        let errorAlert = UIAlertController(title: title, message: errorMessage.localizedDescription, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            ///
        }))
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    private func closeWindow() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let itemListViewController = storyBoard.instantiateViewController(withIdentifier: "NavigationController")
            self.present(itemListViewController, animated: true, completion: nil)
        }
    }
}


extension AddItemViewController:UIScrollViewDelegate {
}

// MARK: UITextFieldDelegate
extension AddItemViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        do {
            // try (textField as! CheckItemsTextField).checkInputValue()
        }
        catch CheckedItemsTextFieldError.wrongNumberFormat(let fieldName) {
            
            becomeFirstResponder()
            showErrorMessageExtended(.wrongNumberFormat(textFieldName: fieldName))
            
        } catch CheckedItemsTextFieldError.wrongDateFormat(let fieldName) {
            
            becomeFirstResponder()
            showErrorMessageExtended(.wrongDateFormat(textFieldName: fieldName))
            
        } catch let error as NSError {
            showErrorMessage("Update data error : \(error) \(error.userInfo)")
            return
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setActive(textField as? CheckedItemsTextField)
        
        if activeField == startDateLabel {
            guard let date = dateFormatter.date(from: textField.text!) else {
                return
            }
            datePicker.date = date
        }
    }
}
