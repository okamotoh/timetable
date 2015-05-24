import Foundation
import CoreData

class Canvas: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var order: Int32
    @NSManaged var photos: NSSet

}
