import UIKit
import Foundation

extension UIView {
    func image() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, 0.0)
        let context: CGContextRef = UIGraphicsGetCurrentContext()
        self.layer.renderInContext(context)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return renderedImage
    }
}