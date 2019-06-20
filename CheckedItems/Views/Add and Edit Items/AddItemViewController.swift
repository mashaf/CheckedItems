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
            
            let theSameItem = theSameItems
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
            
        } else if mode == .extend {
            self.addToItem(self.item!.item)
        } else {
            saveItem()
        }
        
    }
    
    private func showDuplicateItemAlert() {
        
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

        let str = ImageProcessHelper().extractTextFrom(image: image.scaleImage(640)!)
        self.imageOfItem.image = image
        /*
        //let cgImageOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: .downMirrored, options: [VNImageOption : Any]())
        //let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [VNImageOption : Any]())
        
        let request = VNDetectTextRectanglesRequest { (request, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.imageOfItem.image = image
                }
                print("\nText recognition Error: \(error?.localizedDescription)\n")
            } else {
                self.handleDetectedRectangles(originImage: image, request: request)
            }
        }
        request.reportCharacterBoxes = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        } */

        activityIndicator.stopAnimating()
        activityIndicator.alpha = 0

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
            //let scaledImage = image.scaleImage(640) {

            activityIndicator.alpha = 1
            activityIndicator.startAnimating()

            //imageOfItem.image = image
            editImage.alpha = 1
            takenImage = true

            picker.dismiss(animated: true, completion: {
                self.startRecognizeText(from: image)
            })
        }
    }
}

extension AddItemViewController: UINavigationControllerDelegate {

}
