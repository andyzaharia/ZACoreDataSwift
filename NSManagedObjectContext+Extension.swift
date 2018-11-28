//
//  NSManagedObjectContext+Extension.swift
//  OC Canvas
//
//  Created by Andrei Zaharia on 11/11/18.
//  Copyright © 2018 Andrei Zaharia. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

    static let kCoreDataStackThreadNamingKey = "kCoreDataStackThreadNamingKey"

    private static var _masterWriterPrivateContext: NSManagedObjectContext?
    private static var _managedObjectContextsDictionary: NSMutableDictionary = NSMutableDictionary()
    private static let queue = DispatchQueue(label: "com.coredata.context.custom.stack", attributes: .concurrent)

    // MARK: - Static

    static var mainThread: NSManagedObjectContext = {
        return NSPersistentContainer.shared.viewContext
    }()

    static var currentThread: NSManagedObjectContext? = {

        if Thread.isMainThread {
            return NSManagedObjectContext.mainThread
        }

        return NSPersistentContainer.shared.newBackgroundContext()
    }()
}
