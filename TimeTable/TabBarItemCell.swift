import UIKit

enum TabBarItemCellType {
    case Tab, Action
}

class TabBarItemCell : UITableViewCell {
    typealias ActionBlock = () -> ()
    
    var titleLabel = UILabel()
    var iconView   = UIImageView()
    var selectedColor: UIColor?
    var actionBlock: ActionBlock?
    var cellType: TabBarItemCellType?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.backgroundColor = UIColor.clearColor()
        self.titleLabel.highlighted = false
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(self.titleLabel)
        
        self.iconView.contentMode = UIViewContentMode.Center
        self.addSubview(self.iconView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        self.iconView.frame = CGRectMake(15.0, 0.0, 40.0, 40.0)
        
        if self.iconView.image == nil {
            self.titleLabel.frame = self.bounds
            self.titleLabel.font  = UIFont.systemFontOfSize(18.0)
        } else {
            self.titleLabel.frame = CGRectMake(0.0, self.bounds.size.height - 20, self.bounds.size.width, 12
            )
            self.titleLabel.font = UIFont.systemFontOfSize(10.0)
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if cellType == .Tab {
            if selected {
                self.titleLabel.textColor = UIColor.whiteColor()
                if let color = self.selectedColor {
                    self.setSelectedBackgroundColor(color)
                }
            } else {
                self.titleLabel.textColor = UIColor.blackColor()
                if let color = self.selectedColor {
                    self.setSelectedBackgroundColor(UIColor.whiteColor())
                }
            }
        }
    }
    
    private func setSelectedBackgroundColor(color: UIColor) {
        var backgroundView = UIView()
        backgroundView.frame = self.bounds
        backgroundView.backgroundColor = color
        self.selectedBackgroundView = backgroundView
    }
}
