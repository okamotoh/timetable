import CoreData

extension NSManagedObject {
    
    func clone() -> NSManagedObject? {
        return self.cloneInContext(self.managedObjectContext!, excludeEntities: [])
    }
    
    func cloneInContext(context: NSManagedObjectContext, inout withCopiedCache alreadyCopied:Dictionary<NSManagedObjectID, NSManagedObject>, excludeEntities namesOfEntitesToExclude: Array<String>) -> NSManagedObject? {
        
        let entityName = self.entity.name!
        if contains(namesOfEntitesToExclude, entityName) {
            return nil
        }
        
        var cloned = alreadyCopied[(self.objectID as NSManagedObjectID)]
        if cloned != nil {
            return cloned
        }
        
        cloned = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as? NSManagedObject
        alreadyCopied[(self.objectID as NSManagedObjectID)] = cloned!
        
        let attributes = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!.attributesByName as! [String: NSAttributeDescription]
        for attr: String in attributes.keys {
            cloned?.setValue(self.valueForKey(attr), forKey: attr)
        }
        
        
        let relationships = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!.relationshipsByName as! [String : NSRelationshipDescription]
        for relName: String in relationships.keys {
            let rel = relationships[relName] as NSRelationshipDescription?
            
            let keyName = rel!.name
            if rel!.toMany {
                if rel!.ordered {
                    let sourceSet = self.mutableOrderedSetValueForKey(keyName)
                    let clonedSet = cloned?.mutableOrderedSetValueForKey(keyName)
                    
                    let e = sourceSet.objectEnumerator()
                    while let relatedObject: NSManagedObject = e.nextObject() as? NSManagedObject {
                        let clonedRelatedObject = relatedObject.cloneInContext(context, withCopiedCache: &alreadyCopied, excludeEntities: namesOfEntitesToExclude)
                        
                        clonedSet?.addObject(clonedRelatedObject!)
                    }
                }
            } else {
                let relatedObject: NSManagedObject? = self.valueForKey(keyName) as? NSManagedObject
                if let object = relatedObject {
                    let clonedRelatedObject = object.cloneInContext(context, withCopiedCache: &alreadyCopied, excludeEntities: namesOfEntitesToExclude)
                    cloned?.setValue(clonedRelatedObject, forKey: keyName)
                }
            }
        }
        return cloned
    }
    
    func cloneInContext(context: NSManagedObjectContext, excludeEntities namesOfEntitiesToExclude: Array<String>) -> NSManagedObject? {
        var copiedCache = Dictionary<NSManagedObjectID, NSManagedObject>()
        return self.cloneInContext(context, withCopiedCache:&copiedCache, excludeEntities:namesOfEntitiesToExclude)
    }
}
