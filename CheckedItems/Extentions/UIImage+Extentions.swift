//
//  UIImage+Extentions.swift
//  CheckedItems
//
//  Created by Maria Soboleva on 4/18/19.
//  Copyright © 2019 Maria Soboleva. All rights reserved.
//

import UIKit

// MARK: - UIImage extension
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
