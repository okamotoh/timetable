import UIKit
import Foundation

extension UIImage {
    
    func cropToBoundingSquare(#boundingSquareSideLength: CGFloat) -> UIImage {
        let originalWidth = self.size.width
        let originalHeight = self.size.height
        
        var croppedRect: CGRect
        if originalHeight <= originalWidth {
            let x = originalWidth / 2 - originalHeight / 2
            let y = CGFloat(0.0)
            croppedRect = CGRectMake(x, y, originalHeight, originalHeight)
        } else {
            let x = CGFloat(0.0)
            let y = originalHeight / 2 - originalWidth / 2
            croppedRect = CGRectMake(x, y, originalWidth, originalWidth)
        }
        
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, croppedRect)
        let croppedImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        let thumbSize = CGSizeMake(boundingSquareSideLength, boundingSquareSideLength)
        UIGraphicsBeginImageContext(thumbSize)
        croppedImage?.drawInRect(CGRectMake(0, 0, thumbSize.width, thumbSize.height))
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return thumbImage
    }
    
    func resizeToBoundingSquare(#boundingSquareSideLength: CGFloat) -> UIImage {
        let imgScale = self.size.width > self.size.height ? boundingSquareSideLength / self.size.width : boundingSquareSideLength / self.size.height
        let newWidth = self.size.width * imgScale
        let newHeight = self.size.height * imgScale
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContext(newSize)
        
        self.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
