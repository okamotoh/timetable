import Foundation
import CoreData

class Category: NSManagedObject {

    @NSManaged var color: AnyObject
    @NSManaged var name: String
    @NSManaged var order: Int32
    @NSManaged var photos: NSOrderedSet

}
