import UIKit

class DetailViewController : UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.viewController?.willMoveToParentViewController(nil)
        self.viewController?.view.removeFromSuperview()
        self.viewController?.removeFromParentViewController()
    }
    
    var viewController: UIViewController? {
        willSet {
            if let newViewController = newValue {
                let oldViewController: UIViewController? = viewController
                
                newViewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
                self.addChildViewController(newViewController)
                self.view.addSubview(newViewController.view)
                newViewController.didMoveToParentViewController(self)
                
                oldViewController?.willMoveToParentViewController(nil)
                oldViewController?.view.removeFromSuperview()
                oldViewController?.removeFromParentViewController()
            }
        }
    }
    
}