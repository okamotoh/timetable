import UIKit
import CoreData

class CategoryEditorListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
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

        self.title = "Categories"
        self.tableView.registerClass(CategoryEditorViewCell.self, forCellReuseIdentifier: "CategoryEditorTableCell")
        self.tableView.separatorInset = UIEdgeInsetsZero
        if self.tableView.respondsToSelector("layoutMargins") {
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        self.tableView.tableFooterView = UIView()
        
        self.navigationItem.leftBarButtonItem  = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewCategoryButtonTapped:")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let category = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Category
            CoreDataManager.shared.deleteEntity(category)
            
            let count = self.fetchedResultsController.fetchedObjects?.count
            for var i = indexPath.row; i < count; i++ {
                let object = self.fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: i, inSection: indexPath.section)) as! Category
                object.order = Int32(i-1)
            }
            CoreDataManager.shared.saveContext()
        }
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let fromIndex = sourceIndexPath.row
        let toIndex   = destinationIndexPath.row
        
        if fromIndex == toIndex { return }
        
        let categories = self.fetchedResultsController.fetchedObjects as? [Category]
        let category = categories?[fromIndex]
        category?.order = Int32(toIndex)
        
        var start, end: Int
        var delta: Int
        
        if fromIndex < toIndex {
            start = fromIndex + 1
            end = toIndex
            delta = -1
        } else {
            start = toIndex
            end = fromIndex - 1
            delta = 1
        }
        
        for var i = start; i <= end; i++ {
            let objects = self.fetchedResultsController.fetchedObjects as? [Category]
            let object = objects?[i]
            object?.order += Int32(delta)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let info = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryEditorTableCell", forIndexPath: indexPath) as! CategoryEditorViewCell
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        if cell.respondsToSelector("preservesSuperviewLayoutMargins") {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        if cell.respondsToSelector("layoutMargins") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    func configureCell(cell: CategoryEditorViewCell, atIndexPath indexPath: NSIndexPath) {
        let category = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Category
        if let c = category {
            cell.textLabel!.text = c.name + "\(c.order)"
            cell.color           = c.color as? UIColor
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let category = self.fetchedResultsController.objectAtIndexPath(indexPath) as? Category
        
        if let c = category {
            let editViewController = CategoryEditorEditViewController(category: c)
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        var selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            selectedIndexPath = newIndexPath
        case .Update:
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? CategoryEditorViewCell
            if let c = cell {
                self.configureCell(c, atIndexPath: indexPath!)
            }
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            selectedIndexPath = indexPath
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            return
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(TabbedSplitViewController.notificationNameChangeCategory, object: nil, userInfo: nil)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    func addNewCategoryButtonTapped(sender: UIButton) {
        let addNewCategoryViewController = CategoryEditorEditViewController(category: nil)
        self.navigationController?.pushViewController(addNewCategoryViewController, animated: true)
    }
}
