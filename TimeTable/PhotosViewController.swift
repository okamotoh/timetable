import UIKit
import CoreData

class PhotosViewController : UITableViewController, UIGestureRecognizerDelegate, DraggingImageViewDelegate {
    
    var category: Category?
    var photos: [Photo] = []
    static var canvasCollectionController: CanvasSelectViewController?
    var canvasFrames: [CGRect] = []
    var canvases : [Canvas] = []
    static var canvasCollectionIndex: Int?
    
    func didChangeCanvas(notification: NSNotification?) {
        if let n = notification {
            PhotosViewController.canvasCollectionController = n.object as? CanvasSelectViewController
            self.canvasFrames = (n.object as? CanvasSelectViewController)!.canvasFrames
            self.canvases = (n.object as? CanvasSelectViewController)!.canvas
        }
    }
    
    convenience init(category: Category?) {
        self.init(style: UITableViewStyle.Plain)
        self.category = category
        loadPhotosOfCategory(self.category)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didChangeCanvas:", name: CanvasSelectViewController.notificationNameChangeCanvas, object: nil)
    }
    
    private func loadPhotosOfCategory(cateogry: Category?) {
        if let cat = category {
            let fetchRequest = NSFetchRequest()
            let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: CoreDataManager.shared.managedObjectContext!)
            fetchRequest.entity = entity
            
            let sort = NSSortDescriptor(key: "order", ascending: true)
            fetchRequest.sortDescriptors = [sort]
            
            let predicate = NSPredicate(format: "category == %@", cat)
            fetchRequest.predicate = predicate
            
            photos = CoreDataManager.shared.managedObjectContext?.executeFetchRequest(
                fetchRequest, error: nil) as! [Photo]
            
            for (index, photo) in enumerate(photos) {
                photo.order = Int32(index)
            }
        }
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init!(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        self.tableView.registerClass(PhotoCell.self, forCellReuseIdentifier: "PhotosTableCell")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var insets: UIEdgeInsets = self.tableView.contentInset
        insets.top += UIApplication.sharedApplication().statusBarFrame.height
        self.tableView.contentInset = insets
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognizerHandler:")
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panGestureRecognizerHandler:")
        panGestureRecognizer.delegate = self
        self.tableView.addGestureRecognizer(panGestureRecognizer)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CanvasSelectViewController.notificationNameChangeCanvas, object: nil)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 190.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotosTableCell", forIndexPath: indexPath) as! PhotoCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: PhotoCell, atIndexPath indexPath: NSIndexPath) {
        let photo = photos[indexPath.row]
        if let thumbnail = photo.thumbnail {
            cell.thumbnailImage = UIImage(data: thumbnail)
        } else {
            cell.thumbnailImage = nil
        }
        cell.order = "\(photo.order)"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    var shouldAllowPan = false
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPanGestureRecognizer) && shouldAllowPan == false {
            return false
        }
        return true
    }
    
    var draggingView: DraggingImageView?
    var overlayView: OverlayView?
    var sourceIndexPath: NSIndexPath?
    var savedPhoto: Photo?
    
    func longPressGestureRecognizerHandler(gesture: UILongPressGestureRecognizer) -> Void {
        let state = gesture.state
        let location = gesture.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)

        switch(state) {
        case UIGestureRecognizerState.Began:
            if let index = indexPath {
                sourceIndexPath = index
                savedPhoto = self.photos[index.row]
                let cell = self.tableView.cellForRowAtIndexPath(index) as! PhotoCell
                
                overlayView = OverlayView(frame: UIScreen.mainScreen().bounds)
                overlayView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "backgroundViewTapped:"))
                self.view.window!.addSubview(overlayView!)
                
                UIGraphicsBeginImageContextWithOptions(cell.photoImageView!.bounds.size, false, 0)
                cell.photoImageView!.layer.renderInContext(UIGraphicsGetCurrentContext())
                let cellImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                draggingView = DraggingImageView(image: cellImage)
                draggingView!.center = cell.convertPoint(cell.photoImageView!.center, toView: overlayView)
                draggingView!.delegate = self
                self.view.window!.addSubview(draggingView!)
                
                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panGestureRecognizerHandler:")
                draggingView!.addGestureRecognizer(panGestureRecognizer)
                
                draggingView!.startWobbleAnimation()
                cell.hidePhotoImage()
            }
            
        case UIGestureRecognizerState.Changed:
            shouldAllowPan = true
            
        case UIGestureRecognizerState.Cancelled, UIGestureRecognizerState.Ended, UIGestureRecognizerState.Failed:
            // shouldAllowPan = false
            if let index = indexPath {
                let cell = self.tableView.cellForRowAtIndexPath(index) as! PhotoCell
                cell.showPhotoImage()
            }

            println()
        default:
            println("never reach here...")
        }
        
    }
    
    func panGestureRecognizerHandler(gesture: UIPanGestureRecognizer) -> Void {
        if !shouldAllowPan { return }
        
        let state = gesture.state
        let location = gesture.locationInView(self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(location)
        
        switch(state) {
        case UIGestureRecognizerState.Changed:
            let translation = gesture.translationInView(self.tableView)
            draggingView?.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, translation.x, translation.y)
            
            if indexPath != nil && indexPath!.isEqual(sourceIndexPath) == false {
                let temp = self.photos[sourceIndexPath!.row]
                self.photos[sourceIndexPath!.row] = self.photos[indexPath!.row]
                self.photos[sourceIndexPath!.row].order = Int32(sourceIndexPath!.row)
                
                self.photos[indexPath!.row] = temp
                self.photos[indexPath!.row].order = Int32(indexPath!.row)
                
                self.tableView.moveRowAtIndexPath(sourceIndexPath!, toIndexPath: indexPath!)
                sourceIndexPath = indexPath
            }
            
            if let canvasCollectionController = PhotosViewController.canvasCollectionController {
                let canvasCollectionView = canvasCollectionController.collectionView
                let locationInScreen = gesture.locationInView(self.overlayView)
                
                if let index = PhotosViewController.canvasCollectionIndex {
                    // let currentCanvasFrame = canvasCollectionView.convertRect(canvasCollectionController.canvasFrames[index], toView: self.overlayView)
                    let currentCanvasFrame = canvasCollectionView.convertRect(self.canvasFrames[index], toView: self.overlayView)
                    if CGRectContainsPoint(currentCanvasFrame, locationInScreen) { return }
                }

                for (index, frame) in enumerate(self.canvasFrames) {
                    let frameInScreen = canvasCollectionView.convertRect(frame, toView: self.overlayView)
                    if CGRectContainsPoint(frameInScreen, locationInScreen) {
                        overlayView?.transparentFrame = frameInScreen

                        PhotosViewController.canvasCollectionIndex = index
                        break
                    } else {
                        overlayView?.transparentFrame = nil
                        self.view.window!.addSubview(overlayView!)
                        PhotosViewController.canvasCollectionIndex = nil
                    }
                }
                self.view.window!.bringSubviewToFront(self.draggingView!)
            }
            
        case UIGestureRecognizerState.Ended:
            var cell: PhotoCell?
            if indexPath != nil && indexPath!.isEqual(sourceIndexPath) == false {
                self.photos[indexPath!.row] = savedPhoto!
                self.photos[indexPath!.row].order = Int32(indexPath!.row)
                cell = self.tableView.cellForRowAtIndexPath(indexPath!) as? PhotoCell
            } else {
                cell = self.tableView.cellForRowAtIndexPath(sourceIndexPath!) as? PhotoCell
            }
            
            UIView.animateWithDuration(0.3,
                animations: {
                    self.draggingView?.transform = CGAffineTransformIdentity
                    self.draggingView?.frame = cell!.convertRect(cell!.thumbnailImageFrame, toView: self.overlayView)
                },
                completion: {
                    (value: Bool) in
                    self.sourceIndexPath = nil
                    self.savedPhoto = nil
                    
                    self.draggingView?.stopWobbleAnimation()
                    self.draggingView?.removeFromSuperview()
                    self.draggingView = nil
                    
                    self.overlayView?.removeFromSuperview()
                    self.overlayView = nil
                    
                    self.shouldAllowPan = false
                    
                    cell?.showPhotoImage()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadRowsAtIndexPaths(self.tableView.indexPathsForVisibleRows()!, withRowAnimation: UITableViewRowAnimation.Fade)
                    })
                }
            )
            
        default:
            println("never reach here...")
        }
    }
    
    func backgroundViewTapped(gesture: UITapGestureRecognizer) {
        draggingView?.stopWobbleAnimation()
        draggingView?.removeFromSuperview()
        draggingView = nil
        
        overlayView?.removeFromSuperview()
        overlayView = nil
        
        shouldAllowPan = false
    }
    
    func delete() {
        if let photo = savedPhoto {
            CoreDataManager.shared.deleteEntity(photo)
            CoreDataManager.shared.saveContext()
            
            overlayView?.removeFromSuperview()
            overlayView = nil
            
            draggingView?.removeFromSuperview()
            draggingView = nil
            
            photos.removeAtIndex(self.sourceIndexPath!.row)
            self.tableView.deleteRowsAtIndexPaths([self.sourceIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            
            loadPhotosOfCategory(self.category)
        
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadRowsAtIndexPaths(self.tableView.indexPathsForVisibleRows()!, withRowAnimation: UITableViewRowAnimation.Fade)
            })
            
            NSNotificationCenter.defaultCenter().postNotificationName("DidSelectCategory", object: nil, userInfo: ["category": category!])
        }
    }
}
