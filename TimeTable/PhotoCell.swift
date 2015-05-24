import UIKit

class PhotoCell : UITableViewCell {
    
    var photoImageView: UIImageView?
    var orderLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.orderLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        self.orderLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 64)
        self.orderLabel.textAlignment = NSTextAlignment.Center        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let view = self.photoImageView {
            view.frame = self.thumbnailImageFrame
        }
        self.orderLabel.frame = self.thumbnailImageFrame
    }
    
    func hidePhotoImage() {
        self.photoImageView?.hidden = true
    }
    func showPhotoImage() {
        self.photoImageView?.hidden = false
    }

    var thumbnailImageFrame: CGRect {
        get {
            return CGRectMake(10, 5, self.bounds.width - 20, self.bounds.height - 10)
        }
    }
    
    var thumbnailImage: UIImage? {
        get {
            return self.photoImageView?.image
        }
        set {
            if let view = self.photoImageView {
                view.removeFromSuperview()
                self.photoImageView = nil
            }
            
            if newValue == nil {
                self.photoImageView = nil
            } else {
                self.photoImageView = UIImageView()
                self.photoImageView!.userInteractionEnabled = true
                self.photoImageView!.contentMode = UIViewContentMode.ScaleAspectFill
                self.photoImageView!.clipsToBounds = true
                self.photoImageView!.layer.borderColor = UIColor.whiteColor().CGColor
                self.photoImageView!.layer.borderWidth = 5.0
                self.photoImageView!.image = newValue
                self.addSubview(self.photoImageView!)
            }
            self.setNeedsLayout()
        }
    }
    
    var order: String? {
        get {
            return self.orderLabel.text!
        }
        set {
            if newValue == nil {
                self.orderLabel.text = nil
                self.orderLabel.removeFromSuperview()
            } else {
                self.orderLabel.text = newValue
                self.addSubview(self.orderLabel)
                self.bringSubviewToFront(self.orderLabel)
            }
        }
    }
}