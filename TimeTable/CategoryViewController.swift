import UIKit
import CoreData

class CategoryViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate {
    
    let category: Category?
    var photosViewController: PhotosViewController? = nil
    var popoverController: UIPopoverController? = nil
    let imagePicker = UIImagePickerController()
    let addNewPhotoButton = UIButton()
    let rightBorder = CALayer()
    
    init(category: Category) {
        self.category = category
        self.photosViewController = PhotosViewController(category: category)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = category!.color as? UIColor
        imagePicker.delegate = self
        
        addNewPhotoButton.setTitle("Add New Photo", forState: .Normal)
        addNewPhotoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        addNewPhotoButton.layer.backgroundColor = UIColor(red: 0x54/255.0, green: 0xB9/255.0, blue: 0x53/255.0, alpha: 0xFF/255.0).CGColor
        addNewPhotoButton.addTarget(self, action: "addNewPhotoButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        addNewPhotoButton.clipsToBounds = true
        self.view.addSubview(addNewPhotoButton)
        
        rightBorder.borderColor = UIColor.whiteColor().CGColor
        rightBorder.borderWidth = 1
        addNewPhotoButton.layer.addSublayer(rightBorder)
        
        self.view.addSubview(photosViewController!.view)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addNewPhotoButton.frame = CGRectMake(0, self.parentViewController!.view.frame.height - 44, self.parentViewController!.view.frame.size.width, 44)
        photosViewController!.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - addNewPhotoButton.frame.size.height)
        rightBorder.frame = CGRectMake(-1, -1, CGRectGetWidth(addNewPhotoButton.frame) + 1, CGRectGetHeight(addNewPhotoButton.frame) + 2)
    }
    
    func addNewPhotoButtonTapped(sender: UIButton) {
        let alertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)

        alertController.addAction(
            UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                    self.photoFromCamera(sender)
                }
            )
        )
        alertController.addAction(
            UIAlertAction(title: "Library", style: UIAlertActionStyle.Default, handler: {
                (action: UIAlertAction!) -> Void in
                    self.photoFromLibrary(sender)
                }
            )
        )
        alertController.addAction(
            UIAlertAction (title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) -> Void in
                }
            )
        )
        
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.popoverPresentationController?.sourceRect = sender.frame
        self.view.window!.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func photoFromCamera(sender: UIButton) {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.cameraCaptureMode = .Photo
            imagePicker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.view.window?.rootViewController?.presentViewController(imagePicker, animated: true, completion: nil)
            }
        } else {
            photoFromLibrary(sender)
        }
    }
    
    func photoFromLibrary(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        popoverController = UIPopoverController(contentViewController: imagePicker)
        NSOperationQueue.mainQueue().addOperationWithBlock() {
            self.popoverController!.presentPopoverFromRect(sender.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let c = category {
                let managedContext: NSManagedObjectContext = CoreDataManager.shared.managedObjectContext!
                let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: managedContext)
                let photo = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
         
                photo.setValue(UIImageJPEGRepresentation(image, 1.0), forKey: "image")
                photo.setValue(UIImageJPEGRepresentation(image.cropToBoundingSquare(boundingSquareSideLength: 180), 1.0), forKey: "thumbnail")
                photo.setValue(c, forKey: "category")
                photo.setValue(CoreDataManager.shared.maxOrder("Photo"), forKey: "order")
                CoreDataManager.shared.saveContext()

                self.dismissViewControllerAnimated(true, completion: nil)
                popoverController = nil
        
                self.photosViewController?.tableView.reloadData()
                NSNotificationCenter.defaultCenter().postNotificationName("DidChangeCategory", object: nil, userInfo: ["category": c])
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        popoverController = nil
    }
}
