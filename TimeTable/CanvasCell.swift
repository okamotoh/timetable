import UIKit
import CoreData

class CanvasCell: UICollectionViewCell {
    
    var textField    = UITextField()
    var canvasImage  = UIImageView()
    var orderLabel   = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.contentView.addSubview(self.canvasImage)
        self.contentView.addSubview(self.textField)
        
        self.textField.textAlignment = NSTextAlignment.Center
        self.textField.clearButtonMode = UITextFieldViewMode.WhileEditing
        self.textField.placeholder = "Enter Canvas Name"
        
        self.orderLabel.backgroundColor = UIColor.clearColor()
        self.orderLabel.textColor = UIColor(white: 0.5, alpha: 0.5)
        self.orderLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 64)
        self.orderLabel.textAlignment = NSTextAlignment.Center
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textField.frame  = CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44)
        self.canvasImage.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 44)
        self.orderLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
    }
    
    var name: String? {
        get {
            return self.textField.text
        }
        set {
            self.textField.text = newValue
        }
    }
    
    var order: String? {
        get {
            return self.orderLabel.text!
        }
        set {
            if newValue == nil {
                self.orderLabel.text == ""
                self.orderLabel.removeFromSuperview()
            } else {
                self.orderLabel.text = newValue
                self.contentView.addSubview(self.orderLabel)
                self.contentView.sendSubviewToBack(self.orderLabel)
            }
        }
    }
}
