//
//  AddItemViewController.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 11/16/18.
//  Copyright © 2018 Maria Soboleva. All rights reserved.
//

import UIKit
import TesseractOCR
import Vision

class AddItemViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameLabel: CheckedItemsTextField!
    @IBOutlet weak var dailyAmountLabel: CheckedItemsTextField!
    @IBOutlet weak var startAmountLabel: CheckedItemsTextField!
    @IBOutlet weak var startDateLabel: CheckedItemsTextField!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var imageOfItem: UIImageView!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var countOfBoxes: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var dateFormatter = { () -> DateFormatter in
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        return df
    }()
    
    let datePicker = UIDatePicker()
    var activeField: UITextField?
    var takenImage: Bool = false
    var item:CheckedItems?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.alpha = 0
        
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
            
            if item!.image != nil  {
                imageOfItem.image = UIImage(data: item!.image as! Data)
                editImage.alpha = 1
            } else {
                imageOfItem.image = #imageLiteral(resourceName: "camera")
                editImage.alpha = 0
            }
            
        } else {
            startDateLabel.text = dateFormatter.string(from: Date())
            imageOfItem.image = #imageLiteral(resourceName: "camera")
            editImage.alpha = 0
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
        
        if takenImage {
            item!.image = UIImagePNGRepresentation(imageOfItem.image!) as NSData?
        }
        
        CoreDataManager.instance.saveContext()
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
    
    
    // MARK: text recognition methods
    private func startRecognizeText(from image:UIImage) {
       
        let str = extractTextFrom(image: image.scaleImage(640)!)
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
    
    private func handleDetectedRectangles(originImage: UIImage, request: VNRequest) {
        DispatchQueue.main.async {
            let markedImage = self.drawRectForDetectingText(image: originImage, results: request.results as! Array<VNTextObservation>)
            for img in self.textImages {
                let a = self.extractTextFrom(image: img)
                print("text is \(String(describing: a))")
            }
            self.imageOfItem.image = markedImage
        }
    }
    
    private func drawRectForDetectingText(image: UIImage, results:Array<VNTextObservation> ) -> UIImage? {
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(at: CGPoint.zero)
        //image.draw(in: CGRect(x:0, y:0, width: image.size.width, height: image.size.height))
        
        let context = UIGraphicsGetCurrentContext()!
        
        //let ciImage = CIImage(image:image)
        let  transform = CGAffineTransform.identity.scaledBy(x: image.size.width, y:image.size.height) //(x: ciImage!.extent.size.width, y: ciImage!.extent.size.height)

        //transform.translatedBy(x: 0, y: -1)
        
        for item in results {
            context.setFillColor(UIColor.clear.cgColor)
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(2.0)
            context.addRect(item.boundingBox.applying(transform))
            context.drawPath(using: .fillStroke)
            addScreenshotOfDetectingText(sourceImage: image, boundingBox: item.boundingBox.applying(transform))
        }
        
        let markedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return markedImage
    }
    
    
    
    private var textImages = [UIImage]()
    private func addScreenshotOfDetectingText(sourceImage image:UIImage, boundingBox: CGRect) {
        let pct:CGFloat = 0.1
        let newRect = boundingBox.insetBy(dx: -boundingBox.width*pct/2, dy: -boundingBox.height*pct/2)
        let imageRef = image.cgImage?.cropping(to: newRect)
        let croppedImage = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        textImages.append(croppedImage)
    }
    
    private func extractTextFrom(image:UIImage) -> String {
        var string: String = ""
        if let tesseract = G8Tesseract(language: "eng+rus") {
            tesseract.engineMode =  .tesseractOnly
            tesseract.pageSegmentationMode = .auto
            tesseract.image = image//.g8_blackAndWhite()
            tesseract.recognize()
            string = tesseract.recognizedText ?? ""
            print("image: \(image),  tesseract: " + string)
        }
        return string
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

extension AddItemViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
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

/*extension AddItemViewController: SwiftOCRDelegate {
    func preprocessImageForOCR(_ inputImage: OCRImage) -> OCRImage? {
        
    }
}*/

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
