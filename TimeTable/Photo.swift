import Foundation
import CoreData

class Photo: NSManagedObject {

    @NSManaged var image: NSData?
    @NSManaged var name: String?
    @NSManaged var order: Int32
    @NSManaged var thumbnail: NSData?
    @NSManaged var canvases: NSSet
    @NSManaged var category: Category

}
