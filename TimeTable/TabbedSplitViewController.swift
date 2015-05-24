import UIKit

class TabbedSplitViewController : UIViewController,
    UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate {

    static let notificationNameChangeCategory = "DidChangeCategory"
    
    static let masterViewWidth:  CGFloat = 200.0
    static let tabBarViewWidth:  CGFloat = 70.0
    static let tabBarItemHeight: CGFloat = 60.0
    let popoverViewSize = CGSizeMake(320, 480)
    
    let categoryTabBarViewController = CategoryTabBarViewController()
    let actionTabBarViewController = ActionTabBarViewController()
    let masterViewController = MasterViewController()
    let detailViewController = DetailViewController()
    let configTransitioningDelegate = PresentationManager()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "didChangeCategory:",
            name: TabbedSplitViewController.notificationNameChangeCategory,
            object: nil
        )
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: TabbedSplitViewController.notificationNameChangeCategory,
            object: nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.addChildViewController(categoryTabBarViewController)
        self.view.addSubview(categoryTabBarViewController.view)
        categoryTabBarViewController.didMoveToParentViewController(self)
        
        self.addChildViewController(actionTabBarViewController)
        self.view.addSubview(actionTabBarViewController.view)
        actionTabBarViewController.didMoveToParentViewController(self)
        
        self.addChildViewController(masterViewController)
        self.view.addSubview(masterViewController.view)
        masterViewController.didMoveToParentViewController(self)
        
        self.addChildViewController(detailViewController)
        self.view.addSubview(detailViewController.view)
        detailViewController.didMoveToParentViewController(self)
        
        let actionEdit: TabBarItem = TabBarItem(actionBlock: { () -> () in
            let categoryEditorViewController = CategoryEditorListViewController()
            let navigationController = UINavigationController(rootViewController: categoryEditorViewController)
            navigationController.modalPresentationStyle = UIModalPresentationStyle.Popover
            navigationController.preferredContentSize = self.popoverViewSize
            
            if let popover = navigationController.popoverPresentationController {
                popover.permittedArrowDirections = .Any
                popover.delegate = self
                popover.sourceView = self.view
                
                let rectInTable = self.actionTabBarViewController.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                let rectInView = self.actionTabBarViewController.tableView.convertRect(rectInTable, toView:self.view)
                popover.sourceRect = rectInView
                self.presentViewController(navigationController, animated: true, completion: nil)
            }
        }, image: UIImage(named: "edit")!, title: "Edit Category")
        
        let actionSetting: TabBarItem = TabBarItem(actionBlock: { () -> () in
            let configViewController = ConfigViewController()
            configViewController.modalPresentationStyle = .Custom
            configViewController.transitioningDelegate = self.configTransitioningDelegate
            self.presentViewController(configViewController, animated: true, completion: nil)
        }, image: UIImage(named: "setting")!, title: "Setting")
        
        let actionExit: TabBarItem = TabBarItem(actionBlock: { () -> () in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }, image: UIImage(named: "exit")!, title: "Exit")
        
        actionTabBarViewController.actionsButtons = [actionEdit, actionSetting, actionExit]
        
        NSNotificationCenter.defaultCenter().postNotificationName(TabbedSplitViewController.notificationNameChangeCategory, object: nil, userInfo: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        detailViewController.viewController = CanvasSelectViewController()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let viewWidth  = self.view.bounds.size.width
        let viewHeight = self.view.bounds.size.height
        let actionTabBarViewHeight = actionTabBarViewController.view.frame.height
        
        categoryTabBarViewController.view.frame = CGRectMake(
            0.0, 0.0,
            TabbedSplitViewController.tabBarViewWidth, viewHeight - actionTabBarViewHeight
        )
        masterViewController.view.frame = CGRectMake(
            TabbedSplitViewController.tabBarViewWidth, 0.0,
            TabbedSplitViewController.masterViewWidth, viewHeight
        )
        detailViewController.view.frame = CGRectMake(
            TabbedSplitViewController.tabBarViewWidth + TabbedSplitViewController.masterViewWidth, 0.0,
            viewWidth - TabbedSplitViewController.tabBarViewWidth - TabbedSplitViewController.masterViewWidth, viewHeight
        )
    }
    
    @objc
    func didChangeCategory(notification: NSNotification?) {
        if let category = notification?.userInfo?["category"] as? Category {
            masterViewController.viewController = CategoryViewController(category: category)
            categoryTabBarViewController.tableView.selectRowAtIndexPath(categoryTabBarViewController.fetchedResultsController.indexPathForObject(category), animated: false, scrollPosition: UITableViewScrollPosition.Top)
        } else {
            let firstCategory = categoryTabBarViewController.fetchedResultsController.fetchedObjects?.first as? Category
            if let fc = firstCategory {
                masterViewController.viewController = CategoryViewController(category: fc)
                categoryTabBarViewController.tableView.selectRowAtIndexPath(categoryTabBarViewController.fetchedResultsController.indexPathForObject(fc), animated: true, scrollPosition: UITableViewScrollPosition.Top)
            } else {
                masterViewController.viewController = nil
                categoryTabBarViewController.tableView.selectRowAtIndexPath(nil, animated: true, scrollPosition: UITableViewScrollPosition.Top)
            }

        }
    }
}