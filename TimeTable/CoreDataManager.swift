import Foundation
import CoreData

class CoreDataManager : NSObject {
    
    let storeName = "TimeTable"
    let storeFilename = "TimeTable.sqlite"
    
    class var shared: CoreDataManager {
        get {
            struct Static {
                static var instance: CoreDataManager? = nil
                static var token: dispatch_once_t = 0
            }
            dispatch_once(&Static.token)  { Static.instance = CoreDataManager() }

            return Static.instance!
        }
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1] as! NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.storeName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.storeFilename)
        var error: NSError? = nil
        var failureReason = "Theare was an error creating or loading the applications's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext() {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func deleteEntity(object: NSManagedObject) {
        object.managedObjectContext?.deleteObject(object)
    }
    
    func insertEntity(object: NSManagedObject) {
        object.managedObjectContext?.insertObject(object)
    }
    
    func maxOrder(name: String) -> Int {
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: CoreDataManager.shared.managedObjectContext!)
        request.entity = entity
        request.resultType = NSFetchRequestResultType.DictionaryResultType
        
        let keyPathExpression = NSExpression(forKeyPath: "order")
        let maxExpression = NSExpression(forFunction: "max:", arguments: [keyPathExpression])
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "maxDisplayOrder"
        expressionDescription.expression = maxExpression
        expressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
        
        let countExpression = NSExpression(forFunction: "count:", arguments: [keyPathExpression])
        let countExpressionDescription = NSExpressionDescription()
        countExpressionDescription.name = "count"
        countExpressionDescription.expression = countExpression
        countExpressionDescription.expressionResultType = NSAttributeType.Integer32AttributeType
        
        request.propertiesToFetch = [expressionDescription, countExpressionDescription]
        
        var error: NSError? = nil
        var obj: [AnyObject]? = CoreDataManager.shared.managedObjectContext?.executeFetchRequest(request, error: &error)
        var maxValue = NSNotFound
        if obj == nil {
            println("error")
        } else {
            let result = obj as! [Dictionary<String, Int>]
            
            let count = result[0]["count"]!
            if count == 0 {
                maxValue = 0
            } else {
                maxValue = result[0]["maxDisplayOrder"]! + 1
            }
        }
        return maxValue
    }
}