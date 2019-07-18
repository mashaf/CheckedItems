//
//  AddItemViewController.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, Instantiatable {

    enum EditItemModeType {
        case edit, add, extend
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextField: CheckedItemsTextField!
    @IBOutlet weak var dailyAmountTextField: CheckedItemsTextField!
    @IBOutlet weak var startAmountTextField: CheckedItemsTextField!
    @IBOutlet weak var startDateTextField: CheckedItemsTextField!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var imageOfItem: UIImageView!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var countOfBoxesTextField: CheckedItemsTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    let datePicker = UIDatePicker()
    var activeField: CheckedItemsTextField?
    var takenImage: Bool = false
    var item: CheckItemViewModel?
    var mode: EditItemModeType = .add

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.alpha = 0

        setHidingKeyboardWhenTappedAround()
        scrollView.delegate = self

        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)

        nameTextField.dataFormat = .text
        nameTextField.delegate = self

        dailyAmountTextField.dataFormat = .number
        dailyAmountTextField.delegate = self

        startAmountTextField.dataFormat = .number
        startAmountTextField.delegate = self

        startDateTextField.dataFormat = .date
        startDateTextField.delegate = self
        startDateTextField.inputView = datePicker
        
        countOfBoxesTextField.dataFormat = .number
        countOfBoxesTextField.delegate = self
        countOfBoxesTextField.text = "1"

        if item != nil {
            nameTextField.text = item?.itemName
            dailyAmountTextField.text = item?.dailyAmount
            if mode == .extend {
                startAmountTextField.text = ""
                startAmountTextField.placeholder = String(item!.startAmount ?? "0") + " + "
                startAmountTextField.becomeFirstResponder()
            } else {
                startAmountTextField.text = item?.startAmount
            }
            
            startDateTextField.text = item?.startDate
            imageOfItem.image = item?.image
        } else {
            startDateTextField.text = DateHelper.getStringFrom(NSDate())
            imageOfItem.image = #imageLiteral(resourceName: "camera")
            editImage.alpha = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(aNotification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(aNotification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    @IBAction func saveItem(_ sender: Any) {
        
        do {
            
            try nameTextField.checkInputValueAndNull()
            try countOfBoxesTextField.checkInputValue()
            try dailyAmountTextField.checkInputValueAndNull()
            try startAmountTextField.checkInputValueAndNull()
            try startDateTextField.checkInputValueAndNull()

        } catch CheckedItemsTextFieldError.wrongNumberFormat(let fieldName) {

            becomeFirstResponder()
            showErrorMessageExtended(.wrongNumberFormat(textFieldName: fieldName))

        } catch CheckedItemsTextFieldError.wrongDateFormat(let fieldName) {

            becomeFirstResponder()
            showErrorMessageExtended(.wrongDateFormat(textFieldName: fieldName))

        } catch CheckedItemsTextFieldError.nilDataInput(let fieldName) {

            becomeFirstResponder()
            let missedErrorType = activeField!.errorEmptyFieldType ??
                CheckedItemsTextFieldError.nilDataInput(textFieldName: fieldName)
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
        
        let theSameItems = CheckedItems.getItemByName(nameTextField.text!).filter {$0.finishDate!.compare(Date()) == .orderedDescending}
        if item == nil && theSameItems.count > 0 {
            showDuplicateItemAlert(theSameItems)
        } else if mode == .extend {
            self.addToItem(self.item!.item)
        } else {
            saveItem()
        }
        
    }
    
    private func showDuplicateItemAlert(_ items: [CheckedItems]) {
        let theSameItem = items
            .sorted {$0.finishDate!.compare($1.finishDate! as Date) == .orderedAscending}
            .last
        
        guard theSameItem != nil else { return }
        
        let viewAlert = UIAlertController(title: theSameItem!.itemName, message: "The item is already added.\nDo you want to add the new item to it?", preferredStyle: .actionSheet)
        
        viewAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.addToItem(theSameItem!)
        }))
        
        viewAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
            self.saveItem()
        }))
        
        viewAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(viewAlert, animated: true, completion: nil)
    }
    
    private func addToItem(_ item: CheckedItems) {
        if self.item == nil {
            self.item = CheckItemViewModel(item: item)
        }
        self.item?.addVerifiedValuesToItem(amount: startAmountTextField.text!, boxCount: countOfBoxesTextField.text)
        closeWindow()
    }
    
    private func saveItem() {
        
        if item == nil {
            item = CheckItemViewModel()
        }
        
        item?.saveVerifiedValues(name: nameTextField.text!, dailyAmount: dailyAmountTextField.text!, startAmount: startAmountTextField.text!, startDate: startDateTextField.text!, image: imageOfItem.image, boxCount: countOfBoxesTextField.text!) ///// TODO
        
        closeWindow()
    }

    @IBAction func imageButtonAction(_ sender: Any) {

        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .camera
        imagePickerVC.delegate = self
        present(imagePickerVC, animated: true) {
            //
        }
    }

    func setActive(_ textField: CheckedItemsTextField?) {
        activeField = textField
    }

    @objc func updateDateField(sender: Any) {
        activeField!.setValue(datePicker.date)
    }

    // MARK: keyboard methods
    @objc func keyboardWillHide(aNotification: NSNotification) {
        scrollViewTo(0)
        scrollView.isScrollEnabled = false
    }

    @objc func keyboardWillShow(aNotification: NSNotification) {

        let scrollToY: CGFloat = 100 /// TODO
        scrollViewTo(scrollToY)
        scrollView.isScrollEnabled = true
    }

    func scrollViewTo(_ scrollY: CGFloat) {

        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height + scrollY)
        let offset  = CGPoint(x: 0, y: scrollY)
        if scrollY != 0 { //&&
            //!view.bounds.contains(CGRect(x:activeField!.frame.origin.x, y:activeField!.frame.origin.y - y, width:activeField!.frame.width, height: activeField!.frame.height)) {
            //scrollView.setContentOffset(CGPoint(x: 0, y: activeField!.frame.origin.y), animated: true)
            scrollView.setContentOffset(offset, animated: true)
        } else {
            scrollView.setContentOffset(offset, animated: true)
        }

    }

    // MARK: UIAlert methods
    private func showErrorMessage(_ errMessage: String) {
        showErrorMessageExtended(.otherError(errorMessage: errMessage))
    }

    private func showErrorMessageExtended(_ errorMessage: CheckedItemsTextFieldError) {

        let title = "Something wrong:"
        let errorAlert = UIAlertController(title: title,
                                           message: errorMessage.localizedDescription,
                                           preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            ///
        }))
        self.present(errorAlert, animated: true, completion: nil)
    }

    private func closeWindow() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            let itemListViewController = NavigationController.instantiate()
            self.present(itemListViewController, animated: true, completion: nil)
        }
    }

    // MARK: text recognition methods
    private func startRecognizeText(from image: UIImage) {

        let imageProcesser = ImageProcessHelper()
        imageProcesser.delegate = self
        imageProcesser.processImage(image) //extractTextFrom(image: image) //
       
        activityIndicator.stopAnimating()
        activityIndicator.alpha = 0

    }
}

extension AddItemViewController: ImageProcessHelperDelegate {
    
    func updateView(data: RecognizedDataType?, markedImage: UIImage?) {
        guard let data = data else { return }
        self.imageOfItem.image = markedImage
        let probItemNames = data
            .keys
            .filter({ !$0.isEmpty && data[$0] != nil })
            .sorted { (text1, text2) -> Bool in
                return Float(data[text1]!.size.height) > Float(data[text2]!.size.height)// probably it could be the highest font size
            }
            .map({$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)})
        
        guard probItemNames.count > 0 else {return}
        
        let viewAlert = UIAlertController(title: "CHOOSE THE ITEM NAME", message: "We extract some probable names of item from your image. Use one of them to name the item?", preferredStyle: .actionSheet)
        
        let maxCountOfProbNames = probItemNames.count > 4 ? 4 : probItemNames.count
        for word in probItemNames[0...maxCountOfProbNames-1] {
            viewAlert.addAction(UIAlertAction(title: word, style: .default, handler: { _ in
                self.nameTextField.text = word
            }))
        }
        
        viewAlert.addAction(UIAlertAction(title: "Don't use all of them", style: .cancel, handler: nil))
        self.present(viewAlert, animated: true, completion: nil)
    }
}

extension AddItemViewController: UIScrollViewDelegate {
}

// MARK: UITextFieldDelegate
extension AddItemViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setActive(textField as? CheckedItemsTextField)

        if activeField == startDateTextField {
            guard let date = DateHelper.getDateFrom(textField.text!) else {
                return
            }
            datePicker.date = date as Date
        }
    }
}

extension AddItemViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage { //,
            editImage.alpha = 1
            takenImage = true

            picker.dismiss(animated: true, completion: {
                
                self.activityIndicator.alpha = 1
                self.activityIndicator.startAnimating()

                self.startRecognizeText(from: image)
            })
        }
    }
}

extension AddItemViewController: UINavigationControllerDelegate {

}
