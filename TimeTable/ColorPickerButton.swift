import UIKit

class ColorPickerButton: UIButton {
    
    let checkImage = UIImageView()
    let checkImageSize = CGSizeMake(25.0, 25.0)
    
    init(color: UIColor, frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = color
        self.checkImage.frame = CGRectMake(
            CGFloat((frame.width - checkImageSize.width) / 2.0), CGFloat((frame.height - checkImageSize.height) / 2.0),
            checkImageSize.width, checkImageSize.height)
        self.checkImage.contentMode = UIViewContentMode.ScaleAspectFit
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var selected: Bool {
        willSet {
            if newValue {
                self.checkImage.image = UIImage(named: "check")
                self.addSubview(self.checkImage)
                self.transform = CGAffineTransformMakeScale(0.1, 0.1)
                UIView.animateWithDuration(
                    0.5,
                    delay: 0,
                    usingSpringWithDamping: 0.4,
                    initialSpringVelocity: 6.0,
                    options: UIViewAnimationOptions.AllowUserInteraction,
                    animations: { () -> Void in
                        self.transform = CGAffineTransformMakeScale(1.1, 1.1)
                    },
                    completion: nil
                )
            } else {
                self.checkImage.removeFromSuperview()
                UIView.animateWithDuration(
                    0.5,
                    delay: 0,
                    usingSpringWithDamping: 0.2,
                    initialSpringVelocity: 6.0,
                    options: UIViewAnimationOptions.AllowUserInteraction,
                    animations: { () -> Void in
                        self.transform = CGAffineTransformIdentity
                    },
                    completion: nil
                )
            }
        }
    }
}

