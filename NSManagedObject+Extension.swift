//
//  NSManagedObject+Extension.swift
//  OC Canvas
//
//  Created by Andrei Zaharia on 11/11/18.
//  Copyright © 2018 Andrei Zaharia. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Entity info

extension NSManagedObject {

    class var entityName: String {
        let components = NSStringFromClass(self).components(separatedBy: ".")
        if let name = components.last, name != "NSManagedObject" {
            return name
        } else {
            fatalError("Cannot find entity name.")
        }
    }

    class func countOfEntities(withPredicate predicate: NSPredicate, inContext context: NSManagedObjectContext) -> Int {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate
        request.includesSubentities = false

        do {
            return try context.count(for: request)
        } catch {
            print(error)
        }

        return NSNotFound
    }

    class func countOfEntities(withPredicate predicate: NSPredicate = NSPredicate(value: true)) -> Int {
        if let context = NSManagedObjectContext.currentThread {
            return self.countOfEntities(withPredicate: predicate, inContext: context)
        } else {
            print("Failed to find current thread context.")
        }
        return 0
    }

}

// MARK: - Data fetching.

extension NSManagedObject {

    class func findFirst() -> NSManagedObject? {
        if let context = NSManagedObjectContext.currentThread {
            return self.findFirst(inContext: context)
        } else {
            print("Failed to find current thread context.")
            return nil
        }
    }

    class func findFirst(inContext context: NSManagedObjectContext) -> NSManagedObject? {
        let predicate = NSPredicate(value: true)

        if let context = NSManagedObjectContext.currentThread {
            return self.findFirst(withPredicate: predicate, inContext: context)
        } else {
            print("Failed to find current thread context.")
            return nil
        }
    }

    class func findFirst(withPredicate predicate: NSPredicate) -> NSManagedObject? {
        if let context = NSManagedObjectContext.currentThread {
            return self.findFirst(withPredicate: predicate, inContext: context)
        } else {
            print("Failed to find current thread context.")
            return nil
        }
    }

    class func findFirst<T: NSManagedObject>(withPredicate predicate: NSPredicate, inContext context: NSManagedObjectContext) -> T? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate
        request.fetchLimit = 1

        do {
            let items = try context.fetch(request)

            if let firstItem = items.first as? T {
                return firstItem //as? T
            }
        } catch {
            //print(error)
        }

        return nil
    }

    class func findFirst(byAttributeName attributeName: String, withValue value: Any) -> Self? {
        if let context = NSManagedObjectContext.currentThread {
            return self.findFirst(byAttributeName: attributeName, withValue: value, inContext: context)
        } else {
            print("Failed to find current thread context.")
            return nil
        }
    }

//    class func first(byAttributeName attributeName: String,
//                     withValue value: Any,
//                     inContext context: NSManagedObjectContext) -> Self? {
//        let predicate = NSPredicate(format: "%K == %@", argumentArray: [attributeName, value])
//        if let obj = self.findFirst(withPredicate: predicate, inContext: context) {
//            return obj
//        } else {
//            return self.create(inContext: context)
//        }
//    }

    class func firstOrCreate<T: NSManagedObject>(byAttributeName attributeName: String,
                                                 withValue value: Any,
                                                 inContext context: NSManagedObjectContext = NSManagedObjectContext.mainThread) -> T? {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [attributeName, value])
        let item: T? = self.findFirst(withPredicate: predicate, inContext: context)
        
        if let item = item {
            return item
        } else {
            return self.create(inContext: context)
        }
    }

    class func findFirst(byAttributeName attributeName: String,
                         withValue value: Any,
                         inContext context: NSManagedObjectContext) -> Self? {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [attributeName, value])
        return self.findFirst(withPredicate: predicate, inContext: context)
    }

    class func findAll() -> [NSManagedObject]? {
        let predicate = NSPredicate(value: true)
        return self.findAll(withPredicate: predicate)
    }

    class func findAll(inContext context: NSManagedObjectContext) -> [NSManagedObject]? {
        let predicate = NSPredicate(value: true)
        return self.findAll(withPredicate: predicate, inContext: context)
    }
    
    class func findAll(withPredicate predicate: NSPredicate) -> [NSManagedObject]? {
        if let context = NSManagedObjectContext.currentThread {
            return self.findAll(withPredicate: predicate, inContext: context)
        } else {
            print("Failed to find current thread context.")
            return nil
        }
    }

    class func findAll(byAttribute attributeName: NSString, withValue value: Any) -> [NSManagedObject]? {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [attributeName, value])
        return self.findAll(withPredicate: predicate)
    }

    class func findAll(withPredicate predicate: NSPredicate, inContext context: NSManagedObjectContext) -> [NSManagedObject]? {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate

        do {
            let items = try context.fetch(request)
            if let items = items as? [NSManagedObject] {
                return items
            }
        } catch {
            print(error)
        }

        return nil
    }

    class func findAll(sortedBy sortKey: String, ascending: Bool) -> [NSManagedObject]? {
        if let context = NSManagedObjectContext.currentThread {
            return self.findAll(sortedBy: sortKey, ascending: ascending, inContext: context)
        } else {
            print("Failed to find current thread context.")
            return nil
        }
    }

    class func findAll(sortedBy sortKey: String, ascending: Bool, inContext context: NSManagedObjectContext) -> [NSManagedObject]? {
        let sort = NSSortDescriptor(key: sortKey, ascending: ascending)

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(value: true)
        request.sortDescriptors = [sort]

        do {
            let items = try context.fetch(request)
            if let items = items as? [NSManagedObject] {
                return items
            }
        } catch {
            print(error)
        }

        return nil
    }

}

// MARK: - Data removal.

extension NSManagedObject {

    class func deleteAll(withPredicate predicate: NSPredicate) {
        if let context = NSManagedObjectContext.currentThread {
            self.deleteAll(withPredicate: predicate, inContext: context)
        } else {
            print("Failed to find current thread context.")
        }
    }

    class func deleteAll(withPredicate predicate: NSPredicate, inContext context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate

        let deleteRequest = NSBatchDeleteRequest( fetchRequest: request)
        deleteRequest.resultType = .resultTypeObjectIDs
        do {
            if let result = try context.execute(deleteRequest) as? NSBatchDeleteResult {
                if let objectIDArray = result.result as? [NSManagedObjectID] {
                    let changes = [NSDeletedObjectsKey : objectIDArray]
                    let mainContext = NSPersistentContainer.shared.viewContext
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context, mainContext])
                }
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - Data creation.

extension NSManagedObject {

    static func create<T: NSManagedObject>(inContext context: NSManagedObjectContext) -> T? {
        if let item = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? T {
            return item
        }

        return nil
    }

    static func create<T: NSManagedObject>() -> T? {
        if let context = NSManagedObjectContext.currentThread {
            return T.create(inContext: context)
        } else {
            print("Failed to find current thread context.")
            return nil
        }
    }

    public convenience init(inContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: type(of: self).entityName, in: context)!
        self.init(entity: entity, insertInto: context)
    }
}
