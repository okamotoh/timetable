import UIKit

class OverlayView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var transparentFrame: CGRect? {
        didSet {
            if transparentFrame != oldValue {
                self.setNeedsLayout()
            }
        }
    }
    
    var layerWithTransparentRect: CALayer?
    
    override func layoutSublayersOfLayer(layer: CALayer!) {

        if let l = layerWithTransparentRect {
            l.removeFromSuperlayer()
            layerWithTransparentRect = nil
        }
        
        layerWithTransparentRect = CALayer()
        layerWithTransparentRect!.frame = self.frame
        layerWithTransparentRect!.backgroundColor = UIColor(white: 0.0, alpha: 0.4).CGColor

        if let frame = transparentFrame {
            let maskLayer = CAShapeLayer()
            maskLayer.frame = self.frame
            
            let path = UIBezierPath(rect: frame)
            path.appendPath(UIBezierPath(rect: maskLayer.frame))
            
            maskLayer.fillColor = UIColor.blackColor().CGColor
            maskLayer.path = path.CGPath
            maskLayer.fillRule = kCAFillRuleEvenOdd
            layerWithTransparentRect!.mask = maskLayer
        }

        layer.addSublayer(layerWithTransparentRect!)
    }
}
