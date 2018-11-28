//
//  NSPersistentContainer+Extension.swift
//  OC Canvas
//
//  Created by Andrei Zaharia on 11/11/18.
//  Copyright © 2018 Andrei Zaharia. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentContainer {

    private static var dataModelName: String?
    private static var storeFileName: String?
    private static let queue = DispatchQueue(label: "com.coredata.custom.stack", attributes: .concurrent)
    
    public static let shared: NSPersistentContainer = {
       
        let storePath = NSPersistentContainer.applicationDocumentsDirectory()
        if let storePath = storePath, let storeFileName = storeFileName, let dataModelName = dataModelName {
            let storeURL = NSURL(fileURLWithPath: storePath).appendingPathComponent(storeFileName)
            let bundle = Bundle.main
            
            let modelFileName = dataModelName.appending(".momd")
            if let modelFileUrl = bundle.resourceURL?.appendingPathComponent(modelFileName) {
                
                if let model = NSManagedObjectModel(contentsOf: modelFileUrl), let storeURL = storeURL {
                    
                    let container = NSPersistentContainer(name: storeFileName, managedObjectModel: model)
                    let storeDescription = NSPersistentStoreDescription(url: storeURL)
                    storeDescription.shouldMigrateStoreAutomatically = true
                    storeDescription.shouldInferMappingModelAutomatically = true
                    
                    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                        if (error == nil) {
                            container.viewContext.automaticallyMergesChangesFromParent = true
                            container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                        }
                    })
                    
                    return container
                } else {
                    print("Failed to load model or validate store path.")
                    abort()
                }
            } else {
                abort()
            }
        } else {
            abort()
        }
        
        return NSPersistentContainer(name: "Failure.")
    }()

    class func applicationDocumentsDirectory() -> String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
    }

    public class func setDataModel(_ modelName: String, storeFileName aFileName: String) {
        dataModelName = modelName
        storeFileName = aFileName

        _ = NSManagedObjectContext.mainThread
    }

    public class func removePersistentFile() {
        
        let storePath = NSPersistentContainer.applicationDocumentsDirectory()
        if let storePath = storePath, let storeFileName = storeFileName {
            if let storeURL = NSURL(fileURLWithPath: storePath).appendingPathComponent(storeFileName) {
                try? shared.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
            }
        }
    }
    
}
