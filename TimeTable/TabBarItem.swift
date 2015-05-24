import UIKit

class TabBarItem {
    
    typealias ActionBlock = () -> ()
    
    let title: String?
    let image: UIImage?
    let actionBlock: ActionBlock?
    let viewController: UIViewController?
    
    init(vc: UIViewController?, image: UIImage?, title: String) {
        self.viewController = vc
        self.title = title
        self.image = image
        self.actionBlock = nil
    }
    
    init(actionBlock: ActionBlock?, image: UIImage, title: String) {
        self.viewController = nil
        self.title = title
        self.image = image
        
        if actionBlock != nil {
            self.actionBlock = actionBlock
        } else {
            self.actionBlock = { () -> () in
                println("ActionBlock is nil!")
            }
        }

    }
}
