import UIKit
import CoreData

protocol DraggingImageViewDelegate {
    func delete() -> Void
}

class DraggingImageView: UIImageView {
    
    var delegate: DraggingImageViewDelegate!
    
    override init(image: UIImage) {
        super.init(image: image)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.7
        self.userInteractionEnabled = true
        
        let deleteButton = UIButton()
        deleteButton.frame = CGRectMake(-33, -33, 66, 66)
        deleteButton.addTarget(self, action: "deleteButtonTapped:event:", forControlEvents: UIControlEvents.TouchUpInside)
        deleteButton.setImage(UIImage(named: "close.png"), forState: .Normal)
        self.addSubview(deleteButton)
        
        let audioButton = UIButton()
        audioButton.frame = CGRectMake(self.frame.width - 33, -33, 66, 66)
        audioButton.addTarget(self, action: "audioButtonTapped:event:", forControlEvents: UIControlEvents.TouchUpInside)
        audioButton.setImage(UIImage(named: "audio.png"), forState: .Normal)
        self.addSubview(audioButton)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startWobbleAnimation() {
        let posOffset = 0.1...0.2
        let startCenter = CGPointMake(
            self.sign(self.randomNumberBetween(-1, secondNumber: 1)) * self.randomNumberBetween(CGFloat(posOffset.start), secondNumber: CGFloat(posOffset.end)),
            self.sign(self.randomNumberBetween(-1, secondNumber: 1)) * self.randomNumberBetween(CGFloat(posOffset.start), secondNumber: CGFloat(posOffset.end))
        )
        let endCenter = CGPointMake(
            self.sign(self.randomNumberBetween(-1, secondNumber: 1)) * self.randomNumberBetween(CGFloat(posOffset.start), secondNumber: CGFloat(posOffset.end)),
            self.sign(self.randomNumberBetween(-1, secondNumber: 1)) * self.randomNumberBetween(CGFloat(posOffset.start), secondNumber: CGFloat(posOffset.end))
        )
        let center = self.center
        self.layer.anchorPoint = CGPointMake(0.5 + startCenter.x, 0.5 + startCenter.y)
        
        let bounds = self.bounds
        self.layer.position = CGPointMake(
            self.layer.position.x + bounds.size.width * startCenter.x,
            self.layer.position.y + bounds.size.height * startCenter.y
        )
        
        let amplitude = self.randomNumberBetween(1.0, secondNumber: 1.5)
        let angleStart = -Double(amplitude) * M_PI / 180.0
        let angleEnd = Double(amplitude) * M_PI / 180.0
        self.transform = CGAffineTransformMakeRotation(CGFloat(angleStart))
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationRepeatAutoreverses(true)
        UIView.setAnimationRepeatCount(FLT_MAX)
        UIView.setAnimationDuration(0.12)
        UIView.setAnimationDelay(Double(self.randomNumberBetween(0.0, secondNumber: 0.09)))
        self.transform = CGAffineTransformMakeRotation(CGFloat(angleEnd))
        UIView.commitAnimations()
    }
    
    func stopWobbleAnimation() {
        self.transform = CGAffineTransformIdentity
    }

    func deleteButtonTapped(sender: UIButton, event: UIEvent) {
        if let d = delegate {
            d.delete()
        }
    }
    
    func audioButtonTapped(sender: UIButton, event: UIEvent) {
    
    }
    
    private func randomNumberBetween(firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
    
    private func sign(number: CGFloat) -> CGFloat {
        return number < 0 ? -1 : 1
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if self.clipsToBounds == false && self.hidden == false && self.alpha > 0 {
            for subview in self.subviews.reverse() {
                let subPoint = subview.convertPoint(point, fromView:self)
                let result = subview.hitTest(subPoint, withEvent: event)
                if result != nil {
                    return result
                }
            }
        }
        return nil
    }
}
