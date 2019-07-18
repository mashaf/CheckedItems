//
//  ImageProcessHelper.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 6/17/19.
//  Copyright © 2019 Maria Soboleva. All rights reserved.
//

import UIKit
import TesseractOCR
import Vision

typealias RecognizedDataType = [String: UIImage]
protocol ImageProcessHelperDelegate: NSObject {
    func updateView(data: RecognizedDataType?, markedImage: UIImage?)
}

class ImageProcessHelper {

    weak var delegate: ImageProcessHelperDelegate?
    var markedImage: UIImage?
    
    func processImage(_ originImage: UIImage) {
        
        var processedTextAndImages: RecognizedDataType = [:]
        guard let image = originImage.scaleImage(640) else { return }

        //let cgImageOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: .downMirrored, options: [VNImageOption: Any]())
        //let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [VNImageOption : Any]())
        
        let request = VNDetectTextRectanglesRequest { (request, error) in
            if error != nil {
                //                DispatchQueue.main.async {
                //
                //                }
                print("\nText recognition Error: \(error?.localizedDescription)\n")
            } else {
                processedTextAndImages = self.handleDetectedRectangles(originImage: image, request: request)
            }
            
        }
        
        request.reportCharacterBoxes = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                DispatchQueue.main.async {
                    self.delegate?.updateView(data: processedTextAndImages, markedImage: self.markedImage)
                }
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                return
            }
        }
    }
    
    private func handleDetectedRectangles(originImage: UIImage, request: VNRequest) -> [String: UIImage] {
        
        var processedImages: RecognizedDataType = [:]
            guard let results = request.results as? [VNTextObservation] else {
                fatalError("Wrong results of Detect Rectangles Request")
            }
            markedImage = self.drawRectForDetectingText(image: originImage, results: results)
            for img in self.textImages {
                let text = self.extractTextFrom(image: img)
                processedImages[text] = img
                print("extracted text is: \(text)")
            }
        
        return processedImages
    }
    
    private func drawRectForDetectingText(image: UIImage, results: [VNTextObservation] ) -> UIImage? {
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(at: CGPoint.zero)
        let context = UIGraphicsGetCurrentContext()!
        let  transform = CGAffineTransform.identity.scaledBy(x: image.size.width, y: image.size.height)
        for item in results {
            context.setFillColor(UIColor.clear.cgColor)
            context.setStrokeColor(UIColor.red.cgColor)
            context.setLineWidth(2.0)
            
            var rect = item.boundingBox.applying(transform)
            // extend the rect, it seems, tesseract doesn't work good with tight cropped images
            rect.origin.x -= 10
            rect.origin.y -= 10
            rect.size.width += 20
            rect.size.height += 20
            
            // TODO process the image orientation
            // TODO rotate image if it is not horizontal enough
            
            context.addRect(rect)
            context.drawPath(using: .fillStroke)
            addScreenshotOfDetectingText(sourceImage: image, boundingBox: rect)
        }
        
        let markedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return markedImage
    }
    
    private var textImages = [UIImage]()
    private func addScreenshotOfDetectingText(sourceImage image: UIImage, boundingBox: CGRect) {
        let pct: CGFloat = 0.1
        let newRect = boundingBox.insetBy(dx: -boundingBox.width*pct/2, dy: -boundingBox.height*pct/2)
        let imageRef = image.cgImage?.cropping(to: newRect)
        let croppedImage = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        textImages.append(croppedImage)
    }
    /////
    func extractTextFrom(image: UIImage) -> String {
        var string: String = ""
        guard let scaledImage = image.scaleImage(640) else { return string }
        if let tesseract = G8Tesseract(language: "rus+eng") {
            tesseract.charWhitelist = "-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZабвгдежзиклмнопрстуфхцчшщъыьэюяАБВГДЕЖЗИКЛМНОПРСТУФХЦЧШЩЪЫЭЮЯ"
            tesseract.engineMode = .tesseractOnly
            tesseract.pageSegmentationMode = .auto
            tesseract.image = getBlackWhiteImage(scaledImage) ?? scaledImage
            tesseract.recognize()
            string = tesseract.recognizedText ?? ""
        }
        return string
    }
    
    private func getBlackWhiteImage(_ image: UIImage) -> UIImage? {
        let filter = CIFilter(name: "CIPhotoEffectNoir")
        let ciInput = CIImage(image: image)
        filter?.setValue(ciInput, forKey: "inputImage")
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        let bwImage = UIImage(cgImage: cgImage!)
        return bwImage
    }
    
}
