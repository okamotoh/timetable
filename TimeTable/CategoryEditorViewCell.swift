import UIKit

class CategoryEditorViewCell : UITableViewCell {
    
    let colorCubeImageSize = CGSizeMake(15.0, 15.0)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var color: UIColor? {
        willSet {
            let colorCubeView = UIView(frame: CGRectMake(0.0, 0.0, colorCubeImageSize.width, colorCubeImageSize.height))
            colorCubeView.backgroundColor = newValue
            self.imageView?.image = colorCubeView.image()
        }
    }
}
