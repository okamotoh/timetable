import UIKit
import CoreData

class ActionTabBarViewController : UITableViewController
{
    convenience init() {
        self.init(style: UITableViewStyle.Plain)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(TabBarItemCell.self, forCellReuseIdentifier: "ActionTabBarTableCell")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.scrollEnabled = false
        self.tableView.backgroundColor = UIColor.whiteColor()
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var actionsButtons: [TabBarItem] = [] {
        willSet {
            var actionButtonsHeight: CGFloat = 0.0
            for action in newValue {
                actionButtonsHeight += TabbedSplitViewController.tabBarItemHeight
            }
            self.tableView.frame = CGRectMake(
                0.0, self.tableView.superview!.frame.size.height - CGFloat(actionButtonsHeight),
                CGFloat(TabbedSplitViewController.tabBarViewWidth), CGFloat(actionButtonsHeight)
            )
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(TabbedSplitViewController.tabBarItemHeight)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionsButtons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TabBarItemCell = tableView.dequeueReusableCellWithIdentifier("ActionTabBarTableCell", forIndexPath: indexPath) as! TabBarItemCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: TabBarItemCell, atIndexPath indexPath: NSIndexPath) {
        let tabBarItem = actionsButtons[indexPath.row]
        cell.iconView.image  = tabBarItem.image
        cell.titleLabel.text = tabBarItem.title
        cell.actionBlock     = tabBarItem.actionBlock
        cell.cellType        = TabBarItemCellType.Action
        cell.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as? TabBarItemCell
        if let block = cell?.actionBlock {
            block()
        }
    }
}
