import UIKit
import CoreData

class CanvasSelectViewController : UIViewController, CollectionViewDelegateReorderableLayout, CollectionViewReorderableLayoutDataSource, UITextFieldDelegate {

    static let notificationNameChangeCanvas = "DidChangeCanvas"
    
    var canvas: [Canvas] = []
    var canvasFrames: [CGRect] = []
    var collectionView: UICollectionView!
    var addNewCanvasButton = UIButton()
    let leftBorder = CALayer()
    var activeTextField = UITextField()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadCanvases() {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Canvas", inManagedObjectContext: CoreDataManager.shared.managedObjectContext!)
        fetchRequest.entity = entity
        
        let sort = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        canvas = CoreDataManager.shared.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as! [Canvas]
        self.collectionView.reloadData()
     
        let numberOfCells = self.collectionView.numberOfItemsInSection(0)
        let layout = self.collectionView.collectionViewLayout
        for var i = 0; i < numberOfCells; i++ {
            let layoutAttributes = layout.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0))
            let cellFrame = layoutAttributes.frame
            canvasFrames.append(cellFrame)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addNewCanvasButton.setTitle("Add New Canvas", forState: .Normal)
        addNewCanvasButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        addNewCanvasButton.layer.backgroundColor = UIColor(red: 0x54/255.0, green: 0xB9/255.0, blue: 0x53/255.0, alpha: 0xFF/255.0).CGColor
        addNewCanvasButton.addTarget(self, action: "addNewCanvasButtonTapped:", forControlEvents: .TouchUpInside)
        addNewCanvasButton.clipsToBounds = true
        self.view.addSubview(addNewCanvasButton)
        
        leftBorder.borderColor = UIColor.whiteColor().CGColor
        leftBorder.borderWidth = 1
        addNewCanvasButton.layer.addSublayer(leftBorder)
    
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: CollectionViewReorderableLayout())
        collectionView.registerClass(CanvasCell.self, forCellWithReuseIdentifier: "CanvasCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.scrollEnabled = true
        view.addSubview(collectionView)
        
        var insets: UIEdgeInsets = collectionView.contentInset
        insets.top += UIApplication.sharedApplication().statusBarFrame.height
        collectionView.contentInset = insets
        collectionView.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loadCanvases()
            NSNotificationCenter.defaultCenter().postNotificationName(CanvasSelectViewController.notificationNameChangeCanvas, object: self, userInfo: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    var contentOffsetBeforeEditing = CGPointMake(0,0)
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var keyboardHeight: CGFloat = 0.0
        switch UIApplication.sharedApplication().statusBarOrientation {
        case UIInterfaceOrientation.Portrait, UIInterfaceOrientation.PortraitUpsideDown:
            keyboardHeight = keyboardScreenEndFrame.size.height
        case UIInterfaceOrientation.LandscapeLeft, UIInterfaceOrientation.LandscapeRight:
            keyboardHeight = keyboardScreenEndFrame.size.height
        default:
            println()
        }
        let boundSize = UIScreen.mainScreen().bounds.size
        let keyboardLimit = boundSize.height - keyboardHeight
        
        let textFieldFrame = activeTextField.convertRect(activeTextField.frame, toView: collectionView)
        let textLimit = textFieldFrame.origin.y + textFieldFrame.height + 8.0

        contentOffsetBeforeEditing = collectionView.contentOffset
        if textLimit >= keyboardLimit {
            collectionView.contentOffset.y = textLimit - keyboardLimit
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        collectionView.contentOffset.y = contentOffsetBeforeEditing.y
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.frame = CGRectMake(0, 0, self.parentViewController!.view.frame.width, self.parentViewController!.view.frame.size.height - 44)
        addNewCanvasButton.frame = CGRectMake(0, self.parentViewController!.view.frame.height - 44, self.parentViewController!.view.frame.size.width, 44)
        leftBorder.frame = CGRectMake(0, 0, 1, CGRectGetHeight(addNewCanvasButton.frame))
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canvas.count
    }
    
    func sectionSpacingForCollectionView(collectionView: UICollectionView) -> CGFloat {
        return 10.0
    }
    
    func minimumInteritemSpacingForCollectionView(collectionView: UICollectionView) -> CGFloat {
        return 10.0
    }
    
    func minimumLineSpacingForCollectionView(collectionView: UICollectionView) -> CGFloat {
        return 10.0
    }
    
    func insetsForCollectionView(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5.0, 20.0, 5.0, 20.0)
    }
    
    func autoScrollTrigerEdgeInsets(collectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(50.0, 0, 50.0, 0)
    }
    
    func autoScrollTrigerPadding(CollectionView: UICollectionView) -> UIEdgeInsets {
        return UIEdgeInsetsMake(64.0, 0, 0, 0)
    }
    
    func reorderingItemAlpha(collectionView: UICollectionView) -> CGFloat {
        return 0.7
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, didEndDraggingItemAtIndexPath: NSIndexPath) {
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, itemAtIndexPath fromIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) {
        let c: Canvas = canvas[fromIndexPath.item]
        canvas.removeAtIndex(fromIndexPath.item)
        canvas.insert(c, atIndex: toIndexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, itemAtIndexPath fromIndexPath: NSIndexPath, canMoveToIndexPath toIndexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c: Canvas = canvas[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CanvasCell", forIndexPath: indexPath) as! CanvasCell
        cell.name = c.name
        cell.order = "\(c.order)"
        cell.textField.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    func addNewCanvasButtonTapped(sender: UIButton) {
        let managedContext: NSManagedObjectContext = CoreDataManager.shared.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Canvas", inManagedObjectContext: managedContext)
        let canvas = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        canvas.setValue("", forKey: "name")
        canvas.setValue(CoreDataManager.shared.maxOrder("Canvas"), forKey: "order")
        CoreDataManager.shared.saveContext()
        loadCanvases()
        NSNotificationCenter.defaultCenter().postNotificationName(CanvasSelectViewController.notificationNameChangeCanvas, object: self, userInfo: nil)
    }
}
