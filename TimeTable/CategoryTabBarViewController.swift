import UIKit
import CoreData

class CategoryTabBarViewController : UITableViewController, NSFetchedResultsControllerDelegate {

    convenience init() {
        self.init(style: UITableViewStyle.Plain)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView.registerClass(TabBarItemCell.self, forCellReuseIdentifier: "CategoryTabBarTableCell")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.bounces = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let numberOfCategory = self.tableView.numberOfRowsInSection(0)
        if numberOfCategory > 0 {
            let firstRow = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.selectRowAtIndexPath(firstRow, animated: false, scrollPosition: UITableViewScrollPosition.Top)
            if let category = self.fetchedResultsController.objectAtIndexPath(firstRow) as? Category {
                NSNotificationCenter.defaultCenter().postNotificationName(TabbedSplitViewController.notificationNameChangeCategory, object: nil, userInfo: ["category": category])
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    var fetchedResultsController: NSFetchedResultsController {
        if self._fetchedResultsController != nil {
            return self._fetchedResultsController!
        }
        let managedObjectContext = CoreDataManager.shared.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Category", inManagedObjectContext: managedObjectContext)
        let sort = NSSortDescriptor(key: "order", ascending: true)
        let request = NSFetchRequest()
        request.entity = entity
        request.sortDescriptors = [sort]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        self._fetchedResultsController = aFetchedResultsController
        
        var error: NSError?
        if !self._fetchedResultsController!.performFetch(&error) {
            println("fetch error: \(error!.localizedDescription)")
            abort()
        }
        
        return self._fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController?
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let info = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(TabbedSplitViewController.tabBarItemHeight)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TabBarItemCell = tableView.dequeueReusableCellWithIdentifier("CategoryTabBarTableCell", forIndexPath: indexPath) as! TabBarItemCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: TabBarItemCell, atIndexPath indexPath: NSIndexPath) {
        let category = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Category
        if let c = category {
            cell.cellType        = TabBarItemCellType.Tab
            cell.titleLabel.text = c.name + "\(c.order)"
            cell.selectedColor   = (c.color as? UIColor) ?? UIColor.grayColor()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let category = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Category {
            NSNotificationCenter.defaultCenter().postNotificationName(TabbedSplitViewController.notificationNameChangeCategory, object: nil, userInfo: ["category": category])
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        [self.tableView .reloadData()]
    }
}
