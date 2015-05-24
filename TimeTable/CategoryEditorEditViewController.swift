import UIKit
import CoreData

class CategoryEditorEditViewController: UIViewController {
    
    var category: Category?
    let categoryNameLabel = UILabel()
    let categoryNameTextField = UITextField()
    let colorPickerLabel = UILabel()
    let colorPickerSegmented = UISegmentedControl(items: ["Pallet", "Full Color"])
    let colorPickerViewController = ColorPickerViewController()
    let editCategoryButton = UIButton()
    var isNewCategory: Bool = false
    
    init(category: Category?) {
        super.init(nibName: nil, bundle: nil)
        self.category = category
        isNewCategory = category == nil
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = isNewCategory ? "Add New Category" : "Edit Category"
        self.view.backgroundColor = UIColor(red: 0xF0/255.0, green: 0xF0/255.0, blue: 0xF0/255.0 , alpha: 0xFF/255.0)

        categoryNameLabel.text = "Category Name"
        categoryNameLabel.textColor = UIColor(red: 0x28/255.0, green: 0x28/255.0, blue: 0x28/255.0, alpha: 0xFF/255.0)
        self.view.addSubview(categoryNameLabel)
        
        categoryNameTextField.backgroundColor = UIColor.whiteColor()
        categoryNameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        categoryNameTextField.text = isNewCategory ? "" : category!.name
        self.view.addSubview(categoryNameTextField)
        
        colorPickerLabel.text = "Color Picker"
        colorPickerLabel.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        self.view.addSubview(colorPickerLabel)
        
        colorPickerSegmented.selectedSegmentIndex = 0
        self.view.addSubview(colorPickerSegmented)
        
        self.view.addSubview(colorPickerViewController.view)
        
        let buttonTitle = isNewCategory ? "Add" : "Update"
        editCategoryButton.setTitle(buttonTitle, forState: .Normal)
        editCategoryButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        editCategoryButton.backgroundColor = UIColor(red: 0x54/255.0, green: 0xB9/255.0, blue: 0x53/255.0, alpha: 0xFF/255.0)
        editCategoryButton.addTarget(self, action: "editCategoryButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(editCategoryButton)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !isNewCategory {
            colorPickerViewController.setSelectedColor(category!.color as! UIColor)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        
        categoryNameLabel.frame = CGRectMake(
            15, navBarHeight! + 5,
            self.parentViewController!.view.frame.size.width - 30, 44
        )
        
        categoryNameTextField.frame = CGRectMake(
            15, categoryNameLabel.frame.origin.y + categoryNameLabel.frame.size.height,
            self.parentViewController!.view.frame.size.width - 30, 44
        )
        
        colorPickerLabel.frame = CGRectMake(
            15, categoryNameTextField.frame.origin.y + categoryNameTextField.frame.size.height + 10,
            self.parentViewController!.view.frame.size.width - 30, 44
        )
        
        colorPickerSegmented.frame = CGRectMake(
            15, colorPickerLabel.frame.origin.y + colorPickerLabel.frame.size.height,
            self.parentViewController!.view.frame.size.width - 30, colorPickerSegmented.frame.size.height
        )
        
        colorPickerViewController.view.frame = CGRectMake(
            15,  colorPickerSegmented.frame.origin.y + colorPickerSegmented.frame.size.height + 10,
            self.parentViewController!.view.frame.size.width - 30, 185
        )
        
        editCategoryButton.frame = CGRectMake(
            15, self.parentViewController!.view.frame.height - 15 - 44,
            self.parentViewController!.view.frame.size.width - 30, 44
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func editCategoryButtonTapped(sender: UIButton) {
        let color = colorPickerViewController.selectedButton?.backgroundColor
        if color == nil {
            let alertController = UIAlertController(title: "Alert", message: "Please select one of the colors of the followings", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        if isNewCategory {
            let managedContext: NSManagedObjectContext = CoreDataManager.shared.managedObjectContext!
            let entity = NSEntityDescription.entityForName("Category", inManagedObjectContext: managedContext)
            category = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as? Category
        }

        if let c = self.category {
            c.setValue(categoryNameTextField.text ?? "", forKey: "name")
            c.setValue(color, forKey: "color")
            if isNewCategory {
                c.setValue(CoreDataManager.shared.maxOrder("Category"), forKey: "order")
            }
            CoreDataManager.shared.saveContext()
        }
        
        self.view.endEditing(true)
        self.navigationController?.popViewControllerAnimated(true)
        
        if let c = self.category {
            NSNotificationCenter.defaultCenter().postNotificationName(TabbedSplitViewController.notificationNameChangeCategory, object: nil, userInfo: ["category": category!])
        }
    }
}
